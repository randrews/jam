require(File.dirname(__FILE__)+"/query_lexer.rb")
require(File.dirname(__FILE__)+"/query_parser.rb")

class Jam::SqlEvaluator < Dhaka::Evaluator

  self.grammar=Jam::QueryGrammar

  attr_accessor :results

  def get_tag(name)
    @tags ||= {}
    @tags[name] ||= Jam::connection[:tags].filter(:name=>name).get :id
  end

  # Takes a tagname and an optional value, returns all the file IDs with that tag
  def query(tagname, value=nil, comparator="=")
    tag_id=get_tag(tagname)
    
    all_ft=Jam::connection[:files_tags].filter(:tag_id=>tag_id)
    all_ft=all_ft.filter("note #{comparator} ? ",value) if value

    all_ft.select(:file_id).all.map{|r| r[:file_id]}
  end

  # All the file IDs that there are (needed to do negation clauses)
  def universe
    if !@universe
      @universe=Jam::connection[:files].select(:id).all.map{|r| r[:id]}
    end
    @universe
  end

  def result_files
    Jam::connection[:files].filter(:id=>results).all
  end

  def result_paths
    result_files.map{|f| f[:path]}
  end

  define_evaluation_rules do
    for_start do
      self.results = evaluate(child_nodes[0])
    end

    for_parenthesized_query do
      evaluate child_nodes[1]
    end

    for_oneclause do
      evaluate child_nodes[0]
    end

    for_negated do
      universe - evaluate(child_nodes[1])
    end

    for_intersection do
      evaluate(child_nodes[0]) & evaluate(child_nodes[2])
    end

    for_union do
      evaluate(child_nodes[0]) | evaluate(child_nodes[2])
    end

    for_presence do
      sym=child_nodes[0].token.value
      query(sym)
    end

    for_equality do
      sym=child_nodes[0].token.value
      val=evaluate child_nodes[2]
      query(sym,val)
    end

    for_string do
      child_nodes[0].token.value
    end

    for_number do
      child_nodes[0].token.value.to_f
    end

    for_gt do
      sym=child_nodes[0].token.value
      val=evaluate child_nodes[2]
      query sym,val,'>'
    end

    for_lt do
      sym=child_nodes[0].token.value
      val=evaluate child_nodes[2]
      query sym,val,'<'
    end

    for_ge do
      sym=child_nodes[0].token.value
      val=evaluate child_nodes[2]
      query sym,val,'>='
    end

    for_le do
      sym=child_nodes[0].token.value
      val=evaluate child_nodes[2]
      query sym,val,'<='
    end
  end

  def self.evaluate query
    evaluate_tree(Jam::QueryParser.
                  parse(Jam::QueryLexer.
                        lex(query)))
  end

  def self.evaluate_tree tree
    ev=Jam::SqlEvaluator.new
    ev.evaluate(tree)
    ev
  end
end

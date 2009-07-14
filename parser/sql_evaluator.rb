require(File.dirname(__FILE__)+"/query_lexer.rb")
require(File.dirname(__FILE__)+"/query_parser.rb")
require(File.dirname(__FILE__)+"/sql_sorter.rb")

class Jam::SqlEvaluator < Dhaka::Evaluator
  include Jam::SqlSorter

  self.grammar=Jam::QueryGrammar

  attr_accessor :results
  attr_accessor :sort_columns

  def get_tag(name)
    @tags ||= {}
    @tags[name] ||= Jam::db[:tags].filter(:name=>name).get :id
  end

  # Takes a tagname and an optional value, returns all the file IDs with that tag
  def query(type, tagname, value=nil, comparator="=")
    if type==:tag
      tag_id=get_tag(tagname)

      all_ft=Jam::db[:files_tags].filter(:tag_id=>tag_id)
      all_ft=all_ft.filter("note #{comparator} ? ",value) if value
      all_ft=all_ft.select(:file_id)

      all_ft.all.map{|r| r[:file_id]}
    elsif type==:field
      all_files=Jam::db[:files].filter("#{tagname} #{comparator} ?", value).select(:id)
      all_files.all.map{|r| r[:id]}
    end
  end

  # All the file IDs that there are (needed to do negation clauses)
  def universe
    if !@universe
      @universe=Jam::db[:files].select(:id).all.map{|r| r[:id]}
    end
    @universe
  end

  def result_files
    results.map{|r| Jam::File[:id=>r] }
  end

  def result_paths
    result_files.map{|f| f[:path]}
  end

  define_evaluation_rules do
    for_start do
      self.results = evaluate(child_nodes[0])
      self.sort_columns = evaluate(child_nodes[1])
      self.results = post_process(self.sort_columns, results)
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
      query(:tag,sym)
    end

    for_string do
      child_nodes[0].token.value
    end

    for_number do
      child_nodes[0].token.value.to_f
    end

    for_comparison do
      (type, sym)=*evaluate(child_nodes[0])
      comp=evaluate(child_nodes[1])
      val=evaluate child_nodes[2]
      query(type,sym,val,comp)
    end

    { 'eq'=>'=',
      'gt'=>'>',
      'lt'=>'<',
      'ge'=>'>=',
      'le'=>'<=',
      'like'=>'like'}.each do |name, sym|
      self.send("for_#{name}_comparator") do
        child_nodes[0].token.value
      end
    end

    for_symbol_lvalue do
      [:tag, child_nodes[0].token.value]
    end

    for_field_lvalue do
      [:field, child_nodes[0].token.value]
    end

    for_empty_process do
      []
    end

    for_sort_process{evaluate(child_nodes[2])}

    for_column_list{evaluate(child_nodes[0]) + evaluate(child_nodes[2])}
    for_one_sort_column{evaluate(child_nodes[0])}

    for_sort_column do
      lvalue=evaluate(child_nodes[0])
      col = { :name=>lvalue[1].to_sym,
              :type=>lvalue[0],
              :direction=>evaluate(child_nodes[1]) }
      [col]
    end

    for_asc_sort_direction{ :asc }
    for_desc_sort_direction{ :desc }
    for_def_sort_direction{ :asc }
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

require(File.dirname(__FILE__)+"/query_lexer.rb")
require(File.dirname(__FILE__)+"/query_parser.rb")

class Jam::QueryEvaluator < Dhaka::Evaluator

  self.grammar=Jam::QueryGrammar

  attr_accessor :strings

  def add_string str
    @strings ||= []
    strings << str
    strings.length-1
  end

  define_evaluation_rules do
    for_start do
      emit "Proc.new{|file|"
      evaluate child_nodes[0]
      emit "}"
    end

    for_parenthesized_query do
      emit '('
      evaluate child_nodes[1]
      emit ')'
    end

    for_oneclause do
      evaluate child_nodes[0]
    end

    for_intersection do
      evaluate child_nodes[0]
      emit "and"
      evaluate child_nodes[2]
    end

    for_union do
      evaluate child_nodes[0]
      emit "or"
      evaluate child_nodes[2]
    end

    for_presence do
      sym=child_nodes[0].token.value
      emit "file.has_tag?('#{sym}')"
    end

    for_equality do
      sym=child_nodes[0].token.value
      val=evaluate child_nodes[2]
      comparison_clause sym,val,'=='
    end

    for_string do
      idx=add_string child_nodes[0].token.value
      "strings[#{idx}]"
    end

    for_number do
      child_nodes[0].token.value.to_f
    end

    for_gt do
      sym=child_nodes[0].token.value
      val=evaluate child_nodes[2]
      comparison_clause sym,val,'>'
    end

    for_lt do
      sym=child_nodes[0].token.value
      val=evaluate child_nodes[2]
      comparison_clause sym,val,'<'
    end

    for_ge do
      sym=child_nodes[0].token.value
      val=evaluate child_nodes[2]
      comparison_clause sym,val,'>='
    end

    for_le do
      sym=child_nodes[0].token.value
      val=evaluate child_nodes[2]
      comparison_clause sym,val,'<='
    end
  end

  def self.evaluate query
    evaluate_tree(Jam::QueryParser.
                  parse(Jam::QueryLexer.
                        lex(query)))
  end

  def self.evaluate_tree tree
    ev=Jam::QueryEvaluator.new
    ev.evaluate(tree)
    ev
  end

  def text ; @lines.join " " ; end

  def proc
    eval text
  end

  def emit str
    @lines||=[]
    @lines << str
  end

  private

  def comparison_clause sym, val, operator
    emit "(file.has_tag?('#{sym}') and "
    
    if val.is_a? String
      emit "file.tag('#{sym}')[:note] #{operator} #{val}"
    else
      emit "file.tag('#{sym}')[:note].to_f #{operator} #{val}"
    end

    emit ")"
  end
end

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
      emit "file.tag('#{sym}')[:note]==#{val}"
    end

    for_string do
      idx=add_string child_nodes[0].token.value
      "strings[#{idx}]"
    end

    for_number do
      child_nodes[0].token.value
    end
  end

  def self.evaluate str
    ev=Jam::QueryEvaluator.new
    ev.evaluate(Jam::QueryParser.
                parse(Jam::QueryLexer.
                      lex(str)))
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
end
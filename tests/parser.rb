require "#{File.dirname(__FILE__)}/../jam.rb"
Jam::environment=:test

describe "query language parser" do
  def tree str
    Jam::QueryParser.parse(Jam::QueryLexer.lex(str))
  end

  it "should parse an intersection query" do
    tree("a and b").class.should_not==Dhaka::ParseErrorResult
    tree("a and").class.should==Dhaka::ParseErrorResult
  end

  it "should parse a union query" do
    tree("a or b").class.should_not==Dhaka::ParseErrorResult
  end

  it "should parse an equality clause" do
    tree("a=5").class.should_not==Dhaka::ParseErrorResult
  end

  it "should parse strings" do
    tree("a='foo'").class.should_not==Dhaka::ParseErrorResult
  end

  it "should parse complicated expressions" do
    tree("a=5 or b and (c='foo' or d)").class.
      should_not==Dhaka::ParseErrorResult
  end
end

require "#{File.dirname(__FILE__)}/../jam.rb"

describe "query language evaluator" do
  it "should generate a proc" do
    e=Jam::QueryEvaluator.evaluate 'a'
    e.text.should=="Proc.new{|file| file.has_tag?('a') }"
  end

  it "should handle complicated queries" do
    e=Jam::QueryEvaluator.evaluate "a=5 or b and (c='foo' or d)"
    e.text.should=~ /Proc\.new\{\|file\|/
    e.strings[0].should=='foo'
  end
end

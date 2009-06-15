require "#{File.dirname(__FILE__)}/../jam.rb"

describe "query language lexer" do
  def tokens str
    t=[]
    QueryLexer.lex(str).each do |token|
      t << token
    end
    t
  end

  it "should recognize all the operators" do
    t=tokens("()= and or")
    t[0].symbol_name.should=='('
    t[1].symbol_name.should==')'
    t[2].symbol_name.should=='='
    t[3].symbol_name.should=='and'
    t[4].symbol_name.should=='or'
  end

  it "should recognize numbers" do
    t=tokens("1 -2 1.3 -1.3 1.456")
    t[0..4].map(&:value).should==%w{1 -2 1.3 -1.3 1.456}
    t[0..4].map(&:symbol_name).should==['number']*5
  end

  it "should recognize symbols" do
    t=tokens("foo bar or andmore")
    t[0].value.should=='foo'
    t[1].value.should=='bar'
    t[2].value.should=='or'
    t[3].value.should=='andmore'
 
    t[0].symbol_name.should=='symbol'
    t[1].symbol_name.should=='symbol'
    t[2].symbol_name.should=='or'
    t[3].symbol_name.should=='symbol'
  end

  it "should recognize strings" do
    t=tokens "'foo' '' 'it\\'s' 'and' '\\\\'"

    t[0..4].map(&:value).should==["foo","","it's", "and", "\\"]
    t[0..4].map(&:symbol_name).should==['string']*5
  end
end

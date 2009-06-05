require "#{File.dirname(__FILE__)}/../jam.rb"

describe "ignores file" do
  include Jam::IgnoresFile

  attr_accessor :ignores_filename

  it "should handle a basic file" do
    self.ignores_filename=Jam::JAM_DIR+"/tests/fixtures/ignores/basic.txt"

    ignores(true).should==['a','b','c']
  end

  it "should handle comments and blank lines" do
    self.ignores_filename=Jam::JAM_DIR+"/tests/fixtures/ignores/comments.txt"

    ignores(true).should==['a','b','c']
  end

  it "should handle leading/trailing whitespace" do
    self.ignores_filename=Jam::JAM_DIR+"/tests/fixtures/ignores/white.txt"

    ignores(true).should==['a','b','c']
  end
end

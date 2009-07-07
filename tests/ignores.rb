require "#{File.dirname(__FILE__)}/../jam.rb"
Jam::environment=:test

describe "ignores file" do
  include Jam::IgnoresFile

  attr_accessor :ignores_filenames

  it "should handle a basic file" do
    self.ignores_filenames=[Jam::JAM_DIR+"/tests/fixtures/ignores/basic.txt"]

    ignores(true).should==['a','b','c']
  end

  it "should handle comments and blank lines" do
    self.ignores_filenames=[Jam::JAM_DIR+"/tests/fixtures/ignores/comments.txt"]

    ignores(true).should==['a','b','c']
  end

  it "should handle leading/trailing whitespace" do
    self.ignores_filenames=[Jam::JAM_DIR+"/tests/fixtures/ignores/white.txt"]

    ignores(true).should==['a','b','c']
  end

  it "should handle multiple ignore files" do
    self.ignores_filenames=[Jam::JAM_DIR+"/tests/fixtures/ignores/white.txt",
                            Jam::JAM_DIR+"/tests/fixtures/ignores/extra.txt"]

    ignores(true).should==%w{a b c d}
  end

  it "should handle multiple ignore files, some nonexistant" do
    self.ignores_filenames=[Jam::JAM_DIR+"/tests/fixtures/ignores/white.txt",
                            Jam::JAM_DIR+"/tests/fixtures/ignores/extra.txt",
                            Jam::JAM_DIR+"/tests/fixtures/ignores/not-there.txt"]

    ignores(true).should==%w{a b c d}
  end
end

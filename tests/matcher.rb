require "#{File.dirname(__FILE__)}/../jam.rb"

describe "matcher" do
  include Jam::Matcher

  before :all do
    @scratch_dir=verify_test_scratch_dir
    prep_test_tree @scratch_dir, 'simple_dir'
    Jam::InitCommand.run(@scratch_dir)
    Jam::AddCommand.run(@scratch_dir)

    Jam::File.at('one.txt').tag('tag1')
    Jam::File.at('one.txt').tag('tag2')
    Jam::File.at('one.txt').tag('tag3')

    Jam::File.at('two.txt').tag('tag2','foo')
  end

  after :all do
    remove_test_scratch_dir @scratch_dir
  end

  it "should find with presence queries" do
    files=query('tag1')
    files.should==[Jam::File.at('one.txt')]
  end

  it "should find with equality queries" do
    files=query("tag2='foo'")
    files.should==[Jam::File.at('two.txt')]
  end

  it "should find with booleans" do
    files=query("tag2 and tag3")
    files.should==[Jam::File.at('one.txt')]
  end

  it "should handle numeric values"
  it "should handle greater/less than"
  it "should handle negation"
end

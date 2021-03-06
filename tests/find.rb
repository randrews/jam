require "#{File.dirname(__FILE__)}/../jam.rb"
Jam::environment=:test

describe "find command" do
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

  before :each do
    Jam::FindCommand.clear_emitted
  end

  after :all do
    remove_test_scratch_dir @scratch_dir
  end

  it "should find files" do
    Jam::FindCommand.run(@scratch_dir, {:command_opts=>{:verbose=>true}}, ["tag1"])
    Jam::FindCommand.emitted.size.should==4 # file + three tags
    Jam::FindCommand.emitted[0].should=="one.txt"
    Jam::FindCommand.emitted[1].should=="\ttag1"
  end

  it "should find multiple files" do
    Jam::FindCommand.run(@scratch_dir, {:command_opts=>{:verbose=>true}}, ["tag2"])

    Jam::FindCommand.emitted.size.should==6 # file + three tags + file + one tag

    Jam::FindCommand.emitted[0].should=="one.txt"
    Jam::FindCommand.emitted[1].should=="\ttag1"
    Jam::FindCommand.emitted[2].should=="\ttag2"
    Jam::FindCommand.emitted[3].should=="\ttag3"

    Jam::FindCommand.emitted[4].should=="two.txt"
    Jam::FindCommand.emitted[5].should=="\ttag2 = foo"
  end

  it "should list just filenames when not verbose" do
    Jam::FindCommand.run(@scratch_dir, {}, ["tag1"])
    Jam::FindCommand.emitted.size.should==1 # file
    Jam::FindCommand.emitted[0].should=="one.txt"
  end
end

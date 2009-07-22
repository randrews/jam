require "#{File.dirname(__FILE__)}/../jam.rb"
require Jam::JAM_DIR+"/lib/list_file.rb"
Jam::environment=:test

describe "view command" do
  include Jam::ListFile

  before :all do
    @scratch_dir=verify_test_scratch_dir
    prep_test_tree @scratch_dir, 'simple_dir'
    Jam::InitCommand.run(@scratch_dir)
    Jam::AddCommand.run(@scratch_dir)

    Jam::TagCommand.run(@scratch_dir,{},%w{tag1 one.txt dir1/dir2/four.txt})
    Jam::TagCommand.run(@scratch_dir,{},%w{tag2 dir1})
  end

  after :all do
    remove_test_scratch_dir @scratch_dir
  end

  after :each do
    `rm -rf #{@scratch_dir}/view`
  end

  it "should raise an error unless given good arguments" do
    lambda{ Jam::ViewCommand.run(@scratch_dir) }.should raise_error
    lambda{ Jam::ViewCommand.run(@scratch_dir, {}, ["view"]) }.should raise_error
    lambda{ Jam::ViewCommand.run(@scratch_dir, {:command_opts=>{:delete=>true}}, ["view"]) }.should raise_error
    lambda{ Jam::ViewCommand.run(@scratch_dir, {}, ["view", "query"]) }.should_not raise_error
  end

  it "should create a directory for views" do
    Jam::ViewCommand.run(@scratch_dir, {}, ["view", "query"])
    File.directory?("#{@scratch_dir}/view").should be_true
  end

  it "should put the right things in the directory" do
    Jam::ViewCommand.run(@scratch_dir, {}, ["view", "tag1 and tag2"])
    File.exists?("#{@scratch_dir}/view/0001_four.txt").should be_true
  end

  it "should name files with ascending numbers" do
    Jam::ViewCommand.run(@scratch_dir, {}, ["view", "tag2"])
    File.exists?("#{@scratch_dir}/view/0001_four.txt").should be_true
    File.exists?("#{@scratch_dir}/view/0002_three.txt").should be_true
  end

  it "should not allow us to make a view of a file that already exists" do
    lambda{ Jam::ViewCommand.run(@scratch_dir, {}, ["one.txt", "tag2"]) }.should(raise_error(Jam::JamError))
  end

  it "should let us delete a view" do
    Jam::ViewCommand.run(@scratch_dir, {}, ["view", "tag2"])
    Jam::ViewCommand.run(@scratch_dir, {:command_opts=>{:delete=>true}}, ["view"])
    File.exists?("#{@scratch_dir}/view").should be_false
  end

  it "should only delete views" do
    lambda{ Jam::ViewCommand.run(@scratch_dir, {:command_opts=>{:delete=>true}}, ["one.txt"]) }.should raise_error(Jam::JamError)
    File.exists?("#{@scratch_dir}/one.txt").should be_true
  end

  it "should handle deleting views that have already been removed by hand" do
    Jam::ViewCommand.run(@scratch_dir, {}, ["view", "tag2"])
    `rm -rf #{@scratch_dir}/view`
    lambda{ Jam::ViewCommand.run(@scratch_dir, {:command_opts=>{:delete=>true}}, ["view"]) }.should_not raise_error
    exists_in_file?("#{@scratch_dir}/.jam/views","view").should be_false
  end

  it "should append to views" do
    Jam::ViewCommand.run(@scratch_dir, {}, ["view", "tag2"])
    Dir["#{@scratch_dir}/view/*"].size.should==2

    Jam::ViewCommand.run(@scratch_dir, {:command_opts=>{:append=>true}}, ["view", "tag1"])
    Dir["#{@scratch_dir}/view/*"].size.should==3
    File.exists?("#{@scratch_dir}/view/0003_one.txt").should be_true
  end
end

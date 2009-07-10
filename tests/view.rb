require "#{File.dirname(__FILE__)}/../jam.rb"
Jam::environment=:test

describe "view command" do
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
end

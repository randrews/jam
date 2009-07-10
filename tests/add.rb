require "#{File.dirname(__FILE__)}/../jam.rb"
Jam::environment=:test

describe "add command" do
  before :all do
    @scratch_dir=verify_test_scratch_dir
    prep_test_tree @scratch_dir, 'simple_dir'
    Jam::InitCommand.run(@scratch_dir)
  end

  after :all do
    remove_test_scratch_dir @scratch_dir
  end

  after :each do
    Jam::db[:files].delete
  end

  it "should create files for all the things it spiders" do
    Jam::AddCommand.run @scratch_dir

    Jam::File.at('one.txt').should_not be_nil
    Jam::File.at('two.txt').should_not be_nil
    Jam::File.at('dir1/three.txt').should_not be_nil
    Jam::File.at('dir1/dir2/four.txt').should_not be_nil
  end

  it "should set dirname and filename for all the things it spiders" do
    Jam::AddCommand.run @scratch_dir

    Jam::File.at('one.txt').dirname.should==""
    Jam::File.at('one.txt').filename.should=="one.txt"

    Jam::File.at('dir1/dir2/four.txt').dirname.should=="dir1/dir2"
    Jam::File.at('dir1/dir2/four.txt').filename.should=="four.txt"
  end

  it "should be able to add a subdirectory" do
    Jam::AddCommand.run(@scratch_dir,{},[@scratch_dir+'/dir1'])

    Jam::File.at('one.txt').should be_nil
    Jam::File.at('two.txt').should be_nil
    Jam::File.at('dir1/three.txt').should_not be_nil
    Jam::File.at('dir1/dir2/four.txt').should_not be_nil
  end

  it "should not add anything in .jam" do
    Jam::AddCommand.run @scratch_dir, {}, []

    Jam::File.at('.jam/ignore').should be_nil
  end

  it "should error when given a bad (nonexistant) path" do
    lambda{ Jam::AddCommand.run(@scratch_dir,{},["not-there"]) }.should raise_error("Invalid target not-there")
  end

  it "should ignore things that have already been added" do
    Jam::AddCommand.run @scratch_dir, {}, []
    old=Jam::db[:files].count

    Jam::AddCommand.run @scratch_dir, {}, ["dir1"]
    Jam::db[:files].count.should==old
  end
end

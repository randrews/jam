require "#{File.dirname(__FILE__)}/../jam.rb"

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
    Jam.connection << 'delete from files'
  end

  it "should create files for all the things it spiders" do
    Jam::AddCommand.run @scratch_dir

    Jam::File.at('one.txt').should_not be_nil
    Jam::File.at('two.txt').should_not be_nil
    Jam::File.at('dir1/three.txt').should_not be_nil
    Jam::File.at('dir1/dir2/four.txt').should_not be_nil
  end

  it "should be able to add a subdirectory" do
    Jam::AddCommand.run(@scratch_dir,{},[@scratch_dir+'/dir1'])

    Jam::File.at('one.txt').should be_nil
    Jam::File.at('two.txt').should be_nil
    Jam::File.at('dir1/three.txt').should_not be_nil
    Jam::File.at('dir1/dir2/four.txt').should_not be_nil
  end
end

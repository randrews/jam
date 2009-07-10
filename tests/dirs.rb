require "#{File.dirname(__FILE__)}/../jam.rb"
Jam::environment=:test

describe "command dirs" do
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

  it "should find things when run from root" do
    Jam::AddCommand.run(@scratch_dir)
    Jam::File.at('one.txt').should_not be_nil
    Jam::File.at('dir1/three.txt').should_not be_nil
  end

  it "should find things when run from a subdirectory" do
    dir1=File.join(@scratch_dir,'dir1')
    Jam::AddCommand.run(dir1, {}, ['three.txt'])

    Jam::File.at('dir1/three.txt').should_not be_nil
    Jam::File.at('three.txt').should be_nil
    Jam::File.at('one.txt').should be_nil
  end

  it "should find subdirs when run from a subdirectory" do
    dir1=File.join(@scratch_dir,'dir1')
    Jam::AddCommand.run(dir1, {}, ['dir2'])

    Jam::File.at('dir1/dir2/four.txt').should_not be_nil
    Jam::File.at('dir1/three.txt').should be_nil
    Jam::File.at('three.txt').should be_nil
    Jam::File.at('four.txt').should be_nil
    Jam::File.at('one.txt').should be_nil
  end
end

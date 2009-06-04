require "#{File.dirname(__FILE__)}/../jam.rb"

describe "spider module" do
  include Jam::Spider

  before :all do
    @scratch_dir=verify_test_scratch_dir
    `cp -r #{Jam::JAM_DIR}/tests/fixtures/simple_dir/* #{@scratch_dir}`
  end

  after :all do
    remove_test_scratch_dir @scratch_dir
  end

  before :each do
    @files=[]
    spider_directory @scratch_dir do |file|
      @files << file
    end
  end

  it "should find all the files" do
    @files.size.should==4
  end

  it "should find the filea outside a directory" do
    @files.index("one.txt").should_not be_nil
    @files.index("two.txt").should_not be_nil
  end

  it "should find the file inside one directory" do
    @files.index("dir1/three.txt").should_not be_nil
  end

  it "should find the file inside two directories" do
    @files.index("dir1/dir2/four.txt").should_not be_nil
  end

  it "should not find any directories themselves" do
    @files.index("dir1").should be_nil
    @files.index("dir1/dir2").should be_nil
  end
end

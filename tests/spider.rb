require "#{File.dirname(__FILE__)}/../jam.rb"

module FileLister
  include Jam::Spider

  def files_for fixture
    scratch_dir=verify_test_scratch_dir
    prep_test_tree scratch_dir, fixture

    files=[]
    spider_directory scratch_dir do |file|
      files << file
    end

    remove_test_scratch_dir scratch_dir
    files
  end
end

describe "spider module (no ignores)" do
  include FileLister

  before :all do
    @files=files_for 'simple_dir'
  end

  it "should find all the files" do
    @files.size.should==4
  end

  it "should find the files outside a directory" do
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

describe "spider module (with ignores)" do
  include FileLister
  attr_accessor :ignores

  it "should find .hidden with no ignores" do
    self.ignores=nil
    files_for('ignores_dir').index('.hidden').should_not be_nil
  end

  it "should ignore filenames in any directory" do
    self.ignores=['**/ignored.txt']
    files=files_for('ignores_dir')

    files.index('ignored.txt').should be_nil
    files.index('dir1/ignored.txt').should be_nil

    files.index('one.txt').should_not be_nil
    files.index('dir1/three.txt').should_not be_nil
  end

  it "should ignore file paths in just that directory" do
    self.ignores=['dir1/ignored.txt']
    files=files_for('ignores_dir')

    files.index('ignored.txt').should_not be_nil
    files.index('dir1/ignored.txt').should be_nil

    files.index('one.txt').should_not be_nil
    files.index('dir1/three.txt').should_not be_nil
  end

  it "should ignore entire directories" do
    self.ignores=['dir1/*']
    files=files_for('ignores_dir')

    files.index('ignored.txt').should_not be_nil
    files.index('one.txt').should_not be_nil

    files.index('dir1/ignored.txt').should be_nil
    files.index('dir1/three.txt').should be_nil
  end

  it "should ignore certain extensions" do
    self.ignores=["**/*.txt"]
    files=files_for('ignores_dir')

    files.index('ignored.txt').should be_nil
    files.index('dir1/three.txt').should be_nil

    files.index('.hidden').should_not be_nil
  end

  it "should ignore hidden files" do
    self.ignores=["**/.*"]
    files=files_for('ignores_dir')
    files.index('.hidden').should be_nil
    files.index('one.txt').should_not be_nil
  end

  it "should handle the from dir being different from the spider dir" do
    self.ignores=[]

    scratch_dir=verify_test_scratch_dir
    prep_test_tree scratch_dir, 'simple_dir'

    files=spider_directory(scratch_dir+"/dir1", scratch_dir)
    remove_test_scratch_dir scratch_dir

    files.index("dir1/three.txt").should_not be_nil
    files.index("dir1/dir2/four.txt").should_not be_nil

    files.index("one.txt").should be_nil
    files.index("two.txt").should be_nil
  end
end

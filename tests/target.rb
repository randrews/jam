require "#{File.dirname(__FILE__)}/../jam.rb"

describe "target" do
  before :all do
    @scratch_dir=verify_test_scratch_dir
    prep_test_tree @scratch_dir, 'simple_dir'
    Jam::InitCommand.run(@scratch_dir)
    Jam::AddCommand.run(@scratch_dir)
  end

  after :all do
    remove_test_scratch_dir @scratch_dir
  end

  it "should create from a path" do
    FileUtils.cd @scratch_dir do
      t=Jam::Target.from_path 'one.txt'
      t[0].path.should=='one.txt'
    end
  end

  it "should ignore nonexistant paths" do
    FileUtils.cd @scratch_dir do
      Jam::Target.from_path('isnt-there.txt').should==[]
    end
  end

  it "should find paths relative to the root" do
    FileUtils.cd(@scratch_dir+"/dir1") do
      t=Jam::Target.from_path('three.txt')[0]
      t.path.should=='three.txt'
      t.relroot.should=="dir1/three.txt"
    end
  end

  it "should find the absolute path of a file" do
    path=File.expand_path(@scratch_dir)
    FileUtils.cd(@scratch_dir+"/dir1") do
      t=Jam::Target.from_path('three.txt')[0]
      t.abs.should==path+"/dir1/three.txt"
      t.relroot.should=="dir1/three.txt"
    end
  end

  it "should spider directories"
end

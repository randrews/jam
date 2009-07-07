require "#{File.dirname(__FILE__)}/../jam.rb"
Jam::environment=:test

describe "init command (empty dir)" do
  before :each do
    @scratch_dir=verify_test_scratch_dir
    @dotjam=@scratch_dir+"/.jam"
  end

  after :each do
    remove_test_scratch_dir @scratch_dir
  end

  it "should create a .jam directory if there's not one" do
    Jam::InitCommand.run(@scratch_dir)
    File.exists?(@dotjam).should==true
    File.directory?(@dotjam).should==true
  end

  it "shouldn't overwrite a .jam directory unless forced" do
    FileUtils.mkdir(@dotjam)
    begin
      Jam::InitCommand.run(@scratch_dir)
      true.should be_false # we should have thrown...
    rescue
      $!.to_s.should=="#{@dotjam} already exists; use --force to overwrite"
    end
  end

  it "should overwrite a .jam directory when --force" do
    FileUtils.mkdir(@dotjam)
    FileUtils.touch(@dotjam+"/foo.txt")
    Jam::InitCommand.run(@scratch_dir, {:force=>true})
    File.exists?(@dotjam).should be_true
    File.exists?(@dotjam+"/foo.txt").should be_false
  end

  it "should create a sqlite DB" do
    Jam::InitCommand.run(@scratch_dir)
    File.exists?(@dotjam+"/jam.sqlite3").should be_true
  end

  it "should initialize the DB" do
    Jam::InitCommand.run(@scratch_dir)
    Jam::File.create(:path=>'dummy_file')
    Jam::File[1].should_not be_nil
  end

  it "should create a default ignore file" do
    Jam::InitCommand.run(@scratch_dir)
    File.exists?(@dotjam+"/ignore").should be_true
  end
end

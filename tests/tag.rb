require "#{File.dirname(__FILE__)}/../jam.rb"
Jam::environment=:test

describe "tag command" do
  before :all do
    @scratch_dir=verify_test_scratch_dir
    @jam = prep_test_tree @scratch_dir, 'simple_dir'
    Jam::InitCommand.run(@scratch_dir)
    Jam::AddCommand.run(@scratch_dir)
  end

  before :each do
    Jam::TagCommand.clear_emitted
  end

  after :each do
    Jam::db[:files_tags].delete
  end

  after :all do
    remove_test_scratch_dir @scratch_dir
  end

  it "should tag a single file" do
    Jam::TagCommand.run(@scratch_dir, 
                        {}, 
                        ["tag1","one.txt"])

    Jam::File.at('one.txt').has_tag?('tag1').should be_true
  end

  it "should tag a subdirectory" do 
    Jam::TagCommand.run(@scratch_dir, 
                        {}, 
                        ["tag1","dir1"])

    Jam::File.at('one.txt').has_tag?('tag1').should be_false
    
    Jam::File.at('dir1/three.txt').has_tag?('tag1').should be_true
    Jam::File.at('dir1/dir2/four.txt').has_tag?('tag1').should be_true
  end

  it "should tag from a subdirectory" do 
    Jam::TagCommand.run(@scratch_dir+"/dir1", 
                        {}, 
                        ["tag1","three.txt"])

    Jam::File.at('dir1/three.txt').has_tag?('tag1').should be_true
    Jam::File.at('dir1/dir2/four.txt').has_tag?('tag1').should be_false
  end

  it "should apply notes for tags" do
    Jam::TagCommand.run(@scratch_dir,
                        {:command_opts=>{:note=>'foo'}},
                        ["tag1","one.txt"])

    Jam::File.at('one.txt').tags['tag1'][:note].should=='foo'
  end

  it "should set tagged_by" do
    Jam::TagCommand.run(@scratch_dir,
                        {:command_opts=>{:agent=>'foo'}},
                        ["tag1","one.txt"])
    Jam::File.at('one.txt').tags['tag1'][:tagged_by].should==['foo']
  end

  it "should tag multiple targets" do
    Jam::TagCommand.run(@scratch_dir,
                        {:command_opts=>{:agent=>'foo'}},
                        %w{tag1 one.txt dir1/three.txt})

    Jam::File.at('one.txt').has_tag?('tag1').should be_true
    Jam::File.at('two.txt').has_tag?('tag1').should be_false
    Jam::File.at('dir1/three.txt').has_tag?('tag1').should be_true
    Jam::File.at('dir1/dir2/four.txt').has_tag?('tag1').should be_false
  end

  it "should delete tags with -d" do
    Jam::TagCommand.run(@scratch_dir,
                        {},
                        %w{tag1 one.txt})

    Jam::File.at('one.txt').has_tag?('tag1').should be_true

    Jam::TagCommand.run(@scratch_dir,
                        {:command_opts=>{:delete=>true}},
                        %w{tag1 one.txt})

    Jam::File.at('one.txt').has_tag?('tag1').should be_false
  end

  it "should list tags when run with no targets" do
    Jam::TagCommand.run(@scratch_dir, {}, ["tag1","one.txt"])
    Jam::TagCommand.run(@scratch_dir, {}, ["tag2","dir1"])

    Jam::TagCommand.clear_emitted
    Jam::TagCommand.run(@scratch_dir, {}, [])
    
    Jam::TagCommand.emitted[0].should=="1\ttag1"
    Jam::TagCommand.emitted[1].should=="2\ttag2"
    Jam::TagCommand.emitted.size.should==2
  end

  it "should accept a=b style tags" do
    Jam::TagCommand.run(@scratch_dir, {}, ["tag1=1","one.txt"])
    Jam::TagCommand.run(@scratch_dir, {}, ["tag2=foo bar","dir1"])
    
    Jam::File.at('one.txt').has_tag?('tag1').should be_true
    Jam::File.at('dir1/three.txt').has_tag?('tag2').should be_true

    Jam::File.at('one.txt').tags['tag1'][:note].should=='1'
    Jam::File.at('dir1/three.txt').tags['tag2'][:note].should=='foo bar'
  end  

  it "should be able to tag the results of a query" do
    Jam::TagCommand.run(@scratch_dir, {}, ["tag1","one.txt"])
    Jam::TagCommand.run(@scratch_dir, {:command_opts=>{:query=>"tag1"}}, ["tag2"])

    Jam::File.at('one.txt').has_tag?('tag2').should be_true
    Jam::File.at('two.txt').has_tag?('tag2').should be_false
  end

  it "should be able to detag the results of a query" do
    Jam::TagCommand.run(@scratch_dir, {}, ["tag1","one.txt"])
    Jam::TagCommand.run(@scratch_dir, {}, ["tag2","one.txt","two.txt"])
    Jam::TagCommand.run(@scratch_dir, {:command_opts=>{:query=>"tag1", :delete=>true}}, ["tag2"])

    Jam::File.at('one.txt').has_tag?('tag1').should be_true
    Jam::File.at('one.txt').has_tag?('tag2').should be_false
  end

  it "should not allow a tag named after a field" do
    lambda{ @jam["tag id one.txt"] }.should raise_error
    lambda{ @jam["tag id=7 one.txt"] }.should raise_error
  end
end

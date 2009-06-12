require "#{File.dirname(__FILE__)}/../jam.rb"

describe "tag command" do
  before :all do
    @scratch_dir=verify_test_scratch_dir
    prep_test_tree @scratch_dir, 'simple_dir'
    Jam::InitCommand.run(@scratch_dir)
    Jam::AddCommand.run(@scratch_dir)
  end

  after :all do
    remove_test_scratch_dir @scratch_dir
  end

  after :each do
    Jam.connection << 'delete from files_tags'
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
end

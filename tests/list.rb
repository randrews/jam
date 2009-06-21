require "#{File.dirname(__FILE__)}/../jam.rb"

describe "list command" do
  before :all do
    @scratch_dir=verify_test_scratch_dir
    prep_test_tree @scratch_dir, 'simple_dir'
    Jam::InitCommand.run(@scratch_dir)
    Jam::AddCommand.run(@scratch_dir)

    Jam::TagCommand.run(@scratch_dir,{}, 
                        ["tag1","one.txt"])

    Jam::TagCommand.run(@scratch_dir,{}, 
                        ["tag2","dir1/three.txt"])
 
    Jam::TagCommand.run(@scratch_dir,{:command_opts=>{:note=>'foo'}}, 
                        ["tag3","two.txt"])

    class Jam::ListCommand
      def emit str
        self.class.class_eval do
          @emitted ||= []
          @emitted << str
        end
      end
      def self.emitted ; @emitted ; end
      def self.clear_emitted ; @emitted=[] ; end
    end
  end

  after :all do
    remove_test_scratch_dir @scratch_dir
  end

  before :each do
    Jam::ListCommand.clear_emitted
  end

  it "should list a single file" do
    Jam::ListCommand.run(@scratch_dir, {}, ["one.txt"])
    Jam::ListCommand.emitted[0].should=="one.txt"
    Jam::ListCommand.emitted[1].should=="\ttag1"
  end

  it "should list a single file with attrs" do
    Jam::ListCommand.run(@scratch_dir, {}, ["two.txt"])
    Jam::ListCommand.emitted[0].should=="two.txt"
    Jam::ListCommand.emitted[1].should=="\ttag3 = foo"
  end

  it "should list a directory" do
    Jam::ListCommand.run(@scratch_dir, {}, ["dir1"])
    Jam::ListCommand.emitted[0].should=="dir1/dir2/four.txt"
    Jam::ListCommand.emitted[1].should=="dir1/three.txt"
    Jam::ListCommand.emitted[2].should=="\ttag2"
  end

  it "should list from a directory" do
    Jam::ListCommand.run(@scratch_dir+"/dir1", {}, [])
    Jam::ListCommand.emitted[0].should=="dir2/four.txt"
    Jam::ListCommand.emitted[1].should=="three.txt"
    Jam::ListCommand.emitted[2].should=="\ttag2"
  end

  it "should not list files that aren't added" do
    `touch #{@scratch_dir}/unadded.txt`

    Jam::ListCommand.run(@scratch_dir, {}, ['unadded.txt'])
    Jam::ListCommand.emitted.should be_empty
  end

  it "should not list files that don't exist" do
    Jam::ListCommand.run(@scratch_dir, {}, ['uncreated.txt'])
    Jam::ListCommand.emitted.should be_empty
  end
end

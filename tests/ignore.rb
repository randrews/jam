require "#{File.dirname(__FILE__)}/../jam.rb"

describe "ignore command" do
  before :all do
    class Jam::IgnoreCommand
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

  before :each do
    @scratch_dir=verify_test_scratch_dir
    prep_test_tree @scratch_dir, 'simple_dir'
    Jam::InitCommand.run(@scratch_dir)

    Jam::IgnoreCommand.clear_emitted
  end

  after :each do
    remove_test_scratch_dir @scratch_dir
  end

  it "should add ignores" do
    Jam::IgnoreCommand.run(@scratch_dir, {}, [])
    base = Jam::IgnoreCommand.emitted
    Jam::IgnoreCommand.clear_emitted

    Jam::IgnoreCommand.run(@scratch_dir, {}, ["a", "b", "c"])
    Jam::IgnoreCommand.emitted.should be_empty
    Jam::IgnoreCommand.clear_emitted

    Jam::IgnoreCommand.run(@scratch_dir, {}, [])
    (Jam::IgnoreCommand.emitted - base).should==["a", "b", "c"]
  end

  it "should list only user ignores" do
    Jam::IgnoreCommand.run(@scratch_dir, {}, [])
    Jam::IgnoreCommand.emitted.should be_empty

    Jam::IgnoreCommand.run(@scratch_dir, {:command_opts=>{:all=>true}}, [])
    Jam::IgnoreCommand.emitted.should_not be_empty
  end

  it "should remove ignores" do
    Jam::IgnoreCommand.run(@scratch_dir, {}, ["a"])

    Jam::IgnoreCommand.run(@scratch_dir, {}, [])
    Jam::IgnoreCommand.emitted.should==["a"]
    Jam::IgnoreCommand.clear_emitted

    Jam::IgnoreCommand.run(@scratch_dir, {:command_opts=>{:delete=>true}}, ["a"])

    Jam::IgnoreCommand.run(@scratch_dir, {}, [])
    Jam::IgnoreCommand.emitted.should be_empty
  end
end

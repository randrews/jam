require "#{File.dirname(__FILE__)}/../jam.rb"

describe "ignore command" do
  before :all do
    @scratch_dir=verify_test_scratch_dir
    prep_test_tree @scratch_dir, 'simple_dir'
    Jam::InitCommand.run(@scratch_dir)

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
    Jam::IgnoreCommand.clear_emitted
  end

  after :all do
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
end

require "#{File.dirname(__FILE__)}/../jam.rb"
Jam::environment=:test

describe "user commands" do
  include Jam::Dotjam

  before :all do
    @scratch_dir=verify_test_scratch_dir
    prep_test_tree @scratch_dir, 'simple_dir'
    Jam::InitCommand.run(@scratch_dir)
    Jam::AddCommand.run(@scratch_dir)

    fixtures_dir=File.join(File.dirname(__FILE__),'fixtures')
    `cp #{File.join(fixtures_dir,"echo.rb")} #{File.join(@scratch_dir, ".jam", "commands")}`
  end

  after :all do
    remove_test_scratch_dir @scratch_dir
  end

  it "should make the commands dir" do
    File.directory?("#{@scratch_dir}/.jam/commands").should be_true
    File.exists?("#{@scratch_dir}/.jam/commands/echo.rb").should be_true
  end

  it "should load the class for user commands" do
    class_for_command("echo", @scratch_dir).name.should=="EchoCommand"
  end

  it "should run user commands" do
    echo=class_for_command("echo", @scratch_dir)
    echo.run(@scratch_dir, {}, ["foo"])
    echo.emitted.should==["foo"]
  end
end

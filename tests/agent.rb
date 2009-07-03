require "#{File.dirname(__FILE__)}/../jam.rb"

describe "agent command" do
  before :all do
    @scratch_dir=verify_test_scratch_dir
    prep_test_tree @scratch_dir, 'simple_dir'
    Jam::InitCommand.run(@scratch_dir)
    Jam::AddCommand.run(@scratch_dir)
  end

  after :all do
    remove_test_scratch_dir @scratch_dir
  end

  before :each do
    @agent_cmd=Jam::AgentCommand.new(@scratch_dir)
  end

  it "should find agents in root" do
    @agent_cmd.find_agent("leafdir").should ==
      File.join(Jam::JAM_DIR,'agents','leafdir.rb')
  end

  it "should allow us to override agents" do
    `touch #{@scratch_dir}/.jam/agents/leafdir.rb`

    # so dotjam works right; this'll be unneccessary in a real run.
    FileUtils.cd @scratch_dir do
      @agent_cmd.find_agent("leafdir").should ==
        File.join(@scratch_dir,'.jam/agents','leafdir.rb')
    end

    `rm #{@scratch_dir}/.jam/agents/leafdir.rb`
  end
end

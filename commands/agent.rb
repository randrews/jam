class Jam::AgentCommand < Jam::Command

  def run
    connect_to_db

    t=targets
    agent_name=t.shift
    raise "No targets given" if t.empty?

    agent_file=find_agent(agent_name)

    load(agent_file)
  end

  def find_agent name
    filename="agents/#{name}.rb"
    # First, look in .jam
    if File.exists? dotjam(filename)
      dotjam(filename)
    elsif File.exists?(File.join(Jam::JAM_DIR,filename)) # Fail over to /agents
      File.join(Jam::JAM_DIR,filename)
    else
      raise "Agent not found: #{name}"
    end
  end
end

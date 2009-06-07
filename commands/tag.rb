class Jam::TagCommand < Jam::Command

  def run
    connect_to_db

    t=targets
    @tag=t.shift
    raise "No targets given" if t.empty?

    @note=opts[:command_opts][:note] rescue nil
    @agent=opts[:command_opts][:agent] rescue nil

    to_targets t do |file|
      Jam::File.at(file).tag(@tag,@note,@agent)
    end
  end
end

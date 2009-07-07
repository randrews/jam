module Jam::ShortCommands
  def possibilities start, all_commands
    all_commands.reject{|cmd| !cmd.starts_with? start }
  end

  def short_for cmd_start, all_commands=Jam.command_names.keys
    return cmd_start if all_commands.index(cmd_start)

    cmd_poss=possibilities(cmd_start, all_commands)
    if cmd_poss.length > 1
      raise "\"#{cmd_start}\" is ambiguous. Which did you mean:\n\t"+cmd_poss.join("\n\t")
    elsif cmd_poss.empty?
      raise "Unknown command \"#{cmd_start}\"."
    else
      cmd_poss[0]
    end
  end
end
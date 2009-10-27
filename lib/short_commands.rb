module Jam::ShortCommands
  def short_for cmd_start, all_commands=Jam.command_names.keys
    return cmd_start if all_commands.index(cmd_start)

    completions = all_commands.abbrev(cmd_start)
    if completions[cmd_start]
      completions[cmd_start]
    elsif completions.values.uniq.empty?
      Jam::error "Unknown command \"#{cmd_start}\"."
    else
      Jam::error "\"#{cmd_start}\" is ambiguous. Which did you mean:\n\t"+cmd_poss.join("\n\t")
    end
  end
end

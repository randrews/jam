module Jam
  SUB_COMMANDS=%w{add agent find init mv refresh report rm tag untag}
end

def parse_options opts=ARGV

  global_opts = Trollop::options(opts) do
    banner "Jam metadata tracker"
    version Jam::JAM_VERSION
    # TODO stop_on_unknown will let us implement
    # gem's any-unique-substring for subcommands 
    stop_on Jam::SUB_COMMANDS
  end

  cmd=opts.shift
  cmd_opts = {}

  case cmd
  when "init"
    cmd_opts=Trollop::options(opts) do
      opt :force, "Overwrite .jam if it exists", :default=>false, :short=>'f'
    end

  when "add"
    cmd_opts=Trollop::options(opts)

  when "tag"
    cmd_opts=Trollop::options(opts) do
      opt :note, "The value to apply to the file for this tag", :short=>'n'
      opt :agent, "The agent name to use when applying this tag", :short=>'a'
      opt :delete, "Delete the tag instead of applying it", :default=>false, :short=>'d'
    end

  else
    Trollop::die "unknown/unimplemented subcommand #{cmd}"
  end

  return {:global_opts=>global_opts,
    :command=>cmd,
    :command_opts=>cmd_opts,
    :targets=>opts}
end

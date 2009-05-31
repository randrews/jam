module Jam
  SUB_COMMANDS=%w{init tag untag agent report refresh rm mv add find}
end

def parse_options opts=ARGV

  global_opts = Trollop::options(opts) do
    banner "Jam metadata tracker"
    version Jam::JAM_VERSION
    stop_on Jam::SUB_COMMANDS
  end

  cmd=opts.shift
  cmd_opts = {}

  case cmd
  when "init"
    cmd_opts=Trollop::options(opts) # no options

  else
    Trollop::die "unknown/unimplemented subcommand #{cmd}"
  end

  return {:global_opts=>global_opts,
    :command=>cmd,
    :command_opts=>cmd_opts,
    :remaining_args=>opts}
end

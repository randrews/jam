require "#{File.dirname(__FILE__)}/jam.rb"

module JAM
  SUB_COMMANDS=%w{init tag untag agent report refresh rm mv add find}
end

def parse_options opts=ARGV

  global_opts = Trollop::options(opts) do
    banner "Jam metadata tracker"
    version JAM::JAM_VERSION
    stop_on JAM::SUB_COMMANDS
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

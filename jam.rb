require 'rubygems'
require 'activesupport'
require 'trollop'

VERSION="0.0.1"

SUB_COMMANDS=%w{init tag untag agent report refresh rm mv add find}

global_opts = Trollop::options do
  banner "Jam metadata tracker"
  opt :version, "Print version and exit", :short => "-v"
  stop_on SUB_COMMANDS
end

cmd=ARGV.shift

cmd_opts = 
  case cmd
  when "init"
    Trollop::options do
    
  end
  else
    Trollop::die "unknown/unimplemented subcommand #{cmd}"
  end

puts "Global options: #{global_opts.inspect}"
puts "Subcommand: #{cmd.inspect}"
puts "Subcommand options: #{cmd_opts.inspect}"
puts "Remaining arguments: #{ARGV.inspect}"

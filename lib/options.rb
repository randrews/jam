require File.join(Jam::JAM_DIR,"lib","short_commands.rb")
require File.join(Jam::JAM_DIR,"lib","dotjam.rb")
include Jam::ShortCommands
include Jam::Dotjam

def parse_options opts=ARGV
  global_opts = Trollop::options(opts) do
    banner "Jam metadata tracker"
    version Jam::JAM_VERSION
    stop_on_unknown
    opt :profile, "Profile the command while it runs, displays timing data at the end.", :short=>'p', :default=>false
  end

  cmd=short_for(opts.shift)
  cmd_class=class_for_command(cmd)
  cmd_opts = cmd_class.parse_options(opts) || {}

  return {:global_opts=>global_opts,
    :command=>cmd,
    :command_class=>cmd_class,
    :command_opts=>cmd_opts,
    :targets=>opts}
end

def class_for_command cmd, pwd=FileUtils.pwd
  begin
    ("Jam::"+"#{cmd}_command".camelize).constantize
  rescue NameError
    dj=find_dotjam(pwd)
    require File.join(dj,"commands","#{cmd}.rb")
    "#{cmd}_command".camelize.constantize
  end
end

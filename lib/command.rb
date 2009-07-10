require(File.dirname(__FILE__)+"/spider.rb")
require(File.dirname(__FILE__)+"/dotjam.rb")
require(File.dirname(__FILE__)+"/pathutil.rb")
require(File.dirname(__FILE__)+"/to_targets.rb")
require(File.dirname(__FILE__)+"/emit.rb")

class Jam::Command
  attr_reader :pwd
  attr_reader :opts
  attr_reader :targets
  include Jam::Dotjam
  include Jam::Pathutil
  include Jam::ToTargets
  extend Jam::Emit

  def initialize pwd, opts={}, targets=[]
    @pwd=File.expand_path(pwd);@opts=opts;@targets=targets
  end

  def self.run pwd, opts={}, targets=[]
    # This has no effect except in test, since it's
    # assumed that pwd is the real pwd.
    FileUtils.cd pwd do
      new(pwd, opts, targets).start_runtime.run
    end
  end

  def run
    raise NotImplementedException
  end

  # Should return the opts and targets, ready to pass to initialize
  def self.parse_options opts
    Trollop::options(opts)
  end

  def start_runtime
    @start_time = Time.now
    self
  end

  protected

  def connect_to_db
    Jam.db=establish_connection(dotjam('jam.sqlite3'))
  end

  def runtime
    Time.now - @start_time rescue 0
  end

  def command_opts ; opts[:command_opts] || {} ; end
end

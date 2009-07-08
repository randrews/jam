require(File.dirname(__FILE__)+"/spider.rb")
require(File.dirname(__FILE__)+"/dotjam.rb")
require(File.dirname(__FILE__)+"/pathutil.rb")
require(File.dirname(__FILE__)+"/spinner.rb")
require(File.dirname(__FILE__)+"/emit.rb")

class Jam::Command
  attr_reader :pwd
  attr_reader :opts
  attr_reader :targets
  include Jam::Dotjam
  include Jam::Pathutil
  include Jam::Spinner
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

  def to_targets target_paths, spin_msg=nil, &blk
    count=target_count(target_paths)

    if spin_msg and Jam::environment!=:test
      with_spinner count, spin_msg do |spin|
        find_targets(target_paths).each do |tgt|
          yield tgt.relroot, tgt
          spin.call
        end
      end
    else
      find_targets(target_paths).each do |tgt|
        yield tgt.relroot, tgt
      end
    end

    count
  end

  def target_count target_paths
    find_targets(target_paths).length
  end

  def start_runtime
    @start_time = Time.now
    self
  end

  protected

  def find_targets paths, refresh=false
    unless @cached_targets and !refresh
      @cached_targets=[]
      paths.each do |tp|
        @cached_targets += Jam::Target.from_path tp
      end
    end

    @cached_targets
  end

  def connect_to_db
    Jam.connection=establish_connection(dotjam('jam.sqlite3'))
  end

  def runtime
    Time.now - @start_time rescue 0
  end
end

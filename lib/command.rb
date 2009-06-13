require(File.dirname(__FILE__)+"/ignores_file.rb")
require(File.dirname(__FILE__)+"/spider.rb")
require(File.dirname(__FILE__)+"/dotjam.rb")
require(File.dirname(__FILE__)+"/pathutil.rb")

class Jam::Command
  attr_reader :pwd
  attr_reader :opts
  attr_reader :targets
  include Jam::Dotjam
  include Jam::Pathutil

  def initialize pwd, opts={}, targets=[]
    @pwd=File.expand_path(pwd);@opts=opts;@targets=targets
  end

  def self.run pwd, opts={}, targets=[]
    # This has no effect except in test, since it's
    # assumed that pwd is the real pwd.
    FileUtils.cd pwd do
      new(pwd, opts, targets).run
    end
  end

  def run
    raise NotImplementedException
  end

  def to_targets target_paths, &blk
    targets=[]
    target_paths.each do |tp|
      targets += Jam::Target.from_path tp
    end

    targets.each do |tgt|
      yield tgt.relroot, tgt
    end
  end

  protected

  def connect_to_db
    Jam.connection=establish_connection(dotjam('jam.sqlite3'))
  end
end

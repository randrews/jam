require(File.dirname(__FILE__)+"/ignores_file.rb")
require(File.dirname(__FILE__)+"/spider.rb")

class Jam::Command
  include Jam::IgnoresFile
  include Jam::Spider

  attr_reader :pwd
  attr_reader :opts
  attr_reader :targets

  def initialize pwd, opts={}, targets=[]
    @pwd=pwd;@opts=opts;@targets=targets
  end

  def self.run pwd, opts={}, targets=[]
    FileUtils.cd pwd do
      new('.', opts, targets).run
    end
  end

  def run
    raise NotImplementedException
  end

  protected

  def dotjam file=nil
    @dotjam ||= File.join(pwd,'/.jam')
    file.nil? ? @dotjam : File.join(@dotjam,file)
  end

  def root
    File.dirname dotjam
  end

  def ignores_filename
    dotjam('ignore')
  end

  def connect_to_db
    Jam.connection=establish_connection(dotjam('jam.sqlite3'))
  end
end

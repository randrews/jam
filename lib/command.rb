require(File.dirname(__FILE__)+"/ignores_file.rb")
require(File.dirname(__FILE__)+"/spider.rb")

class Jam::Command
  include Jam::IgnoresFile
  include Jam::Spider

  attr_reader :pwd
  attr_reader :opts
  attr_reader :targets

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

  def to_targets targets, &blk
    # Each of targets is a path, either absolute or relative to pwd.

    targets.each do |file|
      if File.directory? file
        spider_directory file do |path|
          to_targets [path], &blk
        end
      else
        yield relroot(file), file
      end
    end
  end

  protected

  def relroot path
    Pathname.new(File.expand_path(path)).
      relative_path_from(Pathname.new(File.expand_path(root))).to_s
  end

  def dotjam file=nil
    @dotjam ||= (find_dotjam(pwd) or File.join(pwd,'.jam'))
    file.nil? ? @dotjam : File.join(@dotjam,file)
  end

  def find_dotjam path
    curr=File.join(path,'.jam')
    if File.directory?(curr)
      curr
    else
      up=File.join(path,'..')
      if File.directory? up
        find_dotjam up
      else
        nil
      end
    end
  end

  def root
    @root ||= File.dirname(dotjam)
  end

  def ignores_filename
    dotjam('ignore')
  end

  def connect_to_db
    Jam.connection=establish_connection(dotjam('jam.sqlite3'))
  end
end

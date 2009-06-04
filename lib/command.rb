class Jam::Command
  attr_reader :pwd
  attr_reader :opts
  attr_reader :targets

  def initialize pwd, opts={}, targets=[]
    @pwd=pwd;@opts=opts;@targets=targets
  end

  def self.run pwd, opts={}, targets=[]
    new(pwd, opts, targets).run
  end

  def run
    raise NotImplementedException
  end

  protected

  def dotjam file=nil
    @dotjam ||= File.join(pwd,'/.jam')
    file.nil? ? @dotjam : File.join(@dotjam,file)
  end
end

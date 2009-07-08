# A target is a representation of a path that points
# to a file in the repository.
#
# This is true of all targets:
# * They point to files, not directories
# * The files they point to exist
# * The files they point to are not on the ignore list

class Jam::Target
  attr_reader :path, :abs
  extend Jam::Dotjam
  extend Jam::Spider
  extend Jam::IgnoresFile

  # Turns a string representing a path either absolute or relative to pwd
  # into an array of Jam::Targets for that path:
  # If it's a file, it returns an array of that file
  # If it's a directory, it spiders it
  # Any ignored patterns get removed from the array
  def self.from_path path
    if File.directory? path
      files=[]
      spider_directory(path,FileUtils.pwd) do |file|
        files << Jam::Target.new(file)
      end
      files
    elsif File.exists? path
      [Jam::Target.new(path)]
    else
      []
    end
  end

  def self.ignores_filenames
    [ dotjam('ignore'),
      dotjam('views'),
      dotjam('user_ignores') ]
  end

  ########################################

  # The root of the repository containing this file
  cached :root do
    Jam::Target.root(File.dirname(path))
  end

  # The path of this file relative to the root.
  def relroot
    Pathname.new(File.expand_path(path)).
      relative_path_from(Pathname.new(File.expand_path(root))).to_s
  end

  def file
    Jam::File.at relroot
  end

  protected

  def initialize path
    @path=path
    @abs=File.expand_path path
  end
end

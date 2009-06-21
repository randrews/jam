module Jam::Spider
  # If it's given a block, it runs that block on every file in dir.
  # Otherwise, returns a list of all files in dir.
  # All paths relative to 'from'.
  def spider_directory dir, from=dir # expects a block, passed a filename
    ignores=[]
    if self.respond_to? :ignores
      ignores=self.ignores || []
    end

    files=[] unless block_given?

    relpath=rel(dir,from)

    FileUtils.cd(dir) do
      file_list.each do |path|
        path=File.join(relpath, path) if(dir!=from)
        next if matches_any?(path,ignores)

        block_given? ? (yield path) : (files << path)
      end
    end

    files unless block_given?
  end

  private

  def file_list
    list=Dir.glob("**/*",File::FNM_DOTMATCH)

    list.delete_if do |path|
      File.directory?(path)
    end
  end

  def matches_any? path, ignores=[]
    unless ignores.nil? or ignores.empty?
      ignores.each do |i|
        return true if File.fnmatch?(i,path,File::FNM_PATHNAME)
      end
    end
    false
  end

  def rel to, from
    Pathname.new(File.expand_path(to)).
      relative_path_from(Pathname.new(File.expand_path(from))).to_s
  end
end

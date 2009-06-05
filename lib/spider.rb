module Jam::Spider
  def spider_directory dir # expects a block, passed a filename
    ignores=[]
    if self.respond_to? :ignores
      ignores=self.ignores || []
    end

    FileUtils.cd(dir) do
      file_list(dir,ignores).each do |path| # All these paths are relative to dir
        yield path
      end
    end
  end

  private

  def file_list dir, ignores=[]
    list=Dir.glob("**/*",File::FNM_DOTMATCH)

    list.delete_if do |path|
      File.directory?(path) or matches_any?(path,ignores)
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
end

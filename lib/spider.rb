module Jam::Spider
  def spider_directory dir, from=dir # expects a block, passed a filename
    ignores=[]
    if self.respond_to? :ignores
      ignores=self.ignores || []
    end

    file_list(dir,ignores,from).each do |path| # All these paths are relative to dir
      yield path
    end
  end

  private

  def file_list dir, ignores=[], from=dir
    list=Dir.glob("#{dir}/**/*",File::FNM_DOTMATCH)

    reallist=[]

    list.each do |path|
      next if File.directory?(path)
      path=clean(path,from)
      next if matches_any?(path,ignores)

      reallist << path
    end

    reallist
  end

  def matches_any? path, ignores=[]
    unless ignores.nil? or ignores.empty?
      ignores.each do |i|
        
        return true if File.fnmatch?(i,path,File::FNM_PATHNAME)
      end
    end
    false
  end

  def clean path, from_path
    Pathname.new(path).relative_path_from(Pathname.new(from_path)).to_s
  end
end

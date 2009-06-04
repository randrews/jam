module Jam::Spider
  def spider_directory dir # expects a block, passed a filename
    FileUtils.cd(dir) do
      file_list(dir).each do |path| # All these paths are relative to dir
        yield path unless File.directory?(path)
      end
    end
  end

  private

  def file_list dir # TODO handle ignores
    Dir["**/*"]
  end
end

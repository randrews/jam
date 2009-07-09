module Jam::Dotjam

  # Returns the path to a file under .jam
  # If no file is given, it returns the path to .jam, or '.jam' if it's not there
  # If a file is given, it returns that/filename
  def dotjam file=nil
    dj=find_dotjam || '.jam'
    if file.nil?
      dj
    else
      File.join(dj,file)
    end
  end

  # Returns the path to the .jam directory above a path
  # example: foo/bar/.jam
  # returns nil if it's not there
  def find_dotjam path=FileUtils.pwd
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

  # Returns the root of a repository, which is the directory
  # that contains .jam
  def root path
    File.dirname(find_dotjam(path))
  end
end

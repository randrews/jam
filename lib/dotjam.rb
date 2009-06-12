module Jam::Dotjam

  # Returns the path to the .jam directory above a path
  # example: foo/bar/.jam
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

  # Returns the root of a repository, which is the directory
  # that contains .jam
  def root path
    File.dirname(find_dotjam(path))
  end

end

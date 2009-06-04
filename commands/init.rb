class Jam::InitCommand < Jam::Command

  def run
    create_dotjam
  end

  def create_dotjam
    if !File.exists?(dotjam)
      # no .jam, proceed with making one
      FileUtils.mkdir dotjam
    elsif File.exists?(dotjam) and File.directory?(dotjam)
      # .jam/ already exists, fail unless --force
      if(opts[:force])
        FileUtils.rm_rf dotjam
        create_dotjam
      else
        raise "#{dotjam} already exists; use --force to overwrite"
      end
    elsif File.exists?(dotjam) and !File.directory?(dotjam)
      # .jam already exists and isn't a dir, even --force won't save us.
      raise "#{dotjam} already exists, and is not a directory."
    end
  end

  def dotjam
    File.join(pwd,'/.jam')
  end
end

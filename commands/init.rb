class Jam::InitCommand < Jam::Command

  def self.parse_options opts
    cmd_opts=Trollop::options(opts) do
      opt :force, "Overwrite .jam if it exists", :default=>false, :short=>'f'
    end
  end

  def run
    create_dotjam
    create_db
    copy_defaults
    emit "Empty Jam repository created in .jam"
  end

  private

  def create_dotjam
    if find_dotjam.nil?
      # no .jam, proceed with making one
      FileUtils.mkdir dotjam
    elsif File.exists?(dotjam) and File.directory?(dotjam)
      # .jam/ already exists, fail unless --force
      if(opts[:force])
        FileUtils.rm_rf dotjam
        create_dotjam
      else
        raise "#{File.expand_path(dotjam)} already exists; use --force to overwrite"
      end
    elsif File.exists?(dotjam) and !File.directory?(dotjam)
      # .jam already exists and isn't a dir, even --force won't save us.
      raise "#{dotjam} already exists, and is not a directory."
    end
  end

  def create_db
    conn=establish_connection dotjam('jam.sqlite3')
    initialize_database conn
    Jam::connection=conn
  end

  def copy_defaults
    src=File.join(Jam::JAM_DIR,'res','defaults','.')
    FileUtils.cp_r(src, dotjam)
    FileUtils.mkdir File.join(dotjam,"commands")
  end
end

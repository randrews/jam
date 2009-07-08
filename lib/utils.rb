def verify_test_scratch_dir scratch_dir=Jam::JAM_DIR+"/tests/scratch"
  if File.exists? scratch_dir
    raise "#{scratch_dir} already exists and is not a directory!" unless File.directory? scratch_dir
  else
    FileUtils.mkdir scratch_dir
  end

  scratch_dir
end

def remove_test_scratch_dir scratch_dir=Jam::JAM_DIR+"/tests/scratch"
  if File.directory? scratch_dir
    FileUtils.rm_rf scratch_dir
  else
    raise "#{scratch_dir} is not a directory; something might be wrong..."
  end

  scratch_dir
end

def verify_in_memory_connection clear=false
  if !Jam::connection or clear
    conn=establish_connection nil # in-memory
    initialize_database conn
    Jam::connection=conn
  end
  Jam::connection
end

def prep_test_tree scratch_dir, tree_name
  `cp -R #{Jam::JAM_DIR}/tests/fixtures/#{tree_name}/ #{scratch_dir}`
end

def create_fake_logger
  logger = Logger.new(STDOUT)
  logger.level = Logger::ERROR
  logger.formatter = Dhaka::ParserLogOutputFormatter.new
  logger
end

module Jam
  def self.command_names
    @command_names ||= {}
  end

  def self.register_command filename
    name=File.basename(filename,'.rb')
    command_names[name]=filename
  end

  def self.environment
    @environment ||= :production
  end

  def self.environment= env
    @environment = env || :production
  end
end

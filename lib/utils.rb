def verify_test_scratch_dir scratch_dir=Jam::JAM_DIR+"/tests/scratch"
  if File.exists? scratch_dir
    Jam::error "#{scratch_dir} already exists and is not a directory!" unless File.directory? scratch_dir
  else
    FileUtils.mkdir scratch_dir
  end

  scratch_dir
end

def remove_test_scratch_dir scratch_dir=Jam::JAM_DIR+"/tests/scratch"
  if File.directory? scratch_dir
    FileUtils.rm_rf scratch_dir
  else
    Jam::erorr "#{scratch_dir} is not a directory; something might be wrong..."
  end

  scratch_dir
end

def verify_in_memory_connection clear=false
  if !Jam::db or clear
    conn=establish_connection nil # in-memory
    initialize_database conn
    Jam::db=conn
  end
  Jam::db
end

def prep_test_tree scratch_dir, tree_name
  `cp -R #{Jam::JAM_DIR}/tests/fixtures/#{tree_name}/ #{scratch_dir}`

  jam=Proc.new do |*args|
    args=args.flatten.join(" ").split(/\s+/)
    opts=parse_options args
    opts[:command_class].run scratch_dir, opts, opts[:targets]
  end

  yield jam if block_given?

  jam
end

def preserve_test_tree scratch_dir, preserve_name
  FileUtils::mkdir_p "#{Jam::JAM_DIR}/preserved/#{preserve_name}"
  `cp -R #{scratch_dir}/ #{Jam::JAM_DIR}/preserved/#{preserve_name}`
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

  def self.require_parser
    require 'dhaka'

    Dir[Jam::JAM_DIR+"/parser/*.rb"].each do |file|
      require file
    end
  end

  def self.error str
    raise Jam::JamError.new(str)
  end

  def self.fieldname? name
    Jam::db[:files].columns.map(&:to_s).include? name
  end
end

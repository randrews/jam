class Jam::ListCommand < Jam::Command

  def parse_options
    cmd_opts=Trollop::options(opts) do
      opt :verbose, "Display tags as well", :default=>false, :short=>'v'
    end
  end

  def run
    connect_to_db

    t=targets
    t=['.'] if t.empty?
    current = rel(FileUtils.pwd, root(FileUtils.pwd))

    to_targets t do |id|
      file=Jam::File.find(:id=>id)

      emit rel(file.path,current)
      file.describe_tags.each{|line| emit line} if command_opts[:verbose]
    end
  end
end

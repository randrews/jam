class Jam::FindCommand < Jam::Command
  include Jam::Matcher

  def parse_options
    cmd_opts=Trollop::options(opts) do
      opt :verbose, "Display tags as well", :default=>false, :short=>'v'
    end
  end

  def run
    connect_to_db

    Jam::error("No query specified") if targets.empty?

    to_query(targets[0]) do |id|
      file=Jam::File.find(:id=>id)
      emit file.path
      file.describe_tags.each{|line| emit line} if command_opts[:verbose]
    end
  end
end

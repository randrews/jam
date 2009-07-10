class Jam::FindCommand < Jam::Command
  include Jam::Matcher

  def run
    connect_to_db

    Jam::error("No query specified") if targets.empty?

    to_query(targets[0]) do |id|
      file=Jam::File.find(:id=>id)
      emit file.path
      file.describe_tags.each{|line| emit line}
    end
  end
end

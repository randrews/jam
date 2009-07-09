class Jam::FindCommand < Jam::Command
  include Jam::Matcher

  def run
    connect_to_db

    raise "No query specified" if targets.empty?

    files=query(targets[0])

    files.each do |id|
      file=Jam::File.find(:id=>id)
      emit file.path
      file.describe_tags.each{|line| emit line}
    end
  end
end

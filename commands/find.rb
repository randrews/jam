class Jam::FindCommand < Jam::Command
  include Jam::Matcher

  def run
    connect_to_db

    raise "No query specified" if targets.empty?

    files=query(targets[0])

    files.each do |file|
      emit file.path
      file.describe_tags.each{|line| emit line}
    end
  end

  # Gets monkeypatched by tests
  def emit str
    puts str
  end
end

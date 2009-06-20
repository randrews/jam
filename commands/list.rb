class Jam::ListCommand < Jam::Command
  def run
    connect_to_db

    t=targets
    t=['.'] if t.empty?

    to_targets t do |path, tgt|
      file=tgt.file || next

      emit rel(tgt.path,'.')
      file.describe_tags.each{|line| emit line}
    end
  end

  # Gets monkeypatched by tests
  def emit str
    puts str
  end
end

class Jam::ListCommand < Jam::Command
  def run
    connect_to_db

    t=targets
    t=['.'] if t.empty?
    current = rel(FileUtils.pwd, root(FileUtils.pwd))

    to_targets t do |id|
      file=Jam::File.find(:id=>id)

      emit rel(file.path,current)
      file.describe_tags.each{|line| emit line}
    end
  end
end

class Jam::AddCommand < Jam::Command

  def run
    connect_to_db

    t=targets
    t=[pwd] if t.empty?

    t.each do |file|
      add_file file
    end
  end

  private

  def add_file file
    # TODO check if the file is not inside root

    if File.directory? file
      spider_directory file, root do |path|
        add_file path
      end
    else
      Jam::File.find_or_create :path=>file
    end
  end
end

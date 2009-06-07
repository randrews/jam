class Jam::TagCommand < Jam::Command

  def run
    connect_to_db

    t=targets
    @tag=t.shift
    raise "No targets given" if t.empty?

    @note=opts[:command_opts][:note] rescue nil
    @agent=opts[:command_opts][:agent] rescue nil

    t.each do |file|
      tag_file file
    end
  end

  private

  def tag_file file
    # TODO check if the file is not inside root
    if File.directory? file
      spider_directory file, root do |path|
        tag_file path
      end
    else
      Jam::File.at(file).tag(@tag,@note,@agent)
    end
  end
end

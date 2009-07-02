class Jam::TagCommand < Jam::Command

  def run
    connect_to_db

    t=targets
    tagname=t.shift
    raise "No targets given" if t.empty?

    if (opts[:command_opts][:delete] rescue nil)

      tag=Jam::Tag.find :name=>tagname
      raise "Tag #{tagname} not found" if tag.nil?

      to_targets t, "Detagging files..." do |path, tgt|
        Jam::File.at(path).remove_tag tag
      end

    else

      note=opts[:command_opts][:note] rescue nil
      agent=opts[:command_opts][:agent] rescue nil

      to_targets t, "Tagging files..." do |path, tgt|
        Jam::File.at(path).tag(tagname,note,agent)
      end

    end
  end
end

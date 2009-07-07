class Jam::TagCommand < Jam::Command

  def run
    connect_to_db

    if targets.empty? # Just list the tags
      tag_counts={}
      Jam::Tag.all.each do |tag|
        tag_counts[tag.name] = Jam::connection[:files_tags].filter(:tag_id=>tag.id).count
      end

      tag_counts.keys.sort.each do |tagname|
        emit "#{tag_counts[tagname]}\t#{tagname}"
      end
    elsif (opts[:command_opts][:delete] rescue nil) # De-tag files
      tagname=targets.shift

      tag=Jam::Tag.find :name=>tagname
      raise "Tag #{tagname} not found" if tag.nil?

      to_targets targets, "Detagging files..." do |path, tgt|
        Jam::File.at(path).remove_tag tag
      end
    else # Tag files
      tagname=targets.shift

      note=opts[:command_opts][:note] rescue nil
      agent=opts[:command_opts][:agent] rescue nil

      to_targets targets, "Tagging files..." do |path, tgt|
        Jam::File.at(path).tag(tagname,note,agent)
      end
    end
  end

  def emit str
    puts str
  end
end

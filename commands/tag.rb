class Jam::TagCommand < Jam::Command

  def self.parse_options opts
    cmd_opts=Trollop::options(opts) do
      opt :note, "The value to apply to the file for this tag", :short=>'n', :type=>String
      opt :agent, "The agent name to use when applying this tag", :short=>'a'
      opt :delete, "Delete the tag instead of applying it", :default=>false, :short=>'d'
    end
  end

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
end

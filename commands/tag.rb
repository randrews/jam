class Jam::TagCommand < Jam::Command

  def self.parse_options opts
    cmd_opts=Trollop::options(opts) do
      opt :note, "The value to apply to the file for this tag", :short=>'n', :type=>String
      opt :agent, "The agent name to use when applying this tag", :short=>'a'
      opt :delete, "Delete the tag instead of applying it", :default=>false, :short=>'d'
      opt :query, "Tag the results of a query instead of files/directories", :type=>String, :short=>'q'
      opt :view, "Tag the contents of a view instead of files/directories", :type=>String, :short=>'v'
    end
  end

  def run
    connect_to_db

    if targets.empty?
      list_tags
    else
      (tagname, note) = parse_tagname(targets.shift)

      Jam::error "#{tagname} is not allowed as a tag name" if Jam::fieldname? tagname
      
      if command_opts[:delete]
        count = detag_files(targets, tagname)
        operation = "Detagged"
      else
        count = tag_files(targets, tagname, note)
        operation = "Tagged"
      end

      emit("#{operation} #{count} files in #{runtime} seconds")
    end
  end

  def parse_tagname tagname
    if tagname =~ /(.*)=(.*)/
      [$1, $2]
    else
      note=opts[:command_opts][:note] rescue nil
      [tagname, note]
    end
  end

  private

  def detag_files targets, tagname
    tag=Jam::Tag.find :name=>tagname
    Jam::error "Tag #{tagname} not found" if tag.nil?
    fast_tagger=Jam::FastTagger.new tagname

    if command_opts[:query]
      count=to_query command_opts[:query], "Detagging files..." do |id,tgt|
        fast_tagger.add_detagging_operation id
      end
    elsif command_opts[:view]
      count=to_view command_opts[:view], "Detagging files..." do |id,tgt|
        fast_tagger.add_detagging_operation id
      end
    else
      count=to_targets targets, "Detagging files..." do |id,tgt|
        fast_tagger.add_detagging_operation id
      end
    end

    fast_tagger.wait_for_finish
    count
  end

  def tag_files targets, tagname, note
    agent=opts[:command_opts][:agent] rescue nil
    fast_tagger=Jam::FastTagger.new tagname, note, agent

    if command_opts[:query]
      count=to_query command_opts[:query], "Tagging files..." do |id,tgt|
        fast_tagger.add_tagging_operation id
      end
    elsif command_opts[:view]
      count=to_view command_opts[:view], "Tagging files..." do |id,tgt|
        fast_tagger.add_tagging_operation id
      end
    else    
      count=to_targets targets, "Tagging files..." do |id,tgt|
        fast_tagger.add_tagging_operation id
      end
    end

    fast_tagger.wait_for_finish
    count
  end

  def list_tags
    tag_counts={}
    Jam::Tag.all.each do |tag|
      tag_counts[tag.name] = Jam::db[:files_tags].filter(:tag_id=>tag.id).count
    end

    tag_counts.keys.sort.each do |tagname|
      emit "#{tag_counts[tagname]}\t#{tagname}"
    end
  end
end

module Jam::SqlSorter

  def post_process sort_columns, ids
    if sort_columns.empty?
      ids
    else
      # Build value hashes
      orders=sort_columns.map do |col|
        build_column_ordering(col, ids)
      end

      # Build dir hash
      dirs=build_directions sort_columns

      # Actually sort things
      ids.sort do |a, b|
        n=0
        n+=1 while n<orders.size and orders[n][a]==orders[n][b]

        if n==orders.size # These are equal, we're out of orderings
          0
        else # Something's unequal
          val1=orders[n][a]
          val2=orders[n][b]
          dir=dirs[n]

          if dir==:asc
            if val1.nil? # a is nil, b isn't, a<b
              -1
            elsif val2.nil? # a>b
              1
            else # Neither is nil, spaceship
              val1 <=> val2
            end
          else # Same as above, just reversed because this is desc.
            if val1.nil?
              1
            elsif val2.nil?
              -1
            else
              val2 <=> val1
            end
          end
        end
      end
    end
  end

  private

  def build_directions sort_columns
    h={}
    sort_columns.each_with_index do |col, idx|
      h[idx]=col[:direction]
    end
    h
  end

  def build_column_ordering col, ids
    hash={}
    name=col[:name]

    if col[:type]==:tag
      tag_id=Jam::db[:tags][:name=>name.to_s][:id]

      Jam::db[:files_tags].
        filter(:file_id=>ids, :tag_id=>tag_id).
        select(:file_id, :note).
        each{|row| hash[row[:file_id]]=row[:note]}
    elsif col[:type]==:field
      if name==:id
        ids.each{|id| hash[id]=id}
      else
        Jam::db[:files].
          filter(:id=>ids).
          select(name, :id).
          each{|row| hash[row[:id]]=row[name]}
      end
    end

    hash
  end

end

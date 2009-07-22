module Jam::IgnoresFile
  cached :ignores do
    unless self.respond_to? :ignores_filenames
      raise NotImplementedException("You need to implement ignores_filenames")
    end

    ignores_array=[]

    ignores_filenames.each do |ignores_filename|
      next unless File.readable? ignores_filename

      # Special case for views list
      if File.basename(ignores_filename)=='views'
        ignores_array += ignores_for_views(ignores_filename)
      else
        each_noncomment_line(ignores_filename) do |line|
          ignores_array << line
        end
      end
    end

    ignores_array
  end

  def ignores_for_views views_file
    ignores=[]

    each_noncomment_line(views_file) do |view|
      ignores << "./#{view}/**/*"
      ignores << "./#{view}/*"
    end

    ignores
  end

  private

  def each_noncomment_line file, &blk
    File.open file do |io|
      io.each_line do |line|
        line=line.strip
        next if line.empty? or line[0].chr=="#"
        blk.call line
      end
    end
  end
end

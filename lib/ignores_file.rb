module Jam::IgnoresFile
  cached :ignores do
    unless self.respond_to? :ignores_filenames
      raise "ignores_filenames method not implemented"
    end

    ignores_array=[]

    ignores_filenames.each do |ignores_filename|
      next unless File.readable? ignores_filename

      File.open ignores_filename do |io|
        io.each_line do |line|
          line=line.strip
          ignores_array << line unless line.empty? or line[0].chr=="#"
          end
      end
    end

    ignores_array
  end
end

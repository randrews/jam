module Jam::IgnoresFile
  def ignores reload=false
    @ignores=nil if reload

    if @ignores.nil?
      unless self.respond_to? :ignores_filenames
        raise "ignores_filenames method not implemented"
      end

      @ignores=[]

      ignores_filenames.each do |ignores_filename|
        next unless File.readable? ignores_filename

        File.open ignores_filename do |io|
          io.each_line do |line|
            line=line.strip
            @ignores << line unless line.empty? or line[0].chr=="#"
          end
        end
      end
    end

    @ignores
  end
end

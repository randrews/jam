module Jam::IgnoresFile
  def ignores reload=false
    @ignores=nil if reload

    if @ignores.nil?
      unless self.respond_to? :ignores_filename
        raise "ignores_filename method not implemented"
      end
      File.open ignores_filename do |io|
        @ignores=[]
        io.each_line do |line|
          line=line.strip
          @ignores << line unless line.empty? or line[0].chr=="#"
        end
      end
    end

    @ignores
  end
end

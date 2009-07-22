module Jam::ListFile

  def add_to_file filename, *values
    File.open(filename,'a') do |file|
      values.each do |value|
        file << value
        file << "\n"
      end
    end
  end

  def remove_from_file filename, *values
    lines=[]

    File.open(filename,'r') do |file|
      file.each_line{|l| lines << l.strip }
    end

    new_lines = lines - values

    File.open(filename,'w') do |file|
      new_lines.each do |l|
        file << l
        file << "\n"
      end
    end
  end

  def exists_in_file? filename, value
    File.open(filename,'r') do |file|
      file.each_line do |l|
        return true if l.strip==value
      end
    end
    false
  end

end

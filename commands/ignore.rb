class Jam::IgnoreCommand < Jam::Command
  include Jam::IgnoresFile

  def command_opts
    opts[:command_opts] || {}
  end

  def ignores_filenames
    if command_opts[:all]
      [ dotjam('ignore'),
        dotjam('views'),
        dotjam('user_ignores') ]
    else
      [ dotjam('user_ignores') ]
    end
  end

  def run
    if targets.empty?
      ignores.uniq.each do |i|
        emit(i)
      end
    elsif command_opts[:delete]
      user_ignores=[]

      File.open(dotjam('user_ignores'),'r') do |file|
        file.each_line{|l| user_ignores << l.strip }
      end

      new_ignores = user_ignores - targets

      File.open(dotjam('user_ignores'),'w') do |file|
        new_ignores.each do |i|
          file << i
          file << "\n"
        end
      end
    else
      File.open(dotjam('user_ignores'),'a') do |file|
        targets.each do |t|
          file << t
          file << "\n"
        end
      end
    end
  end

  def emit str
    puts str
  end
end

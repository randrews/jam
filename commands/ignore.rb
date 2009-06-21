class Jam::IgnoreCommand < Jam::Command
  include Jam::IgnoresFile

  def ignores_filenames
    [ dotjam('ignore'),
      dotjam('views'),
      dotjam('user_ignores') ]
  end

  def run
    if targets.empty?
      ignores.uniq.each do |i|
        emit(i)
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

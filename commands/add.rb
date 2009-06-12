class Jam::AddCommand < Jam::Command

  def run
    connect_to_db

    t=targets
    t=[pwd] if t.empty?


    to_targets t do |file, tgt|
      Jam::File.find_or_create :path=>file
    end
  end
end

class Jam::AddCommand < Jam::Command

  def run
    connect_to_db

    t=targets
    t=['.'] if t.empty?

    to_targets t, "Adding files..." do |file, tgt|
      Jam::File.find_or_create :path=>file
    end
  end

end

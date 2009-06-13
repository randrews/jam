module Jam::Pathutil
  # Utility method to find a relative path.
  def rel to, from
    Pathname.new(File.expand_path(to)).
      relative_path_from(Pathname.new(File.expand_path(from))).to_s
  end
end

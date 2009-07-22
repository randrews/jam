module Jam::ViewUtils
  def view_exists? name
    exists_in_file? dotjam('views'), name
  end

  def add_to_view_list name
    add_to_file dotjam('views'), name
  end

  def remove_from_view_list name
    remove_from_file dotjam('views'), name
  end

  def view_dir name
    File.join(root('.'),name)
  end
end

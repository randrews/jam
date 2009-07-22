class Jam::ViewCommand < Jam::Command
  include Jam::ListFile
  include Jam::ViewUtils

  def parse_options opts
    Trollop::options(opts) do
      opt :append, "Add to a pre-existing view", :default=>false, :short=>'a'
      opt :delete, "Delete a pre-existing view", :default=>false, :short=>'d'
    end
  end

  def run
    connect_to_db

    name=targets.shift

    if command_opts[:delete]
      delete_view name
    elsif command_opts[:append]
      query=targets.shift
      append_to_view name, query
    else
      query=targets.shift
      create_view name, query
    end
  end

  private

  def append_to_view name, query
    Jam::error "Usage: jam view -a <name> <query>" unless name and query
    Jam::error "#{name} is not a view" unless view_exists?(name)

    dir=view_dir(name)
    Jam::error "#{dir} is not a directory" unless File.directory?(dir)

    num=1

    # Find the last file's number in the directory
    Dir["#{dir}/*"].sort.reverse.each do |file|
      if File.basename(file)=~/^(\d+)_/
        num=$1.to_i
        break
      end
    end

    # Get the list of files already in the view
    already_in_view = Dir["#{dir}/*"].map do |file|
      File.readlink(file)
    end

    to_query query, "Appending files..." do |id|
      file=Jam::db[:files][:id=>id]
      add_file_to_view dir, file, num unless already_in_view.include?("../#{file[:path]}")
      num+=1
    end
  end

  def create_view name, query
    Jam::error "Usage: jam view <name> <query>" unless name and query
    Jam::error "Cannot create view #{name}; file exists" unless can_create?(name)

    add_to_view_list(name)
    view_path=create_view_directory(name)

    num=1
    to_query query, "Assembling files..." do |id|
      file=Jam::db[:files][:id=>id]
      add_file_to_view view_path, file, num
      num+=1
    end
  end

  def delete_view name
    Jam::error "Usage: jam view -d <name>" unless name
    Jam::error "#{name} is not a view" unless view_exists?(name)

    dir=view_dir(name)

    if File.directory?(dir)
      FileUtils.rm_rf dir
    else
      emit "#{dir} not found; removing from view list"
    end

    remove_from_view_list name
  end

  def add_file_to_view view_path, file, num
    path=file[:path]
    filename=file[:filename]
    num_label=num.to_s.rjust(4,'0')

    FileUtils.ln_s("../#{path}","#{view_path}/#{num_label}_#{filename}")
  end

  def can_create? name
    !File.exists?(view_dir(name))
  end

  def create_view_directory name
    dir=view_dir(name)
    FileUtils.mkdir(dir)
    dir
  end
end

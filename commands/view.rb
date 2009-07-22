require(Jam::JAM_DIR+"/lib/list_file.rb")

class Jam::ViewCommand < Jam::Command
  include Jam::ListFile

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
    else
      query=targets.shift
      create_view name, query
    end
  end

  private

  def create_view name, query
    Jam::error "Usage: jam view <name> <query>" unless name and query

    raise NotImplementedException if command_opts[:append]

    Jam::error "Cannot create view #{name}; file exists" unless can_create?(name)

    add_to_view_list(name)
    view_path=create_view_directory(name)

    num=1
    to_query query, "Assembling files..." do |id|
      file=Jam::db[:files][:id=>id]
      path=file[:path]
      filename=file[:filename]
      num_label=num.to_s.rjust(4,'0')

      FileUtils.ln_s("../#{path}","#{view_path}/#{num_label}_#{filename}")
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

  def view_exists? name
    exists_in_file? dotjam('views'), name
  end

  def add_to_view_list name
    add_to_file dotjam('views'), name
  end

  def remove_from_view_list name
    remove_from_file dotjam('views'), name
  end

  def can_create? name
    !File.exists?(view_dir(name))
  end

  def create_view_directory name
    dir=view_dir(name)
    FileUtils.mkdir(dir)
    dir
  end

  def view_dir name
    File.join(root('.'),name)
  end
end

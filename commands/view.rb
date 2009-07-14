class Jam::ViewCommand < Jam::Command
  def parse_options opts
    Trollop::options(opts) do
      opt :append, "Add to a pre-existing view", :default=>false, :short=>'a'
      opt :order, "Field name to order by", :type=>String, :short=>'o', :default=>"filename"
    end
  end

  def run
    connect_to_db

    name=targets.shift
    query=targets.shift

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

  private

  def view_exists? name ; false ; end

  def add_to_view_list name ; end

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

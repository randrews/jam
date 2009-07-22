require(Jam::JAM_DIR+"/lib/list_file.rb")

class Jam::IgnoreCommand < Jam::Command
  include Jam::ListFile
  include Jam::IgnoresFile

  def parse_options opts
    cmd_opts=Trollop::options(opts) do
      opt :delete, "Delete the ignore instead of adding it", :default=>false, :short=>'d'
      opt :all, "List all ignores, not just user-added", :default=>false, :short=>'a'
    end
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
      remove_from_file(dotjam('user_ignores'),*targets)
    else
      add_to_file(dotjam('user_ignores'),*targets)
    end
  end
end

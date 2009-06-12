class Jam::ListCommand < Jam::Command
  def run
    connect_to_db

    t=targets
    t=['.'] if t.empty?

    to_targets t do |path, tgt|
      file=Jam::File.at(path)
      next unless file
      emit path
      file.tags.each do |name, params|
        if params[:note]
          emit "\t#{name} = #{params[:note]}"
        else
          emit "\t#{name}"
        end
      end
    end
  end

  # Gets monkeypatched by tests
  def emit str
    puts str
  end
end

require File.join(Jam::JAM_DIR,"lib","class_utilities.rb")

module Jam::Emit

  array :emitted

  def self.extended base
    base.send :define_method, :emit do |str|
      if Jam::environment==:test
        self.class.class_eval do
          emitted << str
        end
      else
        puts str
      end
    end
  end

end

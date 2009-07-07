module Jam::Emit

  def emitted ; @emitted ; end
  def clear_emitted ; @emitted=[] ; end

  def self.extended base
    base.send :define_method, :emit do |str|
      if Jam::environment==:test
        self.class.class_eval do
          @emitted ||= []
          @emitted << str
        end
      else
        puts str
      end
    end
  end

end

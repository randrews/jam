class Array
  def to_set
    set = ::Set.new
    set.merge self
    set
  end
end

class Symbol
  def to_proc
    Proc.new do |arg|
      arg.send self
    end
  end
end

class String
  def camelize
    gsub(/(^|_)(.)/) { $2.upcase }
  end

  def constantize
    Object.module_eval "::#{self}"
  end
end

module ClassUtilities
  def cached name, &blk
    varname="@#{name}"
    define_method name do |*reload|
      unless instance_variable_get varname and !reload
        instance_variable_set varname, instance_eval(&blk)
      end
      instance_variable_get varname
    end
  end

  def array name, *rest
    varname="@#{name}"
    define_method name do
      unless instance_variable_get varname
        instance_variable_set varname, []
      end
      instance_variable_get varname
    end

    define_method "clear_#{name}" do
      instance_variable_set varname, []
    end

    array *rest unless rest.empty?
  end
end

class Module ; include ClassUtilities ; end
class Class ; include ClassUtilities ; end

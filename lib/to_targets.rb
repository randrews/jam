require(File.dirname(__FILE__)+"/spinner.rb")

module Jam::ToTargets
  include Jam::Spinner

  def to_targets target_paths, spin_msg=nil, &blk
    self.target_paths=target_paths

    count=target_count

    if spin_msg and Jam::environment!=:test
      with_spinner count, spin_msg do |spin|
        find_targets.each do |tgt|
          yield tgt.relroot, tgt
          spin.call
        end
      end
    else
      find_targets.each do |tgt|
        yield tgt.relroot, tgt
      end
    end

    count
  end

  private

  attr_accessor :target_paths

  cached :target_count do
    find_targets.length
  end

  cached :find_targets do
    targets=[]
    target_paths.each do |tp|
      targets += Jam::Target.from_path tp
    end

    targets
  end

end

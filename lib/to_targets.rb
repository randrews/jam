require(File.dirname(__FILE__)+"/spinner.rb")

module Jam::ToTargets
  include Jam::Spinner

  def to_filesystem_targets target_paths, spin_msg=nil, &blk
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

  def to_targets target_paths, spin_msg=nil, &blk
    paths=[]
    dirnames=[]
    ids=[]

    target_paths.each do |path|
      tgt = Jam::Target.from_path(path,false)[0]
      (File.directory?(path) ? dirnames : paths) << tgt.relroot if tgt
    end

    add_filter(:path=>paths) unless paths.empty?
    dirnames.each do |dirname|
      add_filter(:dirname.like("#{dirname}%"))
    end

    raise "No valid targets given" unless @filter_expr
    Jam::connection[:files].filter(@filter_expr).each{|r| ids << r[:id]}

    if spin_msg and Jam::environment!=:test
      with_spinner ids.size, spin_msg do |spin|
        ids.each do |id|
          yield id
          spin.call
        end
      end
    else
      ids.each do |id|
        yield id
      end
    end

    ids.size
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

  def add_filter expr
    @filter_expr = (@filter_expr ? (@filter_expr | expr) : expr)
  end
end

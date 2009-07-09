require(File.dirname(__FILE__)+"/spinner.rb")
require(File.dirname(__FILE__)+"/matcher.rb")

module Jam::ToTargets
  include Jam::Spinner
  include Jam::Matcher

  ##################################################
  ### Filesystem targets ###########################
  ##################################################
  # Spiders all files that aren't ignored, whether
  # in the DB or not. The slowest option.
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

  ##################################################
  ### Targets ######################################
  ##################################################
  # Uses SQL to find the files already in the DB
  # that match the target paths. Much faster.
  def to_targets target_paths, spin_msg=nil, &blk
    ids=[]
    build_dataset_for(target_paths).each{|r| ids << r[:id]}

    to_ids ids, spin_msg, &blk
  end

  ##################################################
  ### Query ########################################
  ##################################################
  # Grinds over anything in the DB that matches the
  # given query. Very fast.
  def to_query query_str, spin_msg=nil, &blk
    to_ids query(query_str), spin_msg, &blk
  end

  ##################################################
  ### IDs ##########################################
  ##################################################
  # Just grinds over a list of IDs. Takes no time at
  # all; used by the other methods.
  def to_ids ids, spin_msg=nil, &blk
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

  def build_dataset_for target_paths
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

    Jam::connection[:files].filter(@filter_expr)
  end

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

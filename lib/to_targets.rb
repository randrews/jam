require(File.dirname(__FILE__)+"/spinner.rb")
require(File.dirname(__FILE__)+"/matcher.rb")
require(File.dirname(__FILE__)+"/view_utils.rb")
require(File.dirname(__FILE__)+"/list_file.rb")

module Jam::ToTargets
  include Jam::Spinner
  include Jam::Matcher
  include Jam::ViewUtils
  include Jam::ListFile

  ##################################################
  ### Filesystem targets ###########################
  ##################################################
  # Spiders all files that aren't ignored, whether
  # in the DB or not. The slowest option.
  def to_filesystem_targets target_paths, spin_msg=nil, &blk
    self.target_paths=target_paths

    count=target_count
    Jam::error "No valid targets given" if target_count==0

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
  ### View #########################################
  ##################################################
  # Grinds over anything in the given view.
  def to_view view_name, spin_msg=nil, &blk
    Jam::error "View #{view_name} not found" unless view_exists?(view_name)

    paths = []
    Dir[File.join(view_dir(view_name),"*")].map do |file|
      path = File.readlink(file) rescue nil
      paths << path[3..path.size] if path # paths all begin with ../
    end

    ids = Jam::db[:files].filter(:path=>paths).select(:id).all.map{|r| r[:id]}
    to_ids ids, spin_msg, &blk
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

    Jam::error("No valid targets given") unless @filter_expr

    Jam::db[:files].filter(@filter_expr)
  end

  attr_accessor :target_paths

  cached :target_count do
    find_targets.length
  end

  cached :find_targets do
    targets=[]
    target_paths.each do |tp|
      tgt=Jam::Target.from_path tp
      Jam::error "Invalid target #{tp}" if tgt==[]
      targets += tgt
    end

    targets
  end

  def add_filter expr
    @filter_expr = (@filter_expr ? (@filter_expr | expr) : expr)
  end
end

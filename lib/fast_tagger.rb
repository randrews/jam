require File.join(Jam::JAM_DIR,"lib","class_utilities.rb")

class Jam::FastTagger
  attr_accessor :tagname, :note, :agent
  MAX_BLOCK_SIZE=100
  SEPARATE_THREADS=false

  def initialize tagname, note="", agent=""
    self.tagname=tagname
    self.note=note
    self.agent=agent
    init_arrays
  end

  def add_tagging_operation file_id
    # if currently tagged
    if current_tagged_ids.include?(file_id)
      ids_to_update << Jam::connection[:files_tags].
        filter(:file_id=>file_id, :tag_id=>tag_object.id).
        select(:id).first[:id]
      flush_updates if ids_to_update.size >= MAX_BLOCK_SIZE
    else # Not currently tagged, create a new files_tags
      file_ids_to_create << file_id
      flush_creates if file_ids_to_create.size >= MAX_BLOCK_SIZE
    end
  end

  def add_detagging_operation file_id
    if current_tagged_ids.include?(file_id)
      ids_to_delete << Jam::connection[:files_tags].
        filter(:file_id=>file_id, :tag_id=>tag_object.id).
        select(:id).first[:id]
      flush_deletes if ids_to_delete.size >= MAX_BLOCK_SIZE
    end
  end

  def wait_for_finish
    flush_updates
    flush_creates
    flush_deletes

    threads.each &:join if SEPARATE_THREADS
  end

  private

  ##################################################
  ### Support functions and buffers ################
  ##################################################

  [:ids_to_update, :file_ids_to_create, :ids_to_delete, :threads].each do |array|
    attr_accessor array
  end

  def init_arrays
    @ids_to_update=Set.new
    @file_ids_to_create=Set.new
    @ids_to_delete=Set.new
    @threads=Set.new
  end

  def current_tagged_files
    @current_tagged_files ||=
      ( Jam::connection[:files].select(:path, :file_id=>:id).
        join(:files_tags, :file_id=>:id).
        filter(:tag_id=>tag_object.id).all )
  end

  def current_tagged_ids
    @current_tagged_ids ||=
      ( current_tagged_files.map{|r| r[:id]}.to_set )
  end

  def tag_object
    @tag_object ||=
      ( Jam::Tag.find_or_create(:name=>tagname) )
  end

  ##################################################
  ### Flush buffer functions #######################
  ##################################################
  # Called when any buffer reaches 1000 rows

  def flush_updates
    update_files_tags
    ids_to_update.clear
  end

  def flush_creates
    create_files_tags
    file_ids_to_create.clear
  end

  def flush_deletes
    delete_files_tags
    ids_to_delete.clear
  end

  ##################################################
  ### Actually CRUD rows ###########################
  ##################################################
  # Actually does DB operations

  def delete_files_tags
    Jam::connection[:files_tags].filter(:id=>ids_to_delete.to_a).delete
  end

  def create_files_tags
    tag_id=tag_object.id
    data=file_ids_to_create.to_a.map{|file_id|
      { :file_id=>file_id,
        :tag_id=>tag_id,
        :note=>note,
        :tagged_by=>agent,
        :created_at=>Time.now,
        :updated_at=>Time.now
      }}

    Jam::connection[:files_tags].multi_insert(data)
  end

  def update_files_tags
    Jam::connection[:files_tags].
      filter(:id=>ids_to_update.to_a).
      update(:note=>note,
             :tagged_by=>agent,
             :updated_at=>Time.now)
  end

end

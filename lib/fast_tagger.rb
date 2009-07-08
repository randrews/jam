require File.join(Jam::JAM_DIR,"lib","class_utilities.rb")

class Jam::FastTagger
  attr_accessor :tagname, :note, :agent
  MAX_BLOCK_SIZE=1000
  SEPARATE_THREADS=false

  def initialize tagname, note="", agent=""
    self.tagname=tagname
    self.note=note
    self.agent=agent
  end

  def add_tagging_operation path
    file_id=Jam::connection[:files].filter(:path=>path).select(:id).first[:id]

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

  def add_detagging_operation path
    file_id=Jam::connection[:files].filter(:path=>path).select(:id).first[:id]

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

  array :ids_to_update, :file_ids_to_create, :ids_to_delete, :threads

  cached :current_tagged_files do
    Jam::connection[:files].select(:path, :file_id=>:id).
      join(:files_tags, :file_id=>:id).
      filter(:tag_id=>tag_object.id).all
  end

  cached :current_tagged_ids do
    current_tagged_files.map{|r| r[:id]}.to_set
  end

  cached :tag_object do
    Jam::Tag.find_or_create(:name=>tagname)
  end

  ##################################################
  ### Flush buffer functions #######################
  ##################################################
  # Called when any buffer reaches 1000 rows

  def flush_buffer msg, buffer
    ids=self.send buffer
    if SEPARATE_THREADS
      threads << Thread.new { self.send msg, ids }
    else
      self.send msg, ids
    end
    self.send "clear_#{buffer}"
  end

  def flush_updates
    flush_buffer :update_files_tags, :ids_to_update
  end

  def flush_creates
    flush_buffer :create_files_tags, :file_ids_to_create
  end

  def flush_deletes
    flush_buffer :delete_files_tags, :ids_to_delete
  end

  ##################################################
  ### Actually CRUD rows ###########################
  ##################################################
  # Actually does DB operations

  def delete_files_tags ids
    Jam::connection[:files_tags].filter(:id=>ids).delete
  end

  def create_files_tags file_ids_to_create
    tag_id=tag_object.id
    data=file_ids_to_create.map{|file_id|
      { :file_id=>file_id,
        :tag_id=>tag_id,
        :note=>note,
        :tagged_by=>agent,
        :created_at=>Time.now,
        :updated_at=>Time.now
      }}

    Jam::connection[:files_tags].multi_insert(data)
  end

  def update_files_tags ids_to_update
    Jam::connection[:files_tags].
      filter(:id=>ids_to_update).
      update(:note=>note,
             :tagged_by=>agent,
             :updated_at=>Time.now)
  end

end

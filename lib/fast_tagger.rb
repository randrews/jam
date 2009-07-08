class Jam::FastTagger
  attr_accessor :tagname, :note, :agent
  MAX_BLOCK_SIZE=1000
  SEPARATE_THREADS=true

  def initialize tagname, note, agent
    self.tagname=tagname
    self.note=note
    self.agent=agent
  end

  def add_tagging_operation path
    file_id=Jam::connection[:files].filter(:path=>path).select(:id).first[:id]

    # if currently tagged
    if current_tagged_ids.include?(file_id)
      ids_to_update << Jam::connection[:files_tags].filter(:file_id=>file_id, :tag_id=>tag_object.id).select(:id).first[:id]
      flush_updates if ids_to_update.size >= MAX_BLOCK_SIZE
    else # Not currently tagged, create a new files_tags
      file_ids_to_create << file_id
      flush_creates if file_ids_to_create.size >= MAX_BLOCK_SIZE
    end
  end

  def wait_for_finish
    flush_updates
    flush_creates

    threads.each &:join
  end

  private

  def threads ; @threads ||= [] ; end

  def flush_updates
    ids=ids_to_update
    if SEPARATE_THREADS
      threads << Thread.new{ update_files_tags ids }
    else
      update_files_tags ids
    end
    @ids_to_update=[]
  end

  def flush_creates
    ids=file_ids_to_create
    if SEPARATE_THREADS
      threads << Thread.new{ create_files_tags ids }
    else
      create_files_tags ids
    end
    @file_ids_to_create=[]
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

  def current_tagged_files
    unless @current_tagged_files
      tag=tag_object
      @current_tagged_files = 
        Jam::connection[:files].select(:path, :file_id=>:id).
        join(:files_tags, :file_id=>:id).
        filter(:tag_id=>tag.id).all
    end
    @current_tagged_files
  end

  def current_tagged_ids
    @current_tagged_ids ||= current_tagged_files.map{|r| r[:id]}.to_set
  end

  def tag_object
    @tag_object ||= Jam::Tag.find_or_create(:name=>tagname)
  end

  def ids_to_update
    @ids_to_update ||= []
  end

  def file_ids_to_create
    @file_ids_to_create ||= []
  end

end

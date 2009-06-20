require File.dirname(__FILE__)+'/tag.rb'

class Jam::File < Sequel::Model(Jam::connection[:files])
  def self.apply_associations
    many_to_many :tags, :class=>Jam::Tag
  end

  def before_create
    self.created_at=Time.now
    self.updated_at=Time.now
  end

  def before_update
    self.updated_at=Time.now
  end

  def self.at path
    self.find :path=>path
  end

  def tag name, note=nil, agent_name=nil, set_created_at=false
    if has_tag? name
      tag=tags_dataset[:name=>name]
      ft=Jam::connection[:files_tags].filter(:file_id=>id, :tag_id=>tag.id).first
      ft[:note] = note || ft[:note]

      if agent_name
        ft[:tagged_by]= add_agent_name(ft[:tagged_by], agent_name)
      end

      ft[:created_at]=Time.now if set_created_at
      ft[:updated_at]=Time.now

      Jam::connection[:files_tags].filter(:id=>ft[:id]).update ft
      ft
    else
      add_tag Jam::Tag.find_or_create(:name=>name)
      self.tag name, note, agent_name, true
    end
  end

  def tags
    t={}
    Jam::connection["select ft.*, tags.name "+
                    "from files_tags ft, tags "+
                    "where ft.file_id=? and ft.tag_id=tags.id",self.id].each do |row|
      t[row[:name]] = {
        :note=>row[:note],
        :tagged_by=>agent_names(row[:tagged_by]),
        :created_at=>row[:created_at],
        :updated_at=>row[:updated_at]
      }
    end
    t
  end

  def has_tag? name
    !self.tags_dataset.filter(:name=>name).empty?
  end

  def get_tag name
    self.tags_dataset.filter(:name=>name).first
  end

  # Returns a string containing the tags for this file, neatly formatted
  def describe_tags indent=1
    strs=[]
    tags.each do |name, params|
      if params[:note]
        strs << ("\t"*indent)+"#{name} = #{params[:note]}"
      else
        strs << ("\t"*indent)+"#{name}"
      end
    end

    strs
  end

  private

  def add_agent_name old_list, new_name
    if old_list.nil? or old_list==""
      new_name
    else
      old_list=old_list.split(' ')
      old_list << new_name
      old_list.uniq.join(' ')
    end
  end

  def agent_names list
    ( list.nil? ? [] : list.split(' '))
  end
end

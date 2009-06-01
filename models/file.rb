require File.dirname(__FILE__)+'/tag.rb'

class Jam::File < Sequel::Model(Jam::connection[:files])
  many_to_many :tags, :class=>Jam::Tag

  def before_create
    self.created_at=Time.now
    self.updated_at=Time.now
  end
  
  def before_update
    self.updated_at=Time.now
  end

  def tag name, note=nil, agent_name=nil
    if has_tag? name
      tag=tags[:name=>name]
      ft=Jam::connection[:files_tags].filter(:file_id=>id, :tag_id=>tag.id).first
      ft[:note] ||= note

      if agent_name
        ft[:tagged_by]= add_agent_name(ft[:tagged_by], agent_name)
      end

      ft[:updated_at]=Time.now
      Jam::connection[:files_tags].filter(:id=>ft[:id]).update ft
      ft
    else
      add_tag Jam::Tag.find_or_create(:name=>name)
      self.tag name, note, agent_name
    end
  end

  def tags ; tags_dataset ; end

  def has_tag? name
    !self.tags_dataset.filter(:name=>name).empty?
  end

  def get_tag name
    self.tags_dataset.filter(:name=>name).first
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
end

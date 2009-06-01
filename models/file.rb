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

  def tag name, note=nil, tagged_by=nil
    if has_tag? name

      return 1
    else
      return 2
    end
  end

  def has_tag? name
    !self.tags_dataset.filter(:name=>name).empty?
  end

  def get_tag name
    self.tags_dataset.filter(:name=>name).first
  end
end

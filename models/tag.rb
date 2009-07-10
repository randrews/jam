class Jam::Tag < Sequel::Model(Jam::db[:tags])

  def self.apply_associations
    many_to_many :file, :class=>Jam::File
  end

  def before_create
    self.created_at=Time.now
    self.updated_at=Time.now
  end
  
  def before_update
    self.updated_at=Time.now
  end
end

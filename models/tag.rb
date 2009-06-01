class Jam::Tag < Sequel::Model(Jam::connection[:tags])
  many_to_many :file

  def before_create
    self.created_at=Time.now
    self.updated_at=Time.now
  end
  
  def before_update
    self.updated_at=Time.now
  end
end

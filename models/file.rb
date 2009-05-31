class Jam::File < Sequel::Model(Jam::connection[:files])
  def before_create
    self.created_at=Time.now
    self.updated_at=Time.now
  end
  
  def before_update
    self.updated_at=Time.now
  end
end

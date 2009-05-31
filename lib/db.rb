def establish_connection filename='jam.sqlite3'
  Sequel.sqlite(filename)
end

def initialize_database connection
  schema=File.read(Jam::JAM_DIR+"/res/sql/schema.sql")
  connection << schema
  connection
end

# Jam has a handle to the Sequel connection, and we can't load the
# model classes until it's set (because it defines their datasets).
# However, once we've loaded them, we can't (yet) change what the
# connection is.
module Jam
  def self.connection ; @connection ; end

  def self.connection= conn
    if @connection.nil?
      @connection=conn
      
      Dir[Jam::JAM_DIR+"/models/*.rb"].each do |file|
        require file
      end
    else
      raise "Don't call Jam::connection= more than once"
    end

    @connection
  end
end

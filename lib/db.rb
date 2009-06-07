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
module Jam
  def self.connection ; @connection ; end

  def self.connection= conn
    if @connection.nil?
      @connection=conn
      
      Dir[Jam::JAM_DIR+"/models/*.rb"].each do |file|
        require file
      end
    else
      @connection=conn
      [Jam::File, Jam::Tag].each{|c| c.db=conn }
    end

    [Jam::File, Jam::Tag].each {|c| c.apply_associations }

    @connection
  end
end

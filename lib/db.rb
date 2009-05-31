def establish_connection filename='jam.sqlite3'
  Sequel.sqlite(filename)
end

def initialize_database connection
  schema=File.read(Jam::JAM_DIR+"/res/sql/schema.sql")
  connection << schema
  connection
end

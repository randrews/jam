def establish_connection filename='jam.sqlite3'
  config={'adapter'=>'sqlite3','database'=>filename}
  ActiveRecord::Base.establish_connection(config)
end


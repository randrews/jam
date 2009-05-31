require "#{File.dirname(__FILE__)}/../jam.rb"

describe "database" do
  before :each do
    @scratch_dir=File.dirname(__FILE__)+"/scratch"
    @conn=establish_connection @scratch_dir+"/scratch.sqlite3"
    initialize_database @conn
  end

  after :each do
    `rm -f #{@scratch_dir}/scratch.sqlite3`
  end

  it "should establish a connection" do
    puts @conn.class
    @conn.is_a?(Sequel::SQLite::Database).should==true
  end

  it "should create three tables" do
    %w{files tags file_tags}.each do |tbl|
      @conn[tbl.to_sym].each
    end
  end
end

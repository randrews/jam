require "#{File.dirname(__FILE__)}/../jam.rb"

describe "database" do
  before :all do
    @scratch_dir=verify_test_scratch_dir
  end

  after :all do
    remove_test_scratch_dir @scratch_dir
  end

  before :each do
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

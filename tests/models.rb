require "#{File.dirname(__FILE__)}/../jam.rb"
Jam::environment=:test

describe "models" do
  before(:all){ @scratch_dir=verify_test_scratch_dir }
  after(:all){ remove_test_scratch_dir @scratch_dir }

  before :each do
    @conn=verify_in_memory_connection true

    @conn << "delete from files"
    @conn[:files].insert(:id=>1, :path=>'foo.txt')
  end

  it "should have working model classes" do
    Jam::File.set_dataset @conn[:files]
    Jam::File[1].nil?.should==false
  end


  it "should allow you to change the db connection" do
    # We'll make a new database, and then start using it
    @conn=establish_connection @scratch_dir+"/scratch.sqlite3"
    initialize_database @conn
    Jam::db=@conn

    # Our fixture now isn't there.
    Jam::File[1].nil?.should==true

    # Set conn back to in-memory
    @conn=establish_connection nil
    initialize_database @conn
    Jam::db=@conn
  end
end

describe "models" do
  before :all do
    @scratch_dir=File.dirname(__FILE__)+"/scratch"
    @conn=establish_connection @scratch_dir+"/models.sqlite3"
    initialize_database @conn
    Jam::connection=@conn
  end

  after :all do
    `rm -f #{@scratch_dir}/models.sqlite3`
  end

  it "should have working model classes" do
    @conn << "delete from files"
    @conn[:files].insert(:id=>1, :path=>'foo.txt')

    Jam::File.set_dataset @conn[:files]
    Jam::File[1].nil?.should==false
  end

end

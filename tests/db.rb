require "#{File.dirname(__FILE__)}/../jam.rb"

describe "database" do
  before :each do
    @scratch_dir=File.dirname(__FILE__)+"/scratch"
    @conn=establish_connection @scratch_dir+"/scratch.db"
  end

  it "should establish a connection" do
    @conn.nil?.should==false
  end
end

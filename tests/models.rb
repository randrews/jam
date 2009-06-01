require "#{File.dirname(__FILE__)}/../jam.rb"

describe "models" do
  before :all do
    @conn=verify_in_memory_connection
  end

  it "should have working model classes" do
    @conn << "delete from files"
    @conn[:files].insert(:id=>1, :path=>'foo.txt')

    Jam::File.set_dataset @conn[:files]
    Jam::File[1].nil?.should==false
  end
end

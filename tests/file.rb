require "#{File.dirname(__FILE__)}/../jam.rb"

describe "file" do
  before :all do
    verify_in_memory_connection
  end

  before :each do
    @file=Jam::File.create :path=>'test tags'
    @tag1=Jam::Tag.create :name=>'tag1'
    @tag2=Jam::Tag.create :name=>'tag2'

    @file.add_tag @tag1
    @file.add_tag @tag2

    @conn=Jam::connection
  end

  after :each do
    @conn << "delete from files"
    @conn << "delete from tags"
    @conn << "delete from files_tags"
  end

  it "should set the created_at when you make one" do
    file=Jam::File.create :path=>'test created_at'

    file.created_at.nil?.should==false
    file.updated_at.nil?.should==false
  end

  it "should have many tags" do
    @file.tags_dataset.map(:name).should==%w{tag1 tag2}
    @conn[:files_tags].count.should==2
  end 

  it "should have a working has_tag" do
    @file.has_tag?('tag1').should==true
    @file.has_tag?('tag2').should==true
    @file.has_tag?('tag3').should==false
  end

  it "should have a working get_tag" do
    @file.get_tag('tag1').should==@tag1
    @file.get_tag('tag2').should==@tag2
    @file.get_tag('tag3').should==nil
  end

  it "should have a working tagger for new tags" do
    ft1=@file.tag('novalue')
    ft2=@file.tag('value','value')
    ft3=@file.tag('value_agent','value','agent')

    @file.has_tag?('novalue').should==true
    ft2[:note].should=='value'
    ft3[:tagged_by].should=='agent'
  end
end

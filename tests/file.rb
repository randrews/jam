require "#{File.dirname(__FILE__)}/../jam.rb"
Jam::environment=:test

describe "file" do
  before :all do
    verify_in_memory_connection true
    @conn=Jam::db
  end

  before :each do
    @file=Jam::File.create :path=>'test tags'
    @tag1=Jam::Tag.create :name=>'tag1'
    @tag2=Jam::Tag.create :name=>'tag2'

    @file.add_tag @tag1
    @file.add_tag @tag2
  end

  after :each do
    [:files, :tags, :files_tags].each do |tbl|
      @conn[tbl].delete
    end
  end

  it "should set the created_at when you make one" do
    file=Jam::File.create :path=>'test created_at'

    file.created_at.nil?.should==false
    file.updated_at.nil?.should==false
  end

  it "should set dirname and filename when you make one" do
    file=Jam::File.create :path=>'dir1/text.txt'
    file.dirname.should=="dir1"
    file.filename.should=="text.txt"
  end

  it "should not set dirname and filename when they're set explicitly" do
    file=Jam::File.create :path=>'dir1/text.txt', :dirname=>'foo', :filename=>'bar'
    file.dirname.should=="foo"
    file.filename.should=="bar"
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

  it "should have a working tagger for tags it already has" do
    ft1=@file.tag('test_tag','value1','agent1')

    ft1[:note].should=='value1'
    ft1[:tagged_by].should=='agent1'

    ft2=@file.tag('test_tag','value2','agent2')

    ft2[:note].should=='value2'
    ft2[:tagged_by].should=='agent1 agent2'
  end

  it "should have a working tags accessor" do
    @file.tag('foo',5,'agentname')

    @file.tags['foo'][:note].should=='5'
    @file.tags['foo'][:tagged_by].should==['agentname']

    @file.tags['foo'][:created_at].nil?.should==false
    @file.tags['foo'][:updated_at].nil?.should==false
  end
end

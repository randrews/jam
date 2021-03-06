require 'rubygems'
Jam::environment=:test

DIR=File.dirname(__FILE__)
require "#{DIR}/../jam.rb"

describe "options parser" do
  it "should recognize subcommands" do
    parse_options(["init"])[:command].should=='init'
  end

  it "should recognize --force and -f on init" do
    parse_options(["init", "--force"])[:command_opts][:force].should==true
    parse_options(["init", "-f"])[:command_opts][:force].should==true
    parse_options(["init"])[:command_opts][:force].should==false
  end

  it "should recognize add" do
    parse_options(["add"])[:command].should=='add'
  end

  it "should recognize params on tag" do
    opts=parse_options(["tag", "-n", "foo"])
    opts[:command].should=='tag'
    opts[:command_opts][:note].should =='foo'

    parse_options(["tag"])[:note].should be_nil
    
    opts2=parse_options(["tag", 'foo', '1', '2'])
    opts2[:targets].should==%w{foo 1 2}

    opts3=parse_options(["tag", 'foo', '-n', 'val', '1', '2'])
    opts3[:targets].should==%w{foo 1 2}
    opts3[:command_opts][:note].should == 'val'
  end

  it "should recognize query params on tag" do
    opts3=parse_options(["tag", '-d', 'tagname', '-q', 'other_tag<3'])
    opts3[:targets].should==%w{tagname}
    opts3[:command_opts][:query].should == 'other_tag<3'
  end

  it "should recognize delete flag on tag" do
    opts=parse_options(["tag", '-d', 'foo', '1', '2'])
    opts[:command_opts][:delete].should_not be_false

    opts2=parse_options(["tag", 'foo', '1', '2'])
    opts2[:command_opts][:delete].should be_false
  end

  it "should recognize the query on find" do
    opts=parse_options(["find", "a=3 or c"])
    opts[:targets].shift.should=="a=3 or c"
  end

  it "should recognize short commands" do
    opts=parse_options(["ignor"])
    opts[:command].should=="ignore"
  end

  it "should bail on unknown commands" do
    lambda{ parse_options(["kwyjibo"]) }.should raise_error
  end

  it "should bail if there's more than one matched command" do
    lambda{ parse_options(["i"]) }.should raise_error
  end

  it "should recognize a complete command even if there's another command that starts with that" do
    Jam.command_names["addstuff"]=:placeholder
    opts=parse_options(["add"])
    opts[:command].should=="add"    
    Jam.command_names.delete "addstuff"
  end
end

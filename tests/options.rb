require 'rubygems'

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
    opts[:command_opts][:note]=='foo'

    parse_options(["tag"])[:note].should be_nil
    
    opts2=parse_options(["tag", 'foo', '1', '2'])
    opts2[:targets].should==%w{foo 1 2}
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
end

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
end

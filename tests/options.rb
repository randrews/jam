require 'rubygems'

DIR=File.dirname(__FILE__)
require "#{DIR}/../jam.rb"

describe "options parser" do
  it "should recognize subcommands" do
    parse_options(["init"])[:command].should=='init'
  end
end

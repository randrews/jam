require 'rubygems'

require 'fileutils'
require 'pathname'

require 'trollop'
require 'sequel'
require 'dhaka'
require 'activesupport'

require 'ruby-debug' rescue nil
require 'ruby-prof' rescue nil

module Jam
  JAM_VERSION="0.0.1" unless const_defined? "JAM_VERSION"

  # The directory jam.rb is in, so we can look up global resources
  JAM_DIR=File.expand_path(File.dirname(__FILE__)) unless const_defined? "JAM_DIR"
end

Dir[Jam::JAM_DIR+"/lib/*.rb"].each do |file|
  require file
end

Dir[Jam::JAM_DIR+"/parser/*.rb"].each do |file|
  require file
end

Dir[Jam::JAM_DIR+"/commands/*.rb"].each do |file|
  require file
  Jam::register_command(file)
end

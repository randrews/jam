$startup_times=["#{$start_time=Time.now} Begin loading jam.rb"]

require 'abbrev'
require 'fileutils'
require 'pathname'
$startup_times << "#{Time.now-$start_time} Loaded Ruby APIs"

%w{rubygems trollop sequel ruby-prof set}.each do |gem|
  require gem
  $startup_times << "#{Time.now-$start_time} gem #{gem}"
end

module Jam
  JAM_VERSION="0.0.5" unless const_defined? "JAM_VERSION"

  # The directory jam.rb is in, so we can look up global resources
  JAM_DIR=File.expand_path(File.dirname(__FILE__)) unless const_defined? "JAM_DIR"
end

Dir[Jam::JAM_DIR+"/lib/*.rb"].each do |file|
  require file
end
$startup_times << "#{Time.now-$start_time} Loaded lib"

Dir[Jam::JAM_DIR+"/commands/*.rb"].each do |file|
  require file
  Jam::register_command(file)
end
$startup_times << "#{Time.now-$start_time} Loaded commands"

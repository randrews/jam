$startup_times=["#{$start_time=Time.now} Begin loading jam.rb"]

require 'fileutils'
require 'pathname'
$startup_times << "#{Time.now-$start_time} Loaded Ruby APIs"

%w{rubygems trollop sequel activesupport ruby-prof}.each do |gem|
  require gem
  $startup_times << "#{Time.now-$start_time} loaded #{gem}"
end

module Jam
  JAM_VERSION="0.0.1" unless const_defined? "JAM_VERSION"

  # The directory jam.rb is in, so we can look up global resources
  JAM_DIR=File.expand_path(File.dirname(__FILE__)) unless const_defined? "JAM_DIR"
end

Dir[Jam::JAM_DIR+"/lib/*.rb"].each do |file|
  require file
end
$startup_times << "Loaded lib #{Time.now-$start_time}"

Dir[Jam::JAM_DIR+"/commands/*.rb"].each do |file|
  require file
  Jam::register_command(file)
end
$startup_times << "Loaded commands #{Time.now-$start_time}"

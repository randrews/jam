require 'rubygems'
require 'activerecord'
require 'activesupport'
require 'trollop'

module JAM
  JAM_VERSION="0.0.1" unless const_defined? "JAM_VERSION"
end

Dir[File.dirname(__FILE__)+"/lib/*.rb"].each do |file|
  require file
end

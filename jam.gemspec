require 'rubygems'

SPEC=Gem::Specification.new do |s|
  s.name='jam'
  s.version='0.0.2'
  s.date='2009-06-20'
  s.author='Andrews, Ross'
  s.email='randrews@geekfu.org'
  s.homepage='http://geekfu.org'
  s.platform=Gem::Platform::RUBY
  s.summary="A file metadata organizer"

  s.files=Dir.glob("**/*")
  s.executables=["jam"]
  s.has_rdoc=false

  s.add_dependency("trollop",">= 1.10.2")
  s.add_dependency('sequel',">= 3.0.0")
  s.add_dependency('dhaka',">= 2.2.1")
end

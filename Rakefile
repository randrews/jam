require 'fileutils'

task :default => :test

task :clean do
  files=Dir["**/*~"]
  puts "Removing #{files.size} Emacs temp file#{(files.size==1?'':'s')}"
  files.each do |tmp|
    FileUtils.rm tmp
  end
end

task :test do
  exec "spec tests/*.rb"
end

task :parse do
  query=ENV['QUERY'] or 
    die "No query specified: try 'rake parse QUERY=\"whatever\"'"
  filename=ENV['FILENAME'] || 'parse.dot'

  require File.join(File.dirname(__FILE__),'jam.rb')

  File.open(filename, 'w') do |file| 
    file << Jam::QueryParser.parse(Jam::QueryLexer.lex(query)).to_dot
  end
end

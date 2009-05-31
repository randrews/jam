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

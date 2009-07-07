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
    raise "No query specified: try 'rake parse QUERY=\"whatever\"'"
  filename=ENV['FILENAME'] || 'parse.dot'

  require File.join(File.dirname(__FILE__),'jam.rb')

  tree = Jam::QueryParser.parse(Jam::QueryLexer.lex(query))
  puts Jam::QueryEvaluator.evaluate_tree(tree).text

  File.open(filename, 'w') do |file|
    file << tree.to_dot
  end
end

task :gem do
  `rm -f jam-*.gem`
  `gem build jam.gemspec`
end

task :install=>:gem do
  `gem install --force jam-*.gem`
end

task :profile do
  require 'rubygems'
  require 'ruby-prof'
  test_dir=File.join(File.dirname(__FILE__),'tests')

  result = RubyProf.profile do
    require File.join(File.dirname(__FILE__),'jam.rb')

    # Monkeypatch Dhaka because it's blowing up on parser.inspect.
    class Dhaka::CompiledParser ; def self.grammar ; "" ; end ; end

    if ENV['TEST']
      require File.join(test_dir,'#{test}.rb')
    elsif ENV['STARTUP']
      # nothing, just load jam.rb
    else
      Dir[File.join(test_dir,'*.rb')].each do |test|
        require test
      end
    end
  end

  # Print a graph profile to text
  printer = RubyProf::FlatPrinter.new(result)
  printer.print(STDOUT, 0)
end

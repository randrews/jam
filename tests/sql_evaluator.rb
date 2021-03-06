require "#{File.dirname(__FILE__)}/../jam.rb"
Jam::environment=:test

describe "find command" do
  before :all do
    @scratch_dir=verify_test_scratch_dir
    prep_test_tree @scratch_dir, 'simple_dir'
    Jam::InitCommand.run(@scratch_dir)
    Jam::AddCommand.run(@scratch_dir)

    Jam::File.at('one.txt').tag('tag1')
    Jam::File.at('one.txt').tag('tag2')
    Jam::File.at('dir1/three.txt').tag('tag3')

    Jam::File.at('two.txt').tag('tag2','foo')
    Jam::File.at('two.txt').tag('filename','one.txt')
  end

  after :all do
    remove_test_scratch_dir @scratch_dir
  end

  it "should find files" do
    Jam::SqlEvaluator.evaluate("tag1").result_paths.should==["one.txt"]
  end

  it "should find multiple files" do
    Jam::SqlEvaluator.evaluate("tag2").result_paths.should==["one.txt", "two.txt"]
  end

  it "should handle more complex queries" do
    Jam::SqlEvaluator.evaluate("tag3 or (tag2 and not tag2='foo')").result_paths.should==["dir1/three.txt", "one.txt"]
  end

  it "should parse sort clauses" do
    ev=Jam::SqlEvaluator.evaluate("tag1 sort(tag1 desc, id)")
    ev.sort_columns.should==[{:name=>:tag1, :type=>:tag, :direction=>:desc},
                             {:name=>:id, :type=>:field, :direction=>:asc}]
  end

  it "should parse a single sort clause" do
    ev=Jam::SqlEvaluator.evaluate("tag1 sort(filename asc)")
    ev.sort_columns.should==[{:name=>:filename, :type=>:field, :direction=>:asc}]
  end

  it "should allow no sort clauses" do
    ev=Jam::SqlEvaluator.evaluate("tag1")
    ev.sort_columns.should==[]
  end

  it "should be able to query by fields" do
    ev=Jam::SqlEvaluator.evaluate("filename='one.txt'")
    ev.result_paths.should==["one.txt"]
  end
end

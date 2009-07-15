require "#{File.dirname(__FILE__)}/../jam.rb"
Jam::environment=:test

describe "find command" do
  before :all do
    @scratch_dir=verify_test_scratch_dir
    prep_test_tree @scratch_dir, 'simple_dir'
    Jam::InitCommand.run(@scratch_dir)
    Jam::AddCommand.run(@scratch_dir)

    Jam::File.at('one.txt').tag('everything')
    Jam::File.at('two.txt').tag('everything')
    Jam::File.at('dir1/three.txt').tag('everything')
    Jam::File.at('dir1/dir2/four.txt').tag('everything')

    Jam::File.at('one.txt').tag('val_tag',2)
    Jam::File.at('two.txt').tag('val_tag',1)
    Jam::File.at('dir1/three.txt').tag('val_tag',4)
    Jam::File.at('dir1/dir2/four.txt').tag('val_tag',3)

    Jam::File.at('one.txt').tag('nulls',2)
    Jam::File.at('two.txt').tag('nulls')
    Jam::File.at('dir1/three.txt').tag('nulls',4)
    Jam::File.at('dir1/dir2/four.txt').tag('nulls')

    Jam::File.at('one.txt').tag('same',2)
    Jam::File.at('two.txt').tag('same',2)
    Jam::File.at('dir1/three.txt').tag('same',2)
    Jam::File.at('dir1/dir2/four.txt').tag('same',2)
  end

  after :all do
    remove_test_scratch_dir @scratch_dir
  end

  it "should sort a simple field clause" do
    ev=Jam::SqlEvaluator.evaluate("everything sort(.filename desc)")
    ev.result_files.map(&:filename).should==%w{two.txt three.txt one.txt four.txt}
  end

  it "should sort by a tag" do
    ev=Jam::SqlEvaluator.evaluate("everything sort(val_tag)")
    ev.result_files.map(&:filename).should==%w{two.txt one.txt four.txt three.txt}
  end

  it "should sort by two things at once" do
    ev=Jam::SqlEvaluator.evaluate("everything sort(@nulls desc, .filename)")
    # three and one both have nulls tag, so they go first, then the rest in ascending filename order
    ev.result_files.map(&:filename).should==%w{three.txt one.txt four.txt two.txt}
  end

  it "should sort two objects that are effectively equal" do
    lambda{ Jam::SqlEvaluator.evaluate("everything sort(same)").result_files.map(&:filename) }.should_not raise_error
  end
end

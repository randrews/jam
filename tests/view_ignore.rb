require "#{File.dirname(__FILE__)}/../jam.rb"
Jam::environment=:test

describe "view command ignores" do
  before :each do
    @scratch_dir=verify_test_scratch_dir
    @jam=prep_test_tree @scratch_dir, 'simple_dir' do |jam|
      jam["init"]
      jam["add dir1"]
      jam["tag tag2 dir1"]
    end
  end

  after :each do
    remove_test_scratch_dir @scratch_dir
  end

  it "should ignore things in views for other commands" do
    @jam["view my-view tag2"]
    @jam["add"]
    preserve_test_tree @scratch_dir, 'foo'
    Jam::db[:files].count.should==4
  end
end

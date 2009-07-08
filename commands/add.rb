class Jam::AddCommand < Jam::Command

  def run
    start=Time.now

    connect_to_db

    t=targets
    t=['.'] if t.empty?

    already_extant=Jam::connection[:files].select(:path).all.map{|r| r[:path]}.to_set
    current_block=[]
    max_block_size=1000
    count=0
    @threads ||= [] # The threads we'll spawn off to stick new files in

    to_targets t, "Adding files..." do |file, tgt|
      unless already_extant.include?(file)
        current_block << {:path=>file, :created_at=>Time.now, :updated_at=>Time.now}
        count+=1
      end

      if current_block.size >= max_block_size
        insert_block(current_block, already_extant)
        current_block=[]
      end
    end

    insert_block(current_block)

    @threads.each &:join

    duration=Time.now-start
    emit("Added #{count} files in #{duration} seconds")
  end

  private

  def insert_block block, extant=nil
    extant += block.map{|r| r[:path]} if extant
    @threads << Thread.new do
      Jam::connection[:files].multi_insert block
    end
  end

end

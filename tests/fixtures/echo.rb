class EchoCommand < Jam::Command
  def run
    emit(targets.shift)
  end
end

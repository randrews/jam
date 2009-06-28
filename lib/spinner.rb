module Jam::Spinner
  def with_spinner total=nil, message="Working...", &step
    current=0
    shown=buildstr(message,current,total)
    printf(shown)

    spin=Proc.new do
      clear(shown)
      current+=1
      shown=buildstr(message,current,total)
      printf(shown)
    end

    yield spin

    clear(shown)
    printf(" "*shown.length)
    clear(shown)
  end

  def spinner_test
    spinner max do |spin|
      (1..max).each do |n|
        spin.call 100
        sleep 0.05
      end
    end
    nil
  end

  private

  def clear str
    printf("\b"*str.length)
  end

  def buildstr message, current, total
    str="#{char(current)} #{message}"
    if total
      percent=(current*100.0/total).round
      str+=" #{percent}%"
    end
    str
  end

  def char n
    %w{/ - \\ |}[n%4]
  end
end

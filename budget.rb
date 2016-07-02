
require 'date'

class Bill
  def initialize(day, amount, desc)
    @day = day
    @amount = amount
    @desc = desc
  end
  def today(date)
    puts "#{@desc} #{@amount}" if (date.mday==@day)
    ((date.mday==@day) ? @amount : 0)
  end
end

class Budget
  attr_accessor :balance, :events
  def initialize(initial_balance)
    @balance = initial_balance
    @events = []
  end
  def day_of_month(day, amount, desc)
    @events << Bill.new(day, amount, desc)
  end
  def payday(date, amount)
    @first_payday = date
    @pay = amount
  end
  def future(days)
    File.open('budget.dat','w') do |tec|
    File.open('budget.m','w') do |f|
      f.puts "#!/usr/bin/env octave"
      f.puts "db=["
      date = Date.today
      balance = @balance
      days.times do |day|
        last_balance = balance
        @events.each do |event|
          balance += event.today(date)
        end

        if ( @first_payday ) then
          delta = date.yday - @first_payday.yday
          if ( 0 == delta.remainder(14) ) 
            balance += @pay 
            puts "pay #{@pay}"
          end
        end
        if (last_balance != balance)
          puts [date.to_s, balance.to_s].join(' : ')
          f.puts [date.jd-Date.today.jd, balance.to_s].join(' , ')+" % oct"        
          tec.puts [date.jd-Date.today.jd, balance.to_s].join(' ')
        end
        date = date.next
      end
      f.puts "];"
      f.puts "plot(db(:,1),db(:,2))"
      f.puts "print -deps budget.eps"
      f.puts "system('epstopdf budget.eps')"      
    end
    end
    `octave -q budget.m`
  end
end

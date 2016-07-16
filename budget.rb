
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

class Payday
  def initialize(first_date, amount, desc)
    @first_date = first_date
    @amount = amount
    @desc = desc
  end
  def today(date)
    delta = date.mjd - @first_date.mjd
    puts "#{@desc} #{@amount}" if (0 == delta.remainder(14))
    ((0 == delta.remainder(14)) ? @amount : 0)
  end
end

class Budget
  attr_accessor :balance, :events
  def initialize(initial_balance)
    @balance = initial_balance
    @events = []
    @paydays = []
  end
  def day_of_month(day, amount, desc)
    @events << Bill.new(day, amount, desc)
  end
  def biweekly_from(date, amount, desc)
    @paydays << Payday.new(date, amount, desc)
  end
  def future(days, dat_file_name = 'budget.dat')
    File.open(dat_file_name,'w') do |tec|
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
          
          @paydays.each do |payday|
            balance += payday.today(date)
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
    #    `octave -q budget.m`
  end
end

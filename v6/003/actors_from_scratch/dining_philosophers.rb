require "pry"

require_relative '../lib/actors'
require_relative "../lib/chopstick"
require_relative "../lib/table"

class Philosopher
  include Actor

  def initialize(name)
    @name = name
  end

  def dine(table, position, waiter)
    @waiter = waiter

    @left_chopstick  = table.left_chopstick_at(position)
    @right_chopstick = table.right_chopstick_at(position)

    think
  end

  def think
    puts "#{@name} is thinking."
    #sleep(rand)

    @waiter.async.request_to_eat(Actor.current)
  end

  def eat
    take_chopsticks

    puts "#{@name} is eating."
    #sleep(rand)

    drop_chopsticks

    @waiter.async.done_eating(Actor.current)

    think
  end

  def take_chopsticks
    puts "#{@name} try to take the left chopstick."
    @left_chopstick.take
    puts "L #{@name} takes the left chopstick."
    puts "#{@name} try to take the right chopstick."
    @right_chopstick.take
    puts "R #{@name} takes the right chopstick."
  end

  def drop_chopsticks
    @left_chopstick.drop
    puts "DL #{@name} drops the left chopstick."
    @right_chopstick.drop
    puts "DR #{@name} drops the right chopstick."
  end
end

class Waiter
  include Actor

  def initialize
    @eating = []
  end

  def request_to_eat(philosopher)
    #binding.pry
    return if @eating.include?(philosopher)

    @eating << philosopher

    philosopher.async.eat
  end

  def done_eating(philosopher)
    @eating.delete(philosopher)
  end
end

names = %w{Heraclitus Aristotle}

philosophers = names.map { |name| Philosopher.new(name) }

waiter = Waiter.new
table = Table.new(philosophers.size)

philosophers.each_with_index do |philosopher, i| 
  philosopher.async.dine(table, i, waiter) 
end

sleep

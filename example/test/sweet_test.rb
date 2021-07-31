CLASS_COUNT = 10
TEST_COUNT = 10

executions = []
at_exit do
  # Everything runs
  if CLASS_COUNT * TEST_COUNT != executions.size
    raise "Expected #{CLASS_COUNT * TEST_COUNT} tests to run but was #{executions.size}"
  end

  suite_order = executions.each_with_object([]) { |exe, memo|
    memo << exe[:suite] unless memo.last == exe[:suite]
  }
  if suite_order.uniq.sort != suite_order.sort
    raise "Expected each suite to be run contiguously, but was not. Actual suite execution order was: #{suite_order}"
  end

  puts "Run order:"
  executions.each.with_index do |execution, i|
    puts "#{i + 1}. #{execution[:suite]}: #{execution[:class]}##{execution[:method]}"
  end
end

require "minitest/suite"
require "minitest/autorun"

CLASS_COUNT.times do |i|
  class_name = "TestCase#{i}"
  Object.const_set(class_name, Class.new(Minitest::Test) {
    if i <= 2
      suite_name = :zeroonetwo
      suite :zeroonetwo
    elsif i <= 5
      suite_name = :threefourfive
      suite :threefourfive
    elsif i <= 7
      suite_name = :sixseven
      Minitest::Suite.register(suite_name: :sixseveneight, test_class: self)
    else
      suite_name = :unsuitened
    end

    TEST_COUNT.times do |j|
      method_name = "test_#{j}"
      define_method "test_#{j}" do
        executions << {
          class: class_name,
          method: method_name,
          suite: suite_name
        }
      end
    end
  })
end

class Pumpkin < Minitest::Test
  suite :veggie
  def test_it() = puts("🎃")
end

class Pear < Minitest::Test
  suite :fruit
  def test_it() = puts("🍐")
end

class Pepper < Minitest::Test
  suite :veggie
  def test_it() = puts("🌶")
end

class Apple < Minitest::Test
  suite :fruit
  def test_it() = puts("🍎")
end

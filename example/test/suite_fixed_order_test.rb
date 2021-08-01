module Exe
  def self.cution(exe)
    @executions ||= []
    @executions << exe
  end

  def self.cutions
    @executions || []
  end
end

at_exit do
  expected = Minitest::Suite.order
  expected_index = 0

  Exe.cutions.each.with_index do |suite, actual_index|
    finished_suites = expected_index == 0 ? [] : expected[0..(expected_index - 1)]

    if finished_suites.include?(suite)
      raise <<~MSG
        Ensuring order #{expected.inspect} but #{suite.inspect} test was just run
        out of order. Actual execution order:

        #{Exe.cutions.map(&:inspect).join("\n")}
      MSG
    elsif suite == expected[expected_index]
      # cool
    else
      expected_index += 1
    end
  end
end

require "minitest/suite"
require "minitest/autorun"

Minitest::Suite.order = ENV["ORDER"].split(",").map(&:to_sym)

class Test1 < Minitest::Test
  suite :suite1

  def test_it
    Exe.cution :suite1
  end
end

class Test2 < Minitest::Test
  suite :suite2

  def test_it
    Exe.cution :suite2
  end
end

class Test3 < Minitest::Test
  suite :suite3

  def test_it
    Exe.cution :suite3
  end
end

class Test4 < Minitest::Test
  def test_it
    Exe.cution :unsuitened
  end
end

class Test5 < Minitest::Test
  suite :suite1

  def test_it
    Exe.cution :suite1
  end
end

class Test6 < Minitest::Test
  suite :suite2

  def test_it
    Exe.cution :suite2
  end
end

class Test7 < Minitest::Test
  suite :suite3

  def test_it
    Exe.cution :suite3
  end
end

class Test8 < Minitest::Test
  def test_it
    Exe.cution :unsuitened
  end
end

class Test9 < Minitest::Test
  suite :suite1

  def test_it
    Exe.cution :suite1
  end
end

class Test10 < Minitest::Test
  suite :suite2

  def test_it
    Exe.cution :suite2
  end
end

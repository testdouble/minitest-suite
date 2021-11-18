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

Minitest::Suite.order = [:model, :weird, :controller]

class ModelTest < Minitest::Test
  suite :model
end

class SomeModel < ModelTest
  def test_it
    Exe.cution :model
  end
end

class OtherModel < ModelTest
  def test_it
    Exe.cution :model
  end
end

class DeepModelTest < ModelTest
end

class OtherOtherModel < DeepModelTest
  def test_it
    Exe.cution :model
  end
end

class WeirdModel < ModelTest
  suite :weird

  def test_it
    Exe.cution :weird
  end
end

class Controller < Minitest::Test
  suite :controller
end

class DeepController < Controller
end

class OneController < Controller
  def test_it
    Exe.cution :controller
  end
end

class TwoController < Controller
  def test_it
    Exe.cution :controller
  end
end

class ThreeController < DeepController
  def test_it
    Exe.cution :controller
  end
end

class WeirdController < Controller
  suite :weird

  def test_it
    Exe.cution :weird
  end
end

class NoSuite < Minitest::Test
  def test_it
    Exe.cution :no_suite
  end
end

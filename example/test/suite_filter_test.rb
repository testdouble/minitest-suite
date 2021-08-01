def assert_good_only_run(suites, bad)
  unless bad.empty?
    raise <<~MSG
      Expected to only run #{suites.inspect}, but these suites ran and shouldn't have:

      #{bad.join("\n")}
    MSG
  end
end

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
  if (setting = ENV["MINITEST_SUITE_ONLY"])
    suites = setting.gsub(/\s+/, "").split(",").map(&:to_sym)
    bad = Exe.cutions.reject { |exe| suites.include?(exe) }
    assert_good_only_run(suites, bad)
  elsif (setting = ENV["MINITEST_SUITE_EXCEPT"])
    suites = setting.gsub(/\s+/, "").split(",").map(&:to_sym)
    bad = Exe.cutions.select { |exe| suites.include?(exe) }
    assert_good_only_run(suites, bad)
  end
end

require "minitest/suite"
require "minitest/autorun"

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

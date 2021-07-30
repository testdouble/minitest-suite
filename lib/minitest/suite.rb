require_relative "suite/version"
require "minitest"

module Minitest
  module Suite
    class Error < StandardError; end

    Thread.current[:minitest_suites] = {}

    def self.register(suite_name:, test_class:)
      raise Error.new("suite_name must be a symbol") unless suite_name.is_a?(Symbol)
      raise Error.new("test_class must be a Minitest::Test") unless test_class.ancestors.include?(Minitest::Test)
    end
  end
end

module Minitest
  class Test < Runnable
    def self.suite(suite_name)
      Minitest::Suite.register(suite_name: suite_name, test_class: self)
    end
  end
end

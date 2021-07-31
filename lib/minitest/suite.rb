require_relative "suite/version"
require "minitest"

module Minitest
  module Suite
    class Error < StandardError; end

    def self.register(suite_name:, test_class:)
      raise Error.new("suite_name must be a Symbol") unless suite_name.is_a?(Symbol)
      raise Error.new("test_class must be a Minitest::Test") unless test_class.ancestors.include?(Minitest::Test)
      if (conflicting_suite_name = (suites.keys - [suite_name]).find { |suite_name| suites[suite_name].include?(test_class) })
        raise Error.new("#{test_class.name || "Class"} is already registered to the #{conflicting_suite_name.inspect} suite")
      end
      suites[suite_name] = (suites[suite_name] + [test_class]).uniq
    end

    def self.suites
      Thread.current[:minitest_suites] || reset
    end

    def self.reset
      Thread.current[:minitest_suites] = Hash.new { [] }
    end

    class PartialArrayProxy < Array
      def shuffle
        suites = (Suite.suites.keys + [:unsuitened]).shuffle
        suites.flat_map { |suite|
          if suite == :unsuitened
            (self - Suite.suites.values.flatten).shuffle
          else
            Suite.suites[suite].shuffle
          end
        }
      end

      def reject
        self.class.new(super)
      end
    end
  end
end

module Minitest
  class Test < Runnable
    def self.suite(suite_name)
      Minitest::Suite.register(suite_name: suite_name, test_class: self)
    end
  end

  class Runnable
    class << self
      undef_method :runnables
      define_method :runnables do
        return @@runnables if @@runnables.is_a?(Minitest::Suite::PartialArrayProxy)
        @@runnables = Minitest::Suite::PartialArrayProxy.new(@@runnables)
      end
    end
  end
end

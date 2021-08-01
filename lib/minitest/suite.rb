require "minitest"
require_relative "suite/version"

module Minitest
  module Suite
    class Error < StandardError; end
    Registration = Struct.new(:suite, :test, keyword_init: true)

    def self.register(suite_name:, test_class:)
      if !suite_name.is_a?(Symbol)
        raise Error.new("suite_name must be a Symbol")
      elsif !test_class.ancestors.include?(Minitest::Test)
        raise Error.new("test_class must be a Minitest::Test")
      elsif (conflict = registrations.find { |r| r.test == test_class && r.suite != suite_name })
        raise Error.new("#{conflict.test.name || "Class"} is already registered to the #{conflict.suite.inspect} suite")
      elsif registrations.none? { |r| r.test == test_class && r.suite == suite_name }
        registrations << Registration.new(suite: suite_name, test: test_class)
      end
    end

    def self.registrations
      Thread.current[:minitest_suites] || reset
    end

    def self.reset
      Thread.current[:minitest_suites] = []
    end

    class PartialArrayProxy < Array
      def shuffle
        suites = (Suite.registrations.map(&:suite).uniq + [:unsuitened]).shuffle
        suites.flat_map { |suite|
          if suite == :unsuitened
            (self - Suite.registrations.map(&:test)).shuffle
          else
            Suite.registrations.select { |r| r.suite == suite }.map(&:test).shuffle
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

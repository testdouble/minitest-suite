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
      @@registrations ||= reset
    end

    def self.reset
      @@registrations = []
    end

    def self.filter_runnables(runnables)
      if (only = ENV["MINITEST_SUITE_ONLY"])
        suites = only.gsub(/\s+/, "").split(",").map(&:to_sym)
        selected_tests = registrations.select { |r| suites.include?(r.suite) }
          .map(&:test)
        runnables.select { |r| selected_tests.include?(r) }
      elsif (except = ENV["MINITEST_SUITE_EXCEPT"])
        suites = except.gsub(/\s+/, "").split(",").map(&:to_sym)
        excepted_tests = registrations.select { |r| suites.include?(r.suite) }
          .map(&:test)
        runnables.reject { |r| excepted_tests.include?(r) }
      else
        runnables
      end
    end

    class PartialArrayProxy < Array
      def shuffle
        filtered = Suite.registrations.select { |r| include?(r.test) }
        suites = (filtered.map(&:suite).uniq + [:__unsuitened]).shuffle
        suites.flat_map { |suite|
          if suite == :__unsuitened
            (self - filtered.map(&:test)).shuffle
          else
            filtered.select { |r| r.suite == suite }.map(&:test).shuffle
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
        filtered = Minitest::Suite.filter_runnables(@@runnables)
        if @@runnables.is_a?(Minitest::Suite::PartialArrayProxy) &&
            filtered == @runnables
          @@runnables
        else
          @@runnables = Minitest::Suite::PartialArrayProxy.new(filtered)
        end
      end
    end
  end
end

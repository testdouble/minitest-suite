require "test_helper"

class Minitest::SuiteTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Minitest::Suite::VERSION
  end

  def test_that_registration_requires_a_symbol_name
    # does not raise
    Minitest::Suite.register(suite_name: :foobar, test_class: Class.new(Minitest::Test))

    # does raise
    assert_raises(Minitest::Suite::Error) {
      Minitest::Suite.register(suite_name: "foobar", test_class: Class.new(Minitest::Test))
    }
  end

  def test_that_registration_requires_a_minitest
    # does not raise
    Minitest::Suite.register(suite_name: :foobar, test_class: Class.new(Minitest::Test))

    # does raise
    assert_raises(Minitest::Suite::Error) {
      Minitest::Suite.register(suite_name: :foobar, test_class: Class.new)
    }
  end
end

require "test_helper"

class Minitest::SuiteTest < Minitest::Test
  def teardown
    Minitest::Suite.reset
  end

  def test_that_it_has_a_version_number
    refute_nil ::Minitest::Suite::VERSION
  end

  def test_that_registration_requires_a_symbol_name
    # does not raise
    Minitest::Suite.register(suite_name: :foobar, test_class: Class.new(Minitest::Test))

    # does raise
    e = assert_raises(Minitest::Suite::Error) do
      Minitest::Suite.register(suite_name: "foobar", test_class: Class.new(Minitest::Test))
    end
    assert_equal "suite_name must be a Symbol", e.message
  end

  def test_that_registration_requires_a_minitest
    # does not raise
    Minitest::Suite.register(suite_name: :foobar, test_class: Class.new(Minitest::Test))

    # does raise
    e = assert_raises(Minitest::Suite::Error) do
      Minitest::Suite.register(suite_name: :foobar, test_class: Class.new)
    end
    assert_equal "test_class must be a Minitest::Test", e.message
  end

  class B < Minitest::Test
  end

  def test_that_multiple_conflicting_registrations_arent_made
    a = Class.new(Minitest::Test)
    c = Class.new(Minitest::Test)
    Minitest::Suite.register(suite_name: :foobar, test_class: a)
    Minitest::Suite.register(suite_name: :foobar, test_class: B)
    Minitest::Suite.register(suite_name: :bizbaz, test_class: c)
    e = assert_raises(Minitest::Suite::Error) do
      Minitest::Suite.register(suite_name: :bizbaz, test_class: B)
    end
    assert_equal "Minitest::SuiteTest::B is already registered to the :foobar suite", e.message
  end

  def test_dedupes
    a = Class.new(Minitest::Test)
    b = Class.new(Minitest::Test)
    Minitest::Suite.register(suite_name: :foobar, test_class: a)
    Minitest::Suite.register(suite_name: :foobar, test_class: b)
    Minitest::Suite.register(suite_name: :foobar, test_class: b)
    Minitest::Suite.register(suite_name: :foobar, test_class: b)
    Minitest::Suite.register(suite_name: :foobar, test_class: b)

    assert_equal [a, b], Minitest::Suite.registrations.select { |r| r.suite == :foobar }.map(&:test)
  end

  def test_order_is_symbols
    Minitest::Suite.order = [:a, :b]
    e = assert_raises(Minitest::Suite::Error) {
      Minitest::Suite.order = ["alpha"]
    }
    assert_equal "Minitest::Suite.order must be an array of Symbol suite names", e.message
    assert_raises(Minitest::Suite::Error) { Minitest::Suite.order = "beta" }
  end
end

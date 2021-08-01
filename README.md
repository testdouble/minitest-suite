# minitest-suite

The minitest-suite gem modifies the way
[Minitest](https://github.com/seattlerb/minitest) shuffles the order in which
`Minitest::Test` subclasses are run by allowing you to organize them into
sub-suites or groups.

This can be handy when you want to (usually for performance reasons) run
one logical grouping of tests at a time before moving onto the next group.

## Using minitest-suite

### Install and setup

Add the gem to your `Gemfile`:

```ruby
gem "minitest-suite"
```

And then require the gem near the top of your test helper:

```ruby
require "minitest/suite"
```

### Declaring suites

Just pass a suite name to `suite` in the class body of each
test to group that test with others of the same named suite:

```ruby
class SweetTest < Minitest::Test
  suite :sugary

  def test_blood_sugar
    #
  end
end
```

Normally, Minitest will shuffle the order of all your test classes. But if
`minitest-suite` is loaded, your tests will be grouped by any suites you've
defined: your suites will be shuffled first, then the test classes within each
of those suites will be shuffled.

For example, suppose you have 4 test classes, two fruits and two vegetables:

```ruby
class Broccoli < Minitest::Test
  suite :veggie
  def test_it() = puts("🥦")
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
```

By declaring their `suite` above, you're guaranteed the two fruits will run next
to each other and the two vegetables will run next to each other (even though
the order will still be randomized):

```
# Running:

🍐
.🍎
.🥦
.🌶
.
```

To wit, the above strategy will ensure you'd never see this test order:
🍐,🌶,🍎,🥦.

Looking for more? Check out this repo's [example
test](/example/test/sweet_test.rb).

### Configuration

Since you're going to the trouble of organizing your tests into logical suites,
you may as well have a little additional control over which suites run and in
what order. Below are a few handy things you can do once you're set up.

#### Filter to run only certain test suites

If you want to run only tests belonging to a certain suite or set of suites,
just set the environment variable `MINITEST_SUITE_ONLY` to a comma-delimited
string of suite names to run:

```
$ MINITEST_SUITE_ONLY="unit,model" bin/rake test
```

When using this option, note that test classes that _don't_ call `suite` **will
not be run**.

#### Run all tests except certain suites

If there's a suite of tests you don't want to run, set the environment variable
`MINITEST_SUITE_EXCEPT` to a comma-delimited string of suite names to skip:

```
$ MINITEST_SUITE_EXCEPT="integration,browser" bin/rake test
```

When using this option, note that test classes that _don't_ call `suite` **will
be run**.

## Code of Conduct

This project follows Test Double's [code of
conduct](https://testdouble.com/code-of-conduct) for all community interactions,
including (but not limited to) one-on-one communications, public posts/comments,
code reviews, pull requests, and GitHub issues. If violations occur, Test Double
will take any action they deem appropriate for the infraction, up to and
including blocking a user from the organization's repositories.


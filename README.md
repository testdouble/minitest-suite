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
class Pumpkin < Minitest::Test
  suite :veggie
  def test_it() = puts("🎃")
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
.🎃
.🌶
.
```

To wit, the above strategy will ensure you'd never see this test order:
🍐,🌶,🍎,🎃.

Looking for more? Check out this repo's [example
test](/example/test/sweet_test.rb).

## Code of Conduct

This project follows Test Double's [code of
conduct](https://testdouble.com/code-of-conduct) for all community interactions,
including (but not limited to) one-on-one communications, public posts/comments,
code reviews, pull requests, and GitHub issues. If violations occur, Test Double
will take any action they deem appropriate for the infraction, up to and
including blocking a user from the organization's repositories.


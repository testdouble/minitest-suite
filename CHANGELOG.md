# 0.0.3

- Adds support for inheriting a suite from a parent type (e.g. a ModelTest that
  sets `suite :model` will pass on that suite to its descendant tests unless
  they override it with a different suite).

# 0.0.2

- Adds Minitest::Suite.order= for specifying initial suite order
- Adds MINITEST_SUITE_ONLY and MINITEST_SUITE_EXCEPT options

# 0.0.1

- initial release

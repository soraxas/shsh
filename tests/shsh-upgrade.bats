#!/usr/bin/env bats

load test_helper

@test "without arguments shows usage" {
  run shsh-upgrade
  assert_failure
  assert_line "Usage: shsh upgrade <package>"
}

@test "with invalid argument, shows usage" {
  run shsh-upgrade lol
  assert_failure
  assert_line "Usage: shsh upgrade <package>"
}

@test "with too many arguments, shows usage" {
  run shsh-upgrade a/b wrong
  assert_failure
  assert_line "Usage: shsh upgrade <package>"
}

@test "upgrades a package to the latest version" {
  mock_clone
  create_package username/package
  shsh-install username/package
  create_exec username/package "second"

  shsh-upgrade username/package

  run shsh-outdated
  assert_output ""
}

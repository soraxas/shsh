#!/usr/bin/env bats

load test_helper

@test "without arguments shows usage" {
  run shsh-upgrade
  assert_failure
  assert_line --partial "Usage: shsh upgrade "
}

@test "with invalid argument, shows usage" {
  run shsh-upgrade lol/lol/lol
  assert_failure
  assert_line --partial "cannot has more than 2 subfolders"
}

@test "with too many arguments, shows usage" {
  run shsh-upgrade a/b wrong
  assert_failure
  assert_line --partial "Usage: shsh upgrade "
}

@test "upgrades a package to the latest version" {
  mock_clone
  create_package username/package
  shsh-install username/package
  create_exec username/package "second"

  shsh-upgrade username/package

  run shsh-outdated --quiet
  assert_output ""
}

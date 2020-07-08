#!/usr/bin/env bats

load test_helper

@test "without arguments, prints usage" {
  run shsh-_deps

  assert_failure
  assert_line --partial "shsh _deps"
}

@test "without dependencies, does nothing" {
  mock_clone
  mock_command shsh-install
  create_package "user/main"
  shsh-_clone false site user/main

  run shsh-_deps user/main

  assert_success ""
}

@test "installs dependencies" {
  mock_clone
  mock_command shsh-install
  create_package "user/main"
  create_dep "user/main" "user/dep1"
  create_dep "user/main" "user/dep2"
  shsh-_clone false site user/main

  run shsh-_deps user/main

  assert_success
  assert_line "shsh-install user/dep1"
  assert_line "shsh-install user/dep2"
}

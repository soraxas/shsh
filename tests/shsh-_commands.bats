#!/usr/bin/env bats

load test_helper

@test "without arguments prints usage" {
  run shsh-_commands
  assert_failure
  assert_line "Usage: shsh _commands <package>"
}

@test "lists commands" {
  run shsh-_commands shsh
  assert_success
  assert_line init
  assert_line help
  assert_line commands
}

@test "does not list hidden commands" {
  run shsh-_commands shsh
  assert_success
  refute_line _commands
}

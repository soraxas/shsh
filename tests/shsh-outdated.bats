#!/usr/bin/env bats

load test_helper

@test "displays nothing if there are no packages" {
  run shsh-outdated
  assert_success
  assert_output ""
}

@test "displays outdated packages" {
  mock_clone
  create_package username/outdated
  create_package username/uptodate
  shsh-install username/outdated
  shsh-install username/uptodate
  create_exec username/outdated "second"

  run shsh-outdated --quiet
  assert_success
  assert_output username/outdated
}

@test "ignore packages checked out with a tag or ref" {
  mock_clone
  create_package username/tagged
  shsh-install username/tagged

  create_command git 'if [ "$1" = "symbolic-ref" ]; then exit 128; fi'

  run shsh-outdated --quiet
  assert_success
  assert_output ""
}

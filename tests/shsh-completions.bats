#!/usr/bin/env bats

load test_helper

@test "command with no completion support" {
  create_command "shsh-hello" "#!$BASH
    echo hello"
  run shsh-completions hello
  assert_success ""
}

@test "command with completion support" {
  create_command "shsh-hello" "#!$BASH
# TAG completions
if [[ \$1 = --complete ]]; then
  echo hello
else
  exit 1
fi"
  run shsh-completions hello
  assert_success "hello"
}

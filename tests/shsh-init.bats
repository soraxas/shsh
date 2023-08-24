#!/usr/bin/env bats

load test_helper

@test "without enough arguments, prints a useful message" {
  run shsh-init
  assert_failure
  assert_line --partial "Usage: "
}

@test "exports SHSH_ROOT" {
  SHSH_ROOT=/lol run shsh-init bash
  assert_success
  assert_line -n 0 'export SHSH_ROOT="/lol"'
}

@test "exports SHSH_PREFIX" {
  SHSH_PREFIX=/lol run shsh-init bash
  assert_success
  assert_line 'export SHSH_PREFIX="/lol"'
}

@test "exports SHSH_PACKAGES_PATH" {
  SHSH_PACKAGES_PATH=/lol/packages run shsh-init bash
  assert_success
  assert_line 'export SHSH_PACKAGES_PATH="/lol/packages"'
}

@test "adds cellar/bin to path" {
  run shsh-init bash
  assert_success
  assert_line 'export PATH="$SHSH_ROOT/cellar/bin:$PATH"'
}

@test "setup include function if it exists" {
  run shsh-init bash
  assert_line '. "$SHSH_ROOT/lib/include.bash"'
}

@test "setup shsh completions if available" {
  run shsh-init bash
  assert_success
  assert_line '. "$SHSH_ROOT/completions/shsh.bash"'
}

@test "doesn't setup include function if it doesn't exist" {
  run shsh-init fakesh
  refute_line 'source "$SHSH_ROOT/lib/include.fakesh"'
}

@test "does not setup shsh completions if not available" {
  run shsh-init fakesh
  assert_success
  refute_line 'source "$SHSH_ROOT/completions/shsh.fakesh"'
  refute_line 'source "$SHSH_ROOT/completions/shsh.other"'
}

hasShell() {
  which "$1" >>/dev/null 2>&1
}

@test "is sh-compatible" {
  hasShell sh || skip "sh was not found in path."
  run sh -ec 'eval "$(shsh init sh)"'
  assert_success
}

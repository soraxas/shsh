#!/usr/bin/env bats

load test_helper

@test "without enough arguments, prints a useful message" {
  run shsh-init -
  assert_failure
  assert_output "echo 'shsh init usage has changed, please specify the name of your shell as an argument:

eval \"\$(shsh init - bash)\" # or zsh, fish, sh etc

For more information, check this PR: https://github.com/shshpm/shsh/pull/77
'"
}

@test "exports SHSH_ROOT" {
  SHSH_ROOT=/lol run shsh-init - bash
  assert_success
  assert_line -n 1 'export SHSH_ROOT=/lol'
}

@test "exports SHSH_PREFIX" {
  SHSH_PREFIX=/lol run shsh-init - bash
  assert_success
  assert_line -n 2 'export SHSH_PREFIX=/lol'
}

@test "exports SHSH_PACKAGES_PATH" {
  SHSH_PACKAGES_PATH=/lol/packages run shsh-init - bash
  assert_success
  assert_line -n 3 'export SHSH_PACKAGES_PATH=/lol/packages'
}

@test "adds cellar/bin to path" {
  run shsh-init - bash
  assert_success
  assert_line -n 4 'export PATH="$SHSH_ROOT/cellar/bin:$PATH"'
}

@test "setup include function if it exists" {
  run shsh-init - bash
  assert_line -n 5 '. "$SHSH_ROOT/lib/include.bash"'
}

@test "doesn't setup include function if it doesn't exist" {
  run shsh-init - fakesh
  refute_line 'source "$SHSH_ROOT/lib/include.fakesh"'
}

@test "setup shsh completions if available" {
  run shsh-init - bash
  assert_success
  assert_line -n 6 '. "$SHSH_ROOT/completions/shsh.bash"'
}

@test "does not setup shsh completions if not available" {
  run shsh-init - fakesh
  assert_success
  refute_line 'source "$SHSH_ROOT/completions/shsh.fakesh"'
  refute_line 'source "$SHSH_ROOT/completions/shsh.other"'
}

@test "setup package completions (bash)" {
  run shsh-init - bash
  assert_success
  assert_line -n 7 'for f in $(command ls "$SHSH_ROOT/cellar/completions/bash"); do source "$SHSH_ROOT/cellar/completions/bash/$f"; done'
}

@test "setup package completions (zsh)" {
  run shsh-init - zsh
  assert_success
  assert_line -n 7 'fpath=("$SHSH_ROOT/cellar/completions/zsh/compsys" $fpath)'
  assert_line -n 8 'for f in $(command ls "$SHSH_ROOT/cellar/completions/zsh/compctl"); do source "$SHSH_ROOT/cellar/completions/zsh/compctl/$f"; done'
}

hasShell() {
  which "$1" >>/dev/null 2>&1
}

@test "is sh-compatible" {
  hasShell sh || skip "sh was not found in path."
  run sh -ec 'eval "$(shsh init - sh)"'
  assert_success
}

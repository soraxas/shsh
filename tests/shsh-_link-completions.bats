#!/usr/bin/env bats

load test_helper

@test "links bash completions to prefix/completions" {
  create_package username/package
  create_bash_completions username/package comp.bash
  mock_clone
  shsh-_clone false site username/package

  run shsh-_link-completions username/package

  assert_success
  assert [ "$(readlink $SHSH_PREFIX/completions/bash/comp.bash)" = "${SHSH_PACKAGES_PATH}/username/package/completions/comp.bash" ]
}

@test "links zsh compsys completions to prefix/completions" {
  create_package username/package
  create_zsh_compsys_completions username/package _exec
  mock_clone
  shsh-_clone false site username/package

  run shsh-_link-completions username/package

  assert_success
  assert [ "$(readlink $SHSH_PREFIX/completions/zsh/compsys/_exec)" = "${SHSH_PACKAGES_PATH}/username/package/completions/_exec" ]
}

@test "links zsh compctl completions to prefix/completions" {
  create_package username/package
  create_zsh_compctl_completions username/package exec
  mock_clone
  shsh-_clone false site username/package

  run shsh-_link-completions username/package

  assert_success
  assert [ "$(readlink $SHSH_PREFIX/completions/zsh/compctl/exec)" = "${SHSH_PACKAGES_PATH}/username/package/completions/exec" ]
}

@test "does not fail if package doesn't have any completions" {
  create_package username/package
  mock_clone
  shsh-_clone false site username/package

  run shsh-_link-completions username/package

  assert_success
}

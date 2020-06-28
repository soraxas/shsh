#!/usr/bin/env bats

load test_helper

@test "unlinks bash completions from prefix/completions" {
  create_package username/package
  create_bash_completions username/package comp.bash
  mock_clone
  shsh-install username/package

  run shsh-_unlink-completions username/package
  assert_success
  assert [ ! -e "$($SHSH_PREFIX/completions/bash/comp.bash)" ]
}

@test "unlinks zsh compsys completions from prefix/completions" {
  create_package username/package
  create_zsh_compsys_completions username/package _exec
  mock_clone
  shsh-install username/package

  run shsh-_unlink-completions username/package
  assert_success
  assert [ ! -e "$(readlink $SHSH_PREFIX/completions/zsh/compsys/_exec)" ]
}

@test "unlinks zsh compctl completions from prefix/completions" {
  create_package username/package
  create_zsh_compctl_completions username/package exec
  mock_clone
  shsh-install username/package

  run shsh-_unlink-completions username/package
  assert_success
  assert [ ! -e "$(readlink $SHSH_PREFIX/completions/zsh/compctl/exec)" ]
}

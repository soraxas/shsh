#!/usr/bin/env bats

load test_helper

@test "removes each man page from the install-man" {
  create_package username/package
  create_man username/package exec.1
  create_man username/package exec.2
  mock_clone
  shsh-install username/package

  run shsh-_unlink-man username/package
  assert_success
  assert [ ! -e "$(readlink $SHSH_INSTALL_MAN/man1/exec.1)" ]
  assert [ ! -e "$(readlink $SHSH_INSTALL_MAN/man2/exec.2)" ]
}

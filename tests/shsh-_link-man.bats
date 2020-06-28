#!/usr/bin/env bats

load test_helper

@test "links each man page to install-man under correct subdirectory" {
  create_package username/package
  create_man username/package exec.1
  create_man username/package exec.2
  mock_clone
  shsh-_clone false site username/package

  run shsh-_link-man username/package
echo "$output"
  assert_success
  assert [ "$(readlink $SHSH_INSTALL_MAN/man1/exec.1)" = "${SHSH_PACKAGES_PATH}/username/package/man/exec.1" ]
  assert [ "$(readlink $SHSH_INSTALL_MAN/man2/exec.2)" = "${SHSH_PACKAGES_PATH}/username/package/man/exec.2" ]
}

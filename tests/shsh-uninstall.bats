#!/usr/bin/env bats

load test_helper

@test "without arguments prints usage" {
  run shsh-uninstall
  assert_failure
  assert_line "Usage: shsh uninstall <package>"
}

@test "with invalid arguments, prints usage" {
  run shsh-uninstall lol
  assert_failure
  assert_line "Usage: shsh uninstall <package>"
}

@test "with too many arguments, prints usage" {
  run shsh-uninstall a/b lol
  assert_failure
  assert_line "Usage: shsh uninstall <package>"
}

@test "fails if package is not installed" {
  run shsh-uninstall user/lol
  assert_failure
  assert_output "Package 'user/lol' is not installed"
}

@test "removes package directory" {
  mock_clone
  create_package username/package
  shsh-install username/package

  run shsh-uninstall username/package
  assert_success
  [ ! -d "$SHSH_PACKAGES_PATH/username/package" ]
}

@test "removes binaries" {
  mock_clone
  create_package username/package
  create_exec username/package exec1
  shsh-install username/package

  run shsh-uninstall username/package
  assert_success
  [ ! -e "$SHSH_INSTALL_BIN/exec1" ]
}

@test "does not remove other package directories and binaries" {
  mock_clone
  create_package username/package1
  create_exec username/package1 exec1
  create_package username/package2
  create_exec username/package2 exec2
  shsh-install username/package1
  shsh-install username/package2

  run shsh-uninstall username/package1
  assert_success
  [ -d "$SHSH_PACKAGES_PATH/username/package2" ]
  [ -e "$SHSH_INSTALL_BIN/exec2" ]
}

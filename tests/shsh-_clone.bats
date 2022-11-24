#!/usr/bin/env bats

load test_helper

@test "without arguments prints usage" {
  run shsh-_clone
  assert_failure
  assert_line "Usage: shsh _clone <use_ssh> <site> <package> <ref> <folder>"
}

@test "invalid package prints usage" {
  run shsh-_clone false github.com invalid_package
  assert_failure
  assert_line "Usage: shsh _clone <use_ssh> <site> <package> <ref> <folder>"
}

@test "too many arguments prints usage" {
  run shsh-_clone false site a/b ref fourth_arg fifth_arg
  assert_failure
  assert_line "Usage: shsh _clone <use_ssh> <site> <package> <ref> <folder>"
}

@test "install a specific version" {
  mock_command git

  run shsh-_clone false site username/package version foldera/folderb
  assert_success
  assert_output "git clone --depth=1 --single-branch --branch version https://site/username/package.git ${SHSH_PACKAGES_PATH}/foldera/folderb"
}

@test "does nothing if package is already present" {
  mkdir -p "$SHSH_PACKAGES_PATH/username/package"

  run shsh-_clone false github.com username/package "" username/package

  assert_failure
  assert_output "Package 'username/package' is already present"
}

@test "using a different site" {
  mock_command git

  run shsh-_clone false site username/package "" username/package
  assert_success
  assert_output "git clone --depth=1 https://site/username/package.git ${SHSH_PACKAGES_PATH}/username/package"
}

@test "without setting SHSH_FULL_CLONE, clones a package with depth option" {
  export SHSH_FULL_CLONE=
  mock_command git

  run shsh-_clone false github.com username/package "" username/package
  assert_success
  assert_output "git clone --depth=1 https://github.com/username/package.git ${SHSH_PACKAGES_PATH}/username/package"
}

@test "setting SHSH_FULL_CLONE to true, clones a package without depth option" {
  export SHSH_FULL_CLONE=true
  mock_command git

  run shsh-_clone false github.com username/package "" username/package
  assert_success
  assert_output "git clone https://github.com/username/package.git ${SHSH_PACKAGES_PATH}/username/package"
}

@test "setting SHSH_FULL_CLONE to non-empty string, clones a package without depth option" {
  export SHSH_FULL_CLONE=false
  mock_command git

  run shsh-_clone false github.com username/package "" username/package
  assert_success
  assert_output "git clone https://github.com/username/package.git ${SHSH_PACKAGES_PATH}/username/package"
}

@test "using ssh protocol" {
  mock_command git

  run shsh-_clone true site username/package "" username/package
  assert_success
  assert_output "git clone --depth=1 git@site:username/package.git ${SHSH_PACKAGES_PATH}/username/package"
}

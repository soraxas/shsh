#!/usr/bin/env bats

load test_helper

@test "without arguments, prints usage" {
  run shsh-package-path
  assert_failure
  assert_line "Usage: source \"\$(shsh package-path <package>)/file.sh\""
}

@test "outputs the package path" {
  mock_clone
  create_package username/package
  shsh-install username/package

  run shsh-package-path username/package
  assert_success "$SHSH_PACKAGES_PATH/username/package"
}

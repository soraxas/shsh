#!/usr/bin/env bats

load test_helper

@test "without arguments prints usage" {
  run shsh-install
  assert_failure
  assert_line "Usage: shsh install [--ssh] [site]/<package>[@ref]"
}

@test "incorrect argument prints usage" {
  run shsh-install first_arg
  assert_failure
  assert_line "Usage: shsh install [--ssh] [site]/<package>[@ref]"
}

@test "too many arguments prints usage" {
  run shsh-install a/b wrong
  assert_failure
  assert_line "Usage: shsh install [--ssh] [site]/<package>[@ref]"
}

@test "executes install steps in right order" {
  mock_command shsh-_clone
  mock_command shsh-_deps
  mock_command shsh-_link-bins
  mock_command shsh-_link-man
  mock_command shsh-_link-completions

  run shsh-install username/package
  assert_success "shsh-_clone false github.com username/package
shsh-_deps username/package
shsh-_link-bins username/package
shsh-_link-man username/package
shsh-_link-completions username/package"
}

@test "with site, overwrites site" {
  mock_command shsh-_clone
  mock_command shsh-_deps
  mock_command shsh-_link-bins
  mock_command shsh-_link-man
  mock_command shsh-_link-completions

  run shsh-install site/username/package

  assert_line "shsh-_clone false site username/package"
}

@test "without site, uses github as default site" {
  mock_command shsh-_clone
  mock_command shsh-_deps
  mock_command shsh-_link-bins
  mock_command shsh-_link-man
  mock_command shsh-_link-completions

  run shsh-install username/package

  assert_line "shsh-_clone false github.com username/package"
}

@test "using ssh protocol" {
  mock_command shsh-_clone
  mock_command shsh-_deps
  mock_command shsh-_link-bins
  mock_command shsh-_link-man
  mock_command shsh-_link-completions

  run shsh-install --ssh username/package

  assert_line "shsh-_clone true github.com username/package"
}

@test "installs with custom version" {
  mock_command shsh-_clone
  mock_command shsh-_deps
  mock_command shsh-_link-bins
  mock_command shsh-_link-man
  mock_command shsh-_link-completions

  run shsh-install username/package@v1.2.3

  assert_line "shsh-_clone false github.com username/package v1.2.3"
}

@test "empty version is ignored" {
  mock_command shsh-_clone
  mock_command shsh-_deps
  mock_command shsh-_link-bins
  mock_command shsh-_link-man
  mock_command shsh-_link-completions

  run shsh-install username/package@

  assert_line "shsh-_clone false github.com username/package"
}

@test "doesn't fail" {
  create_package username/package
  mock_clone

  run shsh-install username/package
  assert_success
}

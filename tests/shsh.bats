#!/usr/bin/env bats

load test_helper

@test "default SHSH_ROOT" {
  SHSH_ROOT= run shsh echo SHSH_ROOT
  assert_output "$HOME/.local/share/shsh"
}

@test "inherited SHSH_ROOT" {
  SHSH_ROOT=/tmp/shsh run shsh echo SHSH_ROOT
  assert_output "/tmp/shsh"
}

@test "inherited SHSH_ROOT" {
  XDG_DATA_HOME=/local/share run shsh echo SHSH_ROOT
  assert_output "$XDG_DATA_HOME/shsh"
}

@test "default SHSH_PREFIX" {
  SHSH_ROOT= SHSH_PREFIX= run shsh echo SHSH_PREFIX
  assert_output "$HOME/.local/share/shsh/cellar"
}

@test "inherited SHSH_PREFIX" {
  SHSH_PREFIX=/usr/local run shsh echo SHSH_PREFIX
  assert_output "/usr/local"
}

@test "SHSH_PREFIX based on SHSH_ROOT" {
  SHSH_ROOT=/tmp/shsh SHSH_PREFIX= run shsh echo SHSH_PREFIX
  assert_output "/tmp/shsh/cellar"
}

@test "inherited SHSH_PACKAGES_PATH" {
  SHSH_PACKAGES_PATH=/usr/local/packages run shsh echo SHSH_PACKAGES_PATH
  assert_output "/usr/local/packages"
}

@test "SHSH_PACKAGES_PATH based on SHSH_PREFIX" {
  SHSH_PREFIX=/tmp/shsh SHSH_PACKAGES_PATH= run shsh echo SHSH_PACKAGES_PATH
  assert_output "/tmp/shsh/packages"
}

@test "default SHSH_INSTALL_BIN" {
  SHSH_ROOT= SHSH_PREFIX= SHSH_INSTALL_BIN= run shsh echo SHSH_INSTALL_BIN
  assert_output "$HOME/.local/share/shsh/cellar/bin"
}

@test "inherited SHSH_INSTALL_BIN" {
  SHSH_INSTALL_BIN=/opt/bin run shsh echo SHSH_INSTALL_BIN
  assert_output "/opt/bin"
}

@test "SHSH_INSTALL_BIN based on SHSH_PREFIX" {
  SHSH_INSTALL_BIN= SHSH_ROOT=/tmp/shsh SHSH_PREFIX=/usr/local run shsh echo SHSH_INSTALL_BIN
  assert_output "/usr/local/bin"
}

@test "default SHSH_INSTALL_MAN" {
  SHSH_ROOT= SHSH_PREFIX= SHSH_INSTALL_MAN= run shsh echo SHSH_INSTALL_MAN
  assert_output "$HOME/.local/share/shsh/cellar/man"
}

@test "inherited SHSH_INSTALL_MAN" {
  SHSH_INSTALL_MAN=/opt/man run shsh echo SHSH_INSTALL_MAN
  assert_output "/opt/man"
}

@test "SHSH_INSTALL_MAN based on SHSH_PREFIX" {
  SHSH_INSTALL_MAN= SHSH_PREFIX=/usr/local run shsh echo SHSH_INSTALL_MAN
  assert_output "/usr/local/man"
}

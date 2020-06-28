mock_command() {
  local command="$1"
  mkdir -p "${SHSH_TEST_DIR}/path/$command"
  cat > "${SHSH_TEST_DIR}/path/$command/$command" <<SH
#!/usr/bin/env sh

echo "$command \$@"
SH
  chmod +x "${SHSH_TEST_DIR}/path/$command/$command"
  export PATH="${SHSH_TEST_DIR}/path/$command:$PATH"
}

mock_clone() {
  export PATH="${BATS_TEST_DIRNAME}/fixtures/commands/shsh-_clone:$PATH"
}

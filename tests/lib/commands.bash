create_command() {
  echo "$2" > "$SHSH_TMP_BIN/$1"
  chmod +x "$SHSH_TMP_BIN/$1"
}

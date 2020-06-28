#!/usr/bin/env bats

load test_helper

@test "without args shows summary of common commands" {
  run shsh-help
  assert_success
  assert_line "Usage: shsh <command> [<args>]"
  assert_line "Some useful shsh commands are:"
}

@test "invalid command" {
  run shsh-help hello
  assert_failure "shsh: no such command 'hello'"
}

@test "shows help for a specific command" {
  cat > "${SHSH_TEST_DIR}/bin/shsh-hello" <<SH
#!shebang
# Usage: shsh hello <world>
# Summary: Says "hello" to you, from shsh
# This command is useful for saying hello.
echo hello
SH

  run shsh-help hello
  assert_success
  assert_output <<SH
Usage: shsh hello <world>

This command is useful for saying hello.
SH
}

@test "replaces missing extended help with summary text" {
  cat > "${SHSH_TEST_DIR}/bin/shsh-hello" <<SH
#!shebang
# Usage: shsh hello <world>
# Summary: Says "hello" to you, from shsh
echo hello
SH

  run shsh-help hello
  assert_success
  assert_output <<SH
Usage: shsh hello <world>

Says "hello" to you, from shsh
SH
}

@test "extracts only usage" {
  cat > "${SHSH_TEST_DIR}/bin/shsh-hello" <<SH
#!shebang
# Usage: shsh hello <world>
# Summary: Says "hello" to you, from shsh
# This extended help won't be shown.
echo hello
SH

  run shsh-help --usage hello
  assert_success "Usage: shsh hello <world>"
}

@test "multiline usage section" {
  cat > "${SHSH_TEST_DIR}/bin/shsh-hello" <<SH
#!shebang
# Usage: shsh hello <world>
#        shsh hi [everybody]
#        shsh hola --translate
# Summary: Says "hello" to you, from shsh
# Help text.
echo hello
SH

  run shsh-help hello
  assert_success
  assert_output <<SH
Usage: shsh hello <world>
       shsh hi [everybody]
       shsh hola --translate

Help text.
SH
}

@test "multiline extended help section" {
  cat > "${SHSH_TEST_DIR}/bin/shsh-hello" <<SH
#!shebang
# Usage: shsh hello <world>
# Summary: Says "hello" to you, from shsh
# This is extended help text.
# It can contain multiple lines.
#
# And paragraphs.

echo hello
SH

  run shsh-help hello
  assert_success
  assert_output <<SH
Usage: shsh hello <world>

This is extended help text.
It can contain multiple lines.

And paragraphs.
SH
}

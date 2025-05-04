#!/usr/bin/env sh

set -e

# source shsh environment variable
eval "$(curl -s https://raw.githubusercontent.com/soraxas/shsh/master/libexec/shsh-_env-var)"

main() {
  ## stop if basher is already installed
  if [ -d "$SHSH_ROOT" ]; then
    error_echo "shsh already exists at '$SHSH_ROOT'."
    error_echo "Delete it if you want to start this bootstrap process again."
    return 1
  fi


  info_echo "Installing shsh to '$SHSH_ROOT'"
  git clone https://github.com/soraxas/shsh.git "$SHSH_ROOT" > /dev/null

  # Check shell type
  shell_type=$(basename "$SHELL")
  info_echo "Detected shell type: $shell_type"
  case "$shell_type" in
    bash)  startup_type="simple" ; startup_script="$HOME/.bashrc" ;;
    zsh)   startup_type="simple" ; startup_script="$HOME/.zshrc"  ;;
    sh)    startup_type="simple" ; startup_script="$HOME/.profile";;
    fish)  startup_type="fish"   ; startup_script="$HOME/.config/fish/config.fish"  ;;
    *)
      error_echo "Unknown shell '$shell_type'."
      error_echo "Perhaps set the \$SHELL environment variable to your shell type before running this?"
      error_echo "e.g. export SHELL=bash"
      return 1
      ;;
  esac


  if [ ! -f "$startup_script" ]; then
    touch "$startup_script"
  fi


  ## now add the basher initialisation lines to the user's startup script
  info_echo "Adding shsh initialisation"
  #shellcheck disable=SC2016
  case "$startup_type" in
    simple)
      printf '%s\n' '' >>"$startup_script"
      printf '%s\n' 'export SHSH_ROOT="'"$SHSH_ROOT"'"' >>"$startup_script"
      printf '%s\n' 'export PATH="$SHSH_ROOT/bin:$PATH"' >>"$startup_script"
      printf '%s\n' 'eval "$(shsh init '"$shell_type"')"' >>"$startup_script"
      ;;
    fish)
      printf '%s\n' '' >>"$startup_script"
      printf '%s\n' 'set -gx SHSH_ROOT "'"$SHSH_ROOT"'"' >>"$startup_script"
      printf '%s\n' 'set -p PATH "$SHSH_ROOT/bin"' >>"$startup_script"
      printf '%s\n' 'status --is-interactive; and shsh init fish | source' >>"$startup_script"
      ;;
    *)
      error_echo "Unknown shell '$shell_type'."
      error_echo "Perhaps set the \$SHELL environment variable to your shell type before running this?"
      error_echo "e.g. export SHELL=bash"
      return 1
      ;;
  esac

  # self-linking
  (
    cd "$SHSH_ROOT"
    if command -v make >/dev/null 2>&1; then
      # use built-in make command
      make self-linking
    else
      # mamually link
      ln -srf "bin/shsh" "$SHSH_ROOT/cellar/bin/shsh"
      ln -srf completions/shsh.bash "$SHSH_ROOT/cellar/completions/bash/shsh.bash"
      ln -srf completions/shsh.fish "$SHSH_ROOT/cellar/completions/fish/shsh.fish"
      ln -srf completions/shsh.zsh "$SHSH_ROOT/cellar/completions/zsh/compctl/shsh.zsh"
    fi
  )
}

# restart shell
main && eval "$("$SHSH_ROOT/bin/shsh" init sh)"


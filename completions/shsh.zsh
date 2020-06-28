if [[ ! -o interactive ]]; then
    return
fi

compctl -K _shsh shsh

_shsh() {
  local words completions
  read -cA words

  if [ "${#words}" -eq 2 ]; then
    completions="$(shsh commands)"
  else
    completions="$(shsh completions ${words[2,-2]})"
  fi

  reply=("${(ps:\n:)completions}")
}

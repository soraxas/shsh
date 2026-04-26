#!/usr/bin/env bash
set -euo pipefail

plugin_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmp_dir="$(mktemp -d)"
work_dir="$tmp_dir/work"
cleanup() {
  rm -rf "$tmp_dir"
}
trap cleanup EXIT

export HOME="$tmp_dir/home"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"
export MISE_DATA_DIR="$tmp_dir/mise-data"
export MISE_CACHE_DIR="$tmp_dir/mise-cache"
export MISE_CONFIG_DIR="$tmp_dir/mise-config"
export MISE_STATE_DIR="$tmp_dir/mise-state"
export MISE_EXPERIMENTAL=1

mise_cmd=(mise -y)

mkdir -p \
  "$XDG_CONFIG_HOME" \
  "$XDG_DATA_HOME" \
  "$XDG_CACHE_HOME" \
  "$XDG_STATE_HOME" \
  "$MISE_DATA_DIR" \
  "$MISE_CACHE_DIR" \
  "$MISE_CONFIG_DIR" \
  "$MISE_STATE_DIR"
mkdir -p "$work_dir"

cd "$work_dir"

"${mise_cmd[@]}" plugin link --force shsh "$plugin_dir"
"${mise_cmd[@]}" cache clear
"${mise_cmd[@]}" ls-remote shsh:soraxas/shsh >"$tmp_dir/versions.txt"
"${mise_cmd[@]}" use shsh:soraxas/shsh
"${mise_cmd[@]}" install shsh:soraxas/shsh@v3.0.2

version_output="$("${mise_cmd[@]}" exec shsh:soraxas/shsh@v3.0.2 -- shsh --version)"
latest_output="$("${mise_cmd[@]}" exec -- shsh --version)"

grep -qx 'latest' "$tmp_dir/versions.txt"
grep -qx 'v3.0.2' "$tmp_dir/versions.txt"
[[ "$version_output" == *"v3.0.2"* ]]
[[ "$latest_output" == *"shell script handler"* ]]
grep -q '"shsh:soraxas/shsh" = "latest"' mise.toml
[[ ! -e "$XDG_CONFIG_HOME/shshrc" ]]

echo "shsh backend plugin smoke test passed"

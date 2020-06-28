load vendor/bats-core/load
load vendor/bats-assert/load

export SHSH_TEST_DIR="${BATS_TMPDIR}/shsh"
export SHSH_ORIGIN_DIR="${SHSH_TEST_DIR}/origin"
export SHSH_CWD="${SHSH_TEST_DIR}/cwd"
export SHSH_TMP_BIN="${SHSH_TEST_DIR}/bin"

export SHSH_ROOT="${BATS_TEST_DIRNAME}/.."
export SHSH_PREFIX="${SHSH_TEST_DIR}/prefix"
export SHSH_INSTALL_BIN="${SHSH_PREFIX}/bin"
export SHSH_INSTALL_MAN="${SHSH_PREFIX}/man"
export SHSH_PACKAGES_PATH="$SHSH_PREFIX/packages"

export FIXTURES_DIR="${BATS_TEST_DIRNAME}/fixtures"

export PATH="${BATS_TEST_DIRNAME}/libexec:$PATH"
export PATH="${BATS_TEST_DIRNAME}/../libexec:$PATH"
export PATH="${SHSH_TMP_BIN}:$PATH"

mkdir -p "${SHSH_TMP_BIN}"
mkdir -p "${SHSH_TEST_DIR}/path"

mkdir -p "${SHSH_ORIGIN_DIR}"

mkdir -p "${SHSH_CWD}"

setup() {
  cd ${SHSH_CWD}
}

teardown() {
  rm -rf "$SHSH_TEST_DIR"
}

load lib/mocks
load lib/package_helpers
load lib/commands

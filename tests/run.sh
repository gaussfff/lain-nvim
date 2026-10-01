#!/usr/bin/env bash
# Checks that the config is healthy: code style, Lua diagnostics,
# then language servers and formatters on throwaway projects.

set -uo pipefail

TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$(dirname "$TESTS_DIR")"
MASON_BIN="${XDG_DATA_HOME:-$HOME/.local/share}/nvim/mason/bin"

BOLD=$'\033[1m'
DIM=$'\033[90m'
RED=$'\033[31m'
GREEN=$'\033[32m'
RESET=$'\033[0m'

status=0

report() {
    local name=$1 ok=$2 detail=${3:-}
    if [ "$ok" -eq 0 ]; then
        printf '  %s✓%s %-34s %s%s%s\n' "$GREEN" "$RESET" "$name" "$DIM" "$detail" "$RESET"
    else
        printf '  %s✗%s %-34s %s%s%s\n' "$RED" "$RESET" "$name" "$DIM" "$detail" "$RESET"
        status=1
    fi
}

printf '%sStyle and static analysis%s\n' "$BOLD" "$RESET"

if [ -x "$MASON_BIN/stylua" ]; then
    if "$MASON_BIN/stylua" --check "$CONFIG_DIR" >/dev/null 2>&1; then
        report "stylua" 0 "formatting is consistent"
    else
        report "stylua" 1 "unformatted files, run stylua ."
    fi
else
    report "stylua" 1 "not installed"
fi

if [ -x "$MASON_BIN/lua-language-server" ]; then
    logs=$(mktemp -d)
    "$MASON_BIN/lua-language-server" --check "$CONFIG_DIR" --checklevel=Warning --logpath="$logs" >/dev/null 2>&1
    if [ -s "$logs/check.json" ] && [ "$(tr -d '[:space:]' <"$logs/check.json")" != "{}" ]; then
        report "lua-language-server" 1 "warnings found"
    else
        report "lua-language-server" 0 "no warnings"
    fi
    rm -rf "$logs"
else
    report "lua-language-server" 1 "not installed"
fi

NVIM_TESTS_DIR="$TESTS_DIR" nvim --headless -c "luafile $TESTS_DIR/init.lua" 2>&1
[ "${PIPESTATUS[0]}" -eq 0 ] || status=1

exit "$status"

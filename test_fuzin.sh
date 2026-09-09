#!/bin/bash

set -u

root=$(cd "$(dirname "$0")" && pwd)
source "$root/fuzin"

fail() {
    echo "FAIL: $1" >&2
    exit 1
}

"$root/fuzin" --help | grep -q '^Usage:' || fail "--help"

ParseArguments --remove --yay
[[ "$mode:$forceManager" == "remove:yay" ]] || fail "combined arguments"
yay() { :; }
DetectPM
[[ "$packageManager:${operation[*]}" == "yay:yay -Rns" ]] || fail "forced removal manager"

packageManager="brew"
mode="install"
preview="brew info {}"
operation=(brew install)

ListPackages() { printf 'alpha\n'; }
brew() { :; }
marker=$(mktemp "${TMPDIR:-/tmp}/fuzin-marker.XXXXXX") || exit 1
rm -f "$marker"
trap 'rm -f "$marker"' EXIT
fzf() { cat >/dev/null; printf 'alpha; touch %s\n' "$marker"; }
Run >/dev/null || fail "safe package execution"
[[ ! -e "$marker" ]] || fail "selected package was evaluated as code"

ListPackages() { return 42; }
Run >/dev/null 2>&1 && fail "package-list failure was ignored"

ListPackages() { printf 'alpha\n'; }
fzf() { cat >/dev/null; return 130; }
Run >/dev/null 2>&1
[[ $? -eq 130 ]] || fail "fzf cancellation status"

echo "ok"

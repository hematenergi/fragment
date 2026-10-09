#!/usr/bin/env bash

make_test_dir_link() {
  local target="$1" link="$2" windows_target windows_link
  case "${OSTYPE:-}" in
    msys*|cygwin*)
      command -v powershell.exe >/dev/null 2>&1 || return 1
      command -v cygpath >/dev/null 2>&1 || return 1
      windows_target=$(cygpath -aw "$target") || return 1
      windows_link=$(cygpath -aw "$link") || return 1
      FRAGMENT_TEST_LINK_PATH="$windows_link" FRAGMENT_TEST_LINK_TARGET="$windows_target" \
        powershell.exe -NoProfile -NonInteractive -Command \
        'New-Item -ItemType Junction -Path $env:FRAGMENT_TEST_LINK_PATH -Target $env:FRAGMENT_TEST_LINK_TARGET -ErrorAction Stop | Out-Null; exit 0' \
        >/dev/null 2>&1
      ;;
    *) ln -s "$target" "$link" 2>/dev/null ;;
  esac
}

make_test_file_link() {
  local target="$1" link="$2" windows_target windows_link
  case "${OSTYPE:-}" in
    msys*|cygwin*)
      command -v powershell.exe >/dev/null 2>&1 || return 1
      command -v cygpath >/dev/null 2>&1 || return 1
      windows_target=$(cygpath -aw "$target") || return 1
      windows_link=$(cygpath -aw "$link") || return 1
      FRAGMENT_TEST_LINK_PATH="$windows_link" FRAGMENT_TEST_LINK_TARGET="$windows_target" \
        powershell.exe -NoProfile -NonInteractive -Command \
        'New-Item -ItemType SymbolicLink -Path $env:FRAGMENT_TEST_LINK_PATH -Target $env:FRAGMENT_TEST_LINK_TARGET -ErrorAction Stop | Out-Null; exit 0' \
        >/dev/null 2>&1
      ;;
    *) ln -s "$target" "$link" 2>/dev/null ;;
  esac
}

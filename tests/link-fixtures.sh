#!/usr/bin/env bash

make_test_dir_link() {
  local target="$1" link="$2" windows_target windows_link windows_status
  case "${OSTYPE:-}" in
    msys*|cygwin*)
      command -v powershell.exe >/dev/null 2>&1 || return 1
      command -v cygpath >/dev/null 2>&1 || return 1
      windows_target=$(cygpath -aw "$target") || return 1
      windows_link=$(cygpath -aw "$link") || return 1
      windows_status=0
      FRAGMENT_TEST_LINK_PATH="$windows_link" FRAGMENT_TEST_LINK_TARGET="$windows_target" \
        powershell.exe -NoProfile -NonInteractive -Command \
        'New-Item -ItemType Junction -Path $env:FRAGMENT_TEST_LINK_PATH -Target $env:FRAGMENT_TEST_LINK_TARGET -ErrorAction Stop | Out-Null; $parent=[System.IO.Path]::GetDirectoryName($env:FRAGMENT_TEST_LINK_PATH); $name=[System.IO.Path]::GetFileName($env:FRAGMENT_TEST_LINK_PATH); $item=Get-ChildItem -LiteralPath $parent -Force | Where-Object { $_.Name -ieq $name } | Select-Object -First 1; if ($null -eq $item -or ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -eq 0) { exit 3 }; exit 0' \
        >/dev/null 2>&1 || windows_status=$?
      case "$windows_status" in 0) return 0 ;; 3) return 2 ;; *) return 1 ;; esac
      ;;
    *) ln -s "$target" "$link" 2>/dev/null ;;
  esac
}

make_test_file_link() {
  local target="$1" link="$2" windows_target windows_link windows_status
  case "${OSTYPE:-}" in
    msys*|cygwin*)
      command -v powershell.exe >/dev/null 2>&1 || return 1
      command -v cygpath >/dev/null 2>&1 || return 1
      windows_target=$(cygpath -aw "$target") || return 1
      windows_link=$(cygpath -aw "$link") || return 1
      windows_status=0
      FRAGMENT_TEST_LINK_PATH="$windows_link" FRAGMENT_TEST_LINK_TARGET="$windows_target" \
        powershell.exe -NoProfile -NonInteractive -Command \
        'New-Item -ItemType SymbolicLink -Path $env:FRAGMENT_TEST_LINK_PATH -Target $env:FRAGMENT_TEST_LINK_TARGET -ErrorAction Stop | Out-Null; $parent=[System.IO.Path]::GetDirectoryName($env:FRAGMENT_TEST_LINK_PATH); $name=[System.IO.Path]::GetFileName($env:FRAGMENT_TEST_LINK_PATH); $item=Get-ChildItem -LiteralPath $parent -Force | Where-Object { $_.Name -ieq $name } | Select-Object -First 1; if ($null -eq $item -or ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -eq 0) { exit 3 }; exit 0' \
        >/dev/null 2>&1 || windows_status=$?
      case "$windows_status" in 0) return 0 ;; 3) return 2 ;; *) return 1 ;; esac
      ;;
    *) ln -s "$target" "$link" 2>/dev/null ;;
  esac
}

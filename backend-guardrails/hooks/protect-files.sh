#!/bin/bash
# PreToolUse hook: runs BEFORE Claude edits/writes a file.
# Exit 2 = block the edit and send stderr to Claude. Exit 0 = allow.

# Claude Code passes the tool call as JSON on stdin. jq pulls out the path of
# the file about to be edited.
#   -r              -> raw output (no JSON quotes around the string)
#   // empty        -> if the field is missing, return an empty string instead of "null"
# Perequisites intsall jq if not intsalled- winget install jqlang.jq
file=$(jq -r '.tool_input.file_path // empty')

# case matches $file against glob patterns. The | means "or"
case "$file" in
  # Matches any path that:
  #   *appsettings.json -> ends with that filename
  #   *.env                        -> ends in .env
  #   *.pfx                        -> ends in .pfx (certificate/private key bundles)
  #   *secrets*                    -> contains "secrets" anywhere in the path
  *appsettings.json|*.env|*.pfx|*secrets*)
    # >&2 sends the message to stderr. On exit 2, Claude Code feeds stderr back
    # to Claude, so it sees why the edit was blocked and can adjust
    echo "Protected file: $file. Don't edit it; ask the user." >&2
    exit 2 ;;
esac

# No pattern matched (or $file was empty), so allow the edit.
exit 0
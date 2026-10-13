#!/bin/bash
# Perequisites intsall jq if not intsalled- winget install jqlang.j
# PostToolUse hook: runs AFTER Claude edits/writes a file.
# It can't undo the edit; exit 2 sends the findings to Claude so it can fix them.
# Read the edited file's path from the hook's JSON input
file=$(jq -r '.tool_input.file_path // empty')

# [[ ... ]] && exit 0  means "if the condition is true, stop here and allow".
# Skip anything that isn't a C# file.
[[ "$file" != *.cs ]] && exit 0

# Skip if the file doesn't exist on disk (e.g. empty path, or file was deleted).
[[ ! -f "$file" ]] && exit 0

# Collects the findings; empty means "nothing found".
issues=""

# Helper function: check <regex> <message>
#   $1 = regex pattern to search for
#   $2 = message to record if the pattern is found
# grep flags:
#   -n -> include line numbers (not displayed here, harmless)
#   -E -> extended regex (lets us use | and + without backslashes)
# >/dev/null discards grep's output; we only care whether it matched.
# && means: if grep found a match (exit 0), append the message to $issues.
# $'\n' is a literal newline so each finding sits on its own line.
check() { grep -nE "$1" "$file" >/dev/null && issues+="- $2"$'\n'; }

check 'FromSqlRaw\(\$"|ExecuteSqlRaw\(\$"|SqlCommand\(\$"' "String-interpolated SQL (injection risk). Use parameters or the stored procedure."
check 'AllowAnyOrigin'                                       "CORS AllowAnyOrigin added."
check '\[AllowAnonymous\]'                                   "[AllowAnonymous] added. Confirm this is intentional."
check 'ServerCertificateCustomValidationCallback|DangerousAcceptAnyServerCertificateValidator' "TLS validation disabled."
check '(password|secret|apikey|connectionstring)\s*=\s*"[^"]{6,}"' "Possible hardcoded secret."
check 'Log(Information|Debug|Warning)\(.*(password|token|secret)' "Possible sensitive value in logs."

# -n tests for a NON-empty string, so this runs only if any check recorded a finding.
if [[ -n "$issues" ]]; then
  echo "Security review needed in $file:" >&2 # header line, to stderr
  echo "$issues" >&2 # the collected findings, to stderr
  exit 2 # tell Claude Code to feed stderr back to Claude
fi

# Nothing found: allow things to continue.
exit 0
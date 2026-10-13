\# my-plugins



\## backend-guardrails (DEMO ONLY)



> \*\*Demo purposes only.\*\* Not production-ready. Review every script before use.



Hooks for Claude Code on a .NET backend:



| Hook | Event | What it does |

|---|---|---|

| protect-files | PreToolUse | Blocks edits to production config, `.env`, `.pfx`, secrets |

| security-scan | PostToolUse | Greps edited `.cs` files for risky patterns, reports to Claude |

| verify-build | Stop | Runs `dotnet build` and `dotnet test` before Claude can finish |



\### Requirements (Windows only)



\- Windows with \*\*Git for Windows\*\* (provides Git Bash, which runs the hooks)

\- \*\*jq\*\*: install in PowerShell, then restart all terminals and Claude Code:

```powershell

&#x20; winget install jqlang.jq

```

&#x20; Verify in Git Bash: `jq --version`

\- .NET SDK (for the verify-build hook)



macOS/Linux are not tested.



\### Install



&#x20;   /plugin marketplace add <your-repo-url-or-owner/repo>

&#x20;   /plugin install backend-guardrails@my-plugins



Restart Claude Code, then run `/hooks` to confirm the three hooks are registered.


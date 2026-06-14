(&mise activate pwsh) | Out-String | Invoke-Expression

function claude { claude.exe --allow-dangerously-skip-permissions @args }

function codex { codex.exe --dangerously-bypass-approvals-and-sandbox @args }

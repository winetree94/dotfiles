# Aliases
maybe_alias "chezmoi" "c"
maybe_alias "kubectl" "k"
maybe_alias "kubectl-ai" "kai"
maybe_alias "aichat" "ai"
maybe_alias "talosctl" "t"
maybe_alias "talhelper" "th"
maybe_alias "dotweave" "dw"
maybe_alias "claude" "claude" "claude --dangerously-skip-permissions"
maybe_alias "codex" "codex" "codex --dangerously-bypass-approvals-and-sandbox"
maybe_alias "copilot" "copilot" "copilot --yolo"
maybe_alias "gemini" "gemini" "gemini --yolo"

bw-vivident()     { BITWARDENCLI_APPDATA_DIR="$HOME/.config/bitwarden-vivident"     bw --session $BW_VIVIDENT_SESSION "$@"; }

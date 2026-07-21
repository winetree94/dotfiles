maybe_eval devtools autocomplete zsh
maybe_eval devsync autocomplete zsh
maybe_eval docker completion zsh
maybe_eval kubectl completion zsh
maybe_eval talosctl completion zsh
maybe_eval opencode completion
if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init zsh)"; fi
# maybe_eval bw completion --shell zsh

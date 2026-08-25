export EDITOR=nvim
ZSH_THEME="ys"

export PUBLIC_CONTROL_PLANE_IP=10.23.11.1

export TALOSCONFIG=$HOME/workspaces/tinyrack/public/talos/talosconfig

export PI_CODING_AGENT_DIR=$HOME/.config/pi/agent

maybe_eval direnv hook zsh

export OPENCODE_DISABLE_CLAUDE_CODE=true

export FZF_BASE=${HOMEBREW_PREFIX}/opt/fzf
# export FZF_BASE=$(brew --prefix)/opt/fzf

# export OPENCODE_EXPERIMENTAL_FILEWATCHER=true
export OPENCODE_EXPERIMENTAL_PLAN_MODE=true

# for ubuntu 26 compatibility
export PLAYWRIGHT_HOST_PLATFORM_OVERRIDE=ubuntu24.04-x64

eval "$(mise activate zsh)"

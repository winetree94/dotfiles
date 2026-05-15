export EDITOR=nvim
export KUBECONFIG=~/.kube/k3s.yaml
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

eval "$(mise activate zsh)"

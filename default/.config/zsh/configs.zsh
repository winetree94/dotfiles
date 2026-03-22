export EDITOR=nvim
export KUBECONFIG=~/.kube/k3s.yaml
ZSH_THEME="ys"

export PUBLIC_CONTROL_PLANE_IP=10.23.11.1

export TALOSCONFIG=$HOME/workspaces/tinyrack/public/talos/talosconfig

export PI_CODING_AGENT_DIR=$HOME/.config/pi/agent

maybe_eval direnv hook zsh

git_clone_if_not_exists "https://github.com/nvm-sh/nvm.git" "--depth=1" "$HOME/.nvm"

export OPENCODE_DISABLE_CLAUDE_CODE=true

export FZF_BASE=${HOMEBREW_PREFIX}/opt/fzf
# export FZF_BASE=$(brew --prefix)/opt/fzf

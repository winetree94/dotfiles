export PATH=$HOME/.local/bin:$PATH
export PATH="$HOME/.cache/.bun/bin:$PATH"
export PATH="$HOME/.bun/bin:$PATH"

export PATH="/home/winetree94/.cache/.bun/bin:$PATH"

# android
case "$OSTYPE" in
  darwin*)
    export ANDROID_HOME="$HOME/Library/Android/Sdk"
    export PATH="$ANDROID_HOME/platform-tools:$PATH"
    export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"
    ;;
  linux*)
    export ANDROID_HOME="$HOME/Android/Sdk"
    export PATH="$ANDROID_HOME/platform-tools:$PATH"
    export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"
    ;;
esac

# brew
export PATH="/home/linuxbrew/.linuxbrew/opt/libpq/bin:$PATH"

# vivident
export VIVIDENT_KEYSTORE_DIR=$HOME/.vivident

# git
export GPG_TTY=$(tty)

export XDG_CONFIG_HOME=$HOME/.config

# pnpm
export PNPM_HOME="/home/winetree94/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac


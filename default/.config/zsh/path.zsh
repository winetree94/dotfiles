export PATH=$HOME/.local/bin:$PATH
export PATH="$HOME/.cache/.bun/bin:$PATH"
export PATH="$HOME/.bun/bin:$PATH"

export PATH="/home/winetree94/.cache/.bun/bin:$PATH"
export JAVA_HOME="/usr/lib/jvm/java-21-openjdk-amd64"
export ANDROID_SDK_ROOT="$HOME/Android/Sdk"
export PATH="/home/linuxbrew/.linuxbrew/opt/libpq/bin:$PATH"

export VIVIDENT_KEYSTORE_DIR=$HOME/.vivident
export GPG_TTY=$(tty)
export XDG_CONFIG_HOME=$HOME/.config
export PNPM_HOME="/home/winetree94/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac


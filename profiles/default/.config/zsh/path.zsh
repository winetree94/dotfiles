export PATH=$HOME/.local/bin:$PATH
export PATH="$HOME/.cache/.bun/bin:$PATH"
export PATH="$HOME/.bun/bin:$PATH"

export PATH="/home/winetree94/.cache/.bun/bin:$PATH"

# android
export JAVA_HOME="/usr/lib/jvm/java-21-openjdk-amd64"
export ANDROID_SDK_ROOT="$HOME/Android/Sdk"
export PATH="$ANDROID_SDK_ROOT/platform-tools:$PATH"
export PATH="$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$PATH"

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


# for ubuntu 26 compatibility
export PLAYWRIGHT_HOST_PLATFORM_OVERRIDE=ubuntu24.04-x64

if [ -n "$DISPLAY" ] || [ -n "$WAYLAND_DISPLAY" ]; then
  pgrep -x ibus-daemon >/dev/null || ibus-daemon -drx >/dev/null 2>&1 &
fi

if [ -n "$DISPLAY" ] || [ -n "$WAYLAND_DISPLAY" ]; then
  pgrep -x ibus-daemon >/dev/null || ibus-daemon -drx >/dev/null 2>&1 &
fi

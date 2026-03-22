git_clone_if_not_exists() {
  local repo_url="$1"
  local options="$2"
  local target_dir="$3"

  if [[ ! -d "$target_dir" ]]; then
    local parent_dir="$(dirname "$target_dir")"
    mkdir -p "$parent_dir"
    echo "📥 $repo_url clone..."
    git clone "$options" "$repo_url" "$target_dir"
  fi
}

maybe_eval() {
  local cmd="$1"
  shift
  if command -v "$cmd" >/dev/null 2>&1; then
    eval "$("$cmd" "$@")"
  fi
}

maybe_alias() {
  local cmd="$1"
  local alias_name="$2"
  local alias_value="${3:-$cmd}"
  if command -v "$cmd" >/dev/null 2>&1; then
    alias "$alias_name"="$alias_value"
  fi
}


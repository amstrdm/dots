# safe_rm – rm wrapper with tree preview & letter confirmation for recursive deletes
# - rm file        -> simple confirmation
# - rm dir         -> behaves like normal rm (error, no preview)
# - rm -rf dir     -> tree preview + letter confirmation + final "delete"

safe_rm() {
  emulate -L zsh
  setopt local_options no_shwordsplit null_glob

  if (( $# == 0 )); then
    print "Usage: rm [options] <file-or-dir> [...]"
    return 1
  fi

  local -a opts targets
  local arg
  local saw_recursive=0

  # Split options and targets, detect -r/-R
  for arg in "$@"; do
    if [[ "$arg" == -* ]]; then
      opts+="$arg"
      if [[ "$arg" == *r* || "$arg" == *R* ]]; then
        saw_recursive=1
      fi
    else
      targets+="$arg"
    fi
  done

  if (( ${#targets} == 0 )); then
    print "Usage: rm [options] <file-or-dir> [...]"
    return 1
  fi

  # Check if there are directories among targets
  local has_dir=0 t
  for t in "${targets[@]}"; do
    [[ -d "$t" ]] && has_dir=1
  done

  # If there is a directory but NO -r/-R, behave like normal rm (no preview)
  if (( has_dir && ! saw_recursive )); then
    command rm "$@"
    return $?
  fi

  # From here on, we handle our "safe recursive/file delete" logic
  local -a confirmed_targets=()
  local use_tree=0

  if command -v tree >/dev/null 2>&1; then
    use_tree=1
  fi

  # Letters as an array (A B C ...)
  local -a letters
  letters=({A..Z})

  for t in "${targets[@]}"; do
    if [[ ! -e "$t" ]]; then
      print "❓ Skipping '$t' (does not exist)"
      continue
    fi

    # Resolve absolute path (prefer realpath, fallback to zsh :A)
    local fullpath danger=0
    if command -v realpath >/dev/null 2>&1; then
      fullpath="$(realpath -- "$t")"
    else
      fullpath="${t:A}"
    fi

    # Heuristic: mark "dangerous" high-level paths
    if [[ "$fullpath" == "/" \
       || "$fullpath" == "/home" \
       || "$fullpath" == "/Users" \
       || "$fullpath" == "/usr" \
       || "$fullpath" == "/etc" \
       || "$fullpath" == "/var" \
       || "$fullpath" == "/opt" \
       || "$fullpath" == "$HOME" ]]; then
      danger=1
    fi

    print
    print "========================================"
    print -P "%B%F{red}About to delete (full path):%f%b"
    print -P "  %B$fullpath%b"
    if (( danger )); then
      print
      print -P "%B%F{yellow}⚠️  WARNING: This is a high-level system or home path. Double-check before deleting!%f%b"
    fi
    print "========================================"

    if [[ -d "$t" ]]; then
      # Directory preview
      if (( use_tree )); then
        print "📂 Directory preview:"
        # adjust depth here if you want (current: 2)
        tree -L 2 -- "$t"
      else
        print "📂 Directory preview (using find):"
        find "$t" -maxdepth 2 | sed "s|^$t|.|"
      fi
      print

      # Build top-level mapping
      print "Top-level entries inside '$t':"

      local i=1
      local branch_letters=""
      local entry base label
      local -a entries

      entries=("$t"/*)

      if (( ${#entries} == 0 )); then
        print "  (empty directory)"
        branch_letters="OK"
        print
        print "To confirm deletion of '$t', type: $branch_letters"
      else
        for entry in "${entries[@]}"; do
          [[ -e "$entry" ]] || continue
          if (( i > ${#letters} )); then
            print "  (more entries exist, not listed)"
            break
          fi
          label=${letters[i]}
          base=${entry:t}
          print "  [$label] $base"
          branch_letters+="$label"
          (( i++ ))
        done
        print
        print "To confirm deletion of '$t', type the letters (in order, no spaces): $branch_letters"
      fi

      local confirm
      read -r "confirm?> "

      if [[ "$confirm" != "$branch_letters" ]]; then
        print "❌ Confirmation mismatch. Skipping '$t'."
        continue
      fi

    else
      # Single file
      print "🗑 File to delete: $t"
      local confirm
      read -r "confirm?Type 'yes' to delete this file: "
      if [[ "$confirm" != "yes" ]]; then
        print "❌ Not confirmed. Skipping '$t'."
        continue
      fi
    fi

    confirmed_targets+="$t"
  done

  if (( ${#confirmed_targets} == 0 )); then
    print
    print "No targets confirmed. Nothing deleted."
    return 0
  fi

  print
  print "🚨 Deleting the following confirmed targets:"
  for t in "${confirmed_targets[@]}"; do
    print "  - $t"
  done

  local final
  read -r "final?Final check – type 'delete' to proceed: "
  if [[ "$final" != "delete" ]]; then
    print "Aborted final step. Nothing deleted."
    return 0
  fi

  # Run real rm with original options + confirmed targets
  command rm "${opts[@]}" -- "${confirmed_targets[@]}"
  print "✅ Deletion complete."
}

alias rm='safe_rm'

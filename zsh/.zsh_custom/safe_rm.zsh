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

  # Wenn Verzeichnisse, aber kein -r/-R: wie normales rm verhalten (kein eigener Kram)
  if (( has_dir && ! saw_recursive )); then
    command rm "$@"
    return $?
  fi

  # --- Entscheiden, ob "heavy mode" notwendig ist ---

  local heavy_mode=0

  if (( ${#targets} > 1 )); then
    # Mehrere Ziele (Wildcards/Pattern etc.) => immer sichere Logik
    heavy_mode=1
  else
    # Genau ein Ziel – prüfen, ob es ein NICHT-leeres Verzeichnis ist
    t=${targets[1]}
    if [[ -d "$t" && -e "$t" ]]; then
      local -a tmp
      tmp=("$t"/*)
      if (( ${#tmp} > 0 )); then
        # Single non-empty directory mit -r/-R => sichere Logik
        heavy_mode=1
      fi
    fi
  fi

  # --- Einfache Bestätigung für: einzelne Datei oder leerer Ordner ---

  if (( ! heavy_mode )); then
    print "🗑 Target to delete: ${targets[1]}"
    local confirm
    print -n "Delete this item? [y/N] "
    read -r confirm

    if [[ ! "$confirm" =~ ^[yY]$ ]]; then
      print "Aborted. Nothing deleted."
      return 0
    fi

    command rm "$@"
    return $?
  fi

  # --- Ab hier: "safe" Logik für non-empty dirs und mehrere Ziele (Patterns etc.) ---

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
        # Falls hier doch leer sein sollte, simple Bestätigung
        print "  (empty directory)"
        local confirm_empty
        print -n "Delete this (empty) directory? [y/N] "
        read -r confirm_empty
        if [[ ! "$confirm_empty" =~ ^[yY]$ ]]; then
          print "❌ Not confirmed. Skipping '$t'."
          continue
        fi
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

        local confirm_dir
        read -r "confirm_dir? "

        if [[ "$confirm_dir" != "$branch_letters" ]]; then
          print "❌ Confirmation mismatch. Skipping '$t'."
          continue
        fi
      fi

    else
      # File im "heavy mode" (z.B. aus Wildcard/mehreren Targets)
      print "🗑 File to delete: $t"
      local confirm_file
      print -n "Delete this file? [y/N] "
      read -r confirm_file
      if [[ ! "$confirm_file" =~ ^[yY]$ ]]; then
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
  print -n "Final check – type 'delete' to proceed: "
  read -r final
  if [[ "$final" != "delete" ]]; then
    print "Aborted final step. Nothing deleted."
    return 0
  fi

  # Run real rm with original options + confirmed targets
  command rm "${opts[@]}" -- "${confirmed_targets[@]}"
  print "✅ Deletion complete."
}

alias rm='safe_rm'

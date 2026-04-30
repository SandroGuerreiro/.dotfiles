gck() {
  local search_root="${1:-$HOME/Code}"
  local R=$'\033[31m' Y=$'\033[33m' C=$'\033[36m' G=$'\033[32m' B=$'\033[1m' X=$'\033[0m'
  local repo_path name unpushed unpulled uncommitted max_len=4 i

  local -a repo_names pushcounts pullcounts dirtycounts

  while IFS= read -r gitdir; do
    repo_path="${gitdir%/.git}"
    name="${repo_path/#$search_root\//}"
    unpushed="$(git -C "$repo_path" log --oneline @{u}..HEAD 2>/dev/null | wc -l | tr -d ' ')"
    unpulled="$(git -C "$repo_path" log --oneline HEAD..@{u} 2>/dev/null | wc -l | tr -d ' ')"
    uncommitted="$(git -C "$repo_path" status --porcelain 2>/dev/null | grep -vc '^??' 2>/dev/null; true)"
    [[ $unpushed -gt 0 || $unpulled -gt 0 || $uncommitted -gt 0 ]] || continue
    repo_names+=("$name")
    pushcounts+=("$unpushed")
    pullcounts+=("$unpulled")
    dirtycounts+=("$uncommitted")
    [[ ${#name} -gt $max_len ]] && max_len=${#name}
  done < <(find "$search_root" -maxdepth 4 -name ".git" -type d 2>/dev/null)

  # Column visible widths
  local nc=$((max_len + 2)) pc=13 lc=13 dc=13

  # Border rows
  local nb pb lb db
  nb="$(printf '─%.0s' $(seq 1 $((nc + 2))))"
  pb="$(printf '─%.0s' $(seq 1 $((pc + 2))))"
  lb="$(printf '─%.0s' $(seq 1 $((lc + 2))))"
  db="$(printf '─%.0s' $(seq 1 $((dc + 2))))"

  printf "\n  ${B}╭${nb}┬${pb}┬${lb}┬${db}╮${X}\n"
  printf "  ${B}│${X} ${B}Repo${X}%*s ${B}│${X} ${B}Push${X}%*s ${B}│${X} ${B}Pull${X}%*s ${B}│${X} ${B}Status${X}%*s ${B}│${X}\n" \
    $((nc - 4)) "" $((pc - 4)) "" $((lc - 4)) "" $((dc - 6)) ""
  printf "  ${B}├${nb}┼${pb}┼${lb}┼${db}┤${X}\n"

  if [[ ${#repo_names[@]} -eq 0 ]]; then
    printf "  ${B}│${X} ${G}%-$((nc + pc + lc + dc + 8))s${X}${B}│${X}\n" "✓ All repos synced"
  else
    for i in {1..${#repo_names[@]}}; do
      local n_text="${repo_names[$i]}"
      local p_text="" p_color=""
      local l_text="" l_color=""
      local d_text="" d_color=""
      [[ ${pushcounts[$i]} -gt 0 ]] && { p_text="↑ ${pushcounts[$i]} to push"; p_color="$R"; }
      [[ ${pullcounts[$i]} -gt 0 ]] && { l_text="↓ ${pullcounts[$i]} to pull"; l_color="$C"; }
      [[ ${dirtycounts[$i]} -gt 0 ]] && { d_text="● uncommitted";              d_color="$Y"; }

      # Pad based on plain text length (before adding colors)
      printf "  ${B}│${X} %-${nc}s ${B}│${X} %s%s%s%*s ${B}│${X} %s%s%s%*s ${B}│${X} %s%s%s%*s ${B}│${X}\n" \
        "$n_text" \
        "$p_color" "$p_text" "$X" $((pc - ${#p_text})) "" \
        "$l_color" "$l_text" "$X" $((lc - ${#l_text})) "" \
        "$d_color" "$d_text" "$X" $((dc - ${#d_text})) ""
    done
  fi

  printf "  ${B}╰${nb}┴${pb}┴${lb}┴${db}╯${X}\n\n"
}

gsk() {
  local search_root="${1:-$HOME/Code}"
  local R=$'\033[31m' Y=$'\033[33m' C=$'\033[36m' G=$'\033[32m' B=$'\033[1m' X=$'\033[0m'
  local repo_path name unpushed unpulled uncommitted i

  local -a repo_names repo_paths pushcounts pullcounts dirtycounts

  while IFS= read -r gitdir; do
    repo_path="${gitdir%/.git}"
    name="${repo_path/#$search_root\//}"
    unpushed="$(git -C "$repo_path" log --oneline @{u}..HEAD 2>/dev/null | wc -l | tr -d ' ')"
    unpulled="$(git -C "$repo_path" log --oneline HEAD..@{u} 2>/dev/null | wc -l | tr -d ' ')"
    uncommitted="$(git -C "$repo_path" status --porcelain 2>/dev/null | grep -vc '^??' 2>/dev/null; true)"
    [[ $unpushed -gt 0 || $unpulled -gt 0 || $uncommitted -gt 0 ]] || continue
    repo_names+=("$name")
    repo_paths+=("$repo_path")
    pushcounts+=("$unpushed")
    pullcounts+=("$unpulled")
    dirtycounts+=("$uncommitted")
  done < <(find "$search_root" -maxdepth 4 -name ".git" -type d 2>/dev/null)

  if [[ ${#repo_names[@]} -eq 0 ]]; then
    printf "\n  ${G}✓ All repos already synced${X}\n\n"
    return
  fi

  printf "  ${B}Before${X}\n"
  gck "$search_root"

  printf "\n  ${B}Syncing ${#repo_names[@]} repo(s)...${X}\n\n"

  for i in {1..${#repo_names[@]}}; do
    local rname="${repo_names[$i]}"
    local rpath="${repo_paths[$i]}"
    printf "  ${B}%s${X}\n" "$rname"

    # Pull — --autostash lets git handle dirty state atomically
    if [[ ${pullcounts[$i]} -gt 0 ]]; then
      [[ ${dirtycounts[$i]} -gt 0 ]] && printf "    ${Y}● stashing changes for pull${X}\n"
      local pull_err
      pull_err="$(git -C "$rpath" pull --rebase --autostash 2>&1 1>/dev/null)"
      if [[ $? -eq 0 ]]; then
        printf "    ${C}↓ pulled %d commit(s)${X}\n" "${pullcounts[$i]}"
        [[ ${dirtycounts[$i]} -gt 0 ]] && printf "    ${Y}● changes restored${X}\n"
      elif [[ "$pull_err" == *"would be overwritten"* ]]; then
        local conflict_file
        conflict_file="$(echo "$pull_err" | grep -v '^error\|^Please\|^Aborting\|autostash' | tr -d '\t' | head -1)"
        printf "    ${R}✗ conflict: remote changed %s${X}\n" "$conflict_file"
        [[ "$pull_err" == *"autostash"* ]] && printf "    ${Y}● your changes are safe — stash was restored${X}\n"
        printf "\n"
        continue
      else
        printf "    ${R}✗ pull failed: %s${X}\n" "$(echo "$pull_err" | head -1)"
        printf "\n"
        continue
      fi
    fi

    # Push local commits
    if [[ ${pushcounts[$i]} -gt 0 ]]; then
      local push_err
      push_err="$(git -C "$rpath" push 2>&1 1>/dev/null)"
      if [[ $? -eq 0 ]]; then
        printf "    ${G}↑ pushed %d commit(s)${X}\n" "${pushcounts[$i]}"
      else
        printf "    ${R}✗ push failed: %s${X}\n" "$push_err"
      fi
    fi

    printf "\n"
  done

  printf "  ${B}After${X}\n"
  gck "$search_root"
}

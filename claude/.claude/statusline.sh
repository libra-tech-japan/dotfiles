#!/usr/bin/env zsh
# Claude Code statusLine — Starship 'tokyo' パレットの powerline 風プロンプトを再現。
#   配色は dotfiles の starship/.config/starship.toml [palettes.tokyo] と一致（truecolor）。
#   Claude Code が状態を JSON で stdin に渡す。jq があれば使い、無ければ簡易抽出にフォールバック。
emulate -L zsh

main() {
  local input; input=$(cat)

  # ---- JSON 抽出 ----
  local cwd model ctx exceeds
  if command -v jq >/dev/null 2>&1; then
    cwd=$(print -r -- "$input"     | jq -r '.cwd // .workspace.current_dir // empty')
    model=$(print -r -- "$input"   | jq -r '.model.display_name // empty')
    ctx=$(print -r -- "$input"     | jq -r '.context_window.used_percentage // empty')
    exceeds=$(print -r -- "$input" | jq -r '.exceeds_200k_tokens // false')
  else
    cwd=$(print -r -- "$input"   | sed -n 's/.*"cwd"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
    model=$(print -r -- "$input" | sed -n 's/.*"display_name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
  fi
  [[ -z "$cwd" ]] && cwd="$PWD"

  # ---- ディレクトリ短縮（starship truncation_length=3 / symbol="…/" 相当）----
  local short=${cwd/#$HOME/\~}
  local -a comps; comps=(${(s:/:)short})
  (( ${#comps} > 3 )) && short="…/${comps[-3]}/${comps[-2]}/${comps[-1]}"

  # ---- Git（cwd がリポジトリ内のときのみ）----
  local branch="" gstat="" ahead behind
  if git -C "$cwd" --no-optional-locks rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null)
    [[ -z "$branch" ]] && branch=$(git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
    [[ -n $(git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null) ]] && gstat+="*"
    ahead=$(git -C "$cwd" --no-optional-locks rev-list --count @{u}..HEAD 2>/dev/null)
    behind=$(git -C "$cwd" --no-optional-locks rev-list --count HEAD..@{u} 2>/dev/null)
    [[ ${ahead:-0} -gt 0 ]]  && gstat+="⇡${ahead}"
    [[ ${behind:-0} -gt 0 ]] && gstat+="⇣${behind}"
  fi

  # ---- OS シンボル ----
  local os_sym
  case "$OSTYPE" in
    darwin*) os_sym=$'' ;;  #  Apple
    linux*)  os_sym=$'' ;;  #  Linux
    *)       os_sym=$'' ;;
  esac

  # ---- tokyo パレット（R;G;B）----
  local HEAD='163;174;210' DIR='118;159;240' GIT='57;66;96' MID='33;39;54' TAIL='29;34;48'
  local DIRTXT='227;229;229' DARK='9;12;12' ACCENT='139;233;253' WARN='255;85;85' TIMETXT='160;169;203'
  local e=$'\033' r=$'\033[0m'
  local SEP=$'' INTRO=$'░▒▓' GBR=$'' CLOCK=$''

  # ---- セグメント組み立て（bg / fg / text）----
  local -a sbg sfg stx
  add() { sbg+=("$1"); sfg+=("$2"); stx+=("$3") }

  add "$HEAD" "$DARK"   " ${os_sym} $(whoami) "
  add "$DIR"  "$DIRTXT" " ${short} "
  if [[ -n "$branch" ]]; then
    local g=" ${GBR} ${branch}"
    [[ -n "$gstat" ]] && g+=" ${gstat}"
    add "$GIT" "$DIR" "${g} "
  fi
  [[ -n "$model" ]] && add "$MID" "$ACCENT" " ✦ ${model} "

  # tail: 時刻 + コンテキスト圧（取得できた場合のみ）
  local ttext=" ${CLOCK} $(date +%R)"
  local cstr="" cwarn=0
  if [[ -n "$ctx" ]]; then
    local ci=${ctx%%.*}; cstr="ctx ${ci}%"; (( ci >= 80 )) && cwarn=1
  elif [[ "$exceeds" == "true" ]]; then
    cstr="200k+"; cwarn=1
  fi
  if [[ -n "$cstr" ]]; then
    if (( cwarn )); then ttext+=" ${e}[38;2;${WARN}m${cstr}${e}[38;2;${TIMETXT}m"
    else ttext+=" · ${cstr}"; fi
  fi
  add "$TAIL" "$TIMETXT" "${ttext} "

  # ---- 描画（powerline: 区切りは前後セグメントの bg で接続）----
  local out="${e}[38;2;${HEAD}m${INTRO}"
  local n=${#sbg} i
  for (( i=1; i<=n; i++ )); do
    out+="${e}[48;2;${sbg[i]}m${e}[38;2;${sfg[i]}m${stx[i]}"
    if (( i < n )); then
      out+="${e}[48;2;${sbg[i+1]}m${e}[38;2;${sbg[i]}m${SEP}"
    else
      out+="${r}${e}[38;2;${sbg[i]}m${SEP}${r}"
    fi
  done
  print -rn -- "$out"
}

main

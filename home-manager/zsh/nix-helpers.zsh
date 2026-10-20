# nix-helpers.zsh — Nix rebuild helpers with a gum UI.
# Sourced from ../zsh.nix (programs.zsh.initContent).
#
#   hms [-p] [perfil]   Home-manager Switch   (USER layer, all platforms)
#   nrs [host]          Nixos-Rebuild Switch  (SYSTEM layer, NixOS only)
#   nfu [inputs…]       Nix Flake Update      (diff table + optional hms)
#   nclean              nh clean, shows reclaimed space
#   nsearch [query]     nh search (prompts when empty)
#   ngen [--system]     pick + activate a previous generation
#   nixprofiles         list homeConfigurations keys
#   nxhelp              this list, as a card
#
# hms and nrs are strictly separate; never chained. Every helper falls back
# to plain text when stdout is not a TTY, gum is missing, NO_COLOR is set or
# TERM=dumb.
#
# Knobs (environment):
#   NX_MOTION=0     no reveal animation / spinners (reduced motion)
#   NX_ICONS=0      ASCII instead of Nerd Font glyphs
#   NX_PROGRESS=1   force the OSC 9;4 taskbar progress (auto: Ghostty)
#
# nh / nix-output-monitor own the terminal while they run: nothing is ever
# drawn on top of them (nom redraws by clearing and reprinting). Animation
# only happens before and after; the OSC 9;4 progress is not drawn in the
# text grid.

zmodload zsh/zselect

zmodload zsh/datetime

typeset -g _NIX_FLAKE="$HOME/.config/nixos"
typeset -g _NIX_PROFILE_CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/nix-home-profiles"

# Palette — same colours as the 🐼 starship prompt.
typeset -gA _NX_C=(
  teal   '#00FFC6'  pink   '#EA047E'  yellow '#FFED00'  lime   '#85EF47'
  green  '#22c55e'  red    '#ef4444'  orange '#FF5722'  blue   '#38bdf8'
  violet '#a78bfa'  amber  '#E5B273'  dim    '#8b93a6'  white  '#f1f5f9'
  ink    '#0b1020'  chip   '#262a40'
  rose   '#FF6EB4'  mist   '#c3c9d9'
)
# Interactive prompts (gum choose/confirm), WCAG-checked on the Warp
# background (#1e1b3a–#3a3a6e): ink on rose 7.3:1, mist 6.3–10:1, teal 8+:1.
# (pink #EA047E alone is only 2.4–3.8:1 there, so it is never used as text.)
typeset -ga _NX_CHOOSE_STYLE=(
  --header.foreground "${_NX_C[teal]}"
  --cursor.foreground "${_NX_C[ink]}" --cursor.background "${_NX_C[rose]}"
  --item.foreground   "${_NX_C[mist]}"
)
typeset -ga _NX_CONFIRM_STYLE=(
  --prompt.foreground     "${_NX_C[teal]}"
  --selected.foreground   "${_NX_C[ink]}"  --selected.background   "${_NX_C[rose]}"
  --unselected.foreground "${_NX_C[mist]}" --unselected.background "${_NX_C[chip]}"
)

# Nerd Font glyphs (v3 codepoints).
typeset -gA _NX_I=(
  nix     $''      home    $'\U000f02dc'  user    $''
  host    $'\U000f0322'  server  $'\U000f048b'  apple   $''
  linux   $''      branch  $''      pkg     $'\U000f03d7'
  ok      $''      fail    $''      warn    $''
  clock   $''      gen     $'\U000f02da'  update  $'\U000f06b0'
  broom   $'\U000f00e2'  trash   $'\U000f01b4'  search  $''
  reboot  $'\U000f0709'  star    $''      disk    $'\U000f02ca'
  dot     $'●'      check   $''      up      $''
  undo    $'\U000f054c'  arrow   $''      cmd     $''
)
if [[ ${NX_ICONS:-1} == 0 ]]; then
  _NX_I=(
    nix '*' home '~' user '@' host '#' server '#' apple '' linux ''
    branch '' pkg '+' ok 'OK' fail 'X' warn '!' clock 't' gen 'g'
    update '^' broom '-' trash '-' search '?' reboot '!' star '>'
    disk 'd' dot '*' check 'v' up '^' undo '<' arrow '>' cmd '$'
  )
fi

# Gradient partner for each card colour (pill background fades into it).
typeset -gA _NX_G=(
  teal blue  blue violet  violet pink  pink orange  amber orange
  red orange  green lime  lime teal  yellow amber  orange red
)

# ── UI primitives ─────────────────────────────────────────────────────────
#
# Fancy mode is decided ONCE per public command (`local _NX_FANCY;
# _nx_begin`), against the real stdout. Helpers below run inside $(…),
# where stdout is a pipe, so they must read the flag instead of testing -t.

_nx_begin() {
  _NX_FANCY=0 _NX_MOTION=0
  [[ -t 1 && -z ${NO_COLOR-} && $TERM != dumb ]] && (( $+commands[gum] )) \
    && _NX_FANCY=1
  (( _NX_FANCY )) && [[ ${NX_MOTION:-1} != 0 ]] && _NX_MOTION=1
}
_nx_fancy()  { (( ${_NX_FANCY:-0} )) }
_nx_motion() { (( ${_NX_MOTION:-0} )) }

# gum prompts draw on the terminal and print the answer on stdout, so they
# work inside $(…); they only need an interactive stdin/stderr.
_nx_interactive() { [[ -t 0 && -t 2 ]] && (( $+commands[gum] )) }

# 24-bit SGR from a palette name: _nx_sgr 38|48 <colour>
_nx_sgr() {
  local h=${_NX_C[$2]#\#}
  print -rn -- $'\e['"$1;2;$(( 16#${h[1,2]} ));$(( 16#${h[3,4]} ));$(( 16#${h[5,6]} ))m"
}

# _nx_c <colour> <text> [bold] → coloured text (plain when not fancy).
_nx_c() {
  if _nx_fancy; then
    local bold=''; [[ -n $3 ]] && bold=$'\e[1m'
    print -rn -- "$bold$(_nx_sgr 38 $1)$2"$'\e[0m'
  else
    print -rn -- "$2"
  fi
}

# Solid badge: dark text on a background that fades from <colour> into its
# _NX_G partner, one cell at a time (24-bit interpolation).
_nx_pill() {
  if ! _nx_fancy; then print -rn -- "[$2]"; return; fi
  local a=${_NX_C[$1]#\#} b=${_NX_C[${_NX_G[$1]:-$1}]#\#} text=" $2 " out ch
  local -i n=${#text} i=0 d r1 g1 b1 r2 g2 b2
  r1=16#${a[1,2]} g1=16#${a[3,4]} b1=16#${a[5,6]}
  r2=16#${b[1,2]} g2=16#${b[3,4]} b2=16#${b[5,6]}
  d=$(( n > 1 ? n - 1 : 1 ))
  out=$'\e[1m'"$(_nx_sgr 38 ink)"
  for ch in ${(s::)text}; do
    out+=$'\e[48;2;'"$(( r1 + (r2 - r1) * i / d ));$(( g1 + (g2 - g1) * i / d ));$(( b1 + (b2 - b1) * i / d ))m$ch"
    (( i++ ))
  done
  print -rn -- "$out"$'\e[0m'
}

# Soft badge: coloured text on a dark chip.
_nx_chip() {
  if _nx_fancy; then
    print -rn -- "$(_nx_sgr 48 chip)$(_nx_sgr 38 $1) $2 "$'\e[0m'
  else
    print -rn -- "($2)"
  fi
}

# Print rendered UI. With motion, reveal it line by line (~12 ms/line,
# each line inside a synchronized-output frame); never delays plain output.
_nx_emit() {
  if ! _nx_motion; then print -r -- "$1"; return; fi
  local line
  for line in "${(@f)1}"; do
    print -rn -- $'\e[?2026h'"$line"$'\n\e[?2026l'
    zselect -t 1 2>/dev/null
  done
}

# gum output captured in $(…) is not a TTY, so lipgloss would strip every
# colour; we already decided fancy mode against the real terminal.
_nx_gum() { CLICOLOR_FORCE=1 COLORTERM=truecolor gum "$@" }

# Strip control characters from untrusted display text (file names…).
_nx_safe() { print -rn -- "${1//[[:cntrl:]]/?}" }

# _nx_spin <title> <cmd…>: spinner while a quiet command runs; its output
# is shown only if it fails. Decided on the real terminal (stdin/stderr),
# so it also works when the caller captures stdout.
_nx_spin() {
  local title=$1; shift
  if _nx_interactive && [[ ${NX_MOTION:-1} != 0 && -z ${NO_COLOR-} && $TERM != dumb ]]; then
    gum spin --spinner points --title " $title" --show-error \
      --spinner.foreground "${_NX_C[pink]}" --title.foreground "${_NX_C[teal]}" \
      -- "$@"
  else
    "$@"
  fi
}

# OSC 9;4 taskbar/tab progress (indeterminate) while nh runs. Re-sent every
# second (Ghostty drops it after ~15 s of silence). Written to /dev/tty, not
# the text grid, so nom's output is untouched. Auto-enabled on Ghostty only;
# NX_PROGRESS=1 forces it elsewhere (Warp/kitty support is unverified).
_nx_progress_on() {
  [[ $TERM_PROGRAM == ghostty || ${NX_PROGRESS:-} == 1 ]] || return 0
  _nx_fancy || return 0
  # Stops on its own if the shell that started it dies (SIGHUP/SIGTERM
  # skip _nx_progress_off).
  local parent=$$
  { while kill -0 $parent 2>/dev/null; do
      printf '\e]9;4;3\e\\' >/dev/tty 2>/dev/null || break; sleep 1
    done } &!
  typeset -g _NX_PROGRESS_PID=$!
}
_nx_progress_off() { # [state: 0 done, 2 error]
  [[ -n ${_NX_PROGRESS_PID-} ]] || return 0
  kill $_NX_PROGRESS_PID 2>/dev/null
  printf '\e]9;4;%s\e\\' "${1:-0}" >/dev/tty
  (( ${1:-0} )) && { sleep 1; printf '\e]9;4;0\e\\' >/dev/tty } &!
  unset _NX_PROGRESS_PID
}

# _nx_row <icon colour> <icon> <label> <value>
_nx_row() {
  print -rn -- " $(_nx_c $1 "$2")  $(_nx_c dim "${(r:8:)3}") $4"
}

# _nx_card <colour> <icon> <TITLE> <subtitle> <rows…>
_nx_card() {
  local color=$1 icon=$2 title=$3 sub=$4; shift 4
  local head="$(_nx_pill $color "$icon  $title")${sub:+  $(_nx_c dim "$sub")}"
  if _nx_fancy; then
    _nx_emit "$(_nx_gum style --border rounded --border-foreground "${_NX_C[$color]}" \
      --padding "0 1" --margin "1 0 0 0" "$head" "" "$@")"
  else
    print -r -- "== $title${sub:+ — $sub}"
    local r; for r in "$@"; do print -r -- "   $r"; done
  fi
}

# One-line closing card: <colour> <pill text> <chips…>
_nx_banner() {
  local color=$1 head=$2; shift 2
  local line="$(_nx_pill $color "$head")" c
  for c in "$@"; do line+=" $c"; done
  if _nx_fancy; then
    _nx_emit "$(_nx_gum style --border rounded --border-foreground "${_NX_C[$color]}" \
      --padding "0 1" "$line")"
  else
    print -r -- "$line"
  fi
}

_nx_warn() { _nx_card amber "${_NX_I[warn]}" "$1" "$2" "${@:3}" }

# Dim rule that introduces nh's own output.
_nx_rule() {
  _nx_fancy || return
  print -r -- "$(_nx_c dim " ${_NX_I[cmd]}  $1 ${(l:40::─:)}")"
}

_nx_dur() {
  local s=$1
  (( s >= 60 )) && printf '%dm %02ds' $(( s / 60 )) $(( s % 60 )) || printf '%ds' $s
}

_nx_ago() {
  local s=$1
  if   (( s < 3600 ));  then print -n "$(( s / 60 ))m"
  elif (( s < 86400 )); then print -n "$(( s / 3600 ))h"
  else                       print -n "$(( s / 86400 ))d"
  fi
}

# Traffic light for input age: <1w lime, <1mo yellow, older orange.
_nx_age_color() {
  if   (( $1 < 604800 ));  then print -n lime
  elif (( $1 < 2592000 )); then print -n yellow
  else                          print -n orange
  fi
}

_nx_human_kb() {
  local kb=$1
  if (( kb >= 1048576 )); then printf '%.1f GiB' $(( kb / 1048576.0 ))
  elif (( kb >= 1024 ));  then printf '%.0f MiB' $(( kb / 1024.0 ))
  else                         printf '%d KiB' $kb
  fi
}

_nx_notify() {
  (( $2 < 30 )) && return
  if [[ $OSTYPE == darwin* ]]; then
    osascript -e "display notification \"$1\" with title \"Nix\"" 2>/dev/null
  elif (( $+commands[notify-send] )); then
    notify-send "Nix" "$1" 2>/dev/null
  fi
}

# ── Context ───────────────────────────────────────────────────────────────

# True only on NixOS — hostname-independent (reads /etc/os-release ID).
_is_nixos() {
  [[ -r /etc/os-release ]] && grep -q '^ID=nixos' /etc/os-release
}

# Auto-derive the home-manager flake profile key for THIS environment.
#   macOS       → $USER@mac
#   NixOS       → $USER@<hostname>   (declarative hostname → matches key)
#   other Linux → $USER@ubuntu-mac   (fixed; NO hostname match required)
_hm_profile() {
  if [[ "$OSTYPE" == darwin* ]]; then
    echo "${USER}@mac"
  elif _is_nixos; then
    echo "${USER}@$(hostname -s)"
  else
    echo "${USER}@ubuntu-mac"
  fi
}

_nx_os() {
  if [[ $OSTYPE == darwin* ]]; then
    print -n "$(_nx_c white "${_NX_I[apple]} macOS $(sw_vers -productVersion)") $(_nx_c dim "· $(uname -m)")"
  elif _is_nixos; then
    print -n "$(_nx_c blue "${_NX_I[nix]} NixOS $(nixos-version 2>/dev/null | cut -d' ' -f1)") $(_nx_c dim "· $(uname -m)")"
  else
    print -n "$(_nx_c amber "${_NX_I[linux]} Linux") $(_nx_c dim "· $(uname -m)")"
  fi
}

_nx_host_row() {
  _nx_row blue "${_NX_I[host]}" host "$(_nx_c white "$(hostname -s)")  $(_nx_os)"
}

# _nx_inputs_row <input…>: age of each root flake input's locked revision,
# read with a single jq call ("name lastModified" per input).
_nx_inputs_row() {
  local -a parts; local n ts s stale=0
  for n ts in $(jq -r '
      .nodes as $nodes | .nodes.root.inputs as $in
      | $ARGS.positional[]
      | select($in[.] | type == "string")
      | . as $n | ($nodes[$in[$n]].locked.lastModified // empty)
      | "\($n) \(.)"' --args "$@" <"$_NIX_FLAKE/flake.lock" 2>/dev/null); do
    s=$(( EPOCHSECONDS - ts ))
    parts+=("$(_nx_c white $n) $(_nx_chip $(_nx_age_color $s) "$(_nx_ago $s)")")
    (( s >= 2592000 )) && stale=1
  done
  (( stale )) && parts+=("$(_nx_c dim "${_NX_I[arrow]} nfu")")
  _nx_row lime "${_NX_I[pkg]}" inputs "${(j:  :)parts}"
}

# Sets $reply to the git rows: branch/dirty/ahead + untracked .nix files,
# which the flake cannot see until they are `git add`ed.
_nx_git_rows() {
  local d=$_NIX_FLAKE branch dirty ahead v f
  branch=$(git -C $d symbolic-ref --short HEAD 2>/dev/null) \
    || branch=$(git -C $d rev-parse --short HEAD 2>/dev/null)
  dirty=$(git -C $d status --porcelain 2>/dev/null | wc -l | tr -d ' ')
  ahead=$(git -C $d rev-list --count '@{upstream}..HEAD' 2>/dev/null)
  v="$(_nx_c yellow "$branch" bold)  "
  if (( dirty )); then v+="$(_nx_chip orange "${_NX_I[dot]} $dirty sin commit")"
  else                 v+="$(_nx_chip lime "${_NX_I[check]} limpio")"
  fi
  (( ahead )) && v+=" $(_nx_chip blue "${_NX_I[up]} $ahead sin push")"
  reply=("$(_nx_row yellow "${_NX_I[branch]}" rama "$v")")
  for f in ${(f)"$(git -C $d ls-files --others --exclude-standard -- '*.nix' 2>/dev/null)"}; do
    reply+=("$(_nx_row orange "${_NX_I[warn]}" 'sin git' "$(_nx_c amber "$(_nx_safe "$f")")  $(_nx_c dim 'el flake no lo ve · git add')")")
  done
}

# Generation number of a profile symlink (…/home-manager-14-link → 14).
_nx_gen() {
  local link; link=$(readlink "$1" 2>/dev/null) || return 1
  link=${link:t}; link=${link%-link}; print -n "${link##*-}"
}

_nx_hm_profile_link() { print -n "${XDG_STATE_HOME:-$HOME/.local/state}/nix/profiles/home-manager" }

# Runs a nix command without the "Git tree is dirty" warning (the card
# already shows it). Sets _NX_ELAPSED; returns the command's status.
_nx_run() {
  local start=$EPOCHSECONDS st
  setopt localoptions localtraps
  trap '_nx_progress_off 2; return 130' INT
  _nx_progress_on
  local -x NIX_CONFIG="warn-dirty = false${NIX_CONFIG:+$'\n'$NIX_CONFIG}"
  "$@"
  st=$?
  _nx_progress_off $(( st ? 2 : 0 ))
  typeset -g _NX_ELAPSED=$(( EPOCHSECONDS - start ))
  return $st
}

# Shared closing banners for switch commands.
_nx_done_ok() {   # <gen> <rollback cmd> [extra chips…]
  _nx_banner green "${_NX_I[ok]}  APLICADO" \
    "$(_nx_chip lime "${_NX_I[gen]} gen $1")" \
    "$(_nx_chip blue "${_NX_I[clock]} $(_nx_dur $_NX_ELAPSED)")" \
    "${@:3}" \
    "$(_nx_chip violet "${_NX_I[undo]} $2")"
}
_nx_done_fail() { # <status>
  _nx_banner red "${_NX_I[fail]}  FALLÓ" \
    "$(_nx_chip red "código $1")" \
    "$(_nx_chip blue "${_NX_I[clock]} $(_nx_dur $_NX_ELAPSED)")" \
    "$(_nx_chip dim "${_NX_I[search]} revisa el error arriba")"
}

# ── Profiles ──────────────────────────────────────────────────────────────

# List homeConfigurations keys. Cached; refreshes when flake.nix/flake.lock
# change or on `nixprofiles --refresh`. Avoids a ~1-2s nix eval on every switch.
# Plain list when piped (used by hms); decorated card at a terminal.
nixprofiles() {
  local _NX_FANCY; _nx_begin
  local lock="${_NIX_FLAKE}/flake.lock"
  if [[ "$1" == "--refresh" || ! -s "$_NIX_PROFILE_CACHE" \
        || "$lock" -nt "$_NIX_PROFILE_CACHE" || "${_NIX_FLAKE}/flake.nix" -nt "$_NIX_PROFILE_CACHE" ]]; then
    mkdir -p "${_NIX_PROFILE_CACHE:h}"
    local list
    # Only replace the cache on a successful, non-empty eval, so a broken
    # flake doesn't leave an empty cache that looks valid.
    list=$(_nx_spin "evaluando perfiles del flake…" \
      nix eval "${_NIX_FLAKE}#homeConfigurations" --apply builtins.attrNames --json 2>/dev/null \
      | jq -r '.[]' 2>/dev/null)
    if [[ -n $list ]]; then
      print -r -- "$list" > "$_NIX_PROFILE_CACHE.$$" && mv -f "$_NIX_PROFILE_CACHE.$$" "$_NIX_PROFILE_CACHE"
    elif [[ ! -s "$_NIX_PROFILE_CACHE" ]]; then
      _nx_warn "SIN PERFILES" "nix eval falló" " $(_nx_c dim 'revisa: nix flake check')" >&2
      return 1
    fi
  fi
  if _nx_fancy; then
    local cur=$(_hm_profile) p; local -a rows
    for p in ${(f)"$(<$_NIX_PROFILE_CACHE)"}; do
      if [[ $p == $cur ]]; then
        rows+=(" $(_nx_c yellow "${_NX_I[star]}")  $(_nx_c pink "$p" bold)  $(_nx_chip lime 'este equipo')")
      else
        rows+=(" $(_nx_c blue "${_NX_I[user]}")  $(_nx_c white "$p")")
      fi
    done
    _nx_card teal "${_NX_I[nix]}" "PERFILES" "homeConfigurations" "${rows[@]}"
  else
    cat "$_NIX_PROFILE_CACHE"
  fi
}

# Interactive profile picker; prints the chosen key.
_nx_pick_profile() {
  if ! _nx_interactive; then
    echo "valid: $(nixprofiles | paste -sd, -)" >&2
    return 1
  fi
  gum choose --header "${_NX_I[nix]}  Elige perfil home-manager" \
    $_NX_CHOOSE_STYLE --cursor "${_NX_I[star]} " --selected "$(_hm_profile)" \
    ${(f)"$(nixprofiles | cat)"}
}

# ── hms — Home-manager Switch ─────────────────────────────────────────────
hms() {
  local _NX_FANCY; _nx_begin
  local pick=0 profile
  case $1 in
    -p|--pick) pick=1; shift ;;
    -h|--help) nxhelp; return ;;
  esac
  profile=${1:-$(_hm_profile)}
  if (( pick )) || ! nixprofiles | grep -qx -- "$profile"; then
    (( pick )) || _nx_warn "PERFIL DESCONOCIDO" "$profile" \
      " $(_nx_c dim 'elige uno de la lista')" >&2
    profile=$(_nx_pick_profile) || { _nx_banner red "${_NX_I[fail]}  SIN PERFIL" >&2; return 1; }
  fi

  _nx_git_rows
  _nx_card teal "${_NX_I[home]}" "HOME-MANAGER SWITCH" "nh home switch" \
    "$(_nx_row pink "${_NX_I[user]}" perfil "$(_nx_c pink "$profile" bold)")" \
    "$(_nx_host_row)" \
    "${reply[@]}" \
    "$(_nx_inputs_row nixpkgs home-manager)"
  _nx_rule "nh home switch"

  if _nx_run nh home switch "$_NIX_FLAKE" -c "$profile" -b backup; then
    print
    _nx_done_ok "$(_nx_gen "$(_nx_hm_profile_link)")" ngen
    _nx_notify "home-manager aplicado ($profile)" $_NX_ELAPSED
  else
    local st=$?
    print
    _nx_done_fail $st
    _nx_notify "home-manager falló ($profile)" $_NX_ELAPSED
    return $st
  fi
}

# ── nrs — Nixos-Rebuild Switch ────────────────────────────────────────────
nrs() {
  local _NX_FANCY; _nx_begin
  if ! _is_nixos; then
    _nx_card red "${_NX_I[fail]}" "SOLO NIXOS" "nrs = nixos-rebuild switch" \
      "$(_nx_host_row)" \
      "$(_nx_row pink "${_NX_I[home]}" usa "$(_nx_c pink hms bold)  $(_nx_c dim 'para la capa de usuario')")" >&2
    return 1
  fi
  local host="${1:-$(hostname -s)}"

  _nx_git_rows
  _nx_card blue "${_NX_I[nix]}" "NIXOS-REBUILD SWITCH" "nh os switch" \
    "$(_nx_row pink "${_NX_I[server]}" host "$(_nx_c pink "$host" bold)  $(_nx_os)")" \
    "$(_nx_row amber "${_NX_I[linux]}" kernel "$(_nx_c white "$(uname -r)")")" \
    "${reply[@]}" \
    "$(_nx_inputs_row nixpkgs hyprland)"
  _nx_rule "nh os switch"

  if _nx_run nh os switch "$_NIX_FLAKE" -H "$host"; then
    local -a extra
    if [[ "$(readlink /run/booted-system/kernel)" != "$(readlink /run/current-system/kernel)" ]]; then
      extra=("$(_nx_chip yellow "${_NX_I[reboot]} reinicio recomendado")")
    fi
    print
    _nx_done_ok "$(_nx_gen /nix/var/nix/profiles/system)" "ngen --system" "${extra[@]}"
    _nx_notify "NixOS aplicado ($host)" $_NX_ELAPSED
  else
    local st=$?
    print
    _nx_done_fail $st
    _nx_notify "NixOS falló ($host)" $_NX_ELAPSED
    return $st
  fi
}

# ── nfu — Nix Flake Update ────────────────────────────────────────────────
# No args = every input; or name inputs: nfu nixpkgs
nfu() {
  local _NX_FANCY; _nx_begin
  local lock="$_NIX_FLAKE/flake.lock" before rows
  before=$(mktemp) && cp "$lock" "$before"

  _nx_card violet "${_NX_I[update]}" "NIX FLAKE UPDATE" "flake.lock" \
    "$(_nx_row violet "${_NX_I[update]}" alcance "${*:-$(_nx_c white todos)}")" \
    "$(_nx_inputs_row ${(f)"$(jq -r '.nodes.root.inputs | keys[]' "$lock" 2>/dev/null)"})"
  _nx_run _nx_spin "actualizando flake.lock…" \
    nix flake update --flake "$_NIX_FLAKE" "$@"
  local st=$?
  if (( st )); then
    rm -f "$before"
    _nx_done_fail $st
    return $st
  fi

  # name <TAB> old rev <TAB> old ts <TAB> new rev <TAB> new ts, changed only
  rows=$(jq -rn --slurpfile a "$before" --slurpfile b "$lock" '
    $a[0] as $o | $b[0] as $n
    | $n.nodes.root.inputs | to_entries[]
    | select(.value | type == "string")
    | .key as $name
    | ($o.nodes[$o.nodes.root.inputs[$name] // ""].locked // {}) as $ol
    | ($n.nodes[.value].locked // {}) as $nl
    | select(($ol.narHash // "") != ($nl.narHash // ""))
    | [$name, (($ol.rev // "—")[0:7]), ($ol.lastModified // 0),
              (($nl.rev // "—")[0:7]), ($nl.lastModified // 0)] | @tsv')
  rm -f "$before"

  if [[ -z $rows ]]; then
    print
    _nx_banner green "${_NX_I[check]}  TODO AL DÍA" \
      "$(_nx_chip blue "${_NX_I[clock]} $(_nx_dur $_NX_ELAPSED)")"
    return 0
  fi

  # gum table --print paints the first data row with the header style, so the
  # header is coloured inline instead and both styles stay neutral.
  local csv="$(_nx_c pink '  input' bold),$(_nx_c pink antes bold),$(_nx_c pink después bold),$(_nx_c pink Δ bold)"
  local name orev ots nrev nts
  while IFS=$'\t' read -r name orev ots nrev nts; do
    local od='—' nd='—' delta='nuevo'
    (( ots )) && od="$orev  $(strftime %Y-%m-%d $ots)"
    (( nts )) && nd="$nrev  $(strftime %Y-%m-%d $nts)"
    (( ots && nts )) && delta="+$(( (nts - ots) / 86400 ))d"
    csv+=$'\n'"${_NX_I[pkg]} $name,$od,$nd,$delta"
  done <<< "$rows"

  print
  if _nx_fancy; then
    print -r -- "$csv" | _nx_gum table --print --border rounded \
      --border.foreground "${_NX_C[violet]}" --header.foreground "${_NX_C[white]}" \
      --cell.foreground "${_NX_C[white]}" --selected.foreground "${_NX_C[white]}"
  else
    print -r -- "$csv" | column -t -s,
  fi
  _nx_banner green "${_NX_I[ok]}  ACTUALIZADO" \
    "$(_nx_chip lime "${_NX_I[pkg]} ${#${(f)rows}} input(s)")" \
    "$(_nx_chip blue "${_NX_I[clock]} $(_nx_dur $_NX_ELAPSED)")" \
    "$(_nx_chip violet "${_NX_I[undo]} git checkout flake.lock")"

  if _nx_fancy && gum confirm "¿Aplicar ahora con hms?" --default=false \
      $_NX_CONFIRM_STYLE; then
    hms
  fi
}

# ── nclean — garbage-collect via nh, report reclaimed space ───────────────
nclean() {
  local _NX_FANCY; _nx_begin
  local free_before free_after scope=user
  _is_nixos && scope=all
  free_before=$(df -k /nix | awk 'NR==2 {print $4}')

  _nx_card amber "${_NX_I[broom]}" "NIX CLEAN" "nh clean $scope" \
    "$(_nx_row blue "${_NX_I[disk]}" libre "$(_nx_c white "$(_nx_human_kb $free_before)") $(_nx_c dim 'en /nix')")" \
    "$(_nx_row lime "${_NX_I[gen]}" conserva "$(_nx_chip lime '30 días')  $(_nx_chip lime '≥ 5 generaciones')")"
  _nx_rule "nh clean $scope"

  if _nx_run nh clean $scope --keep-since 30d --keep 5 --ask; then
    free_after=$(df -k /nix | awk 'NR==2 {print $4}')
    local freed=$(( free_after - free_before ))
    (( freed < 0 )) && freed=0
    print
    _nx_banner green "${_NX_I[ok]}  LIMPIO" \
      "$(_nx_chip lime "${_NX_I[trash]} $(_nx_human_kb $freed) liberados")" \
      "$(_nx_chip blue "${_NX_I[disk]} $(_nx_human_kb $free_after) libres")"
  else
    print
    _nx_banner amber "${_NX_I[warn]}  CANCELADO"
  fi
}

# ── nsearch — nh search, prompting when no query is given ─────────────────
nsearch() {
  local _NX_FANCY; _nx_begin
  local q="$*"
  if [[ -z $q ]] && _nx_interactive; then
    q=$(gum input --prompt "${_NX_I[search]}  " --placeholder "paquete u opción…" \
      --prompt.foreground "${_NX_C[teal]}" --cursor.foreground "${_NX_C[rose]}")
  fi
  [[ -z $q ]] && { _nx_banner amber "${_NX_I[warn]}  BÚSQUEDA VACÍA" >&2; return 1; }
  local out
  out=$(_nx_spin "buscando “$q”…" nh search ${=q}) \
    || { _nx_banner red "${_NX_I[fail]}  BÚSQUEDA FALLÓ" >&2; return 1; }
  print -r -- "$out"
}

# ── ngen — pick and activate a previous generation ────────────────────────
ngen() {
  local _NX_FANCY; _nx_begin
  if [[ $1 == --system ]]; then
    if ! _is_nixos; then
      _nx_banner red "${_NX_I[fail]}  SOLO NIXOS" "$(_nx_chip dim 'ngen --system')" >&2
      return 1
    fi
    _nx_card blue "${_NX_I[gen]}" "GENERACIONES DEL SISTEMA" "nh os info" \
      "$(_nx_row lime "${_NX_I[gen]}" actual "$(_nx_chip lime "gen $(_nx_gen /nix/var/nix/profiles/system)")")"
    nh os info 2>/dev/null | head -15
    _nx_interactive && gum confirm "¿Volver a la generación anterior del sistema?" --default=false $_NX_CONFIRM_STYLE \
      && nh os rollback
    return
  fi

  local -a gens labels; local line id date gpath cur
  gens=(${(f)"$(home-manager generations 2>/dev/null)"})
  (( ${#gens} )) || { _nx_banner red "${_NX_I[fail]}  SIN GENERACIONES" >&2; return 1; }
  if ! _nx_interactive; then print -rl -- $gens; return; fi
  _nx_card pink "${_NX_I[gen]}" "GENERACIONES" "home-manager" \
    "$(_nx_row lime "${_NX_I[gen]}" actual "$(_nx_chip lime "gen $(_nx_gen "$(_nx_hm_profile_link)")")")" \
    "$(_nx_row blue "${_NX_I[clock]}" total "$(_nx_c white "${#gens}") $(_nx_c dim 'generaciones disponibles')")"

  # "2026-10-19 13:30 : id 13 -> /nix/store/…-home-manager-generation (current)"
  for line in $gens; do
    date=${line%% : *}; id=${${line#*id }%% *}; gpath=${${line#*-> }%% *}
    cur=''; [[ $line == *'(current)' ]] && cur="   ${_NX_I[star]} actual"
    labels+=("${_NX_I[gen]} gen ${(l:3:)id}   ${_NX_I[clock]} $date$cur"$'\x1f'"$id|$gpath")
  done

  local choice
  choice=$(gum choose --header "${_NX_I[gen]}  Elige generación home-manager" \
    $_NX_CHOOSE_STYLE --cursor "${_NX_I[arrow]} " --label-delimiter $'\x1f' --height 12 $labels) || return 1
  id=${choice%%|*}; gpath=${choice#*|}

  if gum confirm "¿Activar la generación $id?" --default=false \
      $_NX_CONFIRM_STYLE; then
    if "$gpath/activate"; then
      _nx_banner green "${_NX_I[ok]}  ACTIVADA" \
        "$(_nx_chip lime "${_NX_I[gen]} gen $id")" \
        "$(_nx_chip dim 'abre una terminal nueva')"
    else
      _nx_banner red "${_NX_I[fail]}  NO SE PUDO ACTIVAR" "$(_nx_chip red "gen $id")"
      return 1
    fi
  fi
}

# ── nxhelp ────────────────────────────────────────────────────────────────
nxhelp() {
  local _NX_FANCY; _nx_begin
  local -a rows; local spec cmd args desc color
  for spec in \
    "teal|hms|[-p] [perfil]|home-manager switch" \
    "blue|nrs|[host]|nixos-rebuild switch (NixOS)" \
    "violet|nfu|[inputs…]|nix flake update + tabla de cambios" \
    "amber|nclean||limpieza + espacio liberado" \
    "lime|nsearch|[query]|buscar paquetes / opciones" \
    "pink|ngen|[--system]|elegir y activar una generación" \
    "yellow|nixprofiles|[--refresh]|perfiles del flake"; do
    color=${spec%%|*}; spec=${spec#*|}
    cmd=${spec%%|*}; spec=${spec#*|}
    args=${spec%%|*}; desc=${spec#*|}
    rows+=(" $(_nx_c $color "${_NX_I[arrow]}") $(_nx_c $color "${(r:12:)cmd}" bold)$(_nx_c dim "${(r:15:)args}")$(_nx_c white "$desc")")
  done
  rows+=("" " $(_nx_c dim 'NO_COLOR=1 · NX_MOTION=0 sin animación · NX_ICONS=0 ASCII · NX_PROGRESS=1')")
  _nx_card teal "${_NX_I[nix]}" "NIX HELPERS" "~/.config/nixos" "${rows[@]}"
}

# ── Completion ────────────────────────────────────────────────────────────
_hms() {
  local -a profiles
  profiles=(${(f)"$(nixprofiles 2>/dev/null | cat)"})
  compadd -- -p --pick
  compadd -a profiles
}
compdef _hms hms

_nfu() {
  local -a inputs
  inputs=(${(f)"$(jq -r '.nodes.root.inputs | keys[]' "$_NIX_FLAKE/flake.lock" 2>/dev/null)"})
  compadd -a inputs
}
compdef _nfu nfu

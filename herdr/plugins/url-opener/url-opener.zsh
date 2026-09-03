#!/bin/zsh

setopt no_nomatch

prompt_color=$'\e[42;30m'
active_link_highlight=$'\e[44;4m'
normal_link_highlight=$'\e[94;1;4m'
reset=$'\e[0m'

# Adapted from urxvt's url-select regex.
url_pattern="(https?://|ftp://|news://|git://|mailto:|file://|www\\.)[[:alnum:]_@;/?:&=%\\$.,+!*'()~#-]*[[:alnum:]_@;/?&=%\\$+!*'(~#-]"

herdr=${HERDR_BIN_PATH:-herdr}
pane_id=${HERDR_URL_SOURCE_PANE:-${HERDR_ACTIVE_PANE_ID:-$HERDR_PANE_ID}}
if [[ -z $pane_id && -n $HERDR_PLUGIN_CONTEXT_JSON ]]; then
  pane_id=$(printf '%s' "$HERDR_PLUGIN_CONTEXT_JSON" | jq -r '.focused_pane_id // empty' 2>/dev/null)
fi

fail() {
  print -ru2 -- "$1"
  sleep 1
  exit 1
}

[[ -n $pane_id ]] || fail 'No active Herdr pane'

read rows columns <<<"$(stty size)"
[[ $rows == <-> ]] || rows=80
[[ $columns == <-> ]] || columns=80

buffer=$("$herdr" pane read "$pane_id" \
  --source recent-unwrapped --lines "$rows" --format text) \
  || fail 'Failed to read Herdr pane'

typeset -a matches
rest=$buffer
while [[ $rest =~ $url_pattern ]]; do
  matches+=("$MATCH")
  rest=${rest[$((MEND + 1)),-1]}
done

(( ${#matches} )) || fail 'No URLs'
selection=${#matches}

display() {
  local highlighted='' color keymap prompt_column
  local rest=$buffer
  local index=1

  while [[ $rest =~ $url_pattern ]]; do
    highlighted+=${rest[1,$((MBEGIN - 1))]}
    if (( index == selection )); then
      color=$active_link_highlight
    else
      color=$normal_link_highlight
    fi
    highlighted+=$color$MATCH$reset
    rest=${rest[$((MEND + 1)),-1]}
    (( index++ ))
  done
  highlighted+=$rest

  print -rn -- $'\e[H\e[2J'
  print -rn -- "$highlighted"
  keymap=" URL select: ($selection/${#matches}) [↑/↓ select, enter open, c copy, q/esc quit] "
  (( prompt_column = columns - ${#keymap} + 1 ))
  (( prompt_column < 1 )) && prompt_column=1
  printf '\e[1;%dH%s%s%s' "$prompt_column" "$prompt_color" "$keymap" "$reset"
}

selected_url() {
  local url=${matches[$selection]}
  [[ $url == www.* ]] && url="http://$url"
  print -r -- "$url"
}

copy_url() {
  selected_url | pbcopy || fail 'Failed to copy URL'
}

open_url() {
  open "$(selected_url)" || fail 'Failed to open URL'
}

display
while read -rsk 1 key; do
  if [[ $key == $'\e' ]]; then
    if ! read -rsk 1 -t 0.05 key; then
      break
    fi
    [[ $key == '[' || $key == 'O' ]] || break
    read -rsk 1 -t 0.05 key || continue

    case $key in
      A) key=up ;;
      B) key=down ;;
      *) continue ;;
    esac
  fi

  case $key in
    down) (( selection++ )) ;;
    up) (( selection-- )) ;;
    $'\n' | $'\r') open_url; break ;;
    c) copy_url; break ;;
    q) break ;;
  esac

  (( selection = ((selection - 1) % ${#matches} + ${#matches}) % ${#matches} + 1 ))
  display
done

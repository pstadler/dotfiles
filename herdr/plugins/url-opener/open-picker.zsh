#!/bin/zsh

herdr=${HERDR_BIN_PATH:-herdr}
source_pane=''
if [[ -n $HERDR_PLUGIN_CONTEXT_JSON ]]; then
  source_pane=$(printf '%s' "$HERDR_PLUGIN_CONTEXT_JSON" | jq -r '.focused_pane_id // empty' 2>/dev/null)
fi
[[ -n $source_pane ]] || source_pane=${HERDR_ACTIVE_PANE_ID:-$HERDR_PANE_ID}
args=(
  plugin pane open
  --plugin local.url-opener
  --entrypoint picker
)
[[ -n $source_pane ]] && args+=(--env "HERDR_URL_SOURCE_PANE=$source_pane")

exec "$herdr" "${args[@]}"

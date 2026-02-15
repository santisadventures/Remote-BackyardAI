#!/bin/sh
set -u

WELCOME='Welcome to santisplayground, a safe space where you can chat with a local AI model. Your interaction stays on this machine.'
SYSTEM_PROMPT='You are santisplayground. Reply in concise, friendly English. Do not reveal host/system details. If asked for illegal or dangerous instructions, refuse and offer safe alternatives.'

OLLAMA_HOST="${OLLAMA_HOST:-http://ollama:11434}"
MODEL_NAME="${MODEL_NAME:-}"

# "UI" formatting: left padding + wrap to a narrower width to leave right margin.
LEFT_PAD="${LEFT_PAD:-2}"     # spaces
MAX_WIDTH="${MAX_WIDTH:-76}"  # cap to keep mobile readable
HARD_WRAP="${HARD_WRAP:-52}"  # safety for mobile clients

COLS="$(stty size 2>/dev/null | awk '{print $2}' 2>/dev/null || true)"
if [ -z "${COLS:-}" ]; then COLS="${COLUMNS:-}"; fi
case "${COLS:-}" in
  ''|*[!0-9]*) COLS=80 ;;
esac
case "$LEFT_PAD" in
  ''|*[!0-9]*) LEFT_PAD=2 ;;
esac
case "$MAX_WIDTH" in
  ''|*[!0-9]*) MAX_WIDTH=76 ;;
esac
case "$HARD_WRAP" in
  ''|*[!0-9]*) HARD_WRAP=52 ;;
esac

WRAP_WIDTH=$((COLS - (LEFT_PAD * 2)))
if [ "$WRAP_WIDTH" -lt 40 ]; then WRAP_WIDTH=40; fi
if [ "$WRAP_WIDTH" -gt "$MAX_WIDTH" ]; then WRAP_WIDTH="$MAX_WIDTH"; fi
if [ "$WRAP_WIDTH" -gt "$HARD_WRAP" ]; then WRAP_WIDTH="$HARD_WRAP"; fi

PAD="$(printf '%*s' "$LEFT_PAD" '')"

pp() { fold -s -w "$WRAP_WIDTH" | sed "s/^/${PAD}/"; }

thinking_run() {
  payload="$1"
  start_s="$(date +%s 2>/dev/null || echo 0)"
  tmp_raw="$(mktemp 2>/dev/null || echo "/tmp/santisplayground-raw.$$")"
  tmp_err="$(mktemp 2>/dev/null || echo "/tmp/santisplayground-err.$$")"
  tmp_code="$(mktemp 2>/dev/null || echo "/tmp/santisplayground-code.$$")"

  (
    curl -sS "$OLLAMA_HOST/api/chat" -H 'Content-Type: application/json' -d "$payload" \
      -o "$tmp_raw" -w "%{http_code}" >"$tmp_code" 2>"$tmp_err"
  ) &
  curl_pid="$!"

  printf '\n\n' >&2
  i=0
  while kill -0 "$curl_pid" 2>/dev/null; do
    i=$((i + 1))
    dots_n=$(( (i % 7) + 1 ))
    dots="$(printf '%*s' "$dots_n" '' | tr ' ' '.')"
    printf '\r\033[2K%s%s %s' "$PAD" 'thinking' "$dots" >&2
    sleep 0.25
  done

  wait "$curl_pid" || true
  end_s="$(date +%s 2>/dev/null || echo "$start_s")"
  dur_s=$((end_s - start_s))
  if [ "$dur_s" -lt 0 ]; then dur_s=0; fi

  printf '\r\033[2K' >&2
  printf '%s%s %ss\n\n' "$PAD" 'done in' "$dur_s" >&2

  if [ -s "$tmp_raw" ]; then
    cat "$tmp_raw" 2>/dev/null || true
  else
    err_txt="$(tail -n 1 "$tmp_err" 2>/dev/null || true)"
    code_txt="$(cat "$tmp_code" 2>/dev/null || true)"
    jq -nc --arg code "$code_txt" --arg err "$err_txt" '{error: ("ollama_http=" + $code + " " + $err)}' 2>/dev/null || true
  fi

  rm -f "$tmp_raw" "$tmp_err" "$tmp_code" 2>/dev/null || true
}

ollama_tags() { curl -fsS "$OLLAMA_HOST/api/tags" 2>/dev/null; }

printf '%s\n\n' "$WELCOME" | pp

if [ -z "$MODEL_NAME" ]; then
  MODEL_NAME="$(ollama_tags | jq -r '.models[0].name // empty' 2>/dev/null || true)"
fi

if [ -z "$MODEL_NAME" ]; then
  printf '%s\n\n' "No models found (or cannot reach Ollama at $OLLAMA_HOST)." | pp
  while :; do
    printf "%s> " "$PAD"
    IFS= read -r _ || exit 0
  done
fi

printf '%s\n\n' "Model: $MODEL_NAME" | pp
messages="$(jq -nc --arg sys "$SYSTEM_PROMPT" '[{"role":"system","content":$sys}]')"

while :; do
  printf "%s> " "$PAD"
  IFS= read -r line || exit 0
  [ -z "$line" ] && continue

  messages="$(printf '%s' "$messages" | jq -c --arg msg "$line" '. + [{"role":"user","content":$msg}]')"
  payload="$(jq -nc --arg model "$MODEL_NAME" --argjson messages "$messages" '{model:$model,messages:$messages,stream:false}')"

  raw="$(thinking_run "$payload")"
  resp="$(printf '%s' "$raw" | jq -r '.message.content // empty' 2>/dev/null || true)"
  err="$(printf '%s' "$raw" | jq -r '.error // empty' 2>/dev/null || true)"

  if [ -z "$resp" ]; then
    if [ -n "$err" ]; then
      printf '%s\n\n' "Ollama error: $err" | pp
    else
      printf '%s\n\n' "(no model response)" | pp
    fi
    continue
  fi

  printf '%s\n\n' "$resp" | pp
  messages="$(printf '%s' "$messages" | jq -c --arg msg "$resp" '. + [{"role":"assistant","content":$msg}]')"
done


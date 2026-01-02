#!/usr/bin/env bash

set -euo pipefail

# Example: translate a single .qmd file using Perplexity chat completions API,
# chunked by sections/subsections to handle long files.
# Usage:
#   PERPLEXITY_API_KEY="<key>" ./init-scripts/translate_qmd_perplexity_example.sh input.qmd
# Dry-run (no API call):
#   PERPLEXITY_DRY_RUN=1 ./init-scripts/translate_qmd_perplexity_example.sh input.qmd
# Optional: override max chunk size in characters with PERPLEXITY_MAX_CHUNK_CHARS.

if [[ "$#" -ne 1 ]]; then
  echo "Usage: $0 <file.qmd>" >&2
  exit 2
fi

src="$1"
if [[ ! -f "$src" ]]; then
  echo "File not found: $src" >&2
  exit 2
fi

dst="${src%.qmd}.en.qmd"

PERPLEXITY_MAX_TOKENS="${PERPLEXITY_MAX_TOKENS:-2000}"

# Ensure API key is present (unless running dry-run)
if [[ "${PERPLEXITY_DRY_RUN:-0}" != "1" && -z "${PERPLEXITY_API_KEY:-}" ]]; then
  echo "Error: PERPLEXITY_API_KEY is not set. Export it or prefix the command with the var." >&2
  echo "Example: PERPLEXITY_API_KEY=\"your_key\" $0 $src" >&2
  exit 3
fi

# Token counting helper using tiktoken when available, fallback to char-based estimate
# Input: text on stdin; output: integer token count
token_count() {
  python3 - <<'PY'
import os,sys
text=sys.stdin.read()
model=os.environ.get('MODEL','') or os.environ.get('PERPLEXITY_MODEL','')
try:
    import tiktoken
    try:
        enc = tiktoken.encoding_for_model(model) if model else tiktoken.get_encoding('cl100k_base')
    except Exception:
        enc = tiktoken.get_encoding('cl100k_base')
    print(len(enc.encode(text)))
except Exception:
    # fallback: approximate 1 token ≈ 4 chars
    print(max(1, len(text)//4))
PY
}


# Read YAML front matter (between first two '---') and the rest of the file
yaml=$(sed -n '/^---/,/^---/p' "$src" | sed '1d;$d' || true)
body=$(sed '1,/^---/d' "$src")

SYSTEM_PROMPT='You are a translator: translate French Quarto/Markdown to English. Preserve YAML, code blocks, citations, links, images, math and tables. Translate only natural language text.'
MODEL='sonar-pro'

# Split body into sections by headings (## or ###), keep heading lines with their content
split_into_sections() {
  local text="$1"
  local current=''
  # Print NUL-separated sections
  while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ "$line" =~ ^#{2,3}[[:space:]] ]]; then
      if [[ -n "$current" ]]; then
        printf '%s\0' "$current"
      fi
      current="$line"$'\n'
    else
      current+="$line"$'\n'
    fi
  done <<< "$text"
  [[ -n "$current" ]] && printf '%s\0' "$current"
}

# Further split a long section by paragraphs (double newlines) into chunks of ~max_tokens,
# taking care to avoid leaving a chunk with an unmatched code fence.
split_section_into_chunks_by_tokens() {
  local section="$1"
  local max_tokens="$2"
  # Use awk to get paragraphs as NUL-separated records
  local paras_stream
  paras_stream=$(awk 'BEGIN{RS=""; ORS="\0"} {print $0}' <<< "$section")

  local current=''
  local p
  while IFS= read -r -d '' p; do
    if [[ -z "${current}" ]]; then
      current="$p"
      continue
    fi

    # Estimate tokens of current + p
    local candidate
    candidate="$current"$'\n\n'$p
    local tcount
    tcount=$(printf '%s' "$candidate" | token_count)

    if (( tcount <= max_tokens )); then
      current="$candidate"
      continue
    fi

    # If current chunk has an unmatched code fence (odd number of ```), attach next paragraph
    local fence_count
    fence_count=$(grep -o '\`\`\`' <<< "$current" | wc -l || true)
    if (( fence_count % 2 == 1 )); then
      current+=$'\n\n'$p
      continue
    fi

    printf '%s\0' "$current"
    current="$p"
  done < <(printf '%s' "$paras_stream")
  [[ -n "$current" ]] && printf '%s\0' "$current"
}

# Translate one chunk (honoring dry-run)
translate_chunk() {
  local chunk="$1"
  if [[ "${PERPLEXITY_DRY_RUN:-0}" == "1" ]]; then
    # return unchanged for dry-run
    printf '%s\n' "$chunk"
    return 0
  fi

  local payload
  payload=$(jq -n --arg system "$SYSTEM_PROMPT" --arg chunk "$chunk" --arg model "$MODEL" '{model: $model, messages: [{role: "system", content: $system}, {role: "user", content: ("Translate this French Quarto/Markdown section to English, preserving all structure:\n\n```markdown\n" + $chunk + "\n```") } ], temperature: 0.0, max_tokens: 4096}')

  local response
  response=$(curl -sS -X POST "https://api.perplexity.ai/chat/completions" \
    -H "Authorization: Bearer $PERPLEXITY_API_KEY" \
    -H "Content-Type: application/json" \
    -d "$payload")

  local translated
  translated=$(echo "$response" | jq -r '.choices[0].message.content // empty' | sed 's/^```markdown//; s/```$//')

  if [[ -z "$translated" ]]; then
    echo "Warning: empty translation returned for a chunk — returning original chunk" >&2
    printf '%s\n' "$chunk"
  else
    printf '%s\n' "$translated"
  fi
}

# Main: split into sections, chunk if needed, translate and reassemble
sections=()
while IFS= read -r -d '' sec; do
  sections+=("$sec")
done < <(split_into_sections "$body")

translated_sections=()
for sec in "${sections[@]}"; do
  # Decide based on token estimate whether to chunk
  tcount=$(printf '%s' "$sec" | token_count)
  if (( tcount <= PERPLEXITY_MAX_TOKENS )); then
    translated_sections+=("$(translate_chunk "$sec")")
  else
    # split into smaller chunks and translate each (token-based)
    chunks=()
    while IFS= read -r -d '' ch; do
      chunks+=("$ch")
    done < <(split_section_into_chunks_by_tokens "$sec" "$PERPLEXITY_MAX_TOKENS")

    out=''
    for ch in "${chunks[@]}"; do
      out+=$(translate_chunk "$ch")$'\n'
    done
    translated_sections+=("$out")
  fi
done

# Write YAML + translated body
{
  printf '%s\n' '---'
  printf '%s\n' "$yaml"
  printf '%s\n' '---'
  printf '\n'
  for t in "${translated_sections[@]}"; do
    printf '%s\n' "$t"
  done
} > "$dst"

echo "Wrote: $dst"

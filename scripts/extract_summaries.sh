#!/usr/bin/env bash

set -euo pipefail

# extract_summaries.sh
# Scans `summary_*.md` files in the repo (and subdirs) and produces a compact
# CSV (`summaries/all_summaries.csv`) and a human-friendly `summaries/latest_summary.md`.

OUTDIR="summaries"
mkdir -p "$OUTDIR"
CSV="$OUTDIR/all_summaries.csv"
LATEST_MD="$OUTDIR/latest_summary.md"

# Header
echo "timestamp,hostname,ipv4,os,uptime" > "$CSV"

# Iterate summaries (sorted newest last -> we want newest last)
while IFS= read -r -d '' f; do
  # Get the timestamp from filename if present, else use file mtime
  name=$(basename "$f")
  stamp="$(echo "$name" | sed -n 's/.*summary_\([0-9T_:-]*\).*\.md/\1/p')"
  if [ -z "$stamp" ]; then
    stamp="$(date -r "$f" +%Y%m%d_%H%M%S 2>/dev/null || date +%Y%m%d_%H%M%S)"
  fi

  # Read fields
  hostname=$(grep -m1 -i '\*\*Hostname:\*\*' "$f" | sed -E 's/\*\*Hostname:\*\*\s*([^ ].*)\s*$/\1/' | sed 's/[[:space:]]*$//')
  ipv4=$(grep -m1 -i '\*\*IPv4s:\*\*' "$f" | sed -E 's/\*\*IPv4s:\*\*\s*([^ ].*)\s*$/\1/' | sed 's/[[:space:]]*$//')
  os=$(grep -m1 -i '\*\*OS:\*\*' "$f" | sed -E 's/\*\*OS:\*\*\s*([^ ].*)\s*$/\1/' | sed 's/[[:space:]]*$//')
  uptime=$(grep -m1 -i '\*\*Uptime:\*\*' "$f" | sed -E 's/\*\*Uptime:\*\*\s*([^ ].*)\s*$/\1/' | sed 's/[[:space:]]*$//')

  # Escape commas
  hostname_esc=$(echo "$hostname" | sed 's/,/\,/g')
  ipv4_esc=$(echo "$ipv4" | sed 's/,/\,/g')
  os_esc=$(echo "$os" | sed 's/,/\,/g')
  uptime_esc=$(echo "$uptime" | sed 's/,/\,/g')

  echo "${stamp},${hostname_esc},${ipv4_esc},${os_esc},${uptime_esc}" >> "$CSV"

done < <(find . -type f -name 'summary_*.md' -print0 | sort -z)

# Write latest_summary.md using the last CSV row
if tail -n +2 "$CSV" | tail -n1 >/dev/null 2>&1; then
  last=$(tail -n1 "$CSV")
  IFS=',' read -r stamp hostname ipv4 os uptime <<< "$last"
  cat > "$LATEST_MD" <<EOF
# Latest Summary (generated: $(date -Is))

**Timestamp:** $stamp  
**Hostname:** $hostname  
**IPv4s:** $ipv4  
**OS:** $os  
**Uptime:** $uptime

(Full CSV: \\`$CSV\\`)
EOF
else
  echo "No summary files found to generate summaries." > "$LATEST_MD"
fi

# Success
echo "Wrote: $CSV" >&2
echo "Wrote: $LATEST_MD" >&2

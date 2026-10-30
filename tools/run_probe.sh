#!/bin/bash
# Run one blind probe of a task headless, in a clean environment, at low effort.
# Usage: tools/run_probe.sh <probe_dir> <prompt_file> <wall_seconds> <out_prefix>
# The probe dir holds only the instruction (with /app paths rewritten) and a copy of environment/data.
# env: CLAUDE_BIN (default: claude on PATH), PROBE_MODEL (default: claude-fable-5-1), PROBE_BUDGET_USD (default: 40)
# It skips permission prompts, so run it only on a machine or sandbox where that is acceptable.
P="$1"; PROMPT="$2"; WALL="$3"; OUT="$4"
BIN="${CLAUDE_BIN:-$(command -v claude)}"
cd "$P" || exit 1
exec env -i HOME="$HOME" USER="$USER" LOGNAME="$LOGNAME" PATH="$PATH" SHELL="$SHELL" TMPDIR="$TMPDIR" LANG="${LANG:-en_US.UTF-8}" TERM=xterm-256color \
  perl -e 'alarm shift; exec @ARGV' "$WALL" \
  "$BIN" -p "$(cat "$PROMPT")" \
  --model "${PROBE_MODEL:-claude-fable-5-1}" --effort low \
  --no-session-persistence --strict-mcp-config --mcp-config '{"mcpServers":{}}' \
  --disable-slash-commands --setting-sources project --dangerously-skip-permissions \
  --output-format stream-json --verbose \
  --max-budget-usd "${PROBE_BUDGET_USD:-40}" < /dev/null > "$OUT.jsonl" 2> "$OUT.err"

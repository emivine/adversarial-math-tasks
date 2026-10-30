#!/bin/bash
# Run one Codex step non-interactively and keep its raw record.
# usage: tools/run_codex_step.sh <run dir> <tag> <prompt file> [work dir]
#   run dir   e.g. Task/_notes/run-<date>-<name> (raw output goes to <run dir>/raw/)
#   tag       e.g. 03-structures-codex (used for file names)
#   work dir  default: repo root. For isolated work (independent implementation, adversarial solve)
#             pass a probe folder outside the repo; the session then starts fresh, ephemeral, and can
#             only write inside that folder.
# env: CODEX_EFFORT (default: the codex config)
# Prints one summary line and appends it to <run dir>/raw/calls.tsv.
set -uo pipefail
RUN="$1"; TAG="$2"; PROMPT="$3"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WD="${4:-$ROOT}"
case "$RUN" in /*) ;; *) RUN="$ROOT/$RUN";; esac
OUT="$RUN/raw"; mkdir -p "$OUT"
args=(-C "$WD" -s workspace-write --json -o "$OUT/$TAG.last.md")
[ "$WD" != "$ROOT" ] && args+=(--skip-git-repo-check --ephemeral)
[ -n "${CODEX_EFFORT:-}" ] && args+=(-c "model_reasoning_effort=\"$CODEX_EFFORT\"")
cp "$PROMPT" "$OUT/$TAG.prompt.md"
start=$(date +%s)
codex exec "${args[@]}" - < "$PROMPT" > "$OUT/$TAG.events.jsonl" 2> "$OUT/$TAG.err"
rc=$?
secs=$(( $(date +%s) - start ))
[ -f "$OUT/calls.tsv" ] || printf "time\ttag\twork_dir\teffort\tseconds\texit\n" > "$OUT/calls.tsv"
line="$(date '+%Y-%m-%d %H:%M')\t$TAG\t$WD\t${CODEX_EFFORT:-config}\t$secs\t$rc"
printf "$line\n" >> "$OUT/calls.tsv"
printf "$line\nlast message: $OUT/$TAG.last.md\n"
exit $rc

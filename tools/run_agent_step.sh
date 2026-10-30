#!/bin/bash
# Run one agent step non-interactively and keep its raw record.
# usage: AGENT_CMD='<command that reads the prompt on stdin>' tools/run_agent_step.sh <run dir> <tag> <prompt file> [work dir]
#   run dir   e.g. Task/_notes/run-<date>-<name> (raw output goes to <run dir>/raw/)
#   tag       e.g. 03-structures-attacker (used for file names)
#   work dir  default: repo root. For isolated work (independent implementation, adversarial solve)
#             pass a probe folder outside the repo, and use the agent's own sandbox options in AGENT_CMD.
# Prints one summary line and appends it to <run dir>/raw/calls.tsv.
set -uo pipefail
RUN="$1"; TAG="$2"; PROMPT="$3"
: "${AGENT_CMD:?set AGENT_CMD to a command that reads the prompt on stdin}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WD="${4:-$ROOT}"
case "$RUN" in /*) ;; *) RUN="$ROOT/$RUN";; esac
OUT="$RUN/raw"; mkdir -p "$OUT"
cp "$PROMPT" "$OUT/$TAG.prompt.md"
start=$(date +%s)
(cd "$WD" && bash -c "$AGENT_CMD") < "$PROMPT" > "$OUT/$TAG.out" 2> "$OUT/$TAG.err"
rc=$?
secs=$(( $(date +%s) - start ))
[ -f "$OUT/calls.tsv" ] || printf "time\ttag\twork_dir\tseconds\texit\n" > "$OUT/calls.tsv"
line="$(date '+%Y-%m-%d %H:%M')\t$TAG\t$WD\t$secs\t$rc"
printf "$line\n" >> "$OUT/calls.tsv"
printf "$line\noutput: $OUT/$TAG.out\n"
exit $rc

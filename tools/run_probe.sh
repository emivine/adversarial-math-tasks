#!/bin/bash
# Run one blind probe of a task headless, in a clean environment.
# Usage: PROBE_CMD='<command that reads the prompt on stdin>' tools/run_probe.sh <probe_dir> <prompt_file> <wall_seconds> <out_prefix>
# The probe dir holds only the instruction (with /app paths rewritten) and a copy of environment/data.
# Output goes to <out_prefix>.jsonl and <out_prefix>.err. If PROBE_CMD skips permission prompts,
# run it only on a machine or sandbox where that is acceptable.
P="$1"; PROMPT="$2"; WALL="$3"; OUT="$4"
: "${PROBE_CMD:?set PROBE_CMD to a command that reads the prompt on stdin}"
cd "$P" || exit 1
exec env -i HOME="$HOME" USER="$USER" LOGNAME="$LOGNAME" PATH="$PATH" SHELL="$SHELL" TMPDIR="${TMPDIR:-/tmp}" LANG="${LANG:-en_US.UTF-8}" TERM=xterm-256color \
  perl -e 'alarm shift; exec @ARGV' "$WALL" \
  bash -c "$PROBE_CMD" < "$PROMPT" > "$OUT.jsonl" 2> "$OUT.err"

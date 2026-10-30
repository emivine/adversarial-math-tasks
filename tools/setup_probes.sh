#!/bin/bash
# Build blind probe folders for a task bundle.
# usage: tools/setup_probes.sh <task dir> <scratch dir> <tag> [n=3]
# Creates <scratch>/work-<tag>1..n, each holding TASK.md (instruction.md with /app/ replaced by that folder)
# and data/ (a copy of environment/data). Never copies tests/, solution/ or authoring/.
# Then give each folder to a blind solver and score its output with the bundle's verifier.
set -euo pipefail
TASK="$1"; SCRATCH="$2"; TAG="$3"; N="${4:-3}"
[ -f "$TASK/instruction.md" ] && [ -d "$TASK/environment/data" ] || { echo "not a task bundle: $TASK"; exit 1; }
for i in $(seq 1 "$N"); do
  D="$SCRATCH/work-$TAG$i"
  rm -rf "$D"; mkdir -p "$D/data"
  cp -R "$TASK/environment/data/." "$D/data/"
  sed "s#/app/#$D/#g" "$TASK/instruction.md" > "$D/TASK.md"
  echo "$D"
done

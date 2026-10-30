"""Compare one instruction.md with every other task instruction in this project (Task/*/).

usage: python3 tools/brief_similarity.py Task/<slug>/instruction.md

Prints, for each other task, the word-order similarity (difflib ratio on word and punctuation tokens) and the
vocabulary overlap (Jaccard on lower-case words), highest first, and flags pairs at or above the warning
line. It only catches copied wording. A low score does not make a task original: a task rebuilt in a new
domain can score low and still be a duplicate.
"""
import difflib
import re
import sys
from pathlib import Path

WARN_SEQ, WARN_JAC = 0.45, 0.40
ROOT = Path(__file__).resolve().parent.parent


def tokens(text):
    return re.findall(r"\w+|[^\w\s]", text)


def words(text):
    return {w.lower() for w in re.findall(r"[A-Za-z]+", text)}


def main(path):
    target = Path(path).resolve()
    text = target.read_text()
    tt, tw = tokens(text), words(text)
    rows = []
    for other in sorted(ROOT.glob("Task/*/instruction.md")):
        if other.resolve() == target:
            continue
        o = other.read_text()
        seq = difflib.SequenceMatcher(None, tt, tokens(o), autojunk=False).ratio()
        ow = words(o)
        jac = len(tw & ow) / len(tw | ow)
        rows.append((seq, jac, other.relative_to(ROOT)))
    rows.sort(reverse=True)
    flagged = False
    for seq, jac, name in rows:
        warn = seq >= WARN_SEQ or jac >= WARN_JAC
        flagged |= warn
        print(f"{seq:.3f}  {jac:.3f}  {'WARN ' if warn else '     '}{name}")
    print("highest word-order similarity: %.3f (warning line %.2f)" % (rows[0][0], WARN_SEQ) if rows else "no other tasks")
    return 1 if flagged else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1]))

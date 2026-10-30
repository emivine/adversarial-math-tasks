# Summarise a headless probe run: python3 tools/probe_report.py <run.jsonl> [forbidden regex]
"""Summarise one headless probe run: timing, cost, tool calls, out of bounds access, final report."""
import json, sys, re
f = sys.argv[1]
forbidden = re.compile(sys.argv[2] if len(sys.argv) > 2 else r"ground_truth|/solution/|/tests/|/authoring/|_notes/")
events = []
for line in open(f):
    try: events.append(json.loads(line))
    except Exception: pass
tools, bad = 0, []
for d in events:
    if d.get("type") == "assistant":
        for c in d.get("message", {}).get("content", []):
            if c.get("type") == "tool_use":
                tools += 1
                s = json.dumps(c.get("input", {}))
                for m in forbidden.finditer(s):
                    bad.append(s[max(0, m.start() - 60): m.end() + 60])
res = [d for d in events if d.get("type") == "result"]
if res:
    r = res[-1]
    print("duration min", round(r.get("duration_ms", 0) / 60000, 1), "| turns", r.get("num_turns"), "| cost $", round(r.get("total_cost_usd", 0), 2), "| error", r.get("is_error"), r.get("subtype"))
    print("models:", {k: {kk: v[kk] for kk in ("inputTokens", "outputTokens", "cacheReadInputTokens") if kk in v} for k, v in (r.get("modelUsage") or {}).items()})
    print("tool calls:", tools)
    print("out of bounds references:", len(bad))
    for b in bad[:8]:
        print("  ", b)
    print("---- final report ----")
    print(str(r.get("result"))[:4000])
else:
    print("no result event; tool calls:", tools, "events:", len(events))

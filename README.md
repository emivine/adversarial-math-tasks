# Agent Benchmark Workflow

用两个编程 agent（Claude Code 和 Codex）协作制作 agent 基准任务的流程、脚本和经验总结。

A workflow for building benchmark tasks with two coding agents working together: one builds, the other attacks, and blind solvers measure how hard the result really is. Docs are in Chinese; scripts and comments are in English.

## 解决什么问题

好的 agent 基准任务要同时满足几件互相牵制的事：

- 弱一些的 agent 解不出来，强 agent 也不是几分钟就能解出。
- 难度来自真实的判断，不是信息缺失或题面有歧义。
- 验证器能明确判定对错，而且判得公平：正确的路线都能过，错误的路线都过不了。

只靠作者自己判断，很难知道这几件事是否成立。这套流程用独立的实现、对抗审查和盲测，把它们变成可以测量的结论。

## 仓库内容

| 路径 | 内容 |
|---|---|
| [docs/workflow.md](docs/workflow.md) | 12 步流程、两个 agent 的分工、信息隔离规则 |
| [docs/relay-protocol.md](docs/relay-protocol.md) | 一个会话自动跑完全部步骤的接力协议 |
| [docs/lessons.md](docs/lessons.md) | 做题过程中总结的通用经验 |
| [tools/](tools/) | 建盲测目录、跑盲测、汇总结果、调用 Codex、本地验证、查题面相似度 |
| [.claude/agents/](.claude/agents/) | 低 effort 盲测子代理的定义 |

## 工具

| 脚本 | 作用 |
|---|---|
| `tools/setup_probes.sh` | 从任务包建盲测目录，只放题面和数据 |
| `tools/run_probe.sh` | 在干净环境里无头运行一次盲测 |
| `tools/probe_report.py` | 汇总一次盲测的用时、费用、工具调用和越界访问 |
| `tools/run_codex_step.sh` | 非交互地运行一步 Codex，并保留原始记录 |
| `tools/run_verifier.py` | 在本地用任务的验证器检查一个输出文件 |
| `tools/brief_similarity.py` | 比较题面之间的措辞相似度 |

## 快速开始

需要 Bash、Python 3 和 Perl。跑盲测需要 [Claude Code](https://claude.com/claude-code)，调用 Codex 需要 Codex CLI。

```bash
pip install -r requirements.txt
```

任务包放在 `Task/<slug>/` 下（本仓库不提供，且已被 `.gitignore` 排除），至少要有 `instruction.md` 和 `environment/data/`。

```bash
tools/setup_probes.sh Task/<slug> /tmp/probes demo 3
```

```bash
python3 tools/run_verifier.py Task/<slug>/tests /tmp/probes/work-demo1/output.json
```

`run_probe.sh` 会跳过权限确认，只应在隔离的机器或沙箱里运行。

## 不包含的内容

这里只公开方法和工具，不含任何具体任务、参考解、验证器、数据和运行日志：基准任务的解答一旦公开，任务就失效了。

## 状态

项目已于 2026 年 10 月暂停，不再维护。

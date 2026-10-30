# Adversarial Math Tasks

用任意两个 agent 对抗生成高难度数学题的流程、脚本和经验总结。题目覆盖应用数学、运筹优化和统计，用作 agent 基准任务。

A workflow for generating hard math benchmark tasks with any two agents working against each other: one builds, the other attacks, and blind solvers measure how hard the result really is. Claude and Astra are the recommended pair. Docs are in Chinese; scripts and comments are in English.

## 选哪两个 agent

流程只分两个角色，任意两个 agent 都可以担任：

- **构建方**：把题做出来，并证明它可靠。
- **对抗方**：审数学、找绕过的办法、独立求解。

**推荐用 Claude 当构建方、Astra（通过 Codex CLI 运行）当对抗方。** 它们是写作时最强的两个模型。双方都够强，对抗才有效果：攻击太弱，题里的漏洞就留下来了。本项目用的也是这个组合。

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
| [tools/](tools/) | 建盲测目录、跑盲测、汇总结果、调用 agent、本地验证、查题面相似度 |

## 工具

| 脚本 | 作用 |
|---|---|
| `tools/setup_probes.sh` | 从任务包建盲测目录，只放题面和数据 |
| `tools/run_probe.sh` | 在干净环境里无头运行一次盲测 |
| `tools/probe_report.py` | 汇总一次盲测的用时、费用、工具调用和越界访问 |
| `tools/run_agent_step.sh` | 非交互地运行一步 agent，并保留原始记录 |
| `tools/run_verifier.py` | 在本地用任务的验证器检查一个输出文件 |
| `tools/brief_similarity.py` | 比较题面之间的措辞相似度 |

## 快速开始

需要 Bash、Python 3 和 Perl，以及能无头运行的 agent CLI。

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

`run_probe.sh` 和 `run_agent_step.sh` 通过环境变量接 agent：命令从标准输入读提示。下面是推荐组合的例子，换成别的 agent 只需改这条命令：

```bash
export PROBE_CMD='claude -p --effort low --output-format stream-json --verbose --dangerously-skip-permissions'
```

```bash
export AGENT_CMD='codex exec --json -s workspace-write -'
```

这两个例子里，盲测命令跳过了权限确认，只应在隔离的机器或沙箱里运行。

## 不包含的内容

这里只公开方法和工具，不含任何具体任务、参考解、验证器、数据和运行日志：基准任务的解答一旦公开，任务就失效了。

## 状态

新题制作目前暂缓，项目后续会继续开发。

## 许可证

[MIT](LICENSE)

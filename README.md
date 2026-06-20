# MBD SDLC Skill

A Model-Based Development skill for MATLAB, Simulink, Embedded Coder, Simulink Test, Model Advisor, and V-Model SDLC workflows.

This repository contains:

- a GitHub-ready skill source tree for coding agents
- MATLAB helper assets for indirect Simulink work through scripts and Markdown evidence

## Quickstart

### Install from a published GitHub repo with skills.sh-compatible agents

After this repo is pushed to GitHub, install it with:

```bash
npx skills@latest add mohmed-ahmed-01097/mbd-sdlc
```

Then select `mbd-sdlc` for the coding agents you want.

### Push this folder to GitHub

```bash
gh repo create mohmed-ahmed-01097/mbd-sdlc --public --source=. --remote=origin --push
```

Repository URL: `https://github.com/mohmed-ahmed-01097/mbd-sdlc`


### Use in ChatGPT

To create a ChatGPT uploadable package when needed, run:

```bash
npm run package:chatgpt
```

Then upload the generated `dist/skill.zip` to the ChatGPT Skills interface. The `dist/` folder is generated locally and is not required in the repo zip.

### Optional MATLAB MCP Server integration

For agents that support Model Context Protocol, the skill can use the official MATLAB MCP Server as the preferred MATLAB execution channel. MCP is optional; browser mode and terminal MATLAB execution remain supported.

Typical Claude Code setup after downloading the MATLAB MCP Server binary:

```bash
claude mcp add --transport stdio matlab -- /full/path/to/matlab-mcp-server-binary --initial-working-folder=/path/to/mbd-project --matlab-session-mode=auto --disable-telemetry=true
```

For an already-open MATLAB Desktop session, configure the MCP toolbox once, run `shareMATLABSession()` inside MATLAB, then start the server with `--matlab-session-mode=auto` — this attaches to that shared session automatically and only starts a new one when none is found, so it should be the default rather than an opt-in.

If MCP is unavailable but the MATLAB Engine API for Python is installed, share the running MATLAB Desktop session with:

```matlab
matlab.engine.shareEngine
```

Then call the optional bridge from CMD/PowerShell/Bash:

```bash
python skills/engineering/mbd-sdlc/assets/python/matlab_shared_engine_eval.py --code "assert(1+1==2); disp('ASSERT_TEST_PASS')"
```

For a new interactive MATLAB session that should stay open, use `matlab -r "..."` — only after confirming with the user that a new process (not their open MATLAB Desktop) is what they want. Use `matlab -batch "..."` for automation that should close MATLAB and return an exit code. Neither flag connects to an already-open MATLAB session.

See `docs/matlab-mcp-setup.md` and `skills/engineering/mbd-sdlc/references/matlab-mcp-integration.md`.

## Skill location

```text
skills/engineering/mbd-sdlc/
```


## What the skill does

The skill helps an AI agent work with Simulink indirectly:

1. discover MATLAB release and installed products
2. create or reuse `.MBD_agent/`
3. export model architecture, block parameters, lines, workspace, model workspace, and data dictionary evidence
4. plan in Markdown without polluting project source
5. ask for edit approval and list changes
6. implement through MATLAB `.m` scripts
7. re-export and compare
8. run Model Advisor, tests, and code generation checks when available
9. produce a final review that separates verified and unverified work

## MATLAB baseline

The skill asks for the project release first and uses R2022b-conscious helper scripts where possible. It does not assume toolboxes; it discovers installed products with `ver` and adapts.

## Default MBD scope

- requirements, HLD, LLD, implementation
- MIL, SIL, PIL, HIL workflows
- Embedded Coder production C
- optional AUTOSAR, MISRA-ready, and ISO 26262-oriented branches
- MAAB/MAB-style review and project-specific rules in `.MBD_agent/rules.md`

## V-Model structure for new projects

The skill asks once whether this is needed. If yes, it uses:

```text
01_requirements/
02_system_design_hld/
03_software_design_lld/
04_implementation/
05_mil_tests/
06_sil_tests/
07_pil_tests/
08_hil_tests/
09_codegen/
10_release/
```

## Repository conventions

See:

- `CLAUDE.md` for coding-agent repository rules
- `.claude-plugin/plugin.json` for skills.sh-compatible skill listing
- `docs/invocation.md` for invocation style
- `skills/engineering/README.md` for the skill catalog

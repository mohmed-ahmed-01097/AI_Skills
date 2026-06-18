# MBD SDLC Skill

A Model-Based Development skill for MATLAB, Simulink, Embedded Coder, Simulink Test, Model Advisor, and V-Model SDLC workflows.

This repository contains:

- a GitHub-ready skill source tree for coding agents
- a ChatGPT uploadable package at `dist/skill.zip`
- MATLAB helper assets for indirect Simulink work through scripts and Markdown evidence

## Quickstart

### Install from a published GitHub repo with skills.sh-compatible agents

After this repo is pushed to GitHub, install it with the same pattern used by skills.sh-compatible repositories:

```bash
npx skills@latest add <github-owner>/<repo-name>
```

Example after publishing under your account:

```bash
npx skills@latest add <your-github-user>/mbd-sdlc
```

Then select `mbd-sdlc` for the coding agents you want.

### Push this folder to GitHub

```bash
gh repo create mbd-sdlc --private --source=. --remote=origin --push
```

Use `--public` instead of `--private` if you want a public repo.

## Skill location

```text
skills/engineering/mbd-sdlc/
```

The source skill is also packaged as `dist/skill.zip` for ChatGPT.

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

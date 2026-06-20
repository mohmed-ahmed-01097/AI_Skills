# Invocation

Every `SKILL.md` in this repo is a skill. The repo contains both model-invoked and user-invoked skills.

## Model-invoked

Model-invoked skills can be reached automatically by the agent when the task fits. Their frontmatter description must contain concrete trigger language.

- **`mbd-sdlc`** - invoke for MATLAB project setup or review, MATLAB MCP Server execution for MBD work, existing MATLAB Desktop session execution through MCP or Python shared engine, Simulink model inspection or scripted edits, requirements/HLD/LLD/implementation, MIL/SIL/PIL/HIL testing, Simulink Test Manager workflows, Model Advisor or MAAB/MAB-style checks, Embedded Coder production C, MISRA-ready/AUTOSAR/ISO 26262-oriented evidence.

Do not invoke `mbd-sdlc` for generic MATLAB numerical scripting unless the task touches Model-Based Development artifacts or SDLC process.

## User-invoked

User-invoked skills are reached when the user explicitly chooses them. They use `disable-model-invocation: true` in skills.sh-style repos.

- **`teach`** - use when the user wants a stateful teaching workspace with lessons, references, learning records, and a mission.
- **`writing-great-skills`** - use when improving, reviewing, pruning, or designing skills and skill repositories.

## MATLAB execution preference

When MCP is present, use it as an execution channel for MATLAB commands and files, configured by default to attach to the user's already-open MATLAB session (`--matlab-session-mode=auto`) rather than always starting a new one. When MCP is unavailable, use Python shared engine after the MATLAB session is shared to get the same reuse.

The core MBD workflow remains evidence export, Markdown planning, user-approved scripted edits, re-export, validation, and final review.

## Dependencies between skills

Dependencies should be expressed as `/skill`-style prose invocation rather than deep cross-folder references. Shared reference material should live inside the skill that owns it, or in repository docs when it is repo-level guidance.

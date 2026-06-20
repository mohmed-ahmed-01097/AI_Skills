---
name: mbd-sdlc
description: model-based development workflow for matlab, simulink, stateflow, embedded coder, simulink test, model advisor, and v-model sdlc work. use when asked to inspect, document, edit, create, test, validate, generate code for, or review simulink models, matlab projects (.prj), data dictionaries (.sldd), mat files, requirements, hld/lld designs, mil/sil/pil/hil tests, maab/mab checks, misra-ready code generation, autosar branches, or iso 26262-oriented model-based development. supports optional matlab mcp execution, terminal agents that can run matlab commands, and browser workflows that exchange zip files and generated .m/.md reports.
---

# MBD SDLC

Use this skill to run Model-Based Development work through MATLAB scripts and Markdown evidence rather than guessing inside Simulink diagrams.

## Operating principle

Treat Simulink as an executable artifact that must be inspected, changed, and verified through MATLAB commands, generated `.m` scripts, exported `.md` architecture files, and repeatable reports.

Never rely on visual memory of a model. Export the model, workspace, configuration, and test state before planning material changes. Treat every response as if the project is already complete - not a work in progress being explored in chat.

## Session reuse policy (default behavior — read this first)

**Default to reusing the user's already-open MATLAB session. Do not silently start a brand-new MATLAB process when an open one might already exist.** A fresh `matlab -batch`/`matlab -r` process cannot see the user's loaded models, base workspace variables, or breakpoints, and it consumes a separate license seat. Check for an existing session before launching a new one, in this order:

1. **MCP configured**: the MCP server's session mode decides this, not the agent. Setup should use `--matlab-session-mode=auto` (attach to a shared/existing session if one exists, otherwise start one) so reuse is the default rather than an opt-in. If the server is configured with a different mode and the user wants reuse, tell them to reconfigure — do not work around it with a second execution channel.
2. **No MCP, but MATLAB Engine API for Python is installed**: run the bridge script with `--list` first. If a shared session is found, connect to it. If none is found, ask the user to run `matlab.engine.shareEngine` in their open MATLAB Desktop, then re-check `--list`. Only fall back to spawning a new process if the user declines to share or none is available.
3. **Terminal-only access** (`matlab -batch` / `matlab -r`, no MCP, no Python engine): state plainly that these commands always start a brand-new MATLAB process and cannot attach to an already-open MATLAB Desktop. Ask whether a new process is acceptable, or offer the Python shared-engine path instead.
4. Never run `matlab -r` "just to get a session going" when the goal is reuse — `-r` always creates a new process; it never attaches to one already running.

For mode details, read `references/mbd-operating-modes.md`. For MCP-specific rules and exact setup commands, read `references/matlab-mcp-integration.md`.

## First decision

Classify the session along two independent axes before doing project work.

**Execution channel** — how MATLAB commands actually run:

1. **MATLAB MCP mode**: MATLAB MCP tools are available. Prefer them for discovery, MATLAB code checks, `.m` execution, MATLAB tests, and short reviewed commands. MCP is an execution channel only — it does not replace `.MBD_agent`, Markdown evidence, approval-before-edit, or final review.
2. **Python shared-engine mode**: MCP is unavailable but the user wants their already-open MATLAB Desktop reused, and the MATLAB Engine API for Python is installed. Use `assets/python/matlab_shared_engine_eval.py` against a session shared with `matlab.engine.shareEngine`.
3. **Terminal agent mode**: run MATLAB commands from the shell or CMD when neither of the above is available. Use `-batch` for automation that closes MATLAB; use `-r` only to start a new interactive session that stays open. Console output, warnings, and errors are direct evidence.
4. **Browser mode**: the agent cannot run MATLAB at all. Write `.m` scripts for the user to run, then ask for the resulting zip/reports/logs before continuing.

**Project scale** — how much `.MBD_agent` structure to create:

1. **Single-file/small edit**: keep `.MBD_agent` minimal (no `tasks/`, `architecture/`, or large catalog exports).
2. **Large project/new project**: use the full `.MBD_agent` structure and ask once whether the V-Model structure is required.

## Mandatory questions - ask only what is not already known

Ask these once at project start. Do not repeat if the answer is discoverable or was already given.

- MATLAB/Simulink release. Discover with `ver` when possible. Default to R2022b-safe scripts when uncertain.
- Single-file edit, existing project, or new project?
- V-Model folder structure needed? (For new or safety-related projects.)
- **Where should global scripts live?** Suggest `.MBD_agent/scripts/` for AI-only use or `tools/mbd/` for project-owned scripts that belong in source control. See `references/global-scripts.md`.
- Is there an existing `.prj` file, or should one be created? See `references/matlab-project-prj.md`.
- Edit approval: list the exact intended changes and wait for approval before implementing, unless the user already explicitly authorized it.

## Standard loop

1. **Discover**: first apply the session reuse policy above (check for an existing/shared MATLAB session before launching a new one), then detect whether MATLAB MCP tools are available, then detect MATLAB release, installed products and apps, `.prj` project file, model files, data dictionaries, MAT files, requirements/test artifacts, and generated code folders. Use MCP discovery when available; otherwise run `mbd_discover_environment`. For tasks that involve adding/editing blocks, also run `mbd_export_full_catalog` (cached after the first run) instead of relying on memory for block names or parameters.
2. **Create/reuse `.MBD_agent`**: keep AI artifacts outside project source unless the user asks otherwise. See `references/mbd-agent-folder.md`.
3. **Export evidence**: model architecture (blocks, parameters, lines, annotations, signal attributes), workspace/model workspace/data dictionary, configuration sets, Model Advisor/codegen/test state.
4. **Plan in Markdown**: use exported evidence only. Keep plans task-scoped and short.
5. **Request edit approval**: list the exact model/script/test/config changes and wait for confirmation.
6. **Implement by script**: create `.m` files using `add_place`, `mbd_set_param_strict`, `mbd_connect_line`, `mbd_add_annotations`, and `mbd_apply_model_view`. Use `config_layout.m` for positions - no magic numbers. Run generated scripts through MCP `run_matlab_file` when available; otherwise use terminal MATLAB commands or browser handoff.
7. **Run feedback**: execute scripts, simulation, Model Advisor, tests, and code generation checks as available.
8. **Re-export and compare**: confirm the resulting architecture matches the plan.
9. **Clean final state**: remove stale scripts, scratch files, and unused artifacts from project-owned folders. Keep `.MBD_agent/constitution.md` stable, minimal, and change-averse.

## Reference routing

Read only the reference needed for the current task:

- Modes, MCP, and zip exchange: `references/mbd-operating-modes.md`, `references/matlab-mcp-integration.md`, `references/browser-zip-mode.md`
- `.MBD_agent` layout and governance: `references/mbd-agent-folder.md`
- MATLAB/product discovery: `references/matlab-discovery.md`
- Simulink apps and how to open them: `references/simulink-apps.md`
- Existing model introspection: `references/simulink-introspection.md`
- Scripted Simulink edits: `references/simulink-editing.md`
- Common Simulink blocks (catalog + Continuous, Signal Attributes, Stateflow): `references/common-simulink-blocks.md`
- Base workspace, model workspace, data dictionaries, MAT files: `references/workspace-data-dictionary.md`
- MATLAB project (.prj) management: `references/matlab-project-prj.md`
- Global scripts (build, validate, test): `references/global-scripts.md`
- Requirements, HLD, LLD, implementation: `references/requirements-hld-lld.md`, `references/implementation.md`
- V-Model project structure: `references/v-model-sdlc.md`
- MIL/SIL/PIL/HIL and Simulink Test (harness, assessment, coverage): `references/testing-mil-sil-pil-hil.md`
- Embedded Coder, AUTOSAR, MISRA-ready, hardware implementation: `references/code-generation.md`
- MAAB/MAB, Model Advisor, ISO 26262-oriented review: `references/model-advisor.md`
- MathWorks docs and `openExample` workflow: `references/mathworks-docs-and-examples.md`
- Final review: `references/review-checklist.md`

## MATLAB helper assets

The `assets/matlab/` folder contains reusable helper scripts. Copy them into `.MBD_agent/scripts/` or the user-approved global script folder before use. Do not overwrite project files without approval.

| Script | Purpose |
|---|---|
| `add_place.m` | Add a block with deterministic position |
| `mbd_set_param_strict.m` | Set a parameter only after validating it exists |
| `mbd_connect_line.m` | Connect ports with clear routing default |
| `mbd_add_annotations.m` | Add centered title and subtitle annotations |
| `mbd_apply_model_view.m` | Apply fit-to-view (Ctrl+0 equivalent) |
| `mbd_create_agent_folder.m` | Create the `.MBD_agent` workspace |
| `mbd_discover_environment.m` | Export MATLAB version, products, apps |
| `mbd_export_model_architecture.m` | Export blocks, params, lines, annotations |
| `mbd_export_workspace_state.m` | Export workspace, model workspace, MAT files |
| `mbd_export_data_dictionary.m` | Export data dictionary (dynamic section discovery) |
| `mbd_export_block_library_catalog.m` | Export block library catalog (names, optional default values, multiple roots) |
| `mbd_export_full_catalog.m` | Combine environment + block catalog into one cached file |
| `mbd_run_model_advisor.m` | Run Model Advisor with check group control |
| `mbd_codegen_report.m` | Export code generation config evidence |
| `mbd_test_manager_template.m` | Create a basic Simulink Test file |
| `mbd_project_init.m` | Create or open a MATLAB project (.prj) |
| `config_layout_template.m` | Layout preset template (copy and rename) |

The `assets/python/` folder contains optional bridge tooling for local trusted workflows. Use `matlab_shared_engine_eval.py --list` as part of the session-check step whenever MCP is unavailable, so an already-open MATLAB Desktop is reused instead of starting a new process.

## Non-negotiable rules

- Use MathWorks documentation for the detected MATLAB release as the source of truth. Do not invent API behavior.
- Do not bundle copied MathWorks documentation into the project or the skill.
- **Don't guess block names or parameters from memory.** Run `mbd_export_full_catalog` (cached, regenerate only after a toolbox/release change) or inspect the specific block with `get_param(block, 'DialogParameters')`. `common-simulink-blocks.md` is a rough memory aid only — verify against the generated catalog, not the other way around.
- Use MCP discovery when available; otherwise use `ver`, installed products, and project files to adapt. Do not assume toolboxes.
- **Reuse before you spawn**: follow the session reuse policy above. Do not start a new MATLAB process when an existing/shared session can be used instead.
- Prefer small, reversible scripted changes. With MCP, review model-editing tool calls before execution and do not run model-editing code before user approval.
- **No magic numbers**: put layout positions, sample times, data types, solver settings, and codegen settings into `config_*.m` files. See `assets/matlab/config_layout_template.m`.
- Use existing project style unless the user asks for a new style.
- Make changes minimal - preserve existing naming, structure, and style wherever possible to reduce diff noise.
- Keep Simulink lines clear and straight. Adjust block size and spacing to achieve this; use `Goto`/`From` for long signals.
- Add centered title and subtitle annotations to all generated models and subsystems using `mbd_add_annotations`.
- Apply fit-to-view (`mbd_apply_model_view`) after every scripted model edit.
- Use strict parameter setting (`mbd_set_param_strict`). If a parameter name is wrong or missing, inspect `DialogParameters` and stop - do not guess.
- Use the MATLAB project (`.prj`) for all multi-file projects.
- Before the final reply, run the final review checklist and report: what was changed, how it was verified, and what remains unverified. Never end with a vague promise.

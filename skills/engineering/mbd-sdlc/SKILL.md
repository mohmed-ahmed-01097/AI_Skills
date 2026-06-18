---
name: mbd-sdlc
description: model-based development workflow for matlab, simulink, stateflow, embedded coder, simulink test, model advisor, and v-model sdlc work. use when asked to inspect, document, edit, create, test, validate, generate code for, or review simulink models, matlab projects (.prj), data dictionaries (.sldd), mat files, requirements, hld/lld designs, mil/sil/pil/hil tests, maab/mab checks, misra-ready code generation, autosar branches, or iso 26262-oriented model-based development. supports terminal agents that can run matlab commands and browser workflows that exchange zip files and generated .m/.md reports.
---

# MBD SDLC

Use this skill to run Model-Based Development work through MATLAB scripts and Markdown evidence rather than guessing inside Simulink diagrams.

## Operating principle

Treat Simulink as an executable artifact that must be inspected, changed, and verified through MATLAB commands, generated `.m` scripts, exported `.md` architecture files, and repeatable reports.

Never rely on visual memory of a model. Export the model, workspace, configuration, and test state before planning material changes. Treat every response as if the project is already complete — not a work in progress being explored in chat.

## First decision

Classify the session before doing project work:

1. **Terminal agent mode**: run MATLAB commands from the shell or CMD. Console output, warnings, and errors are direct evidence.
2. **Browser mode**: write MATLAB `.m` scripts for the user to run, then ask for the resulting zip/reports/logs before continuing.
3. **Single-file/small edit**: keep `.MBD_agent` minimal (no `tasks/`, `architecture/`, or large catalog exports).
4. **Large project/new project**: use the full `.MBD_agent` structure and ask once whether the V-Model structure is required.

For mode details, read `references/mbd-operating-modes.md`.

## Mandatory questions — ask only what is not already known

Ask these once at project start. Do not repeat if the answer is discoverable or was already given.

- MATLAB/Simulink release. Discover with `ver` when possible. Default to R2022b-safe scripts when uncertain.
- Single-file edit, existing project, or new project?
- V-Model folder structure needed? (For new or safety-related projects.)
- **Where should global scripts live?** Suggest `.MBD_agent/scripts/` for AI-only use or `tools/mbd/` for project-owned scripts that belong in source control. See `references/global-scripts.md`.
- Is there an existing `.prj` file, or should one be created? See `references/matlab-project-prj.md`.
- Edit approval: list the exact intended changes and wait for approval before implementing, unless the user already explicitly authorized it.

## Standard loop

1. **Discover**: detect MATLAB release, installed products and apps, `.prj` project file, model files, data dictionaries, MAT files, requirements/test artifacts, and generated code folders. Run `mbd_discover_environment`.
2. **Create/reuse `.MBD_agent`**: keep AI artifacts outside project source unless the user asks otherwise. See `references/mbd-agent-folder.md`.
3. **Export evidence**: model architecture (blocks, parameters, lines, annotations, signal attributes), workspace/model workspace/data dictionary, configuration sets, Model Advisor/codegen/test state.
4. **Plan in Markdown**: use exported evidence only. Keep plans task-scoped and short.
5. **Request edit approval**: list the exact model/script/test/config changes and wait for confirmation.
6. **Implement by script**: create `.m` files using `add_place`, `mbd_set_param_strict`, `mbd_connect_line`, `mbd_add_annotations`, and `mbd_apply_model_view`. Use `config_layout.m` for positions — no magic numbers.
7. **Run feedback**: execute scripts, simulation, Model Advisor, tests, and code generation checks as available.
8. **Re-export and compare**: confirm the resulting architecture matches the plan.
9. **Clean final state**: remove stale scripts, scratch files, and unused artifacts from project-owned folders. Keep `.MBD_agent/constitution.md` stable, minimal, and change-averse.

## Reference routing

Read only the reference needed for the current task:

- Modes and zip exchange: `references/mbd-operating-modes.md`, `references/browser-zip-mode.md`
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
| `mbd_export_block_library_catalog.m` | Export installed block catalog |
| `mbd_run_model_advisor.m` | Run Model Advisor with check group control |
| `mbd_codegen_report.m` | Export code generation config evidence |
| `mbd_test_manager_template.m` | Create a basic Simulink Test file |
| `mbd_project_init.m` | Create or open a MATLAB project (.prj) |
| `config_layout_template.m` | Layout preset template (copy and rename) |

## Non-negotiable rules

- Use MathWorks documentation for the detected MATLAB release as the source of truth. Do not invent API behavior.
- Do not bundle copied MathWorks documentation into the project or the skill.
- Use `ver`, installed products, and project files to adapt. Do not assume toolboxes.
- Prefer small, reversible scripted changes.
- **No magic numbers**: put layout positions, sample times, data types, solver settings, and codegen settings into `config_*.m` files. See `assets/matlab/config_layout_template.m`.
- Use existing project style unless the user asks for a new style.
- Make changes minimal — preserve existing naming, structure, and style wherever possible to reduce diff noise.
- Keep Simulink lines clear and straight. Adjust block size and spacing to achieve this; use `Goto`/`From` for long signals.
- Add centered title and subtitle annotations to all generated models and subsystems using `mbd_add_annotations`.
- Apply fit-to-view (`mbd_apply_model_view`) after every scripted model edit.
- Use strict parameter setting (`mbd_set_param_strict`). If a parameter name is wrong or missing, inspect `DialogParameters` and stop — do not guess.
- Use the MATLAB project (`.prj`) for all multi-file projects.
- Before the final reply, run the final review checklist and report: what was changed, how it was verified, and what remains unverified. Never end with a vague promise.

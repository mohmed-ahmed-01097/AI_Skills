# `.MBD_agent` folder

`.MBD_agent` is the AI working area. It keeps analysis, generated helper scripts, reports, and evidence outside the project source.

## Layout

```text
.MBD_agent/
  constitution.md        ? stable project overview (keep minimal and stable)
  rules.md               ? project-specific rules (user + skill defaults)
  README_RUN_ME.md       ? browser-mode: exact command for user to run
  scripts/               ? AI-generated helper scripts
  architecture/          ? model/subsystem Markdown exports
  workspace/             ? workspace, model workspace, data dictionary reports
  reports/               ? environment, Model Advisor, codegen, test reports
  logs/                  ? stdout/stderr from MATLAB runs
  scratch/               ? temporary notes (delete before finishing)
  tasks/                 ? per-task subdirectories (large projects only)
    <YYYY-MM-DD-topic>/
      plan.md
      changes.md
```

### Scale-adjusted layouts

**Single file or small edit** - use only what is needed:

```text
.MBD_agent/
  constitution.md
  rules.md
  scripts/
  reports/
  logs/
```

**Large or new project** - use the full layout including `tasks/`.

## File roles

### `constitution.md`

Stable project description. Keep it short and update only when the project goal, main architecture, or safety boundary changes. Every edit to this file should be intentional - resist adding status updates, chat notes, or per-session changes here.

Recommended sections:

- Project purpose (one paragraph)
- MATLAB/Simulink release and required products
- Main models/subsystems
- Data ownership: base workspace, model workspace, data dictionary, MAT files
- Code generation target
- Test strategy (MIL/SIL/PIL/HIL plan)
- Non-negotiable constraints

### `rules.md`

Project-specific rules merged with skill defaults. Examples:

- naming conventions (models, signals, parameters)
- allowed library paths
- signal naming format
- sample-time rules
- data type rules
- code generation target rules
- additional review checklist items
- user-defined exceptions to skill defaults

### `tasks/<YYYY-MM-DD-topic>/plan.md`

Task-scoped planning for active work on large projects. Use the date-topic naming convention (e.g., `tasks/2024-03-15-add-pid-controller/`). Archive or delete once the task is merged/closed.

### `architecture/`

Generated Markdown exports from `mbd_export_model_architecture`. Name each file `<SafeModelPath>_architecture.md`. Keep before/after pairs during active edits.

### `workspace/`

Reports from `mbd_export_workspace_state` and `mbd_export_data_dictionary`. One `workspace_state.md` per session; dictionary exports use the dictionary filename as prefix.

### `scripts/`

AI-generated helper scripts. Keep only scripts that the current task requires. Delete intermediate scripts after they are superseded or the task is complete. Scripts approved for project use are moved to `tools/mbd/` (or the user-approved location).

### `reports/`

Environment, Model Advisor, codegen config, simulation, and test reports. Named by model and report type: `<model>_codegen_config.md`, `<model>_model_advisor.md`, `matlab_environment.md`.

### `logs/`

Raw stdout/stderr from MATLAB command runs. Name by script and timestamp: `mbd_task_2024-03-15_143200.log`.

### `scratch/`

Temporary notes and intermediate reasoning. Delete or condense before the final response. Do not reference scratch content in the final report.

## Governance

- Never place chat transcripts, session summaries, or conversational AI output in project source folders.
- Do not let `.MBD_agent` accumulate stale scripts and reports between tasks.
- Before the final response, remove obsolete scripts and scratch unless they are evidence.
- For small tasks, err toward fewer files - one architecture export and one report is often enough.

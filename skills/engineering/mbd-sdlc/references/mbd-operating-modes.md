# MBD operating modes

## Terminal agent mode

Use this when the AI agent can run shell/CMD commands and MATLAB commands.

Preferred command patterns:

```bash
matlab -batch "ver; exit"
matlab -batch "run(''.MBD_agent/scripts/mbd_task.m'')"
```

On Windows, use the MATLAB executable available on PATH or the full installation path. Do not assume the executable name if MATLAB is not on PATH.

Evidence rules:

- Treat stdout, stderr, MATLAB warnings, MATLAB errors, generated reports, and changed files as the truth.
- Save important command output to `.MBD_agent/logs/`.
- After a failure, fix the script, not the model manually.
- Do not keep retrying blind. Inspect the exact error, the relevant block parameters, and the generated architecture export.

## Browser mode

Use this when the AI cannot run MATLAB.

Loop:

1. Ask the user to upload the current project zip if not already available.
2. Create or edit `.m` scripts and `.md` instructions.
3. Put all AI-generated helper material under `.MBD_agent/` unless the user asked for project-owned reusable scripts.
4. Return the edited zip or scripts.
5. Ask the user to run one command and upload the resulting `.MBD_agent/reports` or project zip.
6. Continue only from the returned evidence.

See `browser-zip-mode.md` for details.

## Scale modes

### Single model or small edit

Keep the generated files small:

```text
.MBD_agent/
  constitution.md
  rules.md
  scripts/
  reports/
  logs/
```

Export only the affected model/subsystem and relevant workspace/data dictionary items.

### Large project or new project

Use the full `.MBD_agent` structure and create task-scoped subfolders:

```text
.MBD_agent/
  architecture/
  workspace/
  scripts/
  reports/
  logs/
  scratch/
  tasks/<task-id>/
```

Do not create many permanent planning files. Use `tasks/<task-id>/plan.md` only for active work and archive or delete obsolete scratch.

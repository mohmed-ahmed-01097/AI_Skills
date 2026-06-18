# MBD operating modes


## MATLAB MCP agent mode

Use this when the active AI agent exposes MATLAB MCP tools. MCP is preferred over launching repeated independent MATLAB processes because it can run commands, run `.m` files, check MATLAB code, run MATLAB tests, and detect installed products through the configured server.

Rules:

- Treat MCP output as evidence, the same as terminal output.
- Prefer `run_matlab_file` for generated scripts instead of long inline `evaluate_matlab_code` calls.
- Use `check_matlab_code` before running newly generated scripts when available.
- Do not use MCP to bypass approval. Model/project edits still require the user-approved change list.
- If MCP is not available or fails, fall back to terminal agent mode or browser mode.

See `matlab-mcp-integration.md` for setup and tool-use rules.

## Terminal agent mode

Use this when the AI agent can run shell/CMD commands and MATLAB commands.

Preferred command patterns for non-interactive automation:

```bash
matlab -batch "ver"
matlab -batch "run(''.MBD_agent/scripts/mbd_task.m'')"
```

Use `-batch` when the command should run, return an exit code, and close MATLAB. Do not combine `-batch` with `-r`.

For a new interactive MATLAB session that should remain open after the command, use `-r`:

```bash
matlab -r "assert(1+1==2); disp('ASSERT_TEST_PASS')"
```

Use `-nosplash` only as an optional older-release convenience flag; do not depend on it in current MATLAB releases.

To reuse an already-open MATLAB Desktop session from CMD, do not use `-r`. Use MATLAB MCP existing-session mode when available, or use Python shared engine after running `matlab.engine.shareEngine` in MATLAB. See `matlab-mcp-integration.md`.

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

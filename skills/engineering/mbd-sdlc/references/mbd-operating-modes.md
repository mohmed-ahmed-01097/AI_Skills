# MBD operating modes

## Session check (run this before choosing a mode)

Before running any MATLAB command, determine whether an already-open MATLAB session can be reused instead of starting a new process:

1. If MATLAB MCP tools are exposed, the server's configured session mode controls reuse. Confirm it was set up with `--matlab-session-mode=auto` (see `matlab-mcp-integration.md`). If you don't know how the server was configured, ask once rather than assuming a fresh session is fine.
2. If MCP is not exposed but the MATLAB Engine API for Python is installed, run:
   ```bash
   python skills/engineering/mbd-sdlc/assets/python/matlab_shared_engine_eval.py --list
   ```
   If a session name is returned, use it (see Python shared-engine mode below). If none is returned, ask the user to run `matlab.engine.shareEngine` in their open MATLAB Desktop and re-check before falling back to a new process.
3. If neither is available, only `matlab -batch`/`matlab -r` remain, and both always start a new MATLAB process. Say so plainly before running them so the user isn't surprised by a second MATLAB window or a consumed license seat.

## MATLAB MCP agent mode

Use this when the active AI agent exposes MATLAB MCP tools. MCP is preferred over launching repeated independent MATLAB processes because it can run commands, run `.m` files, check MATLAB code, run MATLAB tests, and detect installed products through the configured server.

Rules:

- Treat MCP output as evidence, the same as terminal output.
- Prefer `run_matlab_file` for generated scripts instead of long inline `evaluate_matlab_code` calls.
- Use `check_matlab_code` before running newly generated scripts when available.
- Do not use MCP to bypass approval. Model/project edits still require the user-approved change list.
- Expect the server to attach to an existing/shared MATLAB session when configured with `--matlab-session-mode=auto` or `=existing`. If it was configured with a mode that always starts fresh, flag this to the user rather than silently accepting a new session every call.
- If MCP is not available or fails, fall back to Python shared-engine mode, terminal agent mode, or browser mode in that order.

See `matlab-mcp-integration.md` for setup and tool-use rules.

## Python shared-engine mode

Use this when MCP is unavailable, the user has MATLAB Desktop open, and reusing that exact session matters (open models, base workspace variables, breakpoints). Requires the MATLAB Engine API for Python installed for the active Python environment.

In MATLAB Desktop:

```matlab
matlab.engine.shareEngine
```

From the terminal:

```bash
python skills/engineering/mbd-sdlc/assets/python/matlab_shared_engine_eval.py --list
python skills/engineering/mbd-sdlc/assets/python/matlab_shared_engine_eval.py --code "assert(1+1==2); disp('ASSERT_TEST_PASS')"
python skills/engineering/mbd-sdlc/assets/python/matlab_shared_engine_eval.py --file .MBD_agent/scripts/mbd_task.m
```

If `--list` returns more than one shared session, pass `--engine-name` explicitly rather than letting the script guess - connecting to the wrong session can edit the wrong project. Treat script output the same as MATLAB console evidence and save it to `.MBD_agent/logs/`.

## Terminal agent mode

Use this only when MCP and Python shared-engine mode are both unavailable, or the user explicitly wants an isolated new MATLAB process. The AI agent runs shell/CMD commands and MATLAB commands directly.

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

**Both `-batch` and `-r` always start a new MATLAB process** - neither attaches to an already-open MATLAB Desktop session. If the goal is to reuse an open session, use MCP existing/auto-session mode or Python shared engine instead; see the Session check above and `matlab-mcp-integration.md`.

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

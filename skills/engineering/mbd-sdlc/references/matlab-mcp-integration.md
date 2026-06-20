# MATLAB MCP integration

Use this reference when the active agent environment supports Model Context Protocol (MCP) and the official MATLAB MCP Server is installed or can be configured.

## Role in this skill

MCP is an execution channel, not a replacement for the MBD workflow. Keep the standard loop unchanged:

1. discover the environment
2. export model and workspace evidence
3. plan in `.MBD_agent` Markdown
4. request edit approval
5. implement through `.m` scripts or controlled MATLAB commands
6. re-export, test, and review

Use MCP to run MATLAB commands, run `.m` helper files, check MATLAB code, run tests, and inspect installed products when the agent exposes MATLAB MCP tools - configured by default to reuse the user's open MATLAB session rather than starting a new one. If MCP is unavailable, fall back to the Python shared-engine path when session reuse matters, then to terminal MATLAB commands. If no MATLAB execution channel is available, use browser zip mode.

## Availability decision

At the beginning of agent-mode work, classify the execution path in this order:

1. MATLAB MCP tools available in the current agent - prefer this channel, configured for session reuse (see below).
2. No MCP, but the MATLAB Engine API for Python is installed and the user has MATLAB Desktop open - use the Python shared-engine path to reuse that exact session.
3. Terminal MATLAB commands available, such as `matlab -batch`, `matlab -r`, or OS-specific launch commands - these always start a new process; say so before using them.
4. Browser mode only: write scripts for the user to run and return logs/reports.

Do not assume MCP exists just because the repo mentions it. If the current agent cannot call MCP tools, continue with the next channel in the list.

## MCP setup notes for users

The official MATLAB MCP Server requires a compatible local MATLAB installation and an MCP-compatible AI application. It can start MATLAB, run MATLAB code, analyze MATLAB code, run `.m` files, run MATLAB tests, and detect installed MATLAB products.

Typical Claude Code setup after downloading the server binary:

```bash
claude mcp add --transport stdio matlab -- /full/path/to/matlab-mcp-server-binary --initial-working-folder=/path/to/project --matlab-session-mode=auto
```

Typical VS Code workspace setup uses `.vscode/mcp.json`:

```json
{
  "servers": {
    "matlab": {
      "type": "stdio",
      "command": "C:\\fullpath\\to\\matlab-mcp-server-windows-x64.exe",
      "args": [
        "--initial-working-folder=C:\\path\\to\\project",
        "--matlab-session-mode=auto"
      ]
    }
  }
}
```

For an already-open MATLAB session, configure the server to attach automatically rather than treating reuse as a special case. The usual sequence is:

1. run the MCP server setup command once, such as `matlab-mcp-server --setup-matlab`
2. in the open MATLAB Desktop, run `shareMATLABSession()`
3. start the MCP server with `--matlab-session-mode=auto` so it attaches to that shared session when one exists and only starts a new one when none is found

**Use `--matlab-session-mode=auto` as the default for every setup**, not just when reuse is explicitly requested - it degrades gracefully to a new session when nothing is shared, so there is no downside to leaving it on. Reserve `--matlab-session-mode=existing` for cases where starting a new session should be a hard error if nothing is shared (for example, a CI step that must fail loudly rather than silently spin up MATLAB).

Exact flag names and supported modes can change between MATLAB MCP Server versions. Run the server binary with `--help` (or check the version actually installed) before relying on any flag below, rather than assuming this document is current for that release.

Recommended arguments when suitable:

```text
--initial-working-folder=<project-root>
--matlab-root=<matlab-install-root>
--matlab-session-mode=auto
--disable-telemetry=true
```


## Reusing an already-open MATLAB Desktop session

Two reuse paths exist. Prefer the MCP path when the server is configured for it; otherwise use the Python shared-engine path.

### MCP path (preferred)

Configure the server with `--matlab-session-mode=auto` as shown above, then run `shareMATLABSession()` in the open MATLAB Desktop. The server attaches to that session on its next tool call. No further action is needed per task.

### Python shared-engine path

Use this when MCP is not configured, or when the user specifically wants terminal commands to land in their open MATLAB Desktop without going through MCP at all.

In the already-open MATLAB Desktop session, run:

```matlab
matlab.engine.shareEngine
```

From the system terminal, connect to that shared session and run code:

```bash
python skills/engineering/mbd-sdlc/assets/python/matlab_shared_engine_eval.py --code "assert(1+1==2); disp('ASSERT_TEST_PASS')"
```

Run a generated script in the shared session:

```bash
python skills/engineering/mbd-sdlc/assets/python/matlab_shared_engine_eval.py --file .MBD_agent/scripts/mbd_task.m
```

If more than one shared session exists, pass `--engine-name` explicitly - do not let the script silently pick one, since connecting to the wrong session can edit the wrong project.

Use this only on local trusted machines. A shared MATLAB session can modify the open workspace, models, data dictionaries, files, and project state. Approval-before-edit still applies.

## Terminal startup choices

Use `-batch` for non-interactive automation that should return an exit code and close MATLAB automatically:

```bash
matlab -batch "assert(1+1==2); disp('ASSERT_TEST_PASS')"
```

Use `-r` when the terminal should start a new interactive MATLAB process, run a short command, and leave MATLAB open:

```bash
matlab -r "assert(1+1==2); disp('ASSERT_TEST_PASS')"
```

`-r` does not attach to an already-open MATLAB Desktop session. For that, use MCP configured with `--matlab-session-mode=auto` or the Python shared-engine path.

Use `-nosplash` only as an optional older-release startup flag. Do not depend on it for current-release behavior.

## Tool-use rules

When MCP tools are available, use them as follows:

- use `detect_matlab_toolboxes` before assuming products or releases
- use `check_matlab_code` before running newly generated helper or edit scripts
- use `run_matlab_file` for generated `.m` scripts in `.MBD_agent/scripts/` or the approved project script folder
- use `evaluate_matlab_code` only for short, explicit, reviewable commands
- use `run_matlab_test_file` for MATLAB unit tests when applicable

Prefer file-based execution over long inline commands. Generated `.m` scripts are easier to inspect, rerun, version, and compare.

## Approval and safety

Before any MCP call that can modify models, data dictionaries, project files, generated code settings, requirements, test files, or workspace state:

1. list the exact intended changes
2. identify the script or command that will execute them
3. get user approval unless approval was already explicitly given for that action

Never use MCP to bypass review. Treat MCP execution output as evidence and save important outputs into `.MBD_agent/reports/` or `.MBD_agent/logs/`.

Do not share one MCP MATLAB server between multiple users. Respect MathWorks licensing and the user's local security model.

## Integration with helper assets

For MBD work, copy the relevant helper assets from `assets/matlab/` into `.MBD_agent/scripts/` or the user-approved global script folder, then run them through MCP. Match the actual function signatures - each takes an output directory, not the project root:

```matlab
mbd_create_agent_folder(projectRoot)
mbd_discover_environment(fullfile(projectRoot, '.MBD_agent', 'reports'))
mbd_export_workspace_state(modelName, fullfile(projectRoot, '.MBD_agent', 'workspace'))
mbd_export_model_architecture(modelName, fullfile(projectRoot, '.MBD_agent', 'architecture'))
```

Use `check_matlab_code` on copied/generated scripts before `run_matlab_file` where practical.

## Fallback rules

If MCP fails or is not configured:

- do not stop the task unless the user explicitly required MCP
- if reusing the user's open MATLAB Desktop matters and the MATLAB Engine API for Python is installed, fall back to the Python shared-engine path before resorting to a new process
- otherwise fall back to terminal MATLAB commands if the agent has shell/CMD access
- fall back to browser zip mode if no executable MATLAB channel is available
- record the fallback reason in `.MBD_agent/logs/` for large projects

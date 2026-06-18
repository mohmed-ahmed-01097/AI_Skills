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

Use MCP to run MATLAB commands, run `.m` helper files, check MATLAB code, run tests, and inspect installed products when the agent exposes MATLAB MCP tools. If MCP is unavailable, fall back to terminal MATLAB commands. If terminal execution is unavailable, use browser zip mode.

## Availability decision

At the beginning of agent-mode work, classify the execution path in this order:

1. MATLAB MCP tools available in the current agent.
2. Terminal MATLAB commands available, such as `matlab -batch`, `matlab -r`, or OS-specific launch commands.
3. Browser mode only: write scripts for the user to run and return logs/reports.

Do not assume MCP exists just because the repo mentions it. If the current agent cannot call MCP tools, continue with terminal or browser mode.

## MCP setup notes for users

The official MATLAB MCP Server requires a compatible local MATLAB installation and an MCP-compatible AI application. It can start MATLAB, run MATLAB code, analyze MATLAB code, run `.m` files, run MATLAB tests, and detect installed MATLAB products.

Typical Claude Code setup after downloading the server binary:

```bash
claude mcp add --transport stdio matlab -- /full/path/to/matlab-mcp-server-binary --initial-working-folder=/path/to/project
```

Typical VS Code workspace setup uses `.vscode/mcp.json`:

```json
{
  "servers": {
    "matlab": {
      "type": "stdio",
      "command": "C:\\fullpath\\to\\matlab-mcp-server-windows-x64.exe",
      "args": [
        "--initial-working-folder=C:\\path\\to\\project"
      ]
    }
  }
}
```

For an already-open MATLAB session, prefer MCP existing-session mode only when the release and setup support it. The usual sequence is:

1. run the MCP server setup command once, such as `matlab-mcp-server --setup-matlab`
2. in the open MATLAB Desktop, run `shareMATLABSession()`
3. start the MCP server with `--matlab-session-mode=existing` or `--matlab-session-mode=auto`

Existing-session mode is not the default assumption for R2022b projects. When it is unavailable, use a new MCP MATLAB session or terminal/browser fallback.

Recommended arguments when suitable:

```text
--initial-working-folder=<project-root>
--matlab-root=<matlab-install-root>
--matlab-session-mode=auto
--disable-telemetry=true
```

Use `--matlab-session-mode=existing` only after the user confirms the existing session is configured and shared.


## Reusing an already-open MATLAB Desktop session

There are two supported reuse paths. Prefer MCP existing-session mode when the MCP server and MATLAB release support it. Otherwise, use Python shared engine if the MATLAB Engine API for Python is installed.

### MCP existing-session path

Typical sequence:

1. run `matlab-mcp-server --setup-matlab` once
2. in MATLAB Desktop, run `shareMATLABSession()`
3. start the MCP server with `--matlab-session-mode=existing` or `--matlab-session-mode=auto`

Do not assume this path is available for R2022b-oriented projects. Confirm release support and server setup first.

### Python shared-engine path

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

`-r` does not attach to an already-open MATLAB Desktop session. For that, use MCP existing-session mode or Python shared engine.

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

For MBD work, copy the relevant helper assets from `assets/matlab/` into `.MBD_agent/scripts/` or the user-approved global script folder, then run them through MCP:

```matlab
mbd_create_agent_folder(projectRoot)
mbd_discover_environment(projectRoot, fullfile(projectRoot, '.MBD_agent', 'reports'))
mbd_export_workspace_state(projectRoot, fullfile(projectRoot, '.MBD_agent', 'workspace'))
mbd_export_model_architecture(modelName, fullfile(projectRoot, '.MBD_agent', 'architecture'))
```

Use `check_matlab_code` on copied/generated scripts before `run_matlab_file` where practical.

## Fallback rules

If MCP fails or is not configured:

- do not stop the task unless the user explicitly required MCP
- fall back to terminal MATLAB commands if the agent has shell/CMD access
- fall back to browser zip mode if no executable MATLAB channel is available
- record the fallback reason in `.MBD_agent/logs/` for large projects

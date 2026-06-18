# MATLAB MCP setup for MBD SDLC

This repository can use the official MATLAB MCP Server when the active AI agent supports Model Context Protocol. MCP is optional. The skill still supports terminal MATLAB commands, Python shared-engine execution, and browser zip mode.

## When to use MCP

Use MCP when you want the agent to execute MATLAB commands or `.m` scripts through an MCP server instead of launching independent `matlab -batch` commands.

Good uses:

- detect MATLAB release and installed products
- check generated MATLAB code before execution
- run `.m` helper scripts from `.MBD_agent/scripts/`
- run MATLAB test files
- execute short, reviewed commands

Do not use MCP to bypass the skill approval workflow. For model edits, list the intended changes first and get approval.

## Claude Code example

After downloading the MATLAB MCP Server binary, run:

```bash
claude mcp add --transport stdio matlab -- /full/path/to/matlab-mcp-server-binary --initial-working-folder=/path/to/mbd-project --disable-telemetry=true
```

For a Windows binary path, use the full `.exe` path.

## VS Code MCP example

Create `.vscode/mcp.json` in the workspace and adapt the paths:

```json
{
  "servers": {
    "matlab": {
      "type": "stdio",
      "command": "C:\\fullpath\\to\\matlab-mcp-server-windows-x64.exe",
      "args": [
        "--initial-working-folder=C:\\path\\to\\mbd-project",
        "--disable-telemetry=true"
      ]
    }
  }
}
```

## Existing MATLAB Desktop session through MCP

For an already-open MATLAB Desktop session, use existing-session mode only when supported and configured.

Typical sequence:

1. run `matlab-mcp-server --setup-matlab` once
2. in the open MATLAB Command Window, run `shareMATLABSession()`
3. start the MCP server with `--matlab-session-mode=existing` or `--matlab-session-mode=auto`

For R2022b-oriented projects, do not assume existing-session mode is available. Use a new MCP MATLAB session, Python shared-engine execution, terminal execution, or browser zip mode when needed.

## Existing MATLAB Desktop session through Python shared engine

If MCP existing-session mode is unavailable but the MATLAB Engine API for Python is installed, the agent or user can connect to an already-open MATLAB Desktop session.

In MATLAB Desktop, share the current session:

```matlab
matlab.engine.shareEngine
```

From CMD, PowerShell, or Bash, list shared sessions:

```bash
python skills/engineering/mbd-sdlc/assets/python/matlab_shared_engine_eval.py --list
```

Run a small assertion in the existing shared session:

```bash
python skills/engineering/mbd-sdlc/assets/python/matlab_shared_engine_eval.py --code "assert(1+1==2); disp('ASSERT_TEST_PASS')"
```

Run a generated `.m` script in the existing shared session:

```bash
python skills/engineering/mbd-sdlc/assets/python/matlab_shared_engine_eval.py --file .MBD_agent/scripts/mbd_task.m
```

Use this path only for local trusted workflows. The shared MATLAB session has the same access as the user's open MATLAB Desktop.

## Starting a new interactive MATLAB session from CMD

Use `-r` when a terminal command should start MATLAB, run a short statement, and leave MATLAB open for interactive inspection:

```bash
matlab -r "assert(1+1==2); disp('ASSERT_TEST_PASS')"
```

Use `-nosplash` only as an optional compatibility flag for older releases. In newer releases, MATLAB can ignore it because it is no longer supported:

```bash
matlab -nosplash -r "assert(1+1==2); disp('ASSERT_TEST_PASS')"
```

Do not treat `-r` as a connection to an already-open MATLAB session. It starts a MATLAB process. Use MCP existing-session mode or Python shared engine when the requirement is to reuse an existing MATLAB Desktop session.

Use `-batch` for non-interactive automation that should return an exit code and close MATLAB automatically:

```bash
matlab -batch "assert(1+1==2); disp('ASSERT_TEST_PASS')"
```

Do not combine `-batch` and `-r`.

## Recommended skill behavior

The agent should choose execution in this order:

1. MATLAB MCP tools, if available
2. Python shared-engine execution when an existing MATLAB Desktop session must be reused
3. terminal MATLAB commands, if available
4. browser zip mode

Keep all AI-created MBD artifacts under `.MBD_agent/` unless the user approves another location.

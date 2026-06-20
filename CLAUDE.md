# Agent repository rules

Skills are organized under `skills/`.

- `skills/engineering/` contains engineering workflow skills.
- Every promoted skill must be listed in the top-level `README.md` and `.claude-plugin/plugin.json`.
- Each skill must have a `SKILL.md`.
- Keep skill control files concise. Move detailed workflow material into `references/`.
- Keep executable/reusable assets in `assets/` unless they are repo maintenance scripts.
- Do not place user project outputs, MATLAB generated code, or `.MBD_agent` folders in this repo.

For this repo, `mbd-sdlc` is the primary engineering skill.


## MATLAB MCP integration

If a MATLAB MCP Server is configured in the active agent environment, prefer it for MATLAB discovery, `check_matlab_code`, `run_matlab_file`, `run_matlab_test_file`, and short `evaluate_matlab_code` calls. Keep generated or copied scripts under `.MBD_agent/scripts/` or the user-approved project script folder.

Do not use MCP to bypass the MBD approval workflow. Before running a model-editing or project-modifying MCP call, list the intended changes and get approval unless the user already authorized that exact implementation.

If MCP is unavailable or fails, fall back to the Python shared-engine path (when reuse matters and the MATLAB Engine API for Python is installed), then terminal MATLAB commands, then browser zip mode according to the skill instructions.

## Existing MATLAB Desktop session

Default to reusing the user's already-open MATLAB session rather than starting a new process - this is the standing behavior, not something that requires the user to ask for it first. Do not use `matlab -batch` or `matlab -r` as the default path. Configure MCP with `--matlab-session-mode=auto` so it attaches automatically. If MCP is not configured, ask the user to run `matlab.engine.shareEngine` in MATLAB Desktop and then use `skills/engineering/mbd-sdlc/assets/python/matlab_shared_engine_eval.py` from the terminal.

Use `matlab -r "..."` only to start a new interactive MATLAB process that remains open, and only after the user has confirmed a new process is acceptable. Use `matlab -batch "..."` for non-interactive automation that should close MATLAB and return an exit code.

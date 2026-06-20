# Python assets

`matlab_shared_engine_eval.py` is optional bridge tooling for reusing an
already-open MATLAB Desktop session from the terminal when MATLAB MCP is
not available. It requires the MATLAB Engine API for Python and a MATLAB
session that has run `matlab.engine.shareEngine`.

See `references/matlab-mcp-integration.md` and `docs/matlab-mcp-setup.md`
for the full setup and usage flow. Prefer MATLAB MCP configured with
`--matlab-session-mode=auto` when it is available - this script exists for
the case where MCP is not set up but session reuse still matters.

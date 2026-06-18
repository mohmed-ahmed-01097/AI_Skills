# AGENTS.md

Use the MBD SDLC skill when the task involves MATLAB, Simulink, Model-Based Development, Embedded Coder, Simulink Test, Model Advisor, MAAB/MAB checks, MISRA-ready code generation, AUTOSAR branches, ISO 26262-oriented evidence, or V-Model SDLC artifacts.

Default behavior:

1. If MATLAB MCP tools are available, prefer them for discovery, MATLAB code checks, `.m` execution, and test execution. If the user requires the already-open MATLAB Desktop, use MCP existing-session mode or Python shared engine. Otherwise use terminal or browser mode.
2. Discover MATLAB release and installed products.
3. Keep AI artifacts under `.MBD_agent/`.
4. Export model/workspace evidence before planning changes.
5. Ask for edit approval and list exact intended changes.
6. Implement through `.m` scripts. Use MCP `run_matlab_file` when available; use Python shared engine for an explicitly shared existing MATLAB Desktop session; otherwise use terminal MATLAB commands or browser handoff.
7. Re-export and validate before final response.

Do not edit Simulink models manually when a scripted edit is possible.

MCP does not override approval rules. Review model-editing tool calls before execution and keep the user in control of destructive or structural changes.

For terminal MATLAB startup, use `matlab -batch "..."` for non-interactive automation that closes MATLAB, and `matlab -r "..."` only when starting a new interactive MATLAB session that should stay open. `matlab -r` does not attach to an already-open MATLAB Desktop session.

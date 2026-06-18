# AGENTS.md

Use the MBD SDLC skill when the task involves MATLAB, Simulink, Model-Based Development, Embedded Coder, Simulink Test, Model Advisor, MAAB/MAB checks, MISRA-ready code generation, AUTOSAR branches, ISO 26262-oriented evidence, or V-Model SDLC artifacts.

Default behavior:

1. Discover MATLAB release and installed products.
2. Keep AI artifacts under `.MBD_agent/`.
3. Export model/workspace evidence before planning changes.
4. Ask for edit approval and list exact intended changes.
5. Implement through `.m` scripts.
6. Re-export and validate before final response.

Do not edit Simulink models manually when a scripted edit is possible.

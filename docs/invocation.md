# Invocation

`mbd-sdlc` is intended to be model-invoked and user-invoked.

Invoke it for:

- MATLAB project setup or review
- MATLAB MCP Server based execution for MBD work
- existing MATLAB Desktop session execution through MCP or Python shared engine
- Simulink model inspection or scripted edit
- requirements, HLD, LLD, implementation, or V-Model workflows
- MIL/SIL/PIL/HIL testing
- Simulink Test Manager workflows
- Model Advisor or MAAB/MAB-style checks
- Embedded Coder production C
- MISRA-ready, AUTOSAR, or ISO 26262-oriented evidence

Do not invoke it for generic MATLAB numerical scripting unless the task touches Model-Based Development artifacts or SDLC process.

When MCP is present, use it as an execution channel for MATLAB commands and files. When the user requires reusing an already-open MATLAB Desktop session and MCP existing-session mode is unavailable, use Python shared engine after the MATLAB session is shared. The core workflow remains evidence export, Markdown planning, user-approved scripted edits, re-export, validation, and final review.

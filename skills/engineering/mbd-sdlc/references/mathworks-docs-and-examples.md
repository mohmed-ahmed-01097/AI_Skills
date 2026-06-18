# MathWorks documentation and examples

## Source of truth

Use MathWorks documentation for the detected MATLAB release as the source of truth. Do not rely on memory when APIs, block parameters, product workflows, or code generation settings matter.

## Release handling

1. Detect release with `version` and `ver`.
2. Use documentation for that release when available.
3. If release-specific docs are unavailable, state the uncertainty and verify with MATLAB commands.

## Opening documentation from MATLAB

```matlab
doc simulink
doc add_block
doc get_param
doc set_param
doc Simulink.data.dictionary.open
doc sltest.testmanager
doc coder
doc simulinkcoder
doc embeddedcoder
doc matlab.project
```

## Opening and running built-in examples

Prefer `openExample` — it opens the example in a safe writable copy:

```matlab
% Open a Simulink example by its example name.
openExample('simulink/BasicPIDExampleExample')
openExample('simulink_automotive/PowerWindowExample')
openExample('slcontrol/DesignSingleLoopControllerExample')

% Search for relevant examples in the browser.
exampleBrowser
```

To find the exact example name for a topic:
1. Run `doc <topic>` in MATLAB.
2. Scroll to the "Examples" section.
3. Copy the example function name from the link.

## Workflow when applying an example to a project

1. Run `openExample` to get a writable copy.
2. Export the example architecture: `mbd_export_model_architecture('exampleModel', ...)`.
3. Identify the exact pattern to reuse — do not copy the whole model blindly.
4. List what will be adapted and what will be changed for the project.
5. Implement the adapted pattern with `add_place` and `mbd_set_param_strict`.
6. Verify by simulation and checks.

## Finding library examples for a specific block

```matlab
% Show the library documentation for a block type.
doc('Gain')
doc('Discrete-Time Integrator')

% Open the block reference from an already-placed block.
open_system(gcb, 'mask')
```

## Online documentation URL pattern

For a specific release (example R2023b):

```
https://www.mathworks.com/help/releases/R2023b/simulink/ug/<topic>.html
```

Use this URL pattern when the agent has browser access and the local doc might be unavailable.

## Do not copy MathWorks documentation text

Summarize only what the project needs. Cite or link externally. Do not embed large documentation blocks into project files or `.MBD_agent/`.

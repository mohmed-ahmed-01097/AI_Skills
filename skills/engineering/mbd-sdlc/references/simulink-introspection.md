# Simulink introspection

Use introspection to convert a model or subsystem into evidence the AI can reason over.

## Export first

For an existing model:

```matlab
load_system('modelName');
mbd_export_model_architecture('modelName', fullfile(pwd, '.MBD_agent', 'architecture'));
mbd_export_workspace_state('modelName', fullfile(pwd, '.MBD_agent', 'workspace'));
```

For one subsystem:

```matlab
mbd_export_model_architecture('modelName/Subsystem', fullfile(pwd, '.MBD_agent', 'architecture'));
```

## What to capture

- block path
- parent subsystem
- block type and mask type
- library link status
- position
- ports
- dialog parameters and current values
- callbacks
- annotations
- line source and destination
- signal names
- model configuration set summary

## Reasoning rules

- Do not infer a missing connection from block proximity.
- Do not assume a parameter name. Inspect `get_param(block, 'DialogParameters')`.
- Do not assume masked subsystem internals are visible. Use `LookUnderMasks` deliberately.
- Preserve library links unless the task requires breaking them.
- When a model uses variants, export variant controls and active choices.

## Useful MATLAB commands

```matlab
find_system(model, 'LookUnderMasks', 'all', 'FollowLinks', 'on')
get_param(blockPath, 'ObjectParameters')
get_param(blockPath, 'DialogParameters')
get_param(blockPath, 'PortHandles')
find_system(model, 'FindAll', 'on', 'Type', 'line')
Simulink.findBlocks(model)
Simulink.findBlocksOfType(model, 'Gain')
```

Use `find_system` for broad compatibility and object APIs when available and useful.

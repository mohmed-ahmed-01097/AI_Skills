# Scripted Simulink editing

## Edit policy

Before editing, list the intended changes and ask for approval unless the user already approved implementation.

Always create or edit a MATLAB script rather than making manual Simulink edits. A good edit script:

- opens or creates the model
- runs a layout config file (`config_layout.m`) to define position constants
- uses `add_place` for block placement
- uses `mbd_set_param_strict` for parameter setting
- uses `mbd_connect_line` for routing
- saves only the intended model/project files
- calls `mbd_add_annotations` for titles/subtitles
- calls `mbd_apply_model_view` at the end
- exports architecture after changes

## Block placement with `add_place`

```matlab
% Full signature: library, destination, x, y, width, height, extra name/values.
add_place('simulink/Math Operations/Gain', 'myModel/Controller/GainKp', ...
    LAYOUT_COL2_X, LAYOUT_ROW1_Y, LAYOUT_BLOCK_W, LAYOUT_BLOCK_H);

% Minimal signature: position only, defaults for width/height.
add_place('simulink/Sources/In1', 'myModel/Controller/u', ...
    LAYOUT_COL1_X, LAYOUT_ROW1_Y);
```

### Avoiding duplicate block name errors

If a block name might already exist in the system, use `MakeNameUnique`:

```matlab
add_block('simulink/Math Operations/Gain', 'myModel/Controller/Gain', ...
    'MakeNameUnique', 'on', 'Position', [x y x+w y+h]);
```

`add_place` passes through `varargin` to `add_block`, so:

```matlab
add_place('simulink/Math Operations/Gain', 'myModel/Controller/Gain', ...
    x, y, w, h, 'MakeNameUnique', 'on');
```

### Verifying library paths before use

Run the catalog export or use the quick check:

```matlab
% Verify block exists in the library before add_block.
try
    open_system('simulink');
    h = find_system('simulink', 'FollowLinks', 'on', 'Name', 'Gain');
catch ME
    disp(ME.message);
end
```

For a one-time, cached, release-correct reference instead of repeated quick checks:

```matlab
mbd_export_full_catalog();   % cached after the first run; see matlab-discovery.md
```

## Line routing with `mbd_connect_line`

```matlab
mbd_connect_line(systemPath, 'In1/1', 'Gain/1');
mbd_connect_line(systemPath, 'Gain/1', 'Out1/1');
```

For branching signals (one source ? two destinations), use branching:

```matlab
% Add first connection.
add_line(systemPath, 'Gain/1', 'Sum/1', 'autorouting', 'on');
% Branch from existing line by specifying the same source port.
add_line(systemPath, 'Gain/1', 'Scope/1', 'autorouting', 'on');
```

### Straight-line routing rules

- Increase block height (use `LAYOUT_BLOCK_H_TALL`) to align ports when more than two blocks share a row.
- Increase row gap (`LAYOUT_ROW_GAP`) so horizontal lines have clear lanes.
- Avoid autorouting for simple left-to-right connections when explicit port positions are known.
- Prefer `Goto`/`From` pairs over long cross-canvas wires.
- Use intermediate subsystems to group dense signal clusters.

## Parameter setting

```matlab
% Safe: validates parameter name before setting.
mbd_set_param_strict(blockPath, 'Gain', 'Kp');
mbd_set_param_strict(blockPath, 'SampleTime', '-1');

% If parameter name is unknown, inspect first.
params = get_param(blockPath, 'DialogParameters');
disp(fieldnames(params));
```

## Library-linked blocks

Do not break library links unless:

- the task explicitly requires masking or modification of a library block, OR
- the user has approved unlinking.

To check link status:

```matlab
status = get_param(blockPath, 'LinkStatus'); % 'resolved', 'unresolved', 'none'
```

To intentionally break:

```matlab
set_param(blockPath, 'LinkStatus', 'none');
```

## Annotations (titles and subtitles)

```matlab
% Add a title and subtitle to a generated model or subsystem.
mbd_add_annotations('myModel/Controller', 'Controller Subsystem', 'Rev 1.0');
mbd_add_annotations('myModel', 'Top-Level Model', '');
```

See `assets/matlab/mbd_add_annotations.m` for the implementation.

## Final steps after every scripted edit

```matlab
save_system(modelName);
mbd_add_annotations(systemPath, titleText, subtitleText);
mbd_apply_model_view(systemPath);
mbd_export_model_architecture(modelOrSubsystem, ...
    fullfile(pwd, '.MBD_agent', 'architecture'));
```

## Function header comment format

```matlab
function out = function_name(in)
%FUNCTION_NAME One-line summary.
% Description:
%   Short description of behavior and constraints.
%
% Inputs:
%   in - input description.
%
% Outputs:
%   out - output description.
```

Comments inside functions: explain intent, assumptions, or non-obvious API behavior only. Do not comment every line.

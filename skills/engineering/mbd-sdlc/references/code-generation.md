# Code generation

## Default target

Optimize for Embedded Coder production C when available. Support optional AUTOSAR, MISRA-ready, and ISO 26262-oriented branches only when the project setup already requires them.

## Discovery before changing settings

```matlab
load_system('modelName');
cs = getActiveConfigSet('modelName');
get_param(cs, 'SystemTargetFile')   % e.g., 'ert.tlc' or 'grt.tlc'
get_param(cs, 'SolverType')
get_param(cs, 'FixedStep')
get_param(cs, 'ProdHWDeviceType')   % hardware implementation
```

Generate a config report:

```matlab
mbd_codegen_report('modelName', fullfile(pwd, '.MBD_agent', 'reports'));
```

## Hardware implementation settings

Hardware implementation is the most commonly overlooked setting. Always verify before generating code for a target.

```matlab
% Read key hardware settings.
get_param(cs, 'ProdHWDeviceType')       % e.g., 'ARM Compatible->ARM Cortex'
get_param(cs, 'ProdBitPerChar')         % typically 8
get_param(cs, 'ProdBitPerInt')          % typically 32
get_param(cs, 'ProdBitPerLong')         % 32 or 64
get_param(cs, 'ProdEndianess')          % 'LittleEndian' or 'BigEndian'
get_param(cs, 'ProdIntDivRoundTo')      % 'Zero' for MISRA-ready
get_param(cs, 'ProdShiftRightIntArith') % 'on' for most ARM targets

% Set for a 32-bit ARM Cortex-M target.
set_param(cs, 'ProdHWDeviceType', 'ARM Compatible->ARM Cortex');
set_param(cs, 'ProdBitPerChar',  '8');
set_param(cs, 'ProdBitPerInt',   '32');
set_param(cs, 'ProdBitPerLong',  '32');
set_param(cs, 'ProdEndianess',   'LittleEndian');
```

## Common production C settings

```matlab
set_param(cs, 'SystemTargetFile', 'ert.tlc');       % Embedded Coder
set_param(cs, 'SolverType',       'Fixed-step');
set_param(cs, 'FixedStep',        '0.001');          % 1 ms step
set_param(cs, 'InlineParams',     'on');
set_param(cs, 'OptimizeBlockIOStorage', 'on');
set_param(cs, 'BlockReduction',   'on');
set_param(cs, 'CodeInterfacePackaging', 'Reusable function');
set_param(cs, 'GenerateReport',   'on');
```

## Build policy

Do not run code generation without listing:

- model name and target
- expected output folder (`<model>_ert_rtw/` or `<model>_grt_rtw/`)
- checks to run before/after build

After user approval:

```matlab
slbuild('modelName');
% Or for model reference:
rtwbuild('modelName');
```

## Model reference code generation

```matlab
% Check model reference simulation target.
get_param(cs, 'ModelReferenceCompliant')
get_param(cs, 'ModelReferenceMinAlgLoopOccurrences')

% Generate code for a referenced model independently.
slbuild('referencedModelName', 'ModelReferenceCoderTarget');
```

## MISRA-ready workflow

1. Configure fixed-step discrete solver, no dynamic allocation.
2. Set `ProdIntDivRoundTo = 'Zero'`.
3. Enable `BooleanDataType = 'on'`.
4. Disable floating-point in safety paths if required.
5. Run Model Advisor MAAB and MISRA-C oriented checks.
6. Use Polyspace or approved static-analysis tool when available.
7. Report deviations with justification.

```matlab
% Useful MISRA-oriented settings.
set_param(cs, 'DefaultUnderspecifiedDataType', 'double');
set_param(cs, 'DataTypeOverride', 'UseLocalSettings');
set_param(cs, 'BooleanDataType', 'on');
```

## AUTOSAR branch

Only use AUTOSAR APIs when AUTOSAR support is installed and the project is already AUTOSAR-oriented.

Required decisions before starting:

- Classic or Adaptive AUTOSAR?
- Component and interface naming convention?
- ARXML import/export expectations?
- Data type mapping rules?
- Runnable and event strategy?

## ISO 26262 branch

Do not claim compliance from a script. Produce traceability evidence:

- requirements trace to model elements
- test evidence per ASIL level
- Model Advisor check results
- code generation configuration evidence
- review logs
- open/closed issue list

## Generated code folders

| Target | Output folder |
|---|---|
| ERT (Embedded Coder) | `<model>_ert_rtw/` |
| GRT (Simulink Coder) | `<model>_grt_rtw/` |
| AUTOSAR | `<model>_autosar_rtw/` |
| Model reference target | `slprj/ert/<model>/` |
| Shared utilities | `slprj/ert/_sharedutils/` |

Exclude generated code folders from source control:

```gitignore
*_ert_rtw/
*_grt_rtw/
slprj/
codegen/
```

# Common Simulink blocks

**This file is a hand-written memory aid, not generated from a real MATLAB install.** It is meant only to help recognize common block names and roughly which parameters matter - treat the "Key parameters" column as a rough pointer, not a verified fact. Parameter names, defaults, and availability change between releases and depend on which toolboxes are licensed, and this list was not checked against any specific version.

**Before setting any parameter, verify it against the user's actual MATLAB**, not this table:

```matlab
get_param(blockPath, 'DialogParameters')
```

Or generate a real catalog from the installed release:

```matlab
mbd_export_full_catalog();              % one combined file: environment + block catalog
mbd_export_block_library_catalog();      % block catalog only
```

See `matlab-discovery.md` for when to (re)generate this and how caching works.

## Sources

| Library path | Common use | Key parameters |
|---|---|---|
| `simulink/Sources/In1` | subsystem/model input | `Port`, `OutDataTypeStr`, `SampleTime` |
| `simulink/Sources/Out1` | subsystem/model output | `Port`, `OutDataTypeStr`, `SampleTime` |
| `simulink/Sources/Constant` | constant value | `Value`, `OutDataTypeStr`, `SampleTime` |
| `simulink/Sources/Step` | step stimulus | `Time`, `Before`, `After`, `SampleTime` |
| `simulink/Sources/Ramp` | ramp stimulus | `slope`, `start`, `InitialOutput`, `SampleTime` |
| `simulink/Sources/Sine Wave` | sinusoidal stimulus | `Amplitude`, `Frequency`, `Phase`, `SampleTime` |
| `simulink/Sources/From Workspace` | workspace signal | `VariableName`, `SampleTime` |
| `simulink/Sources/From File` | signal from MAT file | `FileName`, `SampleTime` |
| `simulink/Sources/Signal Builder` | legacy signal stimulus | release-specific |
| `simulink/Sources/Signal Editor` | modern signal stimulus (R2018b+) | release-specific |
| `simulink/Sources/Ground` | zero input stub | `OutDataTypeStr` |

## Sinks

| Library path | Common use | Key parameters |
|---|---|---|
| `simulink/Sinks/Out1` | model/subsystem output | `Port`, `OutDataTypeStr` |
| `simulink/Sinks/Scope` | visual inspection | logging params |
| `simulink/Sinks/To Workspace` | simulation output | `VariableName`, `SaveFormat`, `SampleTime` |
| `simulink/Sinks/To File` | save signal to MAT | `FileName`, `SampleTime` |
| `simulink/Sinks/Display` | scalar display | format params |
| `simulink/Sinks/Terminator` | terminate unused line | none |

## Math Operations

| Library path | Common use | Key parameters |
|---|---|---|
| `simulink/Math Operations/Gain` | scaling | `Gain`, `Multiplication`, `ParamDataTypeStr` |
| `simulink/Math Operations/Sum` | addition/subtraction | `Inputs`, `IconShape`, `OutDataTypeStr` |
| `simulink/Math Operations/Product` | multiply/divide | `Inputs`, `Multiplication` |
| `simulink/Math Operations/Abs` | absolute value | output data type params |
| `simulink/Math Operations/MinMax` | min/max select | `Function`, `Inputs` |
| `simulink/Math Operations/Math Function` | sqrt, exp, log, etc. | `Operator` |
| `simulink/Math Operations/Trigonometric Function` | sin, cos, etc. | `Operator` |

## Continuous

| Library path | Common use | Key parameters |
|---|---|---|
| `simulink/Continuous/Integrator` | continuous integration | `InitialCondition`, `ExternalReset`, `LimitOutput`, `UpperSaturationLimit`, `LowerSaturationLimit` |
| `simulink/Continuous/Derivative` | continuous derivative | `CoefficientsDataTypeStr` |
| `simulink/Continuous/Transfer Fcn` | transfer function | `Numerator`, `Denominator` |
| `simulink/Continuous/State-Space` | state-space model | `A`, `B`, `C`, `D`, `InitialCondition` |
| `simulink/Continuous/PID Controller` | PID control | `P`, `I`, `D`, `N`, `InitialConditionSource`, `AntiWindupMode` |

## Discrete

| Library path | Common use | Key parameters |
|---|---|---|
| `simulink/Discrete/Unit Delay` | one-sample delay | `InitialCondition`, `SampleTime` |
| `simulink/Discrete/Delay` | configurable delay | delay length, initial condition |
| `simulink/Discrete/Discrete-Time Integrator` | discrete integration | `IntegratorMethod`, `SampleTime`, `InitialCondition`, `LimitOutput` |
| `simulink/Discrete/Zero-Order Hold` | sample and hold | `SampleTime` |
| `simulink/Discrete/Discrete Transfer Fcn` | discrete TF | `Numerator`, `Denominator`, `SampleTime` |
| `simulink/Discrete/Discrete Filter` | IIR/FIR filter | `Numerator`, `Denominator`, `SampleTime` |
| `simulink/Discrete/Discrete PID Controller` | discrete PID | `P`, `I`, `D`, `N`, `SampleTime`, `AntiWindupMode` |

## Discontinuities

| Library path | Common use | Key parameters |
|---|---|---|
| `simulink/Discontinuities/Saturation` | clamp | `UpperLimit`, `LowerLimit` |
| `simulink/Discontinuities/Dead Zone` | deadband | `LowerValue`, `UpperValue` |
| `simulink/Discontinuities/Rate Limiter` | slew limit | `RisingSlewLimit`, `FallingSlewLimit` |
| `simulink/Discontinuities/Switch` | conditional switch | `Threshold`, `Criteria` |
| `simulink/Discontinuities/Multiport Switch` | multi-case switch | `Inputs`, `DataPortOrder` |

## Signal Routing

| Library path | Common use | Key parameters |
|---|---|---|
| `simulink/Signal Routing/Mux` | vector combine | `Inputs` |
| `simulink/Signal Routing/Demux` | vector split | `Outputs` |
| `simulink/Signal Routing/Bus Creator` | bus creation | `Inputs` |
| `simulink/Signal Routing/Bus Selector` | bus selection | `OutputSignals` |
| `simulink/Signal Routing/Goto` | local/global goto | `GotoTag`, `TagVisibility` |
| `simulink/Signal Routing/From` | corresponding from | `GotoTag` |
| `simulink/Signal Routing/Manual Switch` | manual path selection | switch state |
| `simulink/Signal Routing/Selector` | element select | `IndexMode`, `Indices`, `InputPortWidth` |

## Signal Attributes

| Library path | Common use | Key parameters |
|---|---|---|
| `simulink/Signal Attributes/Data Type Conversion` | explicit type cast | `OutDataTypeStr`, `ConvertRealWorld` |
| `simulink/Signal Attributes/Signal Conversion` | signal property change | `ConversionOutput` |
| `simulink/Signal Attributes/Rate Transition` | sample rate change | `OutPortSampleTime`, `Integrity`, `Deterministic` |
| `simulink/Signal Attributes/Unit Conversion` | physical unit mapping | `InputUnit`, `OutputUnit` |
| `simulink/Signal Attributes/Data Type Duplicate` | enforce type consistency | - |

## Ports and Subsystems

| Library path | Common use | Key parameters |
|---|---|---|
| `simulink/Ports & Subsystems/Subsystem` | hierarchical grouping | mask, atomic, variant settings |
| `simulink/Ports & Subsystems/Atomic Subsystem` | code-boundary subsystem | `AtomicSubsystem` param = on |
| `simulink/Ports & Subsystems/Enabled Subsystem` | enable-controlled logic | `ZeroCrossAlgorithm` |
| `simulink/Ports & Subsystems/Triggered Subsystem` | trigger-controlled logic | `TriggerType` |
| `simulink/Ports & Subsystems/If` | if action control | condition strings |
| `simulink/Ports & Subsystems/If Action Subsystem` | if branch logic | action port params |
| `simulink/Ports & Subsystems/Switch Case` | switch-case control | case conditions |
| `simulink/Ports & Subsystems/Variant Subsystem` | variant architecture | `VariantControl` |
| `simulink/Ports & Subsystems/Model` | model reference | `ModelName`, `SimulationMode` |

## Logic and Bit Operations

| Library path | Common use | Key parameters |
|---|---|---|
| `simulink/Logic and Bit Operations/Logical Operator` | AND/OR/NOT | `Operator`, `Inputs` |
| `simulink/Logic and Bit Operations/Relational Operator` | compare | `Operator` |
| `simulink/Logic and Bit Operations/Bitwise Operator` | bit manipulation | `Operator` |
| `simulink/Logic and Bit Operations/Compare To Constant` | threshold check | `Operator`, `const` |
| `simulink/Logic and Bit Operations/Compare To Zero` | zero check | `Operator` |

## User-Defined Functions

| Library path | Common use | Key parameters |
|---|---|---|
| `simulink/User-Defined Functions/MATLAB Function` | MATLAB code in model | function code, ports |
| `simulink/User-Defined Functions/Fcn` | expression block | `Expr` |
| `simulink/User-Defined Functions/S-Function` | custom S-function | `FunctionName`, `Parameters` |

## Lookup Tables

| Library path | Common use | Key parameters |
|---|---|---|
| `simulink/Lookup Tables/1-D Lookup Table` | 1-D map | `Table`, `BreakpointsForDimension1`, `InterpMethod`, `ExtrapMethod` |
| `simulink/Lookup Tables/2-D Lookup Table` | 2-D map | `Table`, `BreakpointsForDimension1`, `BreakpointsForDimension2` |
| `simulink/Lookup Tables/n-D Lookup Table` | n-D map | dimensions and breakpoints |

## Model Verification

| Library path | Common use | Key parameters |
|---|---|---|
| `simulink/Model Verification/Assertion` | runtime assertion | `enabled`, `stopSimulation` |
| `simulink/Model Verification/Check Static Range` | range checking | `min`, `max` |
| `simulink/Model Verification/Check Dynamic Range` | dynamic range checking | bounds via input ports |

## Stateflow (requires Stateflow toolbox)

| Block | How to add | Notes |
|---|---|---|
| Stateflow Chart | `sfnew('modelName')` or `add_block('sflib/Chart', ...)` | Use Stateflow API (`sf`) for states and transitions |
| Truth Table | `add_block('sflib/Truth Table', ...)` | Programmatic table via `sf` API |
| State Transition Table | `add_block('sflib/State Transition Table', ...)` | Tabular state machine |

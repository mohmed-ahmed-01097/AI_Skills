# Testing: MIL, SIL, PIL, HIL

## Test levels

| Level | Purpose | Typical evidence |
|---|---|---|
| MIL | verify model behavior before code generation | simulation results, assertions, coverage |
| SIL | verify generated code in host simulation | SIL results, equivalence to MIL |
| PIL | verify generated code on processor/target | PIL results, timing/target evidence |
| HIL | verify integrated software with hardware simulator or rig | HIL procedure, logs, pass/fail report |

## Harness creation workflow

### Using Simulink Test (preferred when available)

```matlab
% Create a test harness for a subsystem.
% Requires Simulink Test R2015b+.
try
    sltest.harness.create('myModel/MySubsystem', ...
        'Name', 'MySubsystem_Harness', ...
        'SaveExternally', true, ...
        'HarnessOwner', 'model');
catch ME
    % API name may differ across releases.
    warning(ME.identifier, '%s', ME.message);
end
```

### Manual harness (when Simulink Test is unavailable)

```matlab
% Create a wrapper model manually.
new_system('MySubsystem_Harness');
load_system('MySubsystem_Harness');
add_block('myModel/MySubsystem', 'MySubsystem_Harness/UUT');
% Add stimulus sources, sinks, and assessment blocks.
save_system('MySubsystem_Harness');
```

## Test case workflow

1. Identify the subsystem or model under test (UUT).
2. Define test signals in a config script or MAT file.
3. Create or open the test harness.
4. Set simulation mode (Normal, Accelerator, SIL, PIL).
5. Create test cases and link to requirements where available.
6. Add baseline, equivalence, or assessment criteria.
7. Run tests and export reports.

## Test Manager API

```matlab
% Check Simulink Test availability.
testAvail = false;
try
    tf = sltest.testmanager.TestFile; %#ok<NASGU>
    testAvail = true;
catch
end

if testAvail
    % Create or load a test file.
    tf = sltest.testmanager.TestFile('myTests.mldatx');
    ts = addTestSuite(tf, 'MIL Suite');
    tc = addTestCase(ts, 'simulation', 'Nominal Test');
    setProperty(tc, 'Model', 'myModel');
    setProperty(tc, 'StopTime', '10');
    saveToFile(tf);
end
```

Use the template helper for a quick start:

```matlab
mbd_test_manager_template('myModel', ...
    fullfile(pwd, '.MBD_agent', 'reports', 'myModel_tests.mldatx'), '10');
```

## Test signal design

Define signals in a config file or MAT file, not inline in the test script.

```matlab
% config_test_signals.m
TEST_NOMINAL_INPUT   = timeseries([0 0 1 1 0], [0 1 2 3 4]);
TEST_BOUNDARY_INPUT  = timeseries([0 0 10 10 0], [0 1 2 3 4]);
TEST_INVALID_INPUT   = timeseries([0 -5 0], [0 1 2]);
```

Signal types to cover:

- nominal operating range
- boundary / saturation cases
- step transitions
- reset / initialization sequences
- out-of-range / fault inputs (if applicable)

## Assessment blocks

In the harness, add:

```matlab
% Verify block (Simulink Test only).
add_block('sltest/Verify', 'myHarness/VerifyOutput', ...
    'Position', [x y x+90 y+40]);

% Or use standard assertion for simpler checks.
add_block('simulink/Model Verification/Assertion', 'myHarness/AssertOutput', ...
    'Position', [x y x+90 y+40]);
```

## Simulation mode for SIL/PIL

```matlab
% Set simulation mode on the harness model.
set_param('myModel', 'SimulationMode', 'software-in-the-loop (sil)');
% For PIL (requires target connection):
set_param('myModel', 'SimulationMode', 'processor-in-the-loop (pil)');
% Reset to Normal.
set_param('myModel', 'SimulationMode', 'normal');
```

## Equivalence testing (MIL vs SIL)

1. Record MIL baseline: run in Normal mode, save outputs.
2. Switch to SIL mode.
3. Compare outputs using tolerance-based assessment in Simulink Test.

## Coverage

```matlab
% Run simulation with coverage collection.
cvsim('myModel');
% Or via test runner:
runCoverage = true; % set in test case properties
```

## Test reports

A test result is incomplete unless it states:

- model/release under test
- test level (MIL, SIL, PIL, HIL)
- configuration set used
- input dataset/signals
- expected vs actual output
- pass/fail result
- unresolved warnings/errors
- coverage percentage (if collected)

Generate a Simulink Test report:

```matlab
tf = sltest.testmanager.load('myTests.mldatx');
sltest.testmanager.run;
sltest.testmanager.exportReport(tf, 'myTests_report.pdf');
```

## Fallback without Simulink Test

Create a Markdown test plan under `.MBD_agent/reports/test_plan.md` with:

- test case table (ID, inputs, expected output, pass criteria)
- manual simulation commands per test case
- instructions for recording outputs to compare

# Simulink apps

Use `mbd_discover_environment` to check which apps are installed before calling their APIs.

## Apps and how to open them from MATLAB

| App | How to open | Key API namespace |
|---|---|---|
| Simulink Test | `sltest.testmanager.show` | `sltest.testmanager.*` |
| Embedded Coder | `coder` (command) | `coder.*`, `slbuild` |
| Simulink Coder | via Model Configuration | `RTW.*`, `slbuild` |
| Simulink Check / Model Advisor | `modeladvisor('modelName')` | `ModelAdvisor.*` |
| Requirements Toolbox | `slreq.editor` | `slreq.*` |
| Stateflow | opens with model | `Stateflow.*`, `sfnew` |
| Fixed-Point Designer | `fixedpointtool('modelName')` | `fi`, `fipref` |
| Simulink Coverage | `cv.cvtest` | `cv.*`, `cvsim` |
| Simulink Design Verifier | `sldvrun('modelName')` | `sldv.*` |
| System Composer | `systemcomposer.openModel` | `systemcomposer.*` |

## Opening an app programmatically

```matlab
% Open Test Manager and load a test file.
sltest.testmanager.show;
tf = sltest.testmanager.load('myTests.mldatx');

% Open Requirements Editor.
slreq.editor;

% Open Model Advisor.
modeladvisor('myModel');

% Open Fixed-Point Tool.
fixedpointtool('myModel');
```

## Checking availability before using an app

```matlab
% Check for Simulink Test before using its APIs.
try
    sltest.testmanager.clear;
    testAvail = true;
catch
    testAvail = false;
end

% Check for Requirements Toolbox.
reqAvail = exist('slreq.ReqSet', 'class') > 0;
```

## App output folders

| App | Typical output location |
|---|---|
| Model Advisor | `slprj/modeladvisor/` |
| Embedded Coder | `<model>_ert_rtw/` |
| Simulink Coder (GRT) | `<model>_grt_rtw/` |
| Coverage | `covhtml/` |
| Simulink Test | `.mldatx` file + `sltest_results/` |
| Requirements | `.slreqx` files |
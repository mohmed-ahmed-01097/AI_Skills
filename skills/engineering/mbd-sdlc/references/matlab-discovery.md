# MATLAB discovery

Use discovery before relying on any toolbox-specific API.

## Minimum discovery command

```matlab
version
ver
license('inuse')
```

## Preferred helper

Copy and run:

```matlab
mbd_discover_environment(fullfile(pwd, '.MBD_agent', 'reports'));
```

The helper writes:

- MATLAB version/release
- installed products from `ver`
- active licenses when available
- installed add-ons when the API exists
- Simulink library discovery sample when Simulink is available

## Project discovery

Look for:

- `*.prj` MATLAB project files
- `*.slx`, `*.mdl`
- `*.sldd`
- `*.slreqx`, `*.req`, `*.xlsx` requirements imports
- `*.mldatx` Simulink Test files
- `*.mat`
- `*.m`, `*.mlx`
- `slprj/`, `*_ert_rtw/`, `*_grt_rtw/`, `codegen/`

## Release-specific behavior

If the release is unknown:

- write R2022b-conscious code
- avoid newer language features
- avoid relying on recently introduced APIs
- generate a discovery script instead of assuming the command exists

## Product adaptation

Do not fail the whole task because a product is missing. Adapt the workflow:

- No Simulink Test: create manual simulation scripts and a test plan Markdown file.
- No Simulink Check: skip Model Advisor automation and document manual checks.
- No Embedded Coder: export configuration and use available Simulink Coder targets.
- No Requirements Toolbox: use Markdown/Excel traceability tables.
- No Stateflow: skip chart-specific introspection.

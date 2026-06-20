# MATLAB discovery

Use discovery before relying on any toolbox-specific API.

## Session check (do this first)

Before running discovery commands, confirm which MATLAB session will actually run them - a new headless process and the user's open MATLAB Desktop are not the same session and will not see each other's variables or loaded models.

- MCP available: confirm the server is configured with `--matlab-session-mode=auto` so it attaches to a shared session automatically. See `matlab-mcp-integration.md`.
- No MCP, Python engine installed: run `matlab_shared_engine_eval.py --list` to check for a shared session before falling back to a new process.
- Neither available: any discovery command via `matlab -batch`/`matlab -r` runs in a brand-new process, not the user's open Desktop. Say so before running it.

See `mbd-operating-modes.md` for the full session-check procedure.

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
- installed Simulink apps (Simulink Test, Embedded Coder, Stateflow, etc.)

Note that this helper reports the environment of whichever MATLAB session executes it - it does not tell you whether that session is new or reused. Settle the session check above first.

## Full catalog: environment + block library in one file

When the task needs to know what blocks/parameters actually exist (not just MATLAB version and products), generate the combined catalog instead of guessing block names from memory:

```matlab
mbd_export_full_catalog();
```

This writes one file, `.MBD_agent/reports/matlab_simulink_full_catalog.md`, combining the environment report above with a Simulink block library catalog (block paths, types, mask types, and dialog parameter names) read directly from the installed MATLAB. It is not a hand-written list - see `common-simulink-blocks.md` for why that distinction matters.

Defaults are deliberately lean: `searchDepth=4`, library root `{'simulink'}` only, and parameter *names* only (no values, since fetching every default value for every block is slow and produces a much larger file for marginal benefit - the AI can fetch a specific block's current value on demand with `get_param` when it actually needs it).

Use the optional arguments when the task needs more:

```matlab
% Include default parameter values too (slower, larger file).
mbd_export_full_catalog(fullfile(pwd, '.MBD_agent', 'reports'), 4, true);

% Also catalog the Stateflow block library, once you've confirmed it's installed
% (check the Simulink apps table in the environment report first).
mbd_export_full_catalog(fullfile(pwd, '.MBD_agent', 'reports'), 4, false, {'simulink', 'sflib'});
```

**Caching**: the catalog reflects the installed release and licensed toolboxes, not the current project, so it does not need regenerating per task. If the merged file already exists, `mbd_export_full_catalog` skips regeneration by default and tells you so. Force a rebuild only after installing/removing a toolbox or upgrading MATLAB:

```matlab
mbd_export_full_catalog(fullfile(pwd, '.MBD_agent', 'reports'), 4, false, {'simulink'}, true);
```

If you only need version/products/apps without the block catalog, use `mbd_discover_environment` alone - it's faster.

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

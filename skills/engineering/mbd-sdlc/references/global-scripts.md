# Global scripts (review, build, validate)

## What are global scripts

Global scripts are project-level automation scripts that apply to the whole project rather than a single implementation step. They are not AI artifacts - they belong to the project and should be version-controlled.

Typical set:

| Script | Purpose |
|---|---|
| `project_startup.m` | Load project, set paths, load config |
| `project_shutdown.m` | Close models, clear workspace |
| `build_all.m` | Build all models in dependency order |
| `run_all_tests.m` | Run MIL/SIL/PIL suites and write reports |
| `validate_all.m` | Run Model Advisor checks across all models |
| `check_codegen.m` | Verify code generation config before build |

## Where to store global scripts

**Ask the user once at project start.**

Two common choices:

| Location | When to use |
|---|---|
| `.MBD_agent/scripts/` | AI-managed scripts, not shared with team |
| `tools/mbd/` | Project-owned, version-controlled, shared |

For single-file or small edits, skip global scripts entirely.

## Recommended global script structure

```text
tools/
  mbd/
    project_startup.m
    project_shutdown.m
    build_all.m
    run_all_tests.m
    validate_all.m
    config/
      config_layout.m
      config_codegen.m
      config_solver.m
      config_test_signals.m
      config_data_types.m
```

## Example: project_startup.m

```matlab
% project_startup.m - runs when the MATLAB project opens.
run(fullfile(pwd, 'tools', 'mbd', 'config', 'config_solver.m'));
run(fullfile(pwd, 'tools', 'mbd', 'config', 'config_data_types.m'));
disp('Project ready.');
```

## Example: build_all.m

```matlab
% build_all.m - build all models in dependency order.
models = {'TopLevelModel', 'SubsystemModel'};
for i = 1:numel(models)
    fprintf('Building %s...\n', models{i});
    load_system(models{i});
    slbuild(models{i});
    fprintf('Done: %s\n', models{i});
end
```

## Example: validate_all.m

```matlab
% validate_all.m - run Model Advisor on all models.
models = {'TopLevelModel', 'SubsystemModel'};
outDir = fullfile(pwd, '.MBD_agent', 'reports');
for i = 1:numel(models)
    mbd_run_model_advisor(models{i}, outDir);
end
```

## Config file conventions

- Use named constants, not bare numbers.
- Group related settings (solver, layout, codegen, test signals, data types).
- Each config file should be `run()`-safe (idempotent, no side effects).
- Keep each file short - one topic per file.

## When the AI creates these scripts

1. AI drafts the script in `.MBD_agent/scripts/` first.
2. After review and approval, AI moves or copies to the project-owned location.
3. User decides the final home.
4. Script is added to the MATLAB project and optionally as a shortcut.
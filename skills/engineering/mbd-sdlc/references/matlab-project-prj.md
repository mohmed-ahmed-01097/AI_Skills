# MATLAB project (.prj)

Use a `.prj` file for all multi-file MBD projects. It manages paths, labels, shortcuts, startup/shutdown scripts, and source control integration.

## When to use

- Any project with more than one model or a V-Model folder structure.
- When reproducible path setup is needed (replace `addpath` clutter).
- When sharing the project across team members or CI.
- Single-file edits: skip the project unless the model already belongs to one.

## Create or open

```matlab
% Use the helper (discovers existing .prj first).
mbd_project_init(pwd, 'MyProject');

% Create directly.
prj = matlab.project.createProject('Name', 'MyProject', 'Folder', pwd);

% Open existing.
matlab.project.loadProject('MyProject.prj');

% Open from Current Folder panel (UI): double-click the .prj file.
```

## Add files and folders

```matlab
prj = currentProject;

% Add a folder with all its contents.
addFolderIncludingChildFiles(prj, '04_implementation');

% Add a single file.
addFile(prj, fullfile('tools', 'mbd', 'project_startup.m'));
```

## Labels (file classification)

Use labels to mark design, test, and generated files so they can be filtered.

```matlab
% Create a label category.
addLabel(prj, 'Classification', 'Design');
addLabel(prj, 'Classification', 'Test');
addLabel(prj, 'Classification', 'Generated');

% Apply label to a file.
f = findFile(prj, 'Name', 'myModel.slx');
addLabel(f, 'Classification', 'Design');
```

## Shortcuts

```matlab
% Add a shortcut to a startup script.
addShortcut(prj, 'Label', 'Build All', 'File', fullfile('tools', 'mbd', 'build_all.m'));

% Add a shortcut to run all tests.
addShortcut(prj, 'Label', 'Run Tests', 'File', fullfile('tools', 'mbd', 'run_all_tests.m'));
```

## Startup and shutdown scripts

In the project Settings dialog (or via API), point to:

- `tools/mbd/project_startup.m` – adds project paths, loads config.
- `tools/mbd/project_shutdown.m` – closes open models, clears workspace.

```matlab
% Set startup file via API.
prj = currentProject;
prj.StartupFile = fullfile(pwd, 'tools', 'mbd', 'project_startup.m');
prj.ShutdownFile = fullfile(pwd, 'tools', 'mbd', 'project_shutdown.m');
```

## Useful discovery commands

```matlab
% Is a project currently loaded?
try, prj = currentProject; catch, prj = []; end

% List all files in the project.
files = prj.Files;

% Find a specific file.
f = findFile(prj, 'Name', 'myModel.slx');

% List labels.
prj.Labels
```

## Source control integration

When the project is under Git:

- Keep `.prj` in source control.
- Add `slprj/`, `*_ert_rtw/`, `.MBD_agent/`, and `*.asv` to `.gitignore`.
- Use `prj.SourceControlMessages` to check for conflicts before editing.

## File types tracked in a project

| Extension | Content |
|---|---|
| `.slx` | Simulink model |
| `.mdl` | Legacy Simulink model |
| `.sldd` | Simulink data dictionary |
| `.slreqx` | Requirements Toolbox requirement set |
| `.mldatx` | Simulink Test file |
| `.mat` | MATLAB data file |
| `.m` / `.mlx` | Script or live script |
| `.prj` | MATLAB project |
| `.slxc` | Simulink cache (exclude from source control) |
| `*.h`, `*.c` | Generated code (exclude from source control) |
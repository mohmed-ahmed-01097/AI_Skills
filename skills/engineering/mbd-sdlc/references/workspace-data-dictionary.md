# Workspace, data dictionary, and MAT files

## Base workspace

Inspect variables:

```matlab
evalin('base', 'whos')
```

Read a variable only when needed:

```matlab
value = evalin('base', 'varName');
```

Write variables through an explicit setup script, not ad hoc console commands.

## Model workspace

```matlab
load_system('modelName');
mws = get_param('modelName', 'ModelWorkspace');
mws.whos
assignin(mws, 'Kp', 1.2)
```

Use model workspace for model-scoped parameters when the project style already does so.

## Data dictionary

Discover dictionary from model:

```matlab
dd = get_param('modelName', 'DataDictionary');
```

Open and inspect:

```matlab
dictObj = Simulink.data.dictionary.open(dd);
sect = getSection(dictObj, 'Design Data');
entries = find(sect);
```

When editing dictionaries:

- make a backup or use source control first
- edit through a script
- save changes explicitly
- export a before/after report

## MAT files

Inspect before loading large data:

```matlab
whos('-file', 'file.mat')
```

Load selected variables:

```matlab
s = load('file.mat', 'signalName');
```

Avoid overwriting MAT files unless the user approved data changes.

## Export helper

Use:

```matlab
mbd_export_workspace_state('modelName', fullfile(pwd, '.MBD_agent', 'workspace'));
mbd_export_data_dictionary('design.sldd', fullfile(pwd, '.MBD_agent', 'workspace'));
```

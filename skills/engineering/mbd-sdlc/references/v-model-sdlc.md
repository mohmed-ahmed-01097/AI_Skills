# V-Model SDLC structure

Ask once at project start whether the V-Model structure is needed. Use it for new safety/embedded projects, not for simple model edits.

## Default folder structure

```text
01_requirements/
02_system_design_hld/
03_software_design_lld/
04_implementation/
05_mil_tests/
06_sil_tests/
07_pil_tests/
08_hil_tests/
09_codegen/
10_release/
tools/
  mbd/
    config/
    project_startup.m
    project_shutdown.m
```

## Folder intent

| Folder | Contents |
|---|---|
| `01_requirements/` | requirement sets, traceability tables, imported `.slreqx` or Excel |
| `02_system_design_hld/` | architecture diagrams, interfaces, allocation tables |
| `03_software_design_lld/` | algorithm designs, data type tables, state machine specs |
| `04_implementation/` | Simulink models (`.slx`), data dictionaries (`.sldd`), libraries |
| `05_mil_tests/` | MIL harnesses, test files (`.mldatx`), test signals, MIL reports |
| `06_sil_tests/` | SIL-mode test files, SIL reports, equivalence results |
| `07_pil_tests/` | PIL target configs, test files, timing evidence |
| `08_hil_tests/` | HIL procedures, test plans, HIL logs |
| `09_codegen/` | codegen config reports, build logs, packaging scripts |
| `10_release/` | release notes, signed reports, baselines, version labels |
| `tools/mbd/` | global project scripts (build, validate, test), config files |

## Keep it simple

Do not create deep sub-trees in each phase folder until needed. Start with one README per phase and a clear file naming convention. Expand only when a folder accumulates more than 5-8 files.

## MATLAB project (.prj)

Use a `.prj` MATLAB project file for path management, shortcuts, and project startup.

```matlab
% Initialize project with V-Model structure.
mbd_project_init(pwd, 'MyProject');
```

See `references/matlab-project-prj.md` for details.

Add shortcuts in the project for the most-used global scripts:

```matlab
prj = currentProject;
addShortcut(prj, 'Label', 'Build All',   'File', 'tools/mbd/build_all.m');
addShortcut(prj, 'Label', 'Run Tests',   'File', 'tools/mbd/run_all_tests.m');
addShortcut(prj, 'Label', 'Validate All','File', 'tools/mbd/validate_all.m');
```

## Questions to ask at project start (ask once, not on every task)

- Project name and MATLAB release.
- Code generation target (ERT/GRT/AUTOSAR).
- Is V-Model structure needed? (If not, use a flat or custom layout.)
- Where should global scripts live: `.MBD_agent/scripts/` (AI-only) or `tools/mbd/` (project-owned)?
- Will a data dictionary be used?
- Model naming convention.
- Is there an existing `.prj` to open or should one be created?

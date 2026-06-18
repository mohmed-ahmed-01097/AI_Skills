# Implementation workflow

## Creating a new model or subsystem

1. Define inputs, outputs, sample times, data types, and calibration parameters.
2. Decide whether a data dictionary is required.
3. Create a layout preset file instead of hard-coding positions throughout the script.
4. Add blocks with `add_place` and verified library paths.
5. Set parameters with `mbd_set_param_strict`.
6. Connect lines with clear left-to-right routing.
7. Add title/subtitle annotations.
8. Apply fit-to-view.
9. Save the model.
10. Export architecture and run review.

## Editing an existing model

1. Export architecture first.
2. Locate exact subsystem/block paths.
3. Inspect block parameters before changing them.
4. Prepare an edit script.
5. Ask for approval and list the changes.
6. Run the edit script.
7. Re-export architecture.
8. Compare before/after.
9. Run simulation/test/checks.

## Style rules

- Use existing naming/style unless user asks for a new style.
- Do not introduce a new data ownership pattern without approval.
- Do not silently replace library-linked blocks.
- Keep generated scripts readable and concise.
- Use comments only where they explain intent, assumptions, or non-obvious API use.

## Configuration files

Avoid magic numbers by using files like:

```text
config_layout.m
config_codegen.m
config_solver.m
config_test_signals.m
config_data_types.m
```

Use the smallest set required for the task.

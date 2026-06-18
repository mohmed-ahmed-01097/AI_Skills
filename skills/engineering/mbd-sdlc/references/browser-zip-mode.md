# Browser zip mode

Use this when the AI cannot run MATLAB commands directly.

## Exchange loop

1. User uploads project zip.
2. AI edits or creates files outside project source when possible:
   - `.MBD_agent/scripts/*.m`
   - `.MBD_agent/README_RUN_ME.md`
   - `.MBD_agent/rules.md`
   - `.MBD_agent/constitution.md`
3. AI returns updated zip or individual scripts.
4. User runs the command printed in `README_RUN_ME.md`.
5. User uploads `.MBD_agent/reports` or the updated project zip.
6. AI continues from the results.

## Command file

Each browser-mode package should include a minimal run instruction like:

```matlab
run(fullfile('.MBD_agent', 'scripts', 'mbd_browser_task.m'))
```

## Constraints

- Do not claim the model was changed successfully until the user returns logs or the changed project.
- Do not make risky edits in source files without a rollback path.
- Keep generated instructions simple enough for a user to execute from MATLAB Current Folder.

## Return package checklist

Before returning a zip:

- scripts have clear headers
- paths are relative where practical
- scripts create required output folders
- scripts do not overwrite source artifacts without approval
- scripts write logs/reports
- README contains exactly what the user should run and upload back

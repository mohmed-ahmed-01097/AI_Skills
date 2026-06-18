# Agent repository rules

Skills are organized under `skills/`.

- `skills/engineering/` contains engineering workflow skills.
- Every promoted skill must be listed in the top-level `README.md` and `.claude-plugin/plugin.json`.
- Each skill must have a `SKILL.md`.
- Keep skill control files concise. Move detailed workflow material into `references/`.
- Keep executable/reusable assets in `assets/` unless they are repo maintenance scripts.
- Do not place user project outputs, MATLAB generated code, or `.MBD_agent` folders in this repo.

For this repo, `mbd-sdlc` is the primary engineering skill.

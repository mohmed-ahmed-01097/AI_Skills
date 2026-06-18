# Final review checklist

Run this before ending the response.

## Change review

- List changed files and generated files.
- Confirm project source changes are intentional.
- Confirm no chat transcript or vague planning artifact was placed in project source.
- Confirm `.MBD_agent` contains only useful scripts, reports, and evidence.

## MATLAB/Simulink review

- MATLAB release and installed products were discovered or clearly stated as unknown.
- Model/subsystem architecture was exported before material edits.
- Workspace/model workspace/data dictionary state was exported when relevant.
- Block library paths were verified.
- Parameters were set using inspected names.
- Lines are readable and avoid avoidable overlap.
- Titles/subtitles and fit-to-view were applied for generated diagrams where useful.

## SDLC review

- Requirements/HLD/LLD outputs are traceable where requested.
- V-Model folders were used only if appropriate or requested.
- Test level is explicit: MIL, SIL, PIL, HIL, or manual fallback.
- Code generation target is explicit when codegen is in scope.
- MAAB/MAB, MISRA-ready, project rules, and optional ISO 26262 checks were handled honestly.

## Evidence review

Separate final status into:

- Verified
- Partially verified
- Not verified because MATLAB/toolbox/user execution was unavailable
- Recommended next command

## Response hygiene

Do not end with a vague promise. Provide the result, the evidence, and the next concrete action if one exists.

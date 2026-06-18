# Requirements, HLD, and LLD

## Requirements

Outputs may include:

- requirement set or Markdown requirement table
- requirement IDs
- acceptance criteria
- verification method per requirement
- trace links to model elements, tests, and generated code artifacts

Minimum requirement fields:

| Field | Meaning |
|---|---|
| ID | stable identifier |
| Text | shall/should statement |
| Rationale | why the requirement exists |
| Type | functional, interface, safety, performance, diagnostic, etc. |
| Source | user, standard, upstream doc |
| Verification | analysis, inspection, MIL, SIL, PIL, HIL |
| Status | draft, reviewed, approved, changed |

## HLD

High-level design should define:

- model boundaries
- major subsystems
- input/output interfaces
- data dictionary strategy
- sample-time architecture
- variant strategy
- fault/safety concept if relevant
- code generation target assumptions

## LLD

Low-level design should define:

- detailed algorithms
- block-level architecture
- states and transitions
- data types and units
- saturation/range behavior
- calibration parameters
- lookup tables
- reset/initialization behavior
- diagnostics and assertions
- test points and coverage targets

## Traceability

For mature projects, maintain links:

```text
Requirement -> HLD element -> LLD element -> Model block/subsystem -> Test case -> Codegen/report evidence
```

When Requirements Toolbox is unavailable, use Markdown or CSV trace matrices under `.MBD_agent/reports/` or the approved project docs folder.

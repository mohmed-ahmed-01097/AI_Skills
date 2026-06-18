# Model Advisor and standards checks

## Default standards focus

Use MAAB/MAB-style modeling checks, MISRA-ready code generation checks, project rules in `.MBD_agent/rules.md`, and optional ISO 26262-oriented evidence.

## Product discovery

Before running automation:

```matlab
ver
which ModelAdvisor.run
```

If Model Advisor APIs are unavailable, create a manual review checklist and do not pretend checks were run.

## Helper

```matlab
mbd_run_model_advisor('modelName', fullfile(pwd, '.MBD_agent', 'reports'));
```

The helper attempts a conservative Model Advisor run and writes evidence/logs. API behavior varies by release and installed products; inspect errors and adapt.

## Review categories

- model configuration and solver
- sample times
- signal attributes and data types
- naming conventions
- library links
- masks and callbacks
- variant controls
- algebraic loops
- unconnected lines/ports
- unreachable or dead logic
- code generation readiness
- testability and observability
- requirements/test traceability

## User/project rules

Always merge standards with `.MBD_agent/rules.md`. If user rules conflict with generic rules, ask for decision or follow project rules when they are clearly authoritative.

## Reporting

Final review must distinguish:

- passed checks
- failed checks
- warnings accepted by user/project rules
- checks skipped because a product/API was missing
- checks not attempted

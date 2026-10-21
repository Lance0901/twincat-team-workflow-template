# Repository Instructions

## Repository purpose

This Repository maintains the reusable TwinCAT team workflow template under `template/`.
It is not a TwinCAT machine project and must not be used as a Runtime Target.

## Required reading

Before changing this Repository, read:

1. `README.md`
2. `CHANGELOG.md`
3. `template/AGENTS.md`
4. `template/docs/architecture/team-workflow.md`
5. `template/.harness/config.json`

## Change rules

- Treat `template/` as the source of truth installed into TwinCAT repositories.
- Keep all paths portable. Do not hardcode a developer machine path or AmsNetId.
- Do not add GitHub Actions unless a human explicitly changes the project decision.
- Preserve the rule that GitHub PR review requests trigger the integrator workflow.
- Preserve the rule that Orca Review is bound to an exact Commit SHA.
- Do not weaken Runtime approval requirements.
- Update `README.md` when installation or operating behavior changes.
- Update `CHANGELOG.md` and `VERSION` for a released template change.

## Required validation

Run both commands before reporting completion:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\Test-Template.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File .\template\tools\Setup-Project.ps1
```

These checks are static. They must not open TwinCAT XAE, build a PLC project, activate a configuration, log in, use ADS, or change PLC state.


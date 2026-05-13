# Review-Driven Regression Loop

Use this when an implementation is already GREEN but a critical review finds a remaining defect.

## Pattern

1. Translate each review finding into a failing regression test before touching production code.
2. Prefer the smallest focused test that proves the exact bad behavior:
   - migration/config transforms: malformed legacy input, normalization/dedupe, invalid type/value, and “fail before producing migrated output” cases;
   - CLI fallback flows: ensure validation happens before the first write;
   - runtime flag handling: non-canonical user input such as surrounding spaces;
   - destructive commands: inherited references and indirect references, not only direct references.
3. Run the targeted test and verify RED for the expected reason.
4. Implement the minimal fix.
5. Run targeted tests, package checks, full build/format checks if the repo uses them, and whitespace checks (`git diff --check`, `git diff --cached --check`).
6. Re-stage only the intended files, then inspect `git status --short` and a diff stat.

## Durable pitfalls

- Do not silently ignore invalid legacy values in migration code just because schema validation will fail later; if the migration runner writes before later validation, ignoring invalid values can turn an invalid old config into a partially migrated invalid new config.
- Preserve domain-specific errors (`DotweaveError`-style code/hint/details) thrown by migration steps when they are actionable user input errors. Wrapping every migration exception in a generic migration failure can erase the fix instructions the user needs.
- Security scans may flag test fixtures such as `token = secret`; classify them explicitly as fixtures rather than treating them as real leaked credentials.

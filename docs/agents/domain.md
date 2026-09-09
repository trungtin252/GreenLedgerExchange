# Domain Docs

This repository uses a single-context domain documentation layout.

## Before exploring, read these

- Read `CONTEXT.md` at the repository root when it exists.
- Read ADRs under `docs/adr/` that affect the area being changed when they exist.

If either location does not exist, proceed silently. The `domain-modeling` skill creates these artifacts lazily when terminology or architectural decisions are resolved.

## File structure

```text
/
|-- CONTEXT.md
|-- docs/
|   |-- adr/
|   `-- agents/
`-- services/
```

## Use the glossary vocabulary

When output names a domain concept in an issue, proposal, hypothesis, or test, use the term defined in `CONTEXT.md`. Avoid synonyms that the glossary explicitly rejects.

If a needed concept is absent, first check whether the repository already uses another term. Record a genuine terminology gap for the `domain-modeling` workflow.

## Flag ADR conflicts

Surface any conflict with an existing ADR explicitly instead of silently overriding the decision. Name the ADR, explain the conflict, and state why reopening it may be warranted.

# ADR 0006: Contract-first generated clients

Public interfaces begin as versioned OpenAPI and AsyncAPI contracts. The web
portal consumes a committed, generated TypeScript client, and CI rejects
unreviewed contract or generated-client drift.

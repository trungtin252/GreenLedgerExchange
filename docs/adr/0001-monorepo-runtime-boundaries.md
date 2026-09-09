# ADR 0001: Monorepo and runtime boundaries

GLX keeps the gateway BFF, registry MRV service, exchange service, AI worker,
web portal, and machine-readable contracts in one repository. Each runtime is
independently deployable and owns its code and persistence boundary; no shared
domain-entity module is introduced.

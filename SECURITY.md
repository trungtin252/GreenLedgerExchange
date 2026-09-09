# Security policy

GreenLedger Exchange is a portfolio sandbox. Do not submit real personal data,
payment credentials, carbon-credit records, private keys, or production
provider credentials to this repository.

## Reporting a vulnerability

Please report suspected vulnerabilities privately to the repository owner. Do
not open a public issue until a maintainer confirms that disclosure is safe.

## Local-development rules

- Keep secrets in a local `.env` file; it is intentionally ignored by Git.
- Use only synthetic identities, organizations, and credentials supplied for the
  local Keycloak realm.
- Treat `GLX-DEMO` and `VND-DEMO` as fictional sandbox values, not financial or
  environmental instruments.

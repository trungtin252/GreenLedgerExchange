# GreenLedger Exchange

GreenLedger Exchange (GLX) is a portfolio sandbox for exploring a
contract-first carbon-market platform. `GLX-DEMO` and `VND-DEMO` are fictional
demo designations only; this repository is not an exchange, payment system, or
official carbon-credit registry.

## Architecture snapshot

The monorepo contains a browser-facing gateway BFF, separate Registry MRV and
Exchange Spring services, a Vue portal, a FastAPI verification worker, and
versioned API/event contracts. PostgreSQL is authoritative and each Java
runtime owns a separate database. This day-zero baseline deliberately contains
no carbon-project, order, payment, ledger-posting, retirement, or blockchain
business workflow.

## Prerequisites

| Tool | Required version |
| --- | --- |
| JDK | 21 (validated with 21.0.11) |
| Maven | 3.9.7 or later in the 3.9 line |
| Node.js | 22.12.0 |
| pnpm | 10.28.2, downloaded project-locally by the facade |
| Python | 3.11 (validated with 3.11.5) |
| uv | project-local executable in `.tools/uv` |
| Docker Desktop | Compose V2, running locally |

## First local run

After installing Docker Desktop and project-local `uv`, a first local setup
should take under ten minutes. pnpm needs no global installation: the facade
downloads its locked version into `.tools/npm-cache` on first use.

Install `uv` from the repository root without changing your user profile or
`PATH`:

```powershell
$env:UV_UNMANAGED_INSTALL = "$PWD\.tools\uv"
irm https://astral.sh/uv/install.ps1 | iex
Remove-Item Env:UV_UNMANAGED_INSTALL
& .\.tools\uv\uv.exe --version
```

Docker Desktop is the only system-level prerequisite: it supplies the Docker
daemon and WSL 2 integration, so it cannot live inside this repository. From
an elevated PowerShell terminal, install it with:

```powershell
winget install --id Docker.DockerDesktop -e --accept-package-agreements --accept-source-agreements
```

Then launch Docker Desktop once, accept its terms, complete its WSL 2 setup if
prompted, and wait until its engine reports as running.

Run one of the equivalent facades:

```powershell
./scripts/bootstrap.ps1
./scripts/dev.ps1 up
```

```bash
./scripts/bootstrap.sh
./scripts/dev.sh up
```

`bootstrap` copies `.env.example` when needed and stops with a concrete list of
local values to fill. Use only synthetic local credentials. The local ports are:

| Runtime | Port |
| --- | ---: |
| Web portal | 5173 |
| Gateway BFF | 8080 |
| Registry MRV | 8081 |
| Exchange | 8082 |
| AI verification | 8090 |
| PostgreSQL | 5432 |
| Redis | 6379 |
| MinIO API / console | 9000 / 9001 |
| Keycloak | 8180 |

The imported local realm contains the synthetic `demo.user` account. Its
temporary password is `glx-local-demo`; it is for this local sandbox only and
must never be reused outside the repository.

## Commands

```text
scripts/bootstrap        Check prerequisites, configure local files, install locked dependencies, pull images, quick verify
scripts/dev up|down|status|logs
scripts/verify --quick|--full
scripts/seed             Idempotently seed synthetic organizations only
```

Full verification requires Docker and executes Testcontainers, Compose health,
browser tests, SBOM, and security scans. It never pushes images, deploys to a
cloud provider, changes branch protection, or changes global Git configuration.

Maintainers must enable GitHub branch protection manually. Require the
`required summary` and `CodeQL` checks, which cover contracts, backend,
frontend, AI, security, Compose smoke, browser accessibility, and the
PowerShell facade check. This bootstrap intentionally does not alter branch
protection itself.

# AGENTS.md

Instructions for AI coding agents, and a short version for anyone working here. [CONTRIBUTING.md](CONTRIBUTING.md) is the full process.

## What this repository is

hello-galaxy-human-machine-onboarding walks through how goat onboards a person, a machine, and a platform made of several workloads. Each scenario is a runbook and one script that narrates the `goat` CLI step by step. With `--offline`, or when `goat` is not on `PATH`, every command is shown and none is run.

It is one of the Hello Galaxy demonstrations: small, runnable examples, each showing one part of [goat](https://github.com/USAREUR-AF/goatcore). It holds no goat source code.

## Layout

| Path | What |
|---|---|
| `scenarios/` | one directory per scenario: `README.md` and `run.sh` |
| `bin/hg-onboard` | the runner |
| `lib/onboarding.sh` | shared shell functions |
| `report/`, `docs/` | the HTML report and background |

## Before you push

CI (`.github/workflows/ci.yml`) runs these; neither needs a goatnet:

```bash
shellcheck -e SC1090,SC1091,SC2086,SC2046,SC2034,SC2164 lib/onboarding.sh bin/hg-onboard scenarios/*/run.sh
NO_COLOR=1 bin/hg-onboard all --offline
```

Every directory under `scenarios/` holds a `README.md` and an executable `run.sh`; CI checks both. `--for-real` runs the write steps against a goatnet and mints real identities; do not use it in a check.

## Rules

1. **Nothing from a real deployment.** No hostname, domain, address, key or person of a real goatnet goes into a file or a commit message. Use made-up names, documentation addresses (RFC 5737) and `example.org` mail.
2. **Commits.** Conventional Commits subject of 100 characters or fewer, with a scope (`fix(<component>): …`). Every commit is signed off (`git commit -s`, the DCO) and signed with a key GitHub verifies. The organization's required check `verified-commits` refuses a pull request that holds an unverified commit.
3. **One logical change per pull request.**
4. **Vulnerabilities** go through [SECURITY.md](SECURITY.md), never a public issue.

The contribution guide for goat as a whole is [goatcore CONTRIBUTING.md](https://github.com/USAREUR-AF/goatcore/blob/main/CONTRIBUTING.md).

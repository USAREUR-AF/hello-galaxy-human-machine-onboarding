# Honesty matrix — live vs represented

The most important doc in the repo. Onboarding **mints real identities on a real
fabric**, and it needs components a laptop can't stand in for (a portal, a sponsor,
an admin, a SPIRE server). So every claim the scenarios make is graded, and the
scenarios never fake the ungraded parts — a WRITE step is *shown* by default and
only *executed* with `--for-real` against a real operator profile. With
`--offline` (automatic when `goat` is not on `PATH`) nothing runs at all: every
command is shown and marked `[needs-goatnet]`. Every **live** grade below means
"live on a goatnet".

| Element | What the demo does | Grade |
|---|---|---|
| **The commands themselves** (`goat admin onboard`, `goat machine enroll`, `goat machine ls`, `goat access who`, `goat who`) | the real `goat` CLI verbs, exactly as an operator runs them | **live** (shown; run with `--for-real` / read steps run outright) |
| **Machine enrollment** (own slot + cert + custody edge + quota) | with `--for-real` + an operator profile, mints a real machine on the target goatnet | **live** |
| **The mesh leg** (class-derived NetBird groups + a one-off single-use setup key) | the portal derives the groups from the node-class and mints the key; hand-picking `auto_groups` for gear is not a sanctioned path anywhere, and an hourly audit reports any peer that got in that way | **live** (needs goat-cli ≥ 0.4.39 — older releases silently DROP the returned key) |
| **The mint is the ONLY door** (gear with no custody edge is reported) | not a demo step — a scheduled audit on each goatnet's mgmt host joins live NetBird membership to the machine registry hourly and grades every gear-class peer `aligned` / `pending-reconcile` / `violation` / `unknown`. Hand-picking `auto_groups` for gear is now *caught*, not merely *unsanctioned* | **live** — per goatnet, the audit either reports a violation or fails its unit on one |
| **The refusal grammar** (`SENSOR`/`EFFECTOR` reserved, intake-only classes, bare `PLATFORM`, `PROCESSOR`) | a real refused enroll is really refused, and the message names the class to use instead; quota is not consumed | **live** |
| **Machine revoke** (scenario 05: peer + unconsumed key cut, THEN the slot freed) | with `--for-real`, really retires a machine; the peer-delete leg is covered by the portal test suite against a fake mgmt server | **live** |
| **The custody read-back** (scenario 04) | `goat machine ls` / `access who` / `who` run read-only against the goatnet's portal | **live** |
| **The quota model** (fail-closed ceiling; returns on revoke) | enforced server-side; a real over-quota enroll is really refused | **live** |
| **PLATFORM composition recorded** (`--workloads`) | the declaration is really stored on the machine | **live** |
| **The three-stage human flow** (invite → submit → vouch → approve → mint) | shown as the real command each of the two gates + the runner executes | **needs-operator** (needs the portal + a sponsor + an admin; the stages are real, the demo doesn't impersonate three actors) |
| **SPIRE workload-SVID registration** from the PLATFORM declaration | the generator (`gen-platform-spire-entries.py`) is live; the actual `spire-server entry create` is a deploy-side step | **represented** (each workload's runtime selector only exists once its containers are deployed) |
| **The `.cbor` bundle a person carries** | described, not produced here (it's minted by the portal certmint) | **represented** |

Read this before you believe any screen. Where a thing is live, `--for-real`
proves it; where it's represented, the scenario says so and shows the real command
you'd run in the place it belongs.

# hello-galaxy-human-machine-onboarding

**A hands-on demonstration of how the goat data fabric onboards *both* people and
machines — a person, then a machine, then a platform that decomposes into
workloads — that you can walk through in a few minutes.**

This repo is a *series of small, self-contained scenarios*. Each is a short,
cold-readable runbook plus a single script that narrates the real `goat`
command-line tool step by step. You do not need to understand the fabric's
internals to follow along.

The whole point: **show, don't tell** — and never fake. Three modes:

| Mode | Needs | What runs |
|---|---|---|
| `--offline` (automatic when `goat` is not on `PATH`) | bash | nothing; every command is shown with what it does |
| default | the `goat` CLI and a goatnet context | read steps run against the goatnet; write steps are shown |
| `--for-real` | an operator profile on that goatnet | write steps run too, minting real identities |

The goatnet can be any appropriate goatnet you have access to:
EFDI, the shared sandbox goatnet that partners are onboarded to (if you are onboarded to it); <!-- oss-allow: operator-approved public example goatnet -->
a goatlite you stand up yourself on a single box (goatcore's
[`docs/tutorials/00-goatlite.md`](https://github.com/usareur-af/goatcore/blob/main/docs/tutorials/00-goatlite.md));
or another goatnet you have access to. `--for-real` mints identities, so it needs an
operator profile from that goatnet's operators. Every claim is graded in [the honesty matrix](docs/honesty-matrix.md).

---

## The one idea

**Everything on the fabric is a principal under a unit.** A human operator, a
headless sensor, a UAS — each is an identity minted across the planes it needs,
stamped with the same five-dimension grammar (role · affiliation · echelon ·
node-class · site), and traceable to whoever brought it online. Humans and
machines run **sibling** ceremonies — same grammar, same registry, *different
gates* — not two disconnected systems.

| | Person | Machine |
|---|---|---|
| Who triggers | a sponsor invites a stranger | a custodian enrolls their own asset |
| Human gates | **two** — sponsor vouch + admin approve | **zero** — the quota is the pre-authorization |
| Identity planes | NetBird + Zenoh + **Ory** + a `.cbor` bundle | NetBird + Zenoh only |
| Provenance | `invited_by` sponsor | `enrolled_by` custody edge |

The asymmetry is the point: a person is a *stranger to prove*; a machine is
*already-vouched-for property* of a vetted person, and that person's quota is the
proof.

A corollary worth saying out loud, because it is often gotten backwards: **a Zenoh
publisher is a cert Common Name, not a person.** Machines and workloads hold their
**own** publisher identity — the fabric admits by CN and never asks whether the
holder is human. If you've heard "publishers can only be people and their keys,"
read [who can be a publisher](docs/who-can-be-a-publisher.md) — it names that
misconception and corrects it.

## How to follow this

This is a **walkthrough you read**, not just scripts you run. Two ways in:

- **Read the visual walkthrough** — open [`report/report.html`](report/report.html)
  in a browser. Sequenced, diagrammed, top-to-bottom: the two ceremonies, the
  machine mint, the platform decomposition, the philosophy, the honesty grading.
  Start here if you want to *understand* onboarding.
- **Walk the scenarios** — each is a **recipe**: a README that frames the problem,
  walks *what you'll see* step by step, and states *what it proves* — with a script
  that runs the real commands as proof. Start here if you want to *do* onboarding.

Every scenario README stands on its own; read them in order the first time.

## Run the proof

```
bin/hg-onboard list                     # the scenarios, in order
bin/hg-onboard all --offline            # the whole walkthrough, no goatnet needed
bin/hg-onboard 00-orient                # start here
bin/hg-onboard 04-see-the-custody       # read-only, runs against the goatnet you are using
bin/hg-onboard 02-onboard-a-machine --for-real   # actually mint (operator profile)
```

`--env <ctx>` targets a goat context (default: the active one). An operator profile enrolling on someone else's behalf adds `--custodian <handle>`. Read steps run
against it; WRITE steps are *shown* by default and only *executed* with
`--for-real` against a real operator profile (use throwaway handles, and retire
them with scenario 05 when done).

## The scenarios — each a recipe

| # | Scenario | Shows |
|---|---|---|
| 00 | [orient](scenarios/00-orient) | the two ceremonies, one grammar |
| 01 | [onboard-a-human](scenarios/01-onboard-a-human) | the delegated three-stage flow (two human gates) |
| 02 | [onboard-a-machine](scenarios/02-onboard-a-machine) | custodian self-service against a quota; the infra gate |
| 03 | [decompose-a-platform](scenarios/03-decompose-a-platform) | a PLATFORM → effector-cue/effector-arbiter workloads, holding their union |
| 04 | [see-the-custody](scenarios/04-see-the-custody) | read the custody edge back, three ways, live |
| 05 | [retire-a-machine](scenarios/05-retire-a-machine) | the exit: mesh-first revoke, quota back, record intact |

## Read next

- **[The visual walkthrough](report/report.html)** — the whole story, sequenced and
  diagrammed, in one page.
- [What is onboarding, here?](docs/00-what-is-onboarding.md) — the framing.
- [The mechanisms & the philosophy](docs/the-philosophy.md) — why the two flows are
  one system, and the ideas behind the shape.
- [The honesty matrix](docs/honesty-matrix.md) — what's live vs represented.
- [Administering onboarding](docs/administering-onboarding.md) — the day-2 side:
  which credential is which, why `goat admin rotate` is not a way to hand someone
  a key, and how to triage "I can't get in".

---

*Part of the Hello Galaxy series (`usareur-af/hello-galaxy-*`): small, runnable,
self-contained demonstrations of the goat data fabric. The designs behind it are in
goatcore: three-stage person onboarding ([ADR 1062](https://github.com/usareur-af/goatcore/blob/main/docs/adr/1062-three-stage-delegated-candidate-onboarding.md)),
delegated machine enrollment ([ADR 1096](https://github.com/usareur-af/goatcore/blob/main/docs/adr/1096-delegated-machine-enrollment.md)) and
mesh-first revocation ([ADR 1031](https://github.com/usareur-af/goatcore/blob/main/docs/adr/1031-credential-revocation-mesh-first-offboarding.md)).*

# Who can be a publisher on the fabric?

> **The misconception this doc exists to correct:** *"Zenoh publishers can only be
> human individuals and their PEM keys — you can't associate a non-person entity
> with a publisher identity."*
>
> **That is not true.** It describes a *legacy allocation habit*, not a limit of the
> fabric. A publisher's identity is a **certificate Common Name (CN)**, not a
> person. A machine, a platform, and a workload each hold their **own** publisher
> identity today — this repo demonstrates exactly that.

## The one sentence

The Zenoh router admits writes by the **CN of the presenting cert**. It has no idea,
and no way to ask, whether the thing behind that cert is a person, a sensor, or a
drone's onboard processor. **A publisher is a cert CN under a slot — full stop.**
Who or what holds that cert is an onboarding decision, not a fabric limit.

## Why anyone believes the "only humans" version

Because for a while it was *effectively* true — not by design, but by omission.

Before machine enrollment existed, the only ceremony that minted a fabric cert was
the **person** flow. So a person got a slot and a cert, and every machine that
person operated **published under the person's one identity**. On the wire, a
custodian's sensor and their effector were the *same* CN — indistinguishable. That
is the world the misconception remembers. It was real. It is also over.

Machine enrollment (scenario 02) closes exactly that gap: **each machine gets its
own slot and its own cert CN**, so it is a distinct principal to the ACL and to
every subscriber. The "one identity per person" state didn't get a workaround — it
got dissolved.

## The non-person publishers, and what's real about each

| Publisher | Its identity | Status | Proven where |
|---|---|---|---|
| **A person** | own slot + cert (CN = slot anchor) + Ory login + `.cbor` bundle | **live** | scenario 01 |
| **A machine** (sensor / effector / processor) | its **own** slot + cert (CN = slot anchor); mesh + fabric only, no console | **live** — `goat machine enroll` mints it | scenario 02 |
| **A platform's workloads** (a UAS's sensor/effector/processor functions) | a SPIRE **X.509-SVID** per workload; each carries the **platform's slot anchor as its CN** (compose by CN), with a distinct `spiffe_id` for attribution | portal records the composition **live**; the SVID `entry create` is a **deploy-side** step (**represented**) | scenario 03 |
| **A non-Rust service** (e.g. a game server) | its **own** vendor/org cert (`CN=<org>-trial-peer`), published through the rest-pub-bridge sidecar | **built**, out of *this* repo's onboarding scope — same CN-anchor principle, different mechanism (see goatcore's [`zenoh-rest-pub-bridge.md`](https://github.com/usareur-af/goatcore/blob/main/docs/design/zenoh-rest-pub-bridge.md)) | — |

Every row above is a **non-person publisher with its own cert CN**. None of them is a
person, and none of them publishes under a human's key.

## "…and their PEM keys"

The other half of the misconception — that a publisher *is* a human's PEM key — mixes
up the **key** with the **principal**. Yes, a person carries a private key. So does a
machine, and so does a workload (its SVID). The key is just the secret that proves
possession of the cert; it is not what makes the holder a person. The router never
sees "a human's PEM" — it sees a CN and checks it against the ACL. **The key proves
the cert; the CN *is* the identity.** A machine's key is exactly as much a
first-class publisher key as a person's.

## The one honest caveat

A machine's cert CN is its slot anchor, and its **node-class** (`SENSOR-FEED` /
`EFFECTOR-CUE` / `KID` / …) and **autonomy** live in the **registry born-as record** — they are
**not yet stamped into the cert's URI-SAN**. That enrichment is a fenced follow-on.
It does **not** weaken the point here: the wire ACL keys on the **CN**, and the
machine already has its own distinct CN, so it is already wire-distinguishable and
already a first-class publisher. The missing SAN axes are *descriptive attribution*,
not *admission* — the registry carries them today.

## The shape to remember

- **The fabric admits by CN, never by person-ness.** Everything downstream follows.
- **A slot can belong to a person, a machine, or (via SPIFFE) a workload.** One
  grammar, siblings under a unit.
- **"Only humans" was a habit, not a rule — and the machine flow dissolved it.**

If someone tells you the fabric can't associate a non-person entity with a
publisher, walk them through scenario 02: one command mints a machine its own cert,
and `goat machine ls` reads it back — a publisher that is not, and never was, a
person.

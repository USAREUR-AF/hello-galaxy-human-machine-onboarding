# Onboard a machine — one command, zero review gates

The analyst from scenario 01 deploys a sensor. On most systems a new device means
another provisioning ticket, another approval queue. Here the analyst is a *vetted*
person who already passed two human gates, and they carry a **machine quota**. That
quota *is* the authorization — so bringing a machine online is **one self-service
command, no review queue.**

Before this flow existed, a person's machines all published under the person's one
Zenoh identity — indistinguishable on the wire. The point of machine enrollment is
to give each machine its **own** identity.

## What you'll see

```
goat machine enroll sensor-01 --node-class SENSOR-FEED --autonomy supervised
```

One command, and — atomically — the machine gets its own identity, or nothing:

1. The server checks the custodian's quota (**fail-closed**, inside the
   transaction, so two concurrent enrolls can't together overrun the grant).
2. It allocates the machine its **own** `<uuid>/<taxonomy>` slot — the thing that
   makes it wire-distinguishable — and mints a Zenoh cert whose **CN is that slot
   anchor**.
3. It records the **custody edge** (`enrolled_by = the custodian`), decrements the
   quota, and writes one custodian-attributed audit event.

And the deliberate omissions: **no `.cbor`, no Ory login.** A machine does not sign
into web consoles; it gets mesh + fabric identity only.

## What it proves

- **The quota is the gate.** No sponsor, no admin queue — the custodian's standing
  grant is the pre-authorization. Over-quota is refused fail-closed; a custodian
  with no grant gets nothing.
- **Each machine is wire-distinguishable** — its own slot, its own cert CN. A
  sensor and an effector under the same custodian are now different principals to
  the ACL and to every subscriber.
- **Revocation returns the quota by construction** — remaining is *derived*
  (`quota − live-enrolled`), never stored, so retiring a machine frees capacity
  with no extra bookkeeping.
- **Infrastructure is the one exception.** `MGMT-HOST`/`ZENOH`/`SNITCH`/`SERVICES`/`NETWORK`/`BREAKGLASS`/`NETWORK-JUMP`
  shape the goatnet itself, so they stay operator-gated (attributed to the
  custodian). `NETWORK-JUMP` is the one peer allowed to reach bearer gear
  ([ADR 1131](https://github.com/usareur-af/goatcore/blob/main/docs/adr/1131-network-jump-class-and-herd-gear-scope.md)). The FUNCTION classes are self-service — `SENSOR-FEED`,
  `SENSOR-TELEMETRY`, `SENSOR-ARBITER`, `EFFECTOR-CUE`, `EFFECTOR-TRACK`,
  `EFFECTOR-TELEMETRY`, `EFFECTOR-ARBITER`, `KID`, `EXTERNAL-KID`,
  `EXTERNAL-INTERMEDIARY`, `FUSION`, `CONTROL`, and `PLATFORM` with declared
  `--workloads`.

  **`SENSOR`, `EFFECTOR` and `PROCESSOR` are not enrollable.**
  The first two are RESERVED — they name the sensing element or the interceptor,
  which is not a mesh peer. `PROCESSOR` has no NetBird group at all, so a peer
  enrolled as one holds nothing; use `FUSION`. The mint refuses each with the
  class you should have used. Full decision table:
  [`docs/operations/gear-enrollment-sop.md`](https://github.com/usareur-af/goatcore/blob/main/docs/operations/gear-enrollment-sop.md) in goatcore.

## Honest caveat

With `--for-real` and an operator profile this mints a **real** machine on the
target goatnet. Use throwaway handles and retire them with scenario 05 when done.
Grade: **live** (needs a goatnet; `--offline` shows the commands only).

```bash
bin/hg-onboard 02-onboard-a-machine            # walk it, commands shown
bin/hg-onboard 02-onboard-a-machine --for-real # actually enroll (operator profile)
```

# 05 — Retire a machine

**The way out.** A machine enrolled in scenario 02 has its own slot, cert,
custody edge and one-off key. Retiring it takes all of that back out, in an
order that never leaves a half-revoked machine behind.

```bash
bin/hg-onboard 05-retire-a-machine [handle] [--offline | --for-real]
```

## What it shows

**Mesh first, and it refuses rather than half-cuts**
([ADR 1031](https://github.com/usareur-af/goatcore/blob/main/docs/adr/1031-credential-revocation-mesh-first-offboarding.md)). The peer and any
*unconsumed* setup key are cut on the mgmt server **before** the registry slot
is freed. In per-uuid slot-pool mode the router bakes a `slot-w-<anchor>` grant
for every slot unconditionally, so the registry teardown moves no authorization
at all — mesh removal is the only barrier that actually falls. If the mgmt
server refuses, you get a **502 with the registry byte-for-byte unchanged**. A
retry is a retry, never a second half-revoke: a row saying "retired" in front of
a machine still holding its tunnel is worse than a clean refusal.

**Key before peer.** Shut the door, then evict. Deleting the peer first leaves a
live single-use key a box could re-join on in the gap.

**A spent key is named, not deleted.** It can admit nothing further, and
deleting it would erase the record of how that peer got there.

**Quota returns by construction.** Remaining quota is *derived* — the grant
minus live enrolled slots, never stored — so stamping `revoked_at` **is** the
refund. Nothing increments a counter, so nothing can drift.

## What survives, and what does not

| | |
|---|---|
| **Survives** | the slot row's born-as class, autonomy and custody edge, alongside `revoked_at`; and an audit event carrying every peer and key id that was cut |
| **Does not** | the identity. The slot index returns to the free pool, so re-enrolling the handle mints a **new** anchor. The retired cert is not restorable, and that index may later belong to a different tenant |

## The one thing it cannot cut

**A peer renamed off its machine handle.** The cut finds peers by name — the
same join key the provenance audit uses. If a key was spent but no peer matches
the handle, the CLI says so plainly: that peer is still on the mesh and must be
found by hand. Keep peer name and machine handle equal.

## Requirements

`goat-cli >= 0.4.40` **and** a portal carrying the endpoint. A portal that
predates it answers **405**, and the CLI names that case rather than surfacing a
bare status — it tells you the goatnet has not taken the image yet and gives the
interim path.

Grade: **live** on a goatnet. Against a real portal with an operator profile
(`--for-real`) this really retires a machine. The peer-delete leg is covered by
the portal test suite against a fake mgmt server. `--offline` shows the
commands only.

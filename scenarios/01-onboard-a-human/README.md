# Onboard a human — prove a stranger, across three delegated stages

A new analyst joins. They have no cryptographic identity, no mesh membership, no
console login, and — critically — **no one has vouched for them yet**. On most
systems an admin just creates an account. On goat, that would put invite,
vouch, and mint in one pair of hands. Instead the person flow is **delegated
across three stages** so two different humans stand behind every new identity.

## What you'll see

A candidate goes from nothing to a full identity through five moves — and no
single actor makes more than one of the trust decisions:

1. **Invite** — a *sponsor* (authorized to sponsor at most their own tier) mints a
   one-time link, pre-binding the things the candidate must not choose for
   themselves: tier, affiliation, site, and a **machine quota**.
   ```
   goat admin invite --tier developer --affiliation acme --machine-quota 5
   ```
2. **Submit** — the candidate opens the public one-time link and fills their own
   details. This lands as an inert *proposal*, not an identity. They **cannot
   self-escalate** their tier — an escalated tier is refused fail-closed.
3. **Vouch** — the sponsor reviews the filled submission and vouches for it. (Gate 1.)
4. **Approve** — a separate *admin* approves the vouched proposal. (Gate 2 — a
   different human.)
   ```
   goat admin queue approve <handle>
   ```
5. **Mint** — the onboard-runner writes the identity across every plane it needs:
   a NetBird setup key (mesh), a Zenoh slot + cert + api_key (fabric), an Ory login
   (console), and the signed **`.cbor` bundle** the person carries.
   ```
   goat admin onboard <handle>
   ```

## What it proves

- **Two human gates precede any mint** — sponsor *and* admin, and they are
  different people. Invite alone mints nothing.
- **A candidate cannot grant themselves anything** — tier/affiliation/site are
  pre-bound in the invite; self-escalation is refused.
- **The output that matters next**: the person now carries a **machine quota** —
  the standing authority to bring their own machines online later. That single
  attribute is the hinge to scenario 02.

## Honest caveat

The full flow needs the portal, a real sponsor, and a real admin — three actors.
This scenario **shows the real command each actor runs**; it does not impersonate
three people. Grade: **needs-operator** (see [the honesty matrix](../../docs/honesty-matrix.md)).

```bash
bin/hg-onboard 01-onboard-a-human            # walk it, commands shown
bin/hg-onboard 01-onboard-a-human --for-real # execute the mint (operator profile)
```

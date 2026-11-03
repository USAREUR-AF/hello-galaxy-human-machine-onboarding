# The mechanisms & the philosophy

The scenarios *show*; this doc *explains*. Why the two onboarding flows are one
system, and the ideas behind the shape.

## Mechanisms — how it holds together

- **One grammar, five orthogonal dimensions** — role · affiliation · echelon ·
  node-class · site. A person carries `role`; a machine carries `node-class` +
  optional `autonomy`; both carry `affiliation`. Machines are **siblings** of their
  custodian *under the same unit* — not a separate class of thing.
- **The custody edge** — `enrolled_by` records who brought a machine online. It is
  custody, not ownership: a human is primary at bootstrap; the system is unit-owned
  thereafter. It rides a read-only actor graph — never an enforcement path.
- **Quota as pre-authorization** — the person's `enrollment_grant` (quota +
  inherited affiliation/site) is the standing authority to enroll machines later.
  Remaining quota is *derived*, never stored (`quota − live-enrolled`), so **revoking
  a machine returns its quota by construction**.
- **The slot pool** — identity-bound `<uuid>/<taxonomy>` slots are pre-cut into the
  router ACL; a mint claims one. Each machine gets its **own** slot, which is what
  makes it wire-distinguishable — the whole reason the machine flow exists (before
  it, a custodian's machines all published under the custodian's one identity).
- **Compose by CN** — the wire ACL admits by the cert's Common Name. A
  portal-minted machine cert and a SPIRE-minted workload SVID are admitted the same
  way; SPIRE composes with the static ACL by CN, no second identity plane.
- **Affiliation is inherited, never chosen** — a machine's affiliation is copied
  from the custodian's grant at mint, preserving the invariant that affiliation is
  identity-only and unit-derived.

## Philosophy — why this shape

- **Identity-first, not network-first.** The fabric finds itself by identity. A
  principal's cert + custody edge come before any capability; access is *derived*
  from identity, never the reverse.
- **Cert = born-as; registry = currently-is.** Immutable facts about what a
  principal was *minted as* live in the cert; mutable facts about what it
  *currently is* live in the registry. A sensor is born a sensor (node-class is
  born-as); a unit that changes on reorg is currently-is.
- **Sibling ceremonies, asymmetric gates.** Humans and machines share the grammar
  and the registry but not the gates — because the trust question differs. Proving a
  stranger takes two humans (sponsor + admin). Actuating a vetted person's asset
  takes their quota. Collapsing the two into one flow would either over-gate
  machines or under-gate people.
- **Each authority owns one identity class.** The portal owns human + machine
  identity + custody; SPIRE owns workload SVIDs; NetBird owns mesh membership; Ory
  owns human console login. Onboarding *composes* these authorities — it never
  proxies one through another. (That is why a platform's workload SVIDs register
  through SPIRE directly, and the portal only records the composition.)
- **Attribution is not enforcement.** Node-class, autonomy, and the custody graph
  are attribution + provenance; the wire ACL keys on the CN. Keeping that split
  honest is why, e.g., node-class in the cert stamp is deferred to the grammar
  cutover rather than bolted on — it would add no enforcement, only a stamp the
  registry already carries.

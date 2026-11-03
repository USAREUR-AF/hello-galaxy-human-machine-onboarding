# What is onboarding, here?

Onboarding is the ceremony that mints a **principal** — a first-class identity on
the fabric — across the planes it needs. It is not "create a user account." It is:
give this entity a cryptographic identity, place it in the registry under its unit,
stamp it with the grammar, and record who brought it online.

Two kinds of principal, two ceremonies:

- **A person** is a stranger who must be *proved*. The person flow is delegated
  across three stages so no single actor both invites and admits, and it mints the
  fullest identity: mesh membership, a fabric cert, an Ory console login, and a
  signed `.cbor` bundle the person carries.

- **A machine** is a vetted person's *property*. The machine flow is custodian
  self-service against a standing quota — the quota is the pre-authorization, so
  there are no review gates (except for infrastructure classes, which shape the
  goatnet itself and stay operator-gated). It mints a mesh + fabric identity only;
  a machine does not sign into consoles.

Both are stamped with the same grammar and land in the same registry as **siblings
under a unit**. See [the philosophy](the-philosophy.md) for why, and
[the honesty matrix](honesty-matrix.md) for what these scenarios prove vs represent.

One thing this makes concrete, because it is commonly gotten wrong: **a fabric
publisher is a cert Common Name, not a person.** A machine gets its *own* cert and
CN — it is not publishing under a human's key. If you've heard that Zenoh
publishers can only be human individuals, [who can be a
publisher](who-can-be-a-publisher.md) names that misconception and corrects it.

# Administering onboarding — the day-2 side

The scenarios in this repo show the *ceremonies*: how a person, a machine, and a
platform become principals. This page is about what happens afterwards, when
someone writes **"I can't get in"** in a chat channel and you are the admin.

The answers people reach for by instinct here tend to make things worse; this
page is the set of answers that don't.

## Where onboarding information lives now

Two places, split on a hard constraint rather than taste:

- **The welcome email** carries only what a person cannot get any other way —
  the mesh setup key, the login link, and (for fabric roles) the portal API key
  and a one-time bundle URL.
- **The guide page** at `guide.<site>.<zone>` carries everything else: CLI
  install, the surfaces, publishing, troubleshooting. It is mesh-only and
  tier-specific.

The cut line is forced. Everything on the guide is only reachable once the
person is on the mesh, and joining the mesh can never move there — until it is
done, the page does not load. A useful consequence when helping someone: **if
the guide opens for them, step 1 already worked.**

The guide carries no credentials and is identical for everyone at a tier, which
is why it needs no login of its own. Do not paste anyone's key into it or ask
for one back through it.

### The guide is per-role, and time-boxed

It is not one page everyone scrolls. Five roles — browse, developer, identity
admin, platform admin, network admin — each get their own path, with the total
and per-step time to complete stated up front so nobody has to guess whether
they are twenty minutes or an afternoon from being useful. Anything with a
deadline (a bundle URL that expires, a key with a window) is called out as a
deadline rather than left in a paragraph to be noticed too late.

Network admin is a separate path rather than a footnote under platform admin,
because the two answer different questions and a network admin may cover more
than one site.

When you point somebody at the guide, point at THEIR role. Sending a new
developer the platform-admin path is how people conclude the system is more
complicated than it is.

### Relay health: introduce it differentially

The relay-fleet dashboard is linked from the guide, and two independent things
decide what a person gets. **The door** is a viewer list — relay addresses and
placement are worth withholding, and being an admin elsewhere does not put you
on it. **The grading** is what an admitted viewer receives: platform and
identity admins the full document, everyone else a reduced one that keeps every
status, latency and capacity number and drops addresses and coordinates.

Both halves matter when you explain it. Saying only "it's gated" sends an
admitted admin away from detail they had. Saying only "you get a reduced view"
promises a non-admin a page that will not let them in.

For non-admins the honest framing is: this exists, admission is a list rather
than an oversight, service status is the surface that answers your question, and
here is how to ask if your work genuinely needs the fleet view.

One detail worth knowing before somebody asks: the dashboard the guide links is
hosted **off** the mesh. That looks inconsistent next to every other surface,
and it is the point — a network-health page reachable only over the mesh is
unavailable exactly when the mesh is what broke.

## The credentials, and where each one lives

Onboarding a person can mint four different secrets, and admins carry a fifth. They are not
interchangeable, they arrive by different routes, and most confusion comes from
treating them as one thing.

| Credential | What it unlocks | Where it arrives |
|---|---|---|
| **Mesh setup key** | `netbird up` — joining the mesh | The welcome email |
| **Ory login** | Every web surface, via single sign-on | The welcome email (one-time link or code) |
| **Portal API key** (`vp_…`) | The Portal only — pasted into its Sign in box | The welcome email; also the last line of `goat-cli.cbor` in the bundle |
| **Fabric cert + private key** | Publishing / subscribing on the fabric | The bundle tarball only — a one-time, mesh-only URL |
| **Operator key** (`op_…`) | Admin actions on the Portal, attributed to you by name | Requested and collected, not minted at onboarding — see below |

The cert's private key is the one that never travels by email, in any
circumstance. The other three do, and that is deliberate: each is scoped,
revocable, and useless without the mesh.

**The first four are not minted on request.** They come out of the onboarding
mint. If a person doesn't have one, the answer is almost never "issue them one
by hand" — it's "find out why the mint didn't produce it, or whether their
access level was never supposed to include it."

**The operator key is the exception, and deliberately so.** It is asked for,
approved, and collected, because it is the credential that makes an admin
action attributable to a named person: nobody should be handed one as a side
effect of being onboarded.

## The operator key: ask for it, don't be issued it

Its whole job is attribution. When an admin mints a slot or changes a level, the
audit records *who* — and it can only do that if the credential presented
belongs to one person rather than to a shared login.

Getting one is three self-service moves, so nobody is tempted to share a key
that already works — which is precisely what the key exists to prevent:

```
goat admin operator-key request <handle> --reason "what you need it for"
goat admin operator-key approve <id>          # an admin, not the requester
goat admin operator-key collect <id> --handle <handle>   # shown ONCE
```

or the same three moves in the console at `/operator-key` and
`/onboarding/operator-keys`.

**Approval is the grant.** This is where it differs from an SSH key, and getting
it wrong sends people away confused in opposite directions. An SSH key still
needs an installer run, so approved there really is not access. An operator key
is live within seconds of approval, because the Portal re-reads its key
directory while running. If it still doesn't work a minute later, that is a
fault to report — not a step somebody forgot.

**Shown once.** The value is delivered a single time and then dropped from the
console's records; only a fingerprint remains. If somebody loses theirs, revoke
and issue a new one. Do not go looking for the old value: a key nobody holds
still works, and nobody can tell you who is using it.

**Revoke through the same path.** Revoking removes the key file, and the Portal
stops accepting it on its next reload. Hand-editing the key directory leaves the
record and reality disagreeing — and the record is what the next reconcile
compares against.

## Not everyone gets a portal key — and that is correct

The portal API key is minted only for onboardees with a **fabric identity**
(`zenoh.enabled` in their manifest). On a typical goatnet that is a minority of
the people onboarded; the rest have no portal key because there is nothing for
them to hold one *for*.

So when someone says "the Portal won't let me in," the first question is not
"where is their key" but **"should they have one at all?"** If their work needs
the Portal, the fix is to change their access level — which mints the key as
part of the change — not to hand them a key that their level doesn't imply.

A welcome email says this plainly to people with no fabric leg, so they don't go
hunting for something that was never created.

## `goat admin rotate` is not a way to get someone a key

`goat admin rotate` **re-issues the certificate in place and returns a new
`api_key`**. The new key works. The old one stops working — including the copy
sitting in that person's own bundle, and any copy they already pasted into a
browser.

Using rotation to produce a working key for someone who can't find theirs looks
like it works: you run it, you get a `vp_…` string, you paste it into an email,
the person gets in. But it silently invalidates the key in their bundle, so:

- The next person told to "look in your `.cbor`" finds a key that doesn't work.
- Anyone comparing the emailed key against the bundle key finds two different
  strings and reasonably concludes the system is broken.
- Each rescue creates the conditions for the next support request.

**Rotate when you mean to rotate** — a suspected compromise, a scheduled
credential refresh, an offboarding-adjacent cleanup. Never as a delivery
mechanism.

## Admin tiers: the SSH key is not automatic

The ceremony reads `manifest.operator.ssh_pubkey` and **skips the SSH step when
that key is absent** — and only the person themselves can supply a public key, so
it is absent at onboard time for anyone who was not asked for it in advance.

So the welcome email asks for the key rather than claiming it was installed, and
the self-service path is: a person submits their own public key on the console
at `/ssh-key`, an admin approves it from the queue at `/onboarding/ssh-keys`,
and a separate installer run places it on the hosts that person's role may
reach. The onboarding guide links both pages, so nobody needs to be told a URL.

**Three states, and only the last one is access.** The distinction is where
almost all the confusion lives:

| state | what it means | can they log in? |
|---|---|---|
| submitted | recorded, waiting on a decision | no |
| approved | an admin said yes | **no** — nothing is on a host yet |
| installed | the installer placed it and reported back | yes |

So "I approved your key" is not the same sentence as "you have access", and
saying the first while meaning the second tells a person they have access they
do not have. When a new admin says "I can't SSH in" after being
approved, check whether the installer has run before looking for a fault.

Two things worth knowing when you are the one approving:

- **You are deciding about the person, not the key.** The parser already
  rejects a malformed key or a pasted private one. What you are deciding is
  whether this person should hold a shell at the scope their role carries.
  Submitting deliberately cannot authorize: the console is reachable with an
  ordinary web session, so if uploading a key also granted access, a stolen
  session would become a root-capable shell.
- **Revoke through the queue, never by editing `authorized_keys`.** A hand edit
  leaves the record and the host disagreeing, and the record is what the next
  install run reconciles against — so the key comes back.

One caveat that is easy to trip over: reaching `/ssh-key` at all means getting
through the console's own login gate first, and that gate is not the same on
every goatnet. On some it admits anyone who can sign in; on others it admits
platform and identity admins only. On the second kind an operator who is neither
cannot submit their own key and has to ask an admin. If somebody reports
that the submit page refuses them, that is the console door rather than
anything about their key.

## Triage: "I can't get in"

Work down this list. Each step tells you which of the four credentials is
actually involved.

**1. Are they on the mesh?** Nothing else can work first. `netbird status -d`
should name *this* goatnet's management URL. If it names another one, they are
on the wrong mesh — `netbird down`, then re-run the join command with their
setup key. Running `netbird up` while connected to another mesh is silently
ignored, which is a common dead end.

**2. Did their welcome email actually contain the credential they need?** Ask
them to look, rather than assuming. A package that predates the current console
may be missing the portal key, or (further back) the setup key.

**3. If a credential is genuinely missing, re-send rather than re-mint.** The
console can re-send a corrected welcome package, marked as a repeat so a second
email doesn't read as a second identity. It can also carry a key the console
never learned. This preserves what they already have; rotating does not.

**4. If they have no key because their level has none,** change the level. See
above.

**5. Only if the identity itself is wrong** — wrong unit, wrong grammar stamp,
compromised — do you reach for rotation or revocation.

## What the system guarantees

Two invariants are worth knowing, because they change what "no email arrived"
means.

**A welcome email is never sent incomplete.** If someone's manifest puts them on
the mesh but no setup key is in hand at send time, the console **holds** the
send and records it in the audit trail with result `held`, rather than mailing a
package that says "your operator will hand you a key."

So: **a missing email is a signal, not a silence.** If someone reports never
receiving one, check for a held send before assuming a delivery problem.

**Credentials are delivered, not described.** The email carries the actual setup
key and the actual portal key. An instruction to go find the portal key "under your identity once
you can reach the Portal" is circular, because that key is how you reach the
Portal; if you find one like that anywhere, treat it as a bug rather than a
procedure.

## Ownership is recorded, not inferred

Every portal slot carries `identity_id`: the Kratos identity of the person it
belongs to. Both mint paths record it.

Why an admin should care: **ownership is what revocation targets.** A recorded
linkage means "revoke this person's access" resolves to a fact. An inferred one
means it resolves to a name match, which is right until two handles look alike.

A slot minted without that linkage is visible, not silent, and the repair is
deliberate: a tool proposes only bindings a source of
truth already proves, and refuses everything else. **Never link a slot to a
person by recognising the name** — a wrong owner is worse than no owner,
because it hands one person authority over another's namespace. Slots for
machines, services, demos and orgs correctly have no person and stay unlinked.

## Machine allowance: grant it at onboarding, not on request

Equipment is enrolled by the person who owns it, against a standing allowance an
admin grants once — `goat machine grant <custodian> --quota N --affiliation <unit>`.
There is no review queue by design: the allowance IS the pre-authorisation, and
the class the custodian picks derives the machine's network reach automatically.

**You are authorising a count, not approving a machine.** What a given box may
reach follows from what it does, is derived at enrolment and enforced from then
on. That part is not a judgement you make per machine, which is why there is
nothing for you to sit in the middle of.

**The failure mode is treating the request as a ticket.** A custodian sitting at
zero when their gear arrives has an alternative that nobody governs and that
takes about a minute: a joining key with hand-picked groups. It produces a
machine that works and is quietly untraceable — no identity of its own, no
record of who brought it on, and network access somebody typed rather than the
system deriving it. Hand-picked groups are how unrelated gear and a person's
laptop end up in one group; a single-use key does not prevent that, because the
problem is who chose the groups.

So: set the allowance when you bring the person on, the same way you set
everything else their role implies. An allowance is a ceiling, not a budget —
retiring a machine returns its unit, so a custodian who cleans up does not come
back to you for more. Raising one is cheap and reversible; lowering it leaves
existing machines untouched and only refuses the next enrolment.

**This is checked rather than trusted.** An hourly audit on each
goatnet's mgmt host joins live mesh membership to the machine registry and names
any gear-class peer with no custody edge. If it names one, read the report before
concluding somebody went around the mint: the join key is `peer name == machine
handle`, so a peer left on a factory hostname reads as a violation with its
paperwork perfectly intact. Rename the peer to its handle — a name-only change —
rather than adding an exception.

## The underlying principle

Onboarding is meant to run **on rails**: one process, tuned per role, that hands
a person everything their role implies. Every time an admin has to step in and
produce a credential by hand, that is not the system working as designed with a
manual assist — it is the rails being broken somewhere upstream, and the manual
step is hiding the break.

When you find yourself doing something repetitive and manual to get people
onboarded, that is worth reporting as a defect, not absorbing as a duty.

---

*See also: [what is onboarding, here?](00-what-is-onboarding.md) for the
ceremonies themselves, and [the honesty matrix](honesty-matrix.md) for what this
repo proves live vs represents.*

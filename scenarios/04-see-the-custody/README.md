# See the custody edge — read it back, live

Every mint in scenarios 02–03 recorded *who brought this machine online*. That
`enrolled_by` custody edge is not decoration — it is how you answer "whose sensor is
that?", "how much of Alice's quota is left?", and "what does this UAS decompose
into?". This scenario reads the edge back three ways. Unlike the mints, **these run
live** — they are read-only queries and need nothing but a reachable portal.

## What you'll see

The same custody edge, from three vantage points:

1. **The fleet / your machines** — one line per machine: handle, node-class,
   autonomy, and for a platform its `[workloads]`, plus the custodian's remaining
   quota.
   ```
   goat machine ls
   ```
2. **An identity's custodied machines, in the COP** — `access who` folds a
   **custody** section into the Data-Access common operating picture.
   ```
   goat access who me
   ```
3. **The full-screen identity browser** — `goat who` is an interactive TUI; select
   an identity and its detail pane shows the same **CUSTODY** section.
   ```
   goat who
   ```

## What it proves

- **The custody edge is queryable from the identity side**, not just recorded at
  mint. A person resolves to their fleet; a machine resolves to its custodian.
- **One edge, three surfaces, one truth** — the fleet view, the COP query, and the
  browser all render the same `enrolled_by` relationship. Nothing is recomputed or
  faked; an identity that custodies nothing shows nothing.
- **Quota is visible where it's spent** — the fleet view carries the custodian's
  remaining quota, closing the loop with scenario 02.

## Honest caveat

These are read-only queries against a goatnet's portal — no mint, no mutation.
Grade: **live** (they need a reachable portal; no operator write profile
required). `--offline` shows the three commands without running them.

```bash
bin/hg-onboard 04-see-the-custody
```

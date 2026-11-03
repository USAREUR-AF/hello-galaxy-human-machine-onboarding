# Decompose a platform — one asset, several workloads

The next asset isn't a single-function sensor — it's a UAS. It observes (a sensor),
it acts (an effector), and it fuses data on board (a processor). Three functions,
one airframe. How do you give it identity without either pretending it's one opaque
box or charging it three separate enrollments?

You declare its **composition** at enroll. The airframe is one asset; its functions
are its internal workloads.

## What you'll see

```
goat machine enroll uas-01 --node-class PLATFORM --workloads sensor,effector,processor
```

1. The `PLATFORM` enrolls like any machine — its own slot, its own cert — and costs
   **exactly one quota unit**. Its workloads are internal composition, *not* three
   separate enrollments.
2. The **portal records** the declared composition as a born-as attribute on the
   machine (`slots.workloads`). It does not mint workload identities itself.
3. **SPIRE mints** one SVID per workload. The bridge that turns the recorded
   declaration into SPIRE registration entries is:
   ```
   ops/identity/gen-platform-spire-entries.py --env <goatnet>   # in goatcore
   ```
4. Each workload SVID carries the **platform's slot anchor as its CN** (so it writes
   under the platform's namespace — *compose by CN*), with a distinct
   `spiffe_id = uas-01/<function>` as its SPIFFE attribution.

## What it proves

- **A platform is one quota unit** — an asset is charged as an asset, not as the sum
  of its parts.
- **Each authority owns one identity class** — the portal owns the machine identity
  and the *recorded composition*; SPIRE owns the *workload SVIDs*. Neither proxies
  the other, so there is no coupling between two identity systems.
- **Compose by CN** — the workloads are attested-and-attributed separately
  (distinct `spiffe_id`) but share the platform's write namespace (same CN). SPIFFE
  identity is not the same as a wire-ACL axis.

## Honest caveat

The generator + the recorded declaration are **live**; the actual `spire-server
entry create` is a **deploy-side** step, because each workload's *selector* (a docker
label) only exists once the platform's containers are deployed. Grade:
**represented** for the SVID registration, **live** for everything upstream of it
(on a goatnet; `--offline` shows the commands only).

```bash
bin/hg-onboard 03-decompose-a-platform
```

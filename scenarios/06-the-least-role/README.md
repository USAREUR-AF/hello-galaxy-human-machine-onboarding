# The least role — a machine's key does the machine's work

A common request reads "I need more than developer but less than admin". For a machine's
data it is almost never a new role. A machine enrolled in scenario 02 has its own slot and
its own portal key, and its topics are registered with that key. Your own sign-in has no
write authority over the machine's slot, whatever role you hold, and that is the design.

## What you'll see

1. What you hold: `goat access who me`.
2. The machine's enrollment bundle made a second context: `goat profile init <machine .cbor> --context <machine>`.
3. The machine's topic registered from the machine's context.
4. The same create from your own context refused with `vendor scope mismatch` (403).
5. The three things not to reach for, and when each one is right.

## What it proves

- **Write authority over a slot belongs to the slot's key.** The portal accepts a topic
  create under a slot from that slot's own key or an operator key, and from nothing else.
- **The audit names the machine.** The create is recorded against the machine, not a person.
- **No role grew.** The person who looks after the machine keeps the role their own job needs.

Which role fits which job: [choosing a role](../../docs/choosing-a-role.md).

```bash
bin/hg-onboard 06-the-least-role                                    # shown
bin/hg-onboard 06-the-least-role --for-real <machine-context> <anchor>   # step 3 runs
```

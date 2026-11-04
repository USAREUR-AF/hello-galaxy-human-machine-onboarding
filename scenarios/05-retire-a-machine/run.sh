#!/usr/bin/env bash
# Retire a machine — mesh first, then the registry.
set -uo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/onboarding.sh"
hg_parse_env "$@"
HANDLE="${HG_ARGS[0]:-demo-sensor}"

hg_banner "Retire a machine — mesh first, and it refuses rather than half-cuts" \
          "Scenario 02 brought a machine in. This is the way out."
hg_preflight || exit 1

hg_step "1 — What is being taken back"
hg_note "A machine from scenario 02 holds its own slot, its own cert, a custody edge"
hg_note "and a one-off setup key. Retiring it removes its reach and frees the slot,"
hg_note "and keeps the record of who brought it on."

hg_step "2 — Retire it"
hg_goat_write machine revoke "$HANDLE" --yes

hg_step "3 — What that did, in this order, and why the order is the design"
hg_say "• deleted the machine's PEER on the mgmt server"
hg_say "• deleted any UNCONSUMED setup key for it"
hg_say "• THEN freed the registry slot and deleted the anchor row"
hg_say ""
hg_say "MESH FIRST (ADR 1031). In slot-pool mode the router bakes a grant for"
hg_say "EVERY slot unconditionally, so the registry teardown moves no"
hg_say "authorization at all — mesh removal is the only barrier that actually"
hg_say "falls. If the mgmt server refuses, you get a 502 and the registry is"
hg_say "byte-for-byte as it was. A retry is a retry, never a second half-revoke."
hg_say ""
hg_say "KEY BEFORE PEER. Shut the door, then evict. Deleting the peer first"
hg_say "leaves a live single-use key a box could re-join on in the gap."

hg_step "4 — What it deliberately does NOT delete"
hg_say "A key that was already SPENT is named in the response and left alone."
hg_say "A spent one-off can admit nothing further, and deleting it would erase"
hg_say "the record of how that peer got there."

hg_step "5 — Quota comes back by construction"
hg_note "Remaining quota is DERIVED — quota minus live enrolled slots, never stored."
hg_say "So stamping revoked_at IS the refund. Nothing increments a counter and"
hg_say "nothing can drift out of step."
hg_cmd "goat --context $HG_CTX machine ls"
hg_goat machine ls || hg_warn "no live output (portal unreachable or nothing enrolled)"

hg_step "6 — What survives, and what does not"
hg_say "SURVIVES: the slot row keeps its born-as class, autonomy and custody edge"
hg_say "alongside revoked_at, and the audit event carries every peer and key id cut."
hg_say "DOES NOT: the identity. The slot index returns to the pool, so re-enrolling"
hg_say "this handle mints a NEW anchor — the retired cert is not restorable, and"
hg_say "that index may later belong to a different tenant."

hg_step "7 — The one thing revoke cannot cut"
hg_warn "A peer RENAMED off its machine handle."
hg_say "The cut finds peers by name — the same join key the provenance audit uses."
hg_say "If a key was spent but no peer matches the handle, the CLI says so plainly:"
hg_say "that peer is still on the mesh and has to be found by hand. Keep peer name"
hg_say "and machine handle equal; that pair is load-bearing twice over."

hg_summary "Result" "A machine cut from the mesh first, its slot freed, its quota back, and its record intact."
hg_honest live "Against a real portal with an operator profile (--for-real), this really retires a machine. A portal predating the endpoint answers 405 and the CLI says so, naming the interim path."

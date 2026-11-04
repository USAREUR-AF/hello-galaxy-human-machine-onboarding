#!/usr/bin/env bash
# Onboard a machine — custodian self-service against a quota.
set -uo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/onboarding.sh"
hg_parse_env "$@"
HANDLE="${HG_ARGS[0]:-demo-sensor-$$}"

hg_banner "Onboard a machine — one command, zero review gates" \
          "The custodian's quota IS the pre-authorization. The machine gets its OWN fabric identity."
hg_preflight || exit 1

hg_step "1 — A function-class machine is self-service"
hg_note "SENSOR-FEED is mission payload the custodian owns → no queue, just their quota."
hg_note "The class is a FUNCTION, not a kind of box. A box doing two jobs"
hg_note "is enrolled twice, once per job — that is what stops a catch-all forming."
hg_goat_write machine enroll "$HANDLE" --node-class SENSOR-FEED --autonomy supervised \
  ${HG_CUSTODIAN:+--custodian "$HG_CUSTODIAN"}

hg_step "2 — What that mint did (atomically)"
hg_say "• allocated the machine its OWN <uuid>/<taxonomy> slot (wire-distinguishable)"
hg_say "• minted a Zenoh cert; recorded the enrolled_by custody edge"
hg_say "• DERIVED its NetBird groups from the node-class and minted a ONE-OFF,"
hg_say "  SINGLE-USE setup key carrying exactly those and nothing else"
hg_say "• decremented the custodian's quota; emitted one custodian-attributed audit event"
hg_say "• did NOT mint a .cbor or an Ory login — machines don't sign into consoles"

hg_step "3 — The mesh half is the point, not a detail"
hg_note "A human typing groups into a setup key is how unrelated gear ends up in one group."
hg_say "So the class decides, and nobody types a group:"
hg_say "  mesh_groups     the FULL group names, derived — never typed"
hg_say "  mesh_setup_key  one-off, usage_limit 1, a 30-day JOIN window (not a trust window)"
hg_say "The key is the enforcement point. Hand-picking auto_groups for gear is not"
hg_say "a sanctioned path anywhere."
hg_note "Needs goat-cli >= 0.4.39 — older releases silently DROP the returned key."

hg_step "4 — Classes the mint REFUSES, and why that is a feature"
hg_say "  SENSOR / EFFECTOR      reserved: they name the sensing element or the"
hg_say "                         interceptor, which is not a mesh peer"
hg_say "  SENSOR-TASKING /       intake-only: inbound permission, no outbound reach —"
hg_say "  EFFECTOR-COMMAND       a peer holding one alone could not reach the router"
hg_say "                         to receive the tasking the class exists for"
hg_say "  PROCESSOR              legacy whole-system class with no group: a peer"
hg_say "                         enrolled as one holds nothing and is uncovered → FUSION"
hg_say "Every refusal names the class you should have used. A refusal you cannot act"
hg_say "on is how a catch-all gets chosen instead."

hg_step "5 — Infrastructure is operator-gated (the deliberate exception)"
hg_note "A non-operator trying an infra class is refused; an operator names the custodian."
hg_goat_write machine enroll demo-mgmt-$$ --node-class MGMT-HOST --custodian "${HG_CUSTODIAN:-$(whoami)}"

hg_summary "Result" "A wire-distinguishable machine principal, custody-attributed, quota-enforced."
hg_honest live "Against a real portal with an operator profile (--for-real), this mints a real machine on the target goatnet. Retire throwaways with scenario 05 when done."

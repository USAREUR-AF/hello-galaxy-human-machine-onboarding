#!/usr/bin/env bash
# Onboard a human — the delegated three-stage flow.
set -uo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/onboarding.sh"
hg_parse_env "$@"
HANDLE="${HG_ARGS[0]:-demo-analyst-$$}"

hg_banner "Onboard a human — three delegated stages" \
          "Two human gates, because a stranger must be proved before they get an identity."
hg_preflight || exit 1

hg_step "1 — Invite (a sponsor mints a one-time link, pre-binding the grant)"
hg_note "The invite pre-binds tier, affiliation, site, and the machine quota that"
hg_note "authorizes this person's machines later (scenario 02)."
hg_goat_write admin invite --tier developer --affiliation acme --machine-quota 5

hg_step "2 — Submit (the candidate fills the public one-time link → an inert proposal)"
hg_note "Public front desk (intake.<zone>); the candidate can NEVER self-escalate their tier."

hg_step "3 — Vouch, then approve (two different humans)"
hg_goat_write admin queue approve "$HANDLE"

hg_step "4 — Mint (the runner writes the identity across every plane)"
hg_note "Produces a NetBird setup key, a Zenoh slot+cert+api_key, an Ory login, and the .cbor bundle."
hg_goat_write admin onboard "$HANDLE"

hg_summary "Result" "The person now exists across every plane — and carries a machine quota. That quota is the hinge to scenario 02."
hg_honest represented "The full three-stage flow needs the portal + a sponsor + an admin; here the stages are shown as the real commands each actor runs. See docs/honesty-matrix.md."

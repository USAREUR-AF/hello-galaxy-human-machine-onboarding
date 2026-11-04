#!/usr/bin/env bash
# Onboard a human — the delegated three-stage flow.
set -uo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/onboarding.sh"
hg_parse_env "$@"
GOATNET="${HG_ARGS[0]:-${HG_CTX%-op}}"

hg_banner "Onboard a human — three delegated stages" \
          "Two human gates, because a stranger must be proved before they get an identity."
hg_preflight || exit 1

hg_step "1 — Invite (a sponsor mints a one-time link, pre-binding the grant)"
hg_note "The invite pre-binds tier, affiliation, site, and the machine quota that"
hg_note "authorizes this person's machines later (scenario 02)."
hg_note "--affiliation <org> also pre-binds the organisation; it must already be registered on $GOATNET."
OUT="$(mktemp)"
hg_goat_write admin invite --env "$GOATNET" --tier developer --machine-quota 5 --note "hello-galaxy demo invite" | tee "$OUT"
INV="$(grep -o 'inv-[0-9a-f]*' "$OUT" | head -n1 || true)"
rm -f "$OUT"

hg_step "2 — Submit (the candidate fills the public one-time link → an inert proposal)"
hg_note "Public front desk (intake.<zone>); the candidate can NEVER self-escalate their tier."

hg_step "3 — Vouch, then approve (two different humans)"
hg_note "These act on the candidate's proposal (prop-…), which exists only once a real person submits the link."
hg_cmd "goat --context $HG_CTX admin queue ls --status proposed"
hg_cmd "goat --context $HG_CTX admin queue sponsor-approve <prop-id>    # the sponsor"
hg_cmd "goat --context $HG_CTX admin queue approve <prop-id>            # a different admin"

hg_step "4 — Mint (the runner writes the identity across every plane)"
hg_note "No command: the admin's approval hands the proposal to the runner, which produces"
hg_note "a NetBird setup key, a Zenoh slot+cert+api_key, an Ory login, and the .cbor bundle."

if [ "$HG_FORREAL" = "1" ]; then
  hg_step "5 — Clean up the demo invite"
  if [ -n "${INV:-}" ]; then
    hg_goat_write admin invites revoke "$INV"
  else
    hg_warn "could not find the demo invite to revoke; list it with: goat admin invites ls"
  fi
fi

hg_summary "Result" "The person now exists across every plane — and carries a machine quota. That quota is the hinge to scenario 02."
hg_honest represented "The full three-stage flow needs the portal + a sponsor + an admin; here the stages are shown as the real commands each actor runs. See docs/honesty-matrix.md."

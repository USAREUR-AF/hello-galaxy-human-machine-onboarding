#!/usr/bin/env bash
# See the custody — read the edge back, live.
set -uo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/onboarding.sh"
hg_parse_env "$@"

hg_banner "See the custody edge — three views, all live" \
          "Read-only: onboarding recorded who enrolled what; here is that edge, from three angles."
hg_preflight || exit 1

hg_step "1 — The fleet / your machines (goat machine ls)"
hg_cmd "goat --context $HG_CTX machine ls"
hg_goat machine ls || hg_warn "no live output (portal unreachable or nothing enrolled yet)"

hg_step "2 — An identity's custodied machines (goat access who)"
hg_cmd "goat --context $HG_CTX access who me"
hg_goat access who me || hg_warn "no live output (portal unreachable)"

hg_step "3 — The full-screen identity browser (goat who)"
hg_note "goat who is an interactive TUI — the detail pane shows a CUSTODY section for"
hg_note "the selected identity. Launch it yourself:"
hg_cmd "goat --context $HG_CTX who"

hg_summary "Result" "The person→system custody edge, minted at onboarding, read back live from three surfaces."
hg_honest live "These are read-only queries against the goatnet's portal; no mint, no mutation."

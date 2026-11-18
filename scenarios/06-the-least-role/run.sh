#!/usr/bin/env bash
# The least role — a machine's key does the machine's work; nobody's role grows.
set -uo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/onboarding.sh"
hg_parse_env "$@"
MCTX="${HG_ARGS[0]:-demo-sensor}"
MANCHOR="${HG_ARGS[1]:-<machine-anchor>}"

hg_banner "The least role — register a machine's topic with the machine's own key" \
          "More than a developer and less than an admin is usually not a new role. It is the right key."
hg_preflight || exit 1

hg_step "1 — What you hold (read-only)"
hg_goat access who me || hg_warn "no live output (portal unreachable)"
hg_note "Roles combine. Data viewing (data.view.*) is granted beside any of them and never writes."

hg_step "2 — The machine from scenario 02 has its OWN slot and portal key"
hg_say "Its enrollment download carries a .cbor profile bundle. Make it a second context:"
hg_cmd "goat profile init <machine .cbor> --context $MCTX"
hg_honest represented "the .cbor comes from your own enrollment download; this repo never handles one"

hg_step "3 — Register the machine's topic FROM the machine's context"
hg_cmd "goat --context $MCTX topic create $MANCHOR/demo/v1 --format json --description \"demo feed\""
if [ "$HG_FORREAL" = "1" ] && [ "$HG_OFFLINE" = "0" ] && [ "$MANCHOR" != "<machine-anchor>" ]; then
  goat --context "$MCTX" topic create "$MANCHOR/demo/v1" --format json --description "demo feed"
else
  hg_honest needs-operator "shown, not run — pass --for-real <machine-context> <machine-anchor> to run it"
fi
hg_say "The portal accepts a create under a slot from that slot's own key, or from an operator key."

hg_step "4 — The same create from YOUR context is refused, by design"
hg_cmd "goat --context $HG_CTX topic create $MANCHOR/demo/v1 --format json"
hg_say "→ 403  vendor scope mismatch"
hg_say "Your sign-in does not carry write authority over the machine's slot, whatever your role."
hg_say "The audit names the machine as the actor, and nobody's role grew to cover it."

hg_step "5 — What not to reach for"
hg_say "  operator key     the whole goatnet's administration, both planes; no narrower variant"
hg_say "  platform admin   deploys and network changes; each holder widens what one stolen laptop can do"
hg_say "  org data lead    data.govern.org:<org> — the right answer only when several of an org's"
hg_say "                   publishers must share ONE topic, and only inside that org"

hg_summary "Result" "A machine's topic, registered with the machine's key; every role unchanged."
hg_honest live "With --for-real and a machine context, step 3 creates a real topic; step 4's refusal is the portal's own scope check."

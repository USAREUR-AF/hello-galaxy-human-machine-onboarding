#!/usr/bin/env bash
# Orient — two ceremonies, one grammar.
set -uo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/onboarding.sh"
hg_parse_env "$@"

hg_banner "Two onboarding ceremonies, one identity grammar" \
          "A person is a stranger to prove (two gates). A machine is a vetted person's property (their quota is the proof)."
hg_preflight || true

hg_step "The two flows at a glance"
printf '  %-22s %-28s %s\n' "" "PERSON" "MACHINE"
printf '  %-22s %-28s %s\n' "who triggers" "a sponsor invites" "a custodian enrolls their own"
printf '  %-22s %-28s %s\n' "human gates" "two (vouch + approve)" "zero (quota is pre-auth)"
printf '  %-22s %-28s %s\n' "identity planes" "NetBird+Zenoh+Ory+.cbor" "NetBird+Zenoh only"
printf '  %-22s %-28s %s\n' "provenance" "invited_by sponsor" "enrolled_by custody edge"

hg_step "The scenarios"
hg_say "01-onboard-a-human        the delegated three-stage flow"
hg_say "02-onboard-a-machine      custodian self-service against a quota"
hg_say "03-decompose-a-platform   a PLATFORM → sensor/effector/processor workloads"
hg_say "04-see-the-custody        read the custody edge back, live"
hg_say "05-retire-a-machine       the exit: mesh first, quota back, record intact"

hg_summary "Next" "bin/hg-onboard 01-onboard-a-human"

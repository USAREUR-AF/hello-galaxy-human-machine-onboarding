#!/usr/bin/env bash
# Decompose a platform — one asset, many workloads.
set -uo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/onboarding.sh"
hg_parse_env "$@"
HANDLE="${HG_ARGS[0]:-demo-uas-$$}"

hg_banner "Decompose a platform into workloads" \
          "A ground segment cues an effector AND arbitrates between effector inputs — one asset, one quota unit, several workload identities."
hg_preflight || exit 1

hg_step "1 — Enroll the PLATFORM, declaring its composition"
hg_note "Workloads are FUNCTION classes. The worked example: one ground-segment box that"
hg_note "both cues and arbitrates — EFFECTOR-CUE + EFFECTOR-ARBITER, both groups."
hg_goat_write machine enroll "$HANDLE" --node-class PLATFORM --autonomy supervised \
  --workloads effector-cue,effector-arbiter \
  ${HG_CUSTODIAN:+--custodian "$HG_CUSTODIAN"}

hg_step "2 — A PLATFORM has no reach of its own"
hg_say "It is a COMPOSITION, so its mesh groups are the UNION of its declared"
hg_say "workloads — which is what NetBird membership already does. A PLATFORM with"
hg_say "no --workloads is REFUSED rather than defaulted: a composition that declares"
hg_say "nothing composes nothing, and guessing there is how gear ends up uncovered."

hg_step "3 — One quota unit"
hg_say "The PLATFORM cost ONE quota unit — its workloads are internal composition,"
hg_say "not three separate machine enrollments. One physical asset, one slot."

hg_step "4 — The portal records; SPIRE owns the SVIDs"
hg_say "The declared composition is stored on the machine (born-as). A generator"
hg_say "turns it into SPIRE registration entries (in goatcore):"
hg_cmd "ops/identity/gen-platform-spire-entries.py --env $HG_CTX"
hg_say "Each workload SVID's CN is the platform's slot anchor (compose-by-CN); its"
hg_say "spiffe_id <platform>/<function> is the SPIFFE attribution. The one deploy-time"
hg_say "piece is each workload's runtime selector (a docker label)."

hg_summary "Result" "A platform whose effector-cue/effector-arbiter functions are separately attested workloads under one asset, holding the union of their derived groups."
hg_honest represented "SPIRE entry registration is a deploy-side step (needs the platform's runtime selectors); the generator + declaration are live."

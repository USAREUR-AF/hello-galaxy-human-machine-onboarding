#!/usr/bin/env bash
# lib/onboarding.sh — shared harness for the human & machine onboarding scenarios.
#
# The scenarios narrate the two onboarding ceremonies. Three modes:
#   offline (--offline, or automatic when `goat` is not on PATH): every command
#     is shown and nothing runs — the walkthrough needs no goatnet.
#   default: READ steps run against your goat context (the active one, or
#     --env <ctx>) and print live output; WRITE steps are SHOWN only.
#   --for-real: WRITE steps (which mint real identities) are executed too, with
#     throwaway handles you can revoke (scenario 05).
# Nothing is ever faked — see docs/honesty-matrix.md.

set -uo pipefail

# --- colors (honest: off when not a tty / NO_COLOR) --------------------------
if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
  HG_BOLD=$'\033[1m'; HG_DIM=$'\033[2m'; HG_GRN=$'\033[32m'; HG_YEL=$'\033[33m'
  HG_RED=$'\033[31m'; HG_CYN=$'\033[36m'; HG_RST=$'\033[0m'
else
  HG_BOLD=; HG_DIM=; HG_GRN=; HG_YEL=; HG_RED=; HG_CYN=; HG_RST=
fi

# --- env parsing -------------------------------------------------------------
# Sets HG_CTX (the goat context: --env, else $GOAT_CONTEXT, else current_context
# in the goat config, else "default"), HG_FORREAL (0/1) and HG_OFFLINE (0/1).
# Leaves the remaining args in HG_ARGS.
hg_active_context() {
  if [ -n "${GOAT_CONTEXT:-}" ]; then echo "$GOAT_CONTEXT"; return; fi
  local cfg="${GOAT_PROFILE_DIR:-$HOME/.goat}/config.toml" cur=""
  [ -f "$cfg" ] && cur="$(sed -n 's/^current_context *= *"\(.*\)"/\1/p' "$cfg" | head -n1)"
  echo "${cur:-default}"
}
hg_parse_env() {
  HG_CTX="$(hg_active_context)"
  HG_FORREAL=0
  HG_OFFLINE="${HG_OFFLINE:-0}"
  HG_ARGS=()
  while [ $# -gt 0 ]; do
    case "$1" in
      --env) HG_CTX="${2:?--env needs a value}"; shift 2 ;;
      --for-real) HG_FORREAL=1; shift ;;
      --offline) HG_OFFLINE=1; shift ;;
      *) HG_ARGS+=("$1"); shift ;;
    esac
  done
  if [ "$HG_OFFLINE" = "0" ] && ! command -v goat >/dev/null 2>&1; then
    HG_OFFLINE=1
    HG_OFFLINE_WHY="the goat CLI is not on PATH"
  fi
}

# --- narration ---------------------------------------------------------------
hg_banner() {
  printf '\n%s%s%s\n' "$HG_BOLD" "$1" "$HG_RST"
  [ -n "${2:-}" ] && printf '%s%s%s\n' "$HG_DIM" "$2" "$HG_RST"
  printf '%s─────────────────────────────────────────────────────────────%s\n' "$HG_DIM" "$HG_RST"
}
hg_step() { printf '\n%s▸ %s%s\n' "$HG_BOLD" "$1" "$HG_RST"; }
hg_say()  { printf '  %s\n' "$1"; }
hg_note() { printf '  %s%s%s\n' "$HG_DIM" "$1" "$HG_RST"; }
hg_cmd()  { printf '  %s$ %s%s\n' "$HG_CYN" "$1" "$HG_RST"; }
hg_ok()   { printf '  %s✓ %s%s\n' "$HG_GRN" "$1" "$HG_RST"; }
hg_warn() { printf '  %s! %s%s\n' "$HG_YEL" "$1" "$HG_RST"; }
hg_fail() { printf '  %s✗ %s%s\n' "$HG_RED" "$1" "$HG_RST"; }
# hg_honest <grade> <text> — grade ∈ live|represented|needs-operator|needs-goatnet
hg_honest() {
  case "$1" in
    live)           printf '  %s[live]%s %s\n' "$HG_GRN" "$HG_RST" "$2" ;;
    represented)    printf '  %s[represented]%s %s\n' "$HG_YEL" "$HG_RST" "$2" ;;
    needs-operator) printf '  %s[needs-operator]%s %s\n' "$HG_YEL" "$HG_RST" "$2" ;;
    needs-goatnet)  printf '  %s[needs-goatnet]%s %s\n' "$HG_YEL" "$HG_RST" "$2" ;;
    *)              printf '  [%s] %s\n' "$1" "$2" ;;
  esac
}

# --- goat wrappers -----------------------------------------------------------
# A read command against the chosen context — run live, output shown. Offline,
# it is shown and not run.
hg_goat() {
  if [ "$HG_OFFLINE" = "1" ]; then
    hg_cmd "goat --context $HG_CTX $*"
    hg_honest needs-goatnet "shown, not run (offline) — needs the goat CLI and a goatnet"
    return 0
  fi
  goat --context "$HG_CTX" "$@"
}

# A mutating command. SHOWN by default; executed only with --for-real. Always
# honest about which happened.
hg_goat_write() {
  hg_cmd "goat --context $HG_CTX $*"
  if [ "$HG_OFFLINE" = "1" ]; then
    hg_honest needs-goatnet "shown, not run (offline)"
    return 0
  fi
  if [ "$HG_FORREAL" = "1" ]; then
    hg_note "(--for-real: executing against $HG_CTX)"
    goat --context "$HG_CTX" "$@"
  else
    hg_honest needs-operator "shown, not run — pass --for-real (with an operator profile) to mint for real"
    return 0
  fi
}

# --- preflight ---------------------------------------------------------------
# Confirms `goat` exists and the context resolves. READ scenarios need only a
# reachable portal; WRITE scenarios additionally need an operator profile, which
# they check at the point of the write (honest, not upfront-gated).
hg_preflight() {
  if [ "$HG_OFFLINE" = "1" ]; then
    if [ "$HG_FORREAL" = "1" ]; then
      hg_fail "--for-real needs the goat CLI and a goatnet; this run is offline (${HG_OFFLINE_WHY:---offline})."
      return 1
    fi
    hg_note "offline: ${HG_OFFLINE_WHY:---offline was passed}. Every command is shown; none runs."
    hg_note "To run the read steps, install goat (goatcore crates/goat-cli) and point it at a goatnet."
    return 0
  fi
  if ! goat --context "$HG_CTX" access who me >/dev/null 2>&1; then
    hg_warn "could not resolve identity in context '$HG_CTX' (portal unreachable or no profile)."
    hg_say  "Read steps will still show the commands; live output needs a reachable portal."
  fi
  return 0
}

hg_summary() {
  printf '\n%s─────────────────────────────────────────────────────────────%s\n' "$HG_DIM" "$HG_RST"
  printf '%s%s%s\n' "$HG_BOLD" "$1" "$HG_RST"
  [ -n "${2:-}" ] && printf '%s\n' "$2"
}

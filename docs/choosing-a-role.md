# Choosing a role — the narrowest one that does the job

Each role on a goatnet serves one kind of work, and roles combine: a person can hold
several, plus a separate data-viewing role. When a task is blocked, the answer is usually
a role that already exists or a machine's own key, not an administrator role.

| Role | Lets you | Right for | Not for |
|---|---|---|---|
| **Browse** | read the web surfaces | observers, leaders, reviewers | publishing; there is no data slot |
| **Developer** | publish and subscribe on your own slot, register your own topics | engineers building on the fabric | writing into another person's or machine's slot |
| **Machine custodian** | enroll your own gear; each machine gets its own slot and key ([scenario 02](../scenarios/02-onboard-a-machine)) | whoever looks after a device, sensor or pipeline | infrastructure classes, which administrators enroll |
| **Data viewing** `data.view.*` | read one producer's, one org's or all data | analysts and integrators | writing anything |
| **Org data lead** `data.govern.org:<org>` | create the org's shared topics that several of its publishers write to | one data lead per org | anything outside the org, or another principal's own slot |
| **Identity administrator** `IAM-ADMIN` | onboard, rotate and revoke people; sponsor up to this level; read diagnostics | team leads and security staff | deploying, network changes, data writes |
| **Network administrator** | change who can reach what, through reviewed changes | site network owners | identities and data |
| **Platform administrator** | deploy, enroll infrastructure, hold an operator key | the few people who run the goatnet | unblocking a single task |

## Three rules

1. **Name the job as verbs on things** ("publish this sensor's events", "onboard my team").
   The role follows from the verbs, not from seniority or from what someone held before.
2. **Prefer a key that belongs to the thing.** Work for a machine is done with the
   machine's key ([scenario 06](../scenarios/06-the-least-role)), so the audit names the
   machine and nobody's role grows to cover it.
3. **Combine narrow roles** rather than reaching for the next one up. Someone who onboards
   people does not need to deploy.

## The operator key is not a larger portal key

Every publisher holds a portal key scoped to their own slot. An operator key is the
whole goatnet's administration on both the portal and the identity console, and there is
no read-only or single-org variant. Only identity and platform administrators may
request one, and a different administrator approves it. Revoke it when the holder's job
no longer needs it; removing a role does not by itself remove a key.

Designs in goatcore: the tiers ([onboard-tier-role-model](https://github.com/usareur-af/goatcore/blob/main/docs/design/onboard-tier-role-model.md)),
data roles ([data-access-roles](https://github.com/usareur-af/goatcore/blob/main/docs/design/data-access-roles.md)),
operator keys ([operator-action-audit](https://github.com/usareur-af/goatcore/blob/main/docs/design/operator-action-audit.md)),
the org data lead ([ADR 1105](https://github.com/usareur-af/goatcore/blob/main/docs/adr/1105-pubsub-org-admin-co-publish-write-grants.md)).

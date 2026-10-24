# First Pre-Defense Submission Summary

## Project

Development of an information system for direct procurement of agricultural products from small-scale farms with transparent pricing.

Team: Ayanat Amangeldi and Dilyara Anetbayeva.

Supervisor: Aldiyar Salkenov.

## Implemented Prototype

The project currently provides a Flutter prototype with buyer, farmer and administrator workflows.

Buyers can browse products, compare farmer offers, inspect quantities and purchasing terms, view the price breakdown, place demonstration orders and inspect their order history.

Farmers can publish and edit offers, update prices and stock, inspect incoming orders, confirm orders, mark them ready for collection, complete them or reject them with a reason.

Administrators can block and unblock accounts, hide and restore offers, and inspect recorded moderation decisions.

The prototype records order price snapshots and dated price changes. Buyer-facing availability filtering excludes offers that cannot currently be purchased.

These workflows use local demonstration data. They do not constitute a shared production system or server implementation.

## Submission Materials

Status updated on 24 October 2026 after the three reviewed documentation PRs
were merged into `main` (merge snapshot `b1fdfb3`).

| Material | Evidence | Publication status |
| --- | --- | --- |
| English report, Sections 1–10 | [Word report](report/farm-direct-pre-defense-report.docx) | Published; original report retained. |
| Analysis, requirements and planning | [Documentation index](README.md), [proposal](project-proposal.md), [requirements](requirements-specification.md), [evaluation plan](verification-and-evaluation-plan.md), [management and risks](project-management-and-risks.md) | Published in `main`. |
| Architecture and editable diagrams/exports | [Architecture](architecture.md), [diagram index](../diagrams/README.md) | Published in `main`. |
| Prototype walkthrough and screenshots | [Prototype documentation](prototype/catalog-and-offers.md); report Section 8 | Published; screenshots document scenarios rather than completed user evaluation. |
| Interview dates, phone-call format and guide | [Evidence](evidence-of-relevance.md), [guide](research/interview-guide.md), [merged PR #9](https://github.com/ayanat-amangeldi/farm-direct-procurement/pull/9) | Published in `main`, merge `7eb5a0f`. |
| Supervisor feedback and migration plan | [Feedback/response](reviews/supervisor-feedback.md), [supplied-text transcript](reviews/sources/supervisor-feedback-2026-10-24.txt), [migration plan](backend-migration-plan.md), [merged PR #10](https://github.com/ayanat-amangeldi/farm-direct-procurement/pull/10) | Published in `main`, merge `39817b2`. |
| Submission checklist and summary | [Checklist](submission-checklist.md), [merged PR #11](https://github.com/ayanat-amangeldi/farm-direct-procurement/pull/11) | Published in `main`, merge `b1fdfb3`; statuses refreshed after merging. |

The preserved Word report contains Sections 1–10. The interview session metadata
and Section 11 are repository supplements. If the submission channel requires a
single Word file, integrating these supplements remains a separate formatting
step before that upload; it has not been performed in this update.

## Verification Evidence

### Previously recorded implementation checks

- The [documentation index](README.md) records 66 passing Flutter tests and clean
  analysis at `4f60cbb`, merged through [PR #6](https://github.com/ayanat-amangeldi/farm-direct-procurement/pull/6).
- The [prototype walkthrough](prototype/catalog-and-offers.md) records manual
  browser checks covering buyer, farmer and administrator scenarios, order
  lifecycle, persistence, moderation and price history.
- The root [README](../README.md) records earlier web-release and iOS Simulator
  builds. These builds were not rerun for the catalog-availability correction.
- The [evaluation plan](verification-and-evaluation-plan.md) defines future
  measurements and acceptance targets. It is a completed planning deliverable;
  execution of the complete platform/accessibility matrix and representative-user
  evaluation remains future work.

### Documentation preparation and peer review

Dilyara prepared the FARM-19 checklist and summary in PR #11 from her GitHub
account, with identifiable commits. Her preparation record included inspection
of Word section headings, local-link checks, a clean diff check and anonymous
GitHub repository access. YouTrack was unavailable in her initial viewer; later
access checks are recorded separately below.

Dilyara approved PR #9 at `f8149f5` and re-approved PR #10 at `bdb767b` after
reading the authenticated FARM-18 record and comparing the feedback transcript.
Ayanat [approved PR #11 at `c5c2f93`](https://github.com/ayanat-amangeldi/farm-direct-procurement/pull/11#pullrequestreview-5637288125)
after reviewing the full diff, resolving all 76 local links checked and verifying
that the Word report and application code were unchanged. Before merging,
index-conflict reconciliation retained both sets of already approved additions.
This status refresh does not claim an additional peer approval of its own.

On 24 October 2026, anonymous API requests without cookies or Authorization
headers returned HTTP 200 with descriptions and comments for FARM-19, FARM-11
and FARM-18. The [FARM-19 access record](https://farm-direct-procurement.youtrack.cloud/issue/FARM-19)
also records the scoped public-reader setup and earlier anonymous checks. These
read checks establish task-reading access; they do not test write restrictions
or the committee's own devices.

No Flutter tests, simulator checks, diagram exports or user-evaluation sessions
were run for these documentation/status changes. Historical missing pre-merge
reviews on early PRs remain a documented process limitation.

## Current Limitations

The prototype stores demonstration data locally on the device. It does not yet
provide a shared production backend or synchronisation between independent
devices. FastAPI, PostgreSQL and REST remain the proposed backend baseline.

Demonstration order placement does not process real payments. Screenshots and
needs interviews do not establish completed prototype usability evaluation.
Remaining implementation/evaluation checks are tracked in the evaluation plan.

## Supervisor Feedback and Next Steps

The [feedback record](reviews/supervisor-feedback.md) contains the supplied
feedback from Aldiyar Salkenov dated 24 October 2026, its provenance, and the
team's response. Dilyara compared the transcript with the team-posted FARM-18
record; this is not independent authentication of a separate signed document.

The next meeting is scheduled for 27 October 2026. The supervisor recommended a
dated migration plan covering migration order, API contracts and what stays
local. The [published migration plan](backend-migration-plan.md) addresses this
recommendation. Its dates are proposed targets for discussion rather than
approved deadlines or completed implementation. FARM-4 and FARM-10 retain the
schema/API/pricing-contract follow-up work.

## Remaining Finalisation and Next-Stage Work

- FARM-11 and FARM-18 are complete after their peer-reviewed PRs were merged.
- FARM-19 remains in Review for final snapshot confirmation and the
  `pre-defense-1` tag. The tag has not been created; existing tags are unchanged.
- If a single Word file is required, integrate the repository supplements before
  that upload and verify the resulting formatting separately.
- Prepare the schema/API drafts and migration discussion for 27 October under
  FARM-4/FARM-10, then implement and evaluate the shared system in the next phase.
- Execute remaining platform/accessibility and representative-user checks under
  the evaluation plan. Their pending execution does not mean the plan is absent.

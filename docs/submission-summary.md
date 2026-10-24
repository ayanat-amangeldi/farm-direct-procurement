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

| Material | Evidence | Status on `main` at `d931496` |
| --- | --- | --- |
| English report, Sections 1–10 | [Word report](report/farm-direct-pre-defense-report.docx) | Available in `main`; original report retained. |
| Readable analysis, requirements and planning documents | [Documentation index](README.md), [proposal](project-proposal.md), [requirements](requirements-specification.md), [verification plan](verification-and-evaluation-plan.md), [management and risks](project-management-and-risks.md) | Available in `main`. |
| Architecture description and editable diagrams/exports | [Architecture description](architecture.md), [diagram index and files](../diagrams/README.md) | Available in `main`. |
| Prototype walkthrough and screenshots | [Prototype documentation](prototype/catalog-and-offers.md); report Section 8 | Available as documented artifacts. Screenshots are not user-evaluation results. |
| Interview dates, phone-call formats and interviewer guide | [PR #9 — FARM-11](https://github.com/ayanat-amangeldi/farm-direct-procurement/pull/9) | Pending — approved but still open and unmerged; not in `main`. |
| Supervisor feedback and backend migration plan | [PR #10 — FARM-18](https://github.com/ayanat-amangeldi/farm-direct-procurement/pull/10) | Pending — changes requested; still open and unmerged, not in `main`. Feedback is a separate Markdown supplement and is absent from the Word report. |
| First pre-defense checklist and this summary | [Checklist](submission-checklist.md), this document, [PR #11](https://github.com/ayanat-amangeldi/farm-direct-procurement/pull/11) | Pending — proposed in open PR #11; not yet merged into `main`. |

The supplied Word report contains Sections 1–10. The interview session metadata/guide in approved-but-unmerged PR #9 and the feedback/migration documents in PR #10 (changes requested) are repository supplements, not additions already present in that DOCX.

## Verification Evidence

### Previously recorded in the repository

- The documentation index records 66 passing Flutter tests and clean `flutter analyze` for commit `4f60cbb`, merged through [PR #6](https://github.com/ayanat-amangeldi/farm-direct-procurement/pull/6). This is prior repository evidence; those commands were not run for this documentation change.
- The [prototype walkthrough](prototype/catalog-and-offers.md) records manual browser checks for buyer, farmer and administrator flows, persistence, order lifecycle, moderation and price history. This is previously recorded evidence, not a new user study.
- The root [README](../README.md) records earlier successful web-release and iOS Simulator builds, while noting that builds were not rerun for the catalog-availability correction. It also identifies Android runtime/device checks and representative-user evaluation as outstanding.
- The [evaluation plan](verification-and-evaluation-plan.md) defines planned checks and measurements. Planned targets are not results.

### Checked while preparing this FARM-19 change

- Confirmed the authenticated GitHub account is `dilyara-anetbayeva`; repository Git author configuration is `dilyara` / `231860557+dilyara-anetbayeva@users.noreply.github.com`.
- Fetched `origin/main` and created the requested branch from commit `d931496`.
- Confirmed PR #9 and PR #10 are both open and inspected their changed-file lists and proposed materials.
- Read the repository README and documentation index and inspected the supplied Word report's document text; the report contains Sections 1–10. The feedback record is separate in the proposed PR #10 materials.
- Verified unauthenticated HTTPS repository access with `git ls-remote`; this does not verify YouTrack or committee access.
- YouTrack FARM-19 could not be opened with the available web viewer. No YouTrack issue status or committee access is claimed as verified.
- For this documentation change, local link resolution and `git diff --check` are run before publication. Flutter, simulator, diagram-export and user-evaluation commands are not run for this change.
- The Flutter SDK was not available on `PATH` in this environment; no Flutter command was run.

## Current Limitations

The prototype stores demonstration data locally on the device. It does not yet provide a shared production backend or synchronisation between independent devices.

FastAPI, PostgreSQL and REST are the proposed backend baseline. Their selection and migration plan do not constitute an implemented backend.

Demonstration order placement does not perform real payment processing.

Formal user evaluation and the complete platform test matrix remain subject to the evaluation plan and available verification evidence. Screenshots and initial interviews do not establish completed prototype usability evaluation.

## Supervisor Feedback and Next Steps

The team-supplied record in [PR #10](https://github.com/ayanat-amangeldi/farm-direct-procurement/pull/10) identifies Supervisor Aldiyar Salkenov and records feedback received on 24 October 2026. It schedules the next meeting for 27 October 2026 and recommends preparing a dated backend migration plan covering migration order, API contracts and the boundary between shared and local data.

PR #10 is still open, so the feedback and plan are not yet in `main`. The record states that the feedback is a separate Markdown supplement and is not included in the preserved Word report. Proposed migration dates are planning targets, not supervisor-approved deadlines or completed work; the 27 October meeting has not yet occurred.

## Outstanding Submission Actions

- Merge the approved interview evidence and interviewer guide in [PR #9](https://github.com/ayanat-amangeldi/farm-direct-procurement/pull/9); approval alone has not added it to `main`.
- Address the requested source-verification change in [PR #10](https://github.com/ayanat-amangeldi/farm-direct-procurement/pull/10), request another review, and merge only after approval.
- Decide separately whether to reconcile repository supplements into a formatted Word-report update; the current DOCX has Sections 1–10 only.
- Review and merge [PR #11](https://github.com/ayanat-amangeldi/farm-direct-procurement/pull/11) for this FARM-19 checklist and summary.
- Verify YouTrack and committee access through an appropriate unauthenticated/committee access method.
- Complete and record the outstanding verification and evaluation work in the evaluation plan.
- Create `pre-defense-1` only after final changes are merged and the exact reviewed commit has been checked. Do not move existing tags.

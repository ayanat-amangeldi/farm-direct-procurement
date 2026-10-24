# 11. Supervisor Feedback

[Documentation index](../README.md) · [Backend migration plan](../backend-migration-plan.md)

Tracked in [FARM-18](https://farm-direct-procurement.youtrack.cloud/issue/FARM-18).

## 11.1. Review Record

| Item | Record |
| --- | --- |
| Supervisor | Aldiyar Salkenov |
| Feedback date | 24 October 2026, confirmed by the team |
| Source | Written feedback supplied by the team for repository publication |
| Reviewed areas named in the feedback | Problem framing and objectives; interview-to-requirement traceability; three-role prototype; order lifecycle, accepted prices and price history; documentation, architecture and task tracking; current limitations |
| Next meeting | 27 October 2026, confirmed by the team |

The quotation below preserves the feedback supplied by the team.

## 11.2. Supervisor's Feedback

> Ayanat and Dilyara have made good progress since the last meeting. The problem framing and objectives are specific and verifiable, the needs analysis traces cleanly from the interviews into concrete requirements, and the prototype now covers all three user roles with the full order lifecycle, price snapshots and dated price history. Documentation, architecture diagrams and YouTrack task tracking are all in good order, and the team states the current limitations openly rather than glossing over them.
>
> One recommendation: the backend is now the critical path. Everything still runs on device-local storage, and FastAPI/PostgreSQL remain a recommendation on paper, so the team should bring a dated migration plan to the next meeting — what moves first, the API contract, and what stays local.
>
> — Aldiyar Salkenov, Supervisor

## 11.3. Team Response and Actions

| ID | Feedback | Team decision and action | Responsible students | Evidence and status |
| --- | --- | --- | --- | --- |
| SF-01 | Positive assessment of framing, needs analysis, prototype coverage, documentation and transparent limitations. | Retain the reviewed scope and the distinction between the local prototype and the intended shared system. Continue requirement-based verification when integrating the backend. | Both students | Existing [requirements](../requirements-specification.md), [architecture](../architecture.md) and [prototype walkthrough](../prototype/catalog-and-offers.md). No new implementation is claimed by recording this assessment. |
| SF-02 | Backend migration is the critical path; bring a dated plan describing migration order, API contract and remaining local responsibilities. | Prepare a dated migration plan for 27 October. Draft the schema and API contract first, then integrate identity/catalog, transactional order/pricing rules and the remaining role workflows. Keep interface state and a separate fictional demo mode local. | Ayanat: backend/schema/pricing; Dilyara: Flutter API integration and scenario review; both: contract agreement and verification | [Migration plan](../backend-migration-plan.md) drafted on 24 October. Contract work: [FARM-4](https://farm-direct-procurement.youtrack.cloud/issue/FARM-4), [FARM-10](https://farm-direct-procurement.youtrack.cloud/issue/FARM-10). Proposed dates and scope await joint review and discussion on 27 October. |

## 11.4. Follow-up and Closure

For the meeting on 27 October, bring the migration plan and the available draft
schema/API examples. Record the supervisor's decisions, changed dates and any
new actions after the meeting. The scheduled meeting has not yet occurred.

FARM-18 remains in Review until the other team member reviews this record and
the response is merged. Implementation and acceptance of the shared backend
remain separate work; recording a plan does not complete FARM-4, FARM-10 or
server-side requirements. Any additional recommendations from the next meeting
will be recorded as follow-up actions.

This is a repository supplement to the previously supplied Word report. The
preserved report has not been edited to insert this section.

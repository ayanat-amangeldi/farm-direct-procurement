# Project Documentation

This directory contains the English analysis and planning report for the first
pre-defense of the Farm Direct Procurement System. The report defines the
proposed shared system and distinguishes it from the implemented local Flutter
prototype.

[Download the complete Word report](report/farm-direct-pre-defense-report.docx).
The supplied report is preserved without changes, including its tables,
references, architecture figures and mobile/web prototype screenshots.

For submission readiness, see the [first pre-defense checklist](submission-checklist.md)
and [submission summary](submission-summary.md). The
[pre-defense-1 verification record](reviews/pre-defense-1-verification.md)
records the final checks and version boundary. The documents distinguish
published first-stage materials from next-stage implementation and evaluation.

The [finalisation post-merge review record](reviews/finalization-post-merge-review.md)
identifies two subsequent direct updates to `main` and the retrospective review
requested for them. It supplements the frozen submission without moving its tag.

## Report Sections

| Report section | Readable repository version | Contents |
| --- | --- | --- |
| 1. Project proposal | [Proposal and scope](project-proposal.md) | Problem, intended users, objectives, responsibilities, scope and expected outcomes. |
| 2. Evidence of relevance | [Interview findings](evidence-of-relevance.md); [interview guide](research/interview-guide.md) | Four reported phone interviews on 23 October 2026, requirement implications and limitations. |
| 3. Literature review | [Literature review](literature-review.md) | Critical synthesis, a structured analysis table and 12 references, including 10 journal articles. |
| 4. Existing system comparison | [System comparison](existing-system-comparison.md) | Open Food Network, Local Food Marketplace, Local Line and Barn2Door against nine criteria. |
| 5. Technology comparison | [Technology comparison](technology-comparison.md) | Client, server, database and communication alternatives, with decisions and trade-offs. |
| 6. Requirements specification | [Requirements and acceptance criteria](requirements-specification.md) | Business rules, 18 functional requirements, nine non-functional requirements and implementation boundaries. |
| 7. Architecture and diagrams | [Architecture description](architecture.md); [editable source and exports](../diagrams/README.md) | Context, use case and draft component diagrams, a three-page `.drawio` source, SVG/PNG exports and requirements-to-component mapping. |
| 8. UX / prototype | Complete Word report, Section 8; [repository walkthrough](prototype/catalog-and-offers.md) | Buyer, farmer and administrator scenarios, with iPhone Simulator and desktop web screenshots. |
| 9. Verification and evaluation plan | [Verification plan](verification-and-evaluation-plan.md) | Test strategy, environments, metrics, a manual-comparison baseline and a proposed participant evaluation. |
| 10. Project management and risks | [Management and risk register](project-management-and-risks.md) | Team ownership, workflow, six milestones, nine risks and dependencies. |
| 11. Supervisor feedback | [Feedback and responses](reviews/supervisor-feedback.md); [backend migration plan](backend-migration-plan.md) | Feedback dated 24 October 2026, the team's response, and proposed migration targets for the meeting on 27 October. |

The Markdown files reproduce the selected report sections for review on GitHub.
Section 11 and the migration plan were added after the supplied Word report was
published; the preserved DOCX still contains Sections 1–10.
The relevance section additionally records interview dates and format supplied
by the team after report publication and links the five-question interview guide.
Headings, lists, tables and hyperlinks are converted to Markdown; the complete
Word report retains the original layout and figures. Section numbers are retained
so references to other report sections can be followed in the complete report.

## Team Contribution and Section Coordination

The report was prepared jointly by **Ayanat Amangeldi** and **Dilyara Anetbayeva**,
as confirmed by the team. The following section coordination follows the existing
YouTrack assignments. The named student coordinates the corresponding task;
requirements discussions, integration of the report and review are shared
activities.

| Report section | Coordinating student | YouTrack task |
| --- | --- | --- |
| 1. Project proposal and scope | Ayanat Amangeldi | [FARM-7](https://farm-direct-procurement.youtrack.cloud/issue/FARM-7) |
| 2. Evidence of relevance | Dilyara Anetbayeva | [FARM-11](https://farm-direct-procurement.youtrack.cloud/issue/FARM-11) |
| 3. Literature review | Ayanat Amangeldi | [FARM-12](https://farm-direct-procurement.youtrack.cloud/issue/FARM-12) |
| 4. Existing system comparison | Dilyara Anetbayeva | [FARM-13](https://farm-direct-procurement.youtrack.cloud/issue/FARM-13) |
| 5. Technology comparison | Ayanat Amangeldi | [FARM-14](https://farm-direct-procurement.youtrack.cloud/issue/FARM-14) |
| 6. Requirements specification | Ayanat Amangeldi | [FARM-15](https://farm-direct-procurement.youtrack.cloud/issue/FARM-15) |
| 7. Architecture and diagrams | Ayanat Amangeldi | [FARM-16](https://farm-direct-procurement.youtrack.cloud/issue/FARM-16) |
| 8. UX / prototype | Dilyara Anetbayeva | [FARM-8](https://farm-direct-procurement.youtrack.cloud/issue/FARM-8), [FARM-9](https://farm-direct-procurement.youtrack.cloud/issue/FARM-9) |
| 9. Verification and evaluation plan | Dilyara Anetbayeva | [FARM-17](https://farm-direct-procurement.youtrack.cloud/issue/FARM-17) |
| 10. Project management and risks | Ayanat Amangeldi and Dilyara Anetbayeva | Shared planning; submission coordination in [FARM-19](https://farm-direct-procurement.youtrack.cloud/issue/FARM-19) |

**Repository publication:** Ayanat coordinates copying the supplied report,
converting the readable sections, validating links and publishing this
documentation through [FARM-21](https://farm-direct-procurement.youtrack.cloud/issue/FARM-21).
The publication commit records that repository operation. The other team member's
review of the publication PR is recorded separately when submitted. Task
completion remains subject to each task's acceptance criteria.

## Evidence and Current Status

- The relevance section records reported experiences from two farmers and two
  buyers. It is qualitative needs evidence, not a completed prototype usability
  evaluation. The team confirmed that F1, F2, B1 and B2 were interviewed by phone
  on 23 October 2026; this metadata is recorded in the relevance section and guide.
- Flutter workflows use fictional, device-local data. FastAPI, PostgreSQL and a
  REST-style JSON API are the proposed shared-system baseline and are not yet
  connected to the prototype.
- Acceptance targets and planned measurements in Sections 6 and 9 are not
  reported evaluation results. Final verification on 24 October 2026 reran
  all 66 Flutter tests and analysis successfully. The application tree is unchanged
  from `4f60cbb`, merged through [PR #6](https://github.com/ayanat-amangeldi/farm-direct-procurement/pull/6);
  see the [version verification record](reviews/pre-defense-1-verification.md).
- **Supervisor feedback dated 24 October 2026 is recorded** in the
  [feedback and response record](reviews/supervisor-feedback.md), tracked in
  [FARM-18](https://farm-direct-procurement.youtrack.cloud/issue/FARM-18).
  The supervisor identified backend migration as the critical path. The team has
  drafted a dated plan for the meeting on 27 October; proposed dates and API
  details still require review. The feedback does not approve an implemented
  backend or report completed shared-system verification.

## Publication and Traceability

Repository publication is tracked in
[FARM-21](https://farm-direct-procurement.youtrack.cloud/issue/FARM-21).
The [YouTrack project](https://farm-direct-procurement.youtrack.cloud/projects/FARM)
tracks analysis, implementation, review and remaining submission work. Publication
of these documents does not by itself complete every related task or the final
submission checklist.

The complete report is 10,894,873 bytes. Its SHA-256 is:

```text
7ea0130b430cab705a63d277e504265b3c1a562eb742df8cf89a588a8e4175a3
```

The same hash was verified against the supplied final DOCX before publication.
The [`pre-defense-1` tag](https://github.com/ayanat-amangeldi/farm-direct-procurement/tree/pre-defense-1)
identifies the first-stage version verified on 24 October 2026. Resolve the tag
for the exact commit; its scope and remaining work are recorded in the
[verification record](reviews/pre-defense-1-verification.md). Existing tags remain fixed.

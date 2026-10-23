# Project Documentation

This directory contains the English analysis and planning report for the first
pre-defense of the Farm Direct Procurement System. The report defines the
proposed shared system and distinguishes it from the implemented local Flutter
prototype.

[Download the complete Word report](report/farm-direct-pre-defense-report.docx).
The supplied report is preserved without changes, including its tables,
references, architecture figures and mobile/web prototype screenshots.

## Report Sections

| Report section | Readable repository version | Contents |
| --- | --- | --- |
| 1. Project proposal | [Proposal and scope](project-proposal.md) | Problem, intended users, objectives, responsibilities, scope and expected outcomes. |
| 2. Evidence of relevance | [Interview findings](evidence-of-relevance.md) | Four reported interviews, requirement implications and limitations. |
| 3. Literature review | [Literature review](literature-review.md) | Critical synthesis, a structured analysis table and 12 references, including 10 journal articles. |
| 4. Existing system comparison | [System comparison](existing-system-comparison.md) | Open Food Network, Local Food Marketplace, Local Line and Barn2Door against nine criteria. |
| 5. Technology comparison | [Technology comparison](technology-comparison.md) | Client, server, database and communication alternatives, with decisions and trade-offs. |
| 6. Requirements specification | [Requirements and acceptance criteria](requirements-specification.md) | Business rules, 18 functional requirements, nine non-functional requirements and implementation boundaries. |
| 7. Architecture and diagrams | Complete Word report, Section 7 | Architectural description, context, use case and draft component diagrams. Separate editable diagram sources remain to be published. |
| 8. UX / prototype | Complete Word report, Section 8; [repository walkthrough](prototype/catalog-and-offers.md) | Buyer, farmer and administrator scenarios, with iPhone Simulator and desktop web screenshots. |
| 9. Verification and evaluation plan | [Verification plan](verification-and-evaluation-plan.md) | Test strategy, environments, metrics, a manual-comparison baseline and a proposed participant evaluation. |
| 10. Project management and risks | [Management and risk register](project-management-and-risks.md) | Team ownership, workflow, six milestones, nine risks and dependencies. |

The Markdown files reproduce the selected report sections for review on GitHub.
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
  evaluation. Interview dates and formats still need to be recorded in the
  research evidence; none have been invented for this publication.
- Flutter workflows use fictional, device-local data. FastAPI, PostgreSQL and a
  REST-style JSON API are the proposed shared-system baseline and are not yet
  connected to the prototype.
- Acceptance targets and planned measurements in Sections 6 and 9 are not
  reported evaluation results. The latest local implementation check recorded
  66 passing Flutter tests and clean analysis for commit `4f60cbb`, merged through
  [PR #6](https://github.com/ayanat-amangeldi/farm-direct-procurement/pull/6).
- **Supervisor feedback is pending** and will be added after the supervisor has
  reviewed the materials. No supervisor approval is claimed by this report
  publication. Feedback and responses are tracked in
  [FARM-18](https://farm-direct-procurement.youtrack.cloud/issue/FARM-18).

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
The `pre-defense-1` tag will identify the reviewed submission once the remaining
submission items are ready; this documentation change does not create that tag.

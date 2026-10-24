# First Pre-Defense Submission Checklist

This checklist records the submission materials and their verified status. An item is marked complete only when the corresponding artifact or review evidence is available. Planned implementation work is tracked separately from the first pre-defense deliverables.

Updated on 24 October 2026 after PR #9, PR #10 and PR #11 were merged into `main` (merge snapshot `b1fdfb3`). This refresh records those completed merges and the remaining final-version step; it does not create a submission tag.

| Item | Evidence | Status | Remaining action |
| --- | --- | --- | --- |
| Project proposal and scope | [Project proposal](project-proposal.md); [Word report, Section 1](report/farm-direct-pre-defense-report.docx) | Complete — proposal and scope are available in the repository and report. | None for this deliverable. |
| Evidence of relevance and interview records | [Evidence of relevance](evidence-of-relevance.md); [interview guide and session record](research/interview-guide.md); [merged PR #9](https://github.com/ayanat-amangeldi/farm-direct-procurement/pull/9) | Complete — the four anonymised phone interviews dated 23 October 2026, findings, limitations and five-question guides are in `main`. | Further user evaluation is separate from the completed needs interviews. |
| Literature review and publication analysis | [Literature review](literature-review.md); [Word report, Section 3](report/farm-direct-pre-defense-report.docx) | Complete — synthesis, analysis table and references are present. | None for this deliverable. |
| Existing system comparison | [Existing system comparison](existing-system-comparison.md); [Word report, Section 4](report/farm-direct-pre-defense-report.docx) | Complete — comparison and analysis are present. | None for this deliverable. |
| Technology comparison | [Technology comparison](technology-comparison.md); [Word report, Section 5](report/farm-direct-pre-defense-report.docx) | Complete — alternatives, trade-offs and proposed baseline are documented. | Keep proposed backend technologies clearly labelled as unimplemented. |
| Functional and non-functional requirements with acceptance criteria | [Requirements specification](requirements-specification.md); [Word report, Section 6](report/farm-direct-pre-defense-report.docx) | Complete — requirements and acceptance/traceability material are present. | None for this deliverable. |
| Architecture description and editable diagrams with exports | [Architecture description](architecture.md); [diagram index, editable source and SVG/PNG exports](../diagrams/README.md); [Word report, Section 7](report/farm-direct-pre-defense-report.docx) | Complete — three-page editable source and published exports are in `main`. | None for this deliverable. |
| UX prototype and screenshots | [Prototype walkthrough and screenshots](prototype/catalog-and-offers.md); [Word report, Section 8](report/farm-direct-pre-defense-report.docx) | Complete — prototype scenarios and captures are available. Screenshots document the interface; they do not establish user-evaluation results. | Conduct and record representative-user evaluation separately. |
| Verification and evaluation plan | [Evaluation plan](verification-and-evaluation-plan.md); recorded checks in [documentation index](README.md) and [prototype walkthrough](prototype/catalog-and-offers.md) | Complete as a first-stage planning deliverable — strategy, metrics, conditions and baseline are documented. Prior repository evidence records 66 passing Flutter tests and clean analysis at `4f60cbb`. | Execute the remaining platform/accessibility checks and representative-user evaluation in the planned implementation/evaluation phase; targets are not results. |
| Responsibilities, milestones, risks and dependencies | [Management and risks](project-management-and-risks.md); [section coordination](README.md); [FARM tracker](https://farm-direct-procurement.youtrack.cloud/projects/FARM/issues) | Complete — planning materials, team allocation and follow-up tasks are documented and task records are readable. | Continue updating backend work under FARM-4/FARM-10; retain the distinction between task coordination and commit authorship. |
| Supervisor feedback and response actions | [Feedback and responses](reviews/supervisor-feedback.md); [supplied-text transcript](reviews/sources/supervisor-feedback-2026-10-24.txt); [migration plan](backend-migration-plan.md); [merged PR #10](https://github.com/ayanat-amangeldi/farm-direct-procurement/pull/10) | Complete — feedback dated 24 October 2026, its provenance and the team response are in `main`, following Dilyara's re-review and approval. | Bring the proposed plan and available schema/API drafts to the meeting on 27 October; record subsequent decisions afterwards. |
| English report and documentation index | [Word report, Sections 1–10](report/farm-direct-pre-defense-report.docx); [documentation index](README.md); [feedback supplement](reviews/supervisor-feedback.md) | Complete as a repository package — the original Word report and readable supplements are available. Interview metadata and Section 11 remain outside the preserved DOCX. | If a single Word document is required for upload, integrate the supplements in a separate formatting task before that upload. |
| Repository and YouTrack access | [Public GitHub repository](https://github.com/ayanat-amangeldi/farm-direct-procurement); [public FARM issues](https://farm-direct-procurement.youtrack.cloud/projects/FARM/issues); [access record in FARM-19](https://farm-direct-procurement.youtrack.cloud/issue/FARM-19); [PR #11 review](https://github.com/ayanat-amangeldi/farm-direct-procurement/pull/11#pullrequestreview-5637288125) | Complete for anonymous reading — repository access was checked during PR preparation; FARM-19, FARM-11 and FARM-18 returned descriptions/comments without cookies or Authorization headers during Ayanat's review on 24 October. | Share these links with the supervisor and committee. Their own devices/accounts and write-denial behaviour were not tested by these read-only requests. |
| Peer review of the final submission changes | [PR #9](https://github.com/ayanat-amangeldi/farm-direct-procurement/pull/9); [PR #10](https://github.com/ayanat-amangeldi/farm-direct-procurement/pull/10); [PR #11 and review](https://github.com/ayanat-amangeldi/farm-direct-procurement/pull/11#pullrequestreview-5637288125) | Complete for the published PR content — Dilyara approved PR #9/#10; Ayanat approved Dilyara's PR #11. All three are merged. Index conflicts were reconciled while retaining both approved additions. | Confirm the final snapshot and its status refresh before assigning the submission tag. Historical missing pre-merge reviews on early PRs remain a recorded limitation. |
| Final submission summary | [Submission summary](submission-summary.md); [merged PR #11](https://github.com/ayanat-amangeldi/farm-direct-procurement/pull/11) | Complete — summary is published in `main` and this refresh records the completed merges, verification evidence and next-stage work. | Keep it aligned with the final tagged snapshot. |
| Final submission tag | [Tagging policy](../README.md); [FARM-19](https://farm-direct-procurement.youtrack.cloud/issue/FARM-19) | Pending — `pre-defense-1` has not been created. FARM-19 remains in Review for final snapshot confirmation and tagging. | Verify the exact final commit and create the tag when the submission version is finalised. Do not move existing tags. |

## Merge and verification record

| PR | Peer approval recorded at | Merge commit in `main` |
| --- | --- | --- |
| [#9 — FARM-11](https://github.com/ayanat-amangeldi/farm-direct-procurement/pull/9) | Dilyara, `f8149f5` | `7eb5a0f` |
| [#10 — FARM-18](https://github.com/ayanat-amangeldi/farm-direct-procurement/pull/10) | Dilyara, `bdb767b` | `39817b2` |
| [#11 — FARM-19](https://github.com/ayanat-amangeldi/farm-direct-procurement/pull/11) | Ayanat, `c5c2f93` | `b1fdfb3` |

The approvals concern the recorded PR versions. Subsequent index-conflict
reconciliation retained the interview, supervisor and submission links. This
post-merge update records status changes; it does not claim an additional peer
approval of the refresh itself.

The supplied Word report is unchanged and contains Sections 1–10. Interview
metadata and Section 11 are linked repository supplements. Future backend work,
full platform verification and representative-user evaluation remain separate
from the completed first-stage plans and prototype documentation.

Anonymous reading was rechecked on 24 October 2026 without session credentials.
FARM-11 and FARM-18 are complete following their reviewed merges; FARM-19 stays
in Review until the final snapshot/tag step is satisfied. No tag is created by
this update.

# First Pre-Defense Version Verification

[Submission checklist](../submission-checklist.md) · [Submission summary](../submission-summary.md) · [FARM-19](https://farm-direct-procurement.youtrack.cloud/issue/FARM-19)

Verification date: **24 October 2026**. The submission version is
[`pre-defense-1`](https://github.com/ayanat-amangeldi/farm-direct-procurement/tree/pre-defense-1).
Resolve the annotated tag to obtain the exact final commit. Existing submission
tags must not be moved.

## Checks Executed

The application checks ran on `main` at
`41c15875a5ae026e22a31dec5e1cde3ae208564c`. The finalisation commit changes only
documentation to record the results and the version designation; application
code, dependencies, diagrams and the Word report are unchanged.

| Check | Result |
| --- | --- |
| `flutter analyze --no-pub` in `apps/mobile` | Passed: no issues found. |
| `flutter test --no-pub --reporter expanded` in `apps/mobile` | Passed: all 66 existing tests. |
| Application tree comparison with `4f60cbb` | Identical; the catalog-availability implementation and its regression tests are retained. |
| Local links in tracked Markdown documents | 186 links resolve, including the finalisation documents. |
| `git diff --check` | Passed for the final documentation changes. |
| Word report integrity | ZIP integrity and document XML are valid; original SHA-256 is unchanged. |
| Diagram files | Editable source has three pages; all three SVG files parse and all three PNG files have valid PNG signatures. No new render/export was performed. |
| PR #9, #10 and #11 | All merged into `main`; approvals and merge commits are recorded in the checklist. No open PRs at the version check. |
| Submission-tag collision check | `pre-defense-1` was absent before creation. The existing `prob-period-1` tag was retained at `68190a63cc82259c39f0887093a9d67c9b1cb158`. |
| Anonymous task reading | FARM-11, FARM-18 and FARM-19 returned descriptions and comments without cookies or Authorization headers on 24 October. Earlier scoped public-reader configuration is recorded in FARM-19. |

The preserved Word report SHA-256 is:

```text
7ea0130b430cab705a63d277e504265b3c1a562eb742df8cf89a588a8e4175a3
```

The reviewed PR content was merged before this final verification. This record
and the version-status updates were prepared by Ayanat at the project owner's
request; no additional peer approval of these metadata changes is claimed.
The tag is an annotated version reference, not a signed release or a claim of
production readiness. The exact remote tag target is recorded in FARM-19 after
publication and checked before task closure.

## Submission Boundary and Follow-up

This version contains the local Flutter prototype, the original English report
(Sections 1–10), readable documentation, interview metadata, editable diagrams,
the supervisor-feedback supplement (Section 11), and the proposed backend
migration plan. A separate Word integration task is needed if the upload channel
requires all supplements in a single DOCX.

The final check does not claim new web/iOS builds, Android runtime verification,
completion of the platform/accessibility matrix, or representative-user
evaluation. Those remain planned work. There is no shared production backend or
real payment processing. Schema/API/pricing-contract follow-ups remain in
FARM-4/FARM-10 for the next phase and the meeting on 27 October 2026.

Historical missing pre-merge reviews on early PRs remain a documented process
limitation. They are not retroactively created by this version check. FARM-19
records closure of the first-stage repository preparation after the remote tag
is verified, with these limits retained.

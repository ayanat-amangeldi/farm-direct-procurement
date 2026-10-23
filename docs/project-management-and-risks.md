# 10. Project Management and Risks

[Documentation index](README.md) · [Complete report with figures](report/farm-direct-pre-defense-report.docx)

This is a readable copy of the corresponding section of the supplied English report. The complete Word report retains its original text, layout and figures.

## 10.1. Project Organisation and Tools

The project is developed by a two-person team. GitHub is used for source-code version control, documentation, and review through pull requests. YouTrack is used to organise tasks, assign responsibilities, track progress, and define upcoming work.

GitHub repository:<br>[https://github.com/ayanat-amangeldi/farm-direct-procurement](https://github.com/ayanat-amangeldi/farm-direct-procurement)

YouTrack project:<br>[https://farm-direct-procurement.youtrack.cloud/projects/FARM](https://farm-direct-procurement.youtrack.cloud/projects/FARM)

Project activities will be traceable through links between requirements, YouTrack tasks, implementation changes, and verification evidence.

## 10.2. Allocation of Responsibilities

| Team member | Primary responsibility | Main activities |
| --- | --- | --- |
| Ayanat Amangeldi | Backend and Transparent Pricing Module | Procurement-process analysis; database and API design; backend implementation; pricing calculations; stock commitments; order-processing rules; price-history functionality. |
| Dilyara Anetbayeva | Frontend and Procurement Scenarios | Flutter interface design and development; responsive mobile and web layouts; product catalog; farmer-offer comparison; checkout; order tracking; farmer and administrator workspaces. |
| Both team members | Shared project activities | Requirements analysis; architecture decisions; integration; testing; documentation; task planning; review and demonstration preparation. |

This allocation defines primary ownership rather than exclusive participation. Tasks involving both interface behaviour and business rules will be coordinated jointly. Completed work and reviews will be recorded according to each member’s actual contribution.

## 10.3. Task Management and Development Workflow

Implementation work will be divided into manageable YouTrack tasks. Each task should contain:

- A clear description and responsible team member.

- Related requirement identifiers.

- Acceptance criteria and relevant dependencies.

- Links to implementation changes and verification evidence.

- A current status indicating whether work is pending, in progress, under review, or completed.

Changes will be developed in branches and reviewed through pull requests before integration into the main branch. Commit messages and pull-request descriptions should reference the corresponding YouTrack issue where applicable.

A task will be considered complete when its acceptance criteria have been checked, relevant changes have been integrated, and supporting evidence has been recorded. Demonstration of local behaviour will not close tasks that require a shared backend.

## 10.4. Project Milestones

| Milestone | Main deliverables | Completion condition | Current position |
| --- | --- | --- | --- |
| M1. Requirements and initial design | Project proposal, relevance evidence, literature review, comparisons, requirements, and draft architecture. | The initial scope and acceptance criteria are documented and reviewed. | Documentation in progress. |
| M2. Local interactive prototype | Buyer, farmer, and administrator workflows; transparent pricing; order processing; price history; moderation; mobile and web screenshots. | The main scenarios can be demonstrated using local fictional data. | Prototype available for demonstration. |
| M3. Backend and database foundation | FastAPI service, PostgreSQL schema, authentication, permissions, migrations, and documented API contracts. | Core records and protected operations are available through the backend. | Planned. |
| M4. Client–server integration | Flutter API integration, shared offers and orders, consistent stock handling, and retry protection. | Buyer and farmer actions work across separate clients and survive service restarts. | Planned. |
| M5. Verification and user evaluation | Automated tests, compatibility checks, performance measurements, baseline comparison, and usability findings. | Results are assessed against Section 6 and documented using the plan in Section 9. | Planned. |
| M6. Final delivery | Corrected implementation, final report, setup instructions, and demonstration materials. | Mandatory requirements are verified and remaining limitations are clearly reported. | Planned. |

Target dates will be agreed with the supervisor and recorded in YouTrack. Functional tests will be developed alongside implementation rather than postponed until the final milestone.

## 10.5. Risk Register

| ID | Risk | Likelihood | Impact | Mitigation and response |
| --- | --- | --- | --- | --- |
| R1 | Additional features expand the scope beyond the available time. | High | High | Prioritise Must requirements. Defer optional features such as online payments, messaging, ratings, and recurring orders. Review proposed additions against the agreed scope. |
| R2 | Differences between frontend assumptions and API behaviour delay integration. | Medium | High | Agree on request formats, response structures, validation rules, and error handling before integration. Integrate one complete procurement scenario early. |
| R3 | Concurrent orders or repeated submissions create inconsistent stock or duplicate orders. | Medium | High | Use database transactions, server-side validation, submission identifiers, and automated concurrency and retry tests. |
| R4 | Incorrect pricing or history handling undermines price transparency. | Medium | High | Use exact monetary representations, centralise pricing rules, preserve accepted order terms, and test successful and failed historical updates. |
| R5 | Incomplete role or ownership checks expose protected operations. | Medium | High | Enforce permissions on the backend and test unauthenticated, incorrect-role, blocked-account, and non-owning-user requests. |
| R6 | Platform differences cause layout or interaction problems. | Medium | Medium | Check core scenarios regularly on Android, iOS, Chrome, and Safari, including narrow viewports, text scaling, and keyboard interaction. |
| R7 | Limited participant availability delays user evaluation. | Medium | Medium | Recruit participants in advance, prepare short role-specific sessions, and allow remote participation where practical. Report any sample limitations. |
| R8 | Data loss or environment failures interrupt development or evaluation. | Medium | High | Push work regularly, document setup, maintain repeatable test data and database migrations, and verify backup restoration before final evaluation. |
| R9 | Uneven workload or temporary unavailability delays dependent tasks. | Medium | Medium | Review workload regularly, document implementation decisions, identify critical dependencies, and redistribute tasks when necessary. |

Risks will be reviewed during progress meetings and before each milestone. Issues that occur will be recorded as actionable YouTrack tasks with an owner and a response plan.

## 10.6. Dependencies and Next Steps

Backend implementation depends on agreed data relationships, order-transition rules, pricing rules, and permission requirements. Flutter integration depends on sufficiently stable API contracts. Concurrent-order and recovery testing depends on the shared database and backend being operational.

User evaluation depends on a stable demonstration build, prepared task instructions, and participant availability. Performance evaluation depends on a documented test environment and a repeatable dataset.

The next development steps are:

1. Finalise the initial requirements and architecture with the supervisor.

2. Define the PostgreSQL schema and API contracts.

3. Implement authentication, role permissions, and core backend operations.

4. Connect the Flutter catalog and offer screens to the API.

5. Integrate order creation, stock commitments, and farmer order processing.

6. Integrate price history and administrator moderation.

7. Execute the verification and evaluation plan and address identified defects.

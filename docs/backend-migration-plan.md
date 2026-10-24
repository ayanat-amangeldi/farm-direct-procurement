# Backend Migration Plan

[Documentation index](README.md) · [Supervisor feedback](reviews/supervisor-feedback.md)

**Prepared:** 24 October 2026. **Meeting:** 27 October 2026.

This is the team's proposed response to SF-02 in
[FARM-18](https://farm-direct-procurement.youtrack.cloud/issue/FARM-18).
All development dates below are planning targets for review, not supervisor-approved
deadlines or completed work. The plan is available for the next meeting; it does
not require the entire backend to be implemented before that meeting.

## 1. Starting Point and Migration Order

The working Flutter prototype stores fictional accounts, farms, offers, orders,
price changes and moderation records in a versioned device-local JSON document
through `OrderStore`, `OrderPersistence` and `shared_preferences`. There is no
connected shared backend.

FastAPI, PostgreSQL and REST/JSON over HTTPS remain the proposed baseline from the
[technology comparison](technology-comparison.md). The first integration should
prove one shared procurement flow before expanding the remaining modules.

The migration order is:

1. Agree the schema, field-level API contracts, permissions and error cases.
2. Establish server identity/farm ownership, shared product types and farmer offers.
3. Move quotes, accepted order terms, stock commitments and order creation into
   one authoritative server workflow.
4. Integrate farmer transitions, price history and administrator moderation.
5. Verify the complete flow between two separate clients, including failures.

## 2. Proposed Dated Milestones

| Target | Deliverable | Primary responsibility | Completion evidence |
| --- | --- | --- | --- |
| 24 October | Publish this plan and the supervisor feedback/response record for joint review. | Ayanat prepares publication; Dilyara reviews. | Linked documents and reviewed PR; meeting and proposed dates clearly labelled. |
| 26 October | Prepare a draft relational schema and versioned API examples for identity, catalog/offers, quotes and orders. | Ayanat; Dilyara checks the contract against Flutter forms and screens. | Tables with primary/foreign keys, request/response examples, permission/error matrix and sample totals under FARM-4/FARM-10. Draft status is explicit. |
| 27 October meeting | Present migration order, contract draft, local/shared boundary, dependencies and test gates. Agree revisions with the supervisor. | Both students. | Dated meeting decisions and updated plan; unready draft items remain open. |
| 28–30 October | Establish FastAPI/PostgreSQL foundation, migrations, test fixtures, server authentication/ownership and the first Flutter catalog/offer adapter. | Ayanat: backend; Dilyara: client adapter and role navigation. | A farmer's offer is read by a buyer on a second client after refresh; seeded records survive backend restart. |
| 2–6 November | Integrate server quotes, accepted-order snapshots, atomic stock reservation and retry-safe order creation. | Ayanat: transaction/pricing rules; Dilyara: checkout and order views. | Two competing 50 kg orders against 80 kg cannot both succeed; retrying one submission creates one order/reservation; later offer edits preserve accepted prices. |
| 9–11 November | Integrate farmer order transitions, dated price history and administrator restrictions/moderation. | Ayanat: protected operations; Dilyara: farmer/admin screens. | Cross-client status and history updates; invalid/foreign-owner/blocked-account actions rejected by the API; cancellation and rejection release stock once. |
| 12–13 November | Execute integrated regression, restart/failure checks and the initial compatibility matrix; update setup instructions and actual results. | Both students. | Requirement-linked test results and a repeatable two-client demonstration. Performance and representative-user evaluation remain separately scheduled under the evaluation plan. |

If the contract or transaction gate fails, dependent work is replanned rather
than marked complete. The 27 October meeting is the checkpoint for confirming
these proposed dates and the scope of the first integrated release.

## 3. API Contract Work for FARM-4 and FARM-10

The detailed contracts must be reviewed before client/server integration. The
following is an agenda for that work, not a claim that endpoints already exist.

| Area | Proposed operations | Contract decisions and checks |
| --- | --- | --- |
| Identity and farms | Register buyer/farmer; sign in/out; obtain the current account and farm. | Server-issued identity, role and ownership; blocked-account responses; authentication/session lifecycle; no public administrator registration. |
| Catalog and offers | List/search product types; list eligible offers; create/edit an owning farm's offer. | Stable identifiers, category/unit/currency, stock/minimum, delivery scope, pagination/filter fields and an offer revision for stale-term checks. |
| Quotes | Request a quote for an offer, whole-kg quantity and pickup/delivery choice. | Integer KZT/whole-kg representation; subtotal, disclosed delivery, zero platform fee and total; quote validity/revision and changed-price response. |
| Orders | Submit an accepted quote with contact details and a submission identifier; list/read the current user's orders. | Server recomputation/validation; immutable accepted terms; atomic stock/order write; retry with the same identifier returns the original result and different payload is rejected. |
| Farmer actions | Confirm, mark ready, complete or reject an owning farm's order; permitted buyer cancellation. | Allowed prior state, rejection reason, ownership, transition timestamps, conflict response and stock release/consumption rules. |
| Price history | Read recorded offer-price changes; record successful changes with offer updates. | Previous/new price and delivery terms, time and responsible actor/farm; stock-only edits create no price event. |
| Administration | Block/unblock eligible accounts, hide/restore offers and read moderation records. | Administrator-only checks, reasons/timestamps, protected administrator accounts and independent account/offer restrictions. |

The first contract document should include proposed paths and HTTP methods,
request/response schemas, examples, role permissions and one consistent error
format. Cover invalid input, unavailable stock, stale quotes, forbidden ownership,
duplicate retries and invalid transitions. Use the requirements' concrete pricing
example: **50 kg × KZT 190 + KZT 2,500 delivery = KZT 12,000**; pickup is KZT 9,500.
Fractional quantities or currency are outside the current business rules; expanding
them would require an explicit representation/rounding decision and new tests.

## 4. What Moves and What Stays Local

| Data or responsibility | Target location | Migration boundary |
| --- | --- | --- |
| Accounts, farms, roles and ownership | Server/database | The backend is authoritative. Local checks continue for interaction but cannot grant access. Existing local credential records are not automatically imported as server identities. |
| Product types, offers, visibility and purchasing conditions | Server/database | Flutter reads shared records and submits authorised edits through the API. |
| Quotes, accepted prices, orders, stock commitments and transitions | Server/database | The server validates and commits changes. A connected client must not silently save a real order locally when the API fails. |
| Price history and moderation records | Server/database | Historical changes are written with the successful business operation, not independently by the client. |
| Current screen, navigation, search/filter controls and other UI preferences | Flutter/device | Remain local; changing a UI preference does not change authoritative business data. |
| Cached display data | Optional client cache | Refresh from the server; caches do not approve orders, allocate stock or grant permissions. |
| Existing fictional local demonstration dataset | Separate explicit demo mode | Preserve a runnable first-stage demo. Do not mix its orders/identities with server-backed records or silently switch a failing connected session to demo mode. |

Authentication storage and token/session handling must be agreed in the contract
stage before implementation; `shared_preferences` is not the authoritative
credential or procurement database for the connected system.

## 5. Integration and Verification Gates

- Keep the existing local demonstration and its tests reproducible while adding
  an identifiable API/repository boundary to the Flutter client.
- First shared-data gate: one farmer publishes or edits an offer and a buyer on
  another client sees the committed record after refresh.
- Procurement gate: accepted prices, stock reservation and order creation are
  committed together; failed transactions leave no partial business records.
- Permission gate: test direct API requests from incorrect roles, non-owning
  accounts, blocked accounts and signed-out clients, independent of UI controls.
- Recovery gate: an interrupted response and a retry do not duplicate an order;
  a restart retains accepted terms and history.
- Record actual version, environment, dataset, steps and outcomes using the
  [verification plan](verification-and-evaluation-plan.md). Backend, security,
  concurrency and shared-device requirements remain unverified until these tests
  run against the integrated implementation.

The existing local prototype checks are a regression baseline, not evidence that
the planned server behaviour has passed. Online payments, courier integration,
multi-farm checkout and public reviews remain outside the initial scope.

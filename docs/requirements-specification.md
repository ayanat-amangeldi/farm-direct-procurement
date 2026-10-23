# 6. Requirements Specification

[Documentation index](README.md) · [Complete report with figures](report/farm-direct-pre-defense-report.docx)

This is a readable copy of the corresponding section of the supplied English report. The complete Word report retains its original text, layout and figures.

## 6.1. Purpose and Scope

This specification defines the functional and non-functional requirements of the Farm Direct Procurement System. Each requirement has an identifier, priority, and acceptance criteria to support verification.

The target system supports three roles:

- Buyer: browses products, compares farmer offers, places orders, and follows their progress.

- Farmer: manages offers, stock, and incoming orders.

- Administrator: moderates accounts and offers and reviews system records.

The requirements describe the intended shared system. The current Flutter prototype demonstrates most user workflows using fictional data stored on one device. Shared persistence and authoritative server-side enforcement remain planned.

## 6.2. Priorities and Requirement Sources

Requirements use the following priorities:

| Priority | Meaning |
| --- | --- |
| Must | Required for acceptance of the intended shared system. |
| Should | Important but may be deferred without preventing the core procurement workflow. |

The specification draws on:

- The reported experiences of the four interview participants.

- Findings from the literature review.

- Documented capabilities of comparable systems.

- The project’s agreed scope and engineering decisions.

Interview findings primarily support offer comparison, clear purchasing conditions, stock coordination, and order management. Roles, moderation, historical records, and retry handling also reflect team design decisions.

Acceptance criteria are proposed verification conditions. They do not represent completed evaluations.

## 6.3. Business Rules

The initial release uses the following rules:

1. Each order concerns one farmer offer. A combined checkout across several farms is outside the initial scope.

2. Quantities are whole kilograms. Unit prices and delivery fees are whole KZT.

3. Quantities must be positive and must satisfy the offer’s minimum quantity and available stock.

4. The item subtotal equals quantity multiplied by the accepted unit price.

5. The final total equals the item subtotal plus the disclosed delivery fee. Pickup is free, and no additional platform fee applies.

6. Prices and purchasing terms are recorded when an order is placed. Later offer edits do not change existing orders.

7. Active orders reserve stock. Cancellation or rejection releases the reservation. Completion consumes the ordered quantity without releasing it for resale.

8. Normal order progression is:

Awaiting confirmation → Confirmed → Ready → Completed

9. Buyers may cancel orders awaiting confirmation. Farmers may reject orders awaiting confirmation or confirmed orders, providing a reason.

10. Hidden offers and offers belonging to blocked farmers are unavailable for new purchases. Moderation does not rewrite existing order terms.

## 6.4. Functional Requirements

| ID | Requirement | Priority | Acceptance criteria |
| --- | --- | --- | --- |
| FR-01 | Register buyer and farmer accounts. | Must | Valid registration creates an account with the selected role. Farmer registration creates an associated farm. Duplicate email addresses are rejected. Public registration cannot create an administrator account. |
| FR-02 | Authenticate users and support logout. | Must | Valid credentials for an active account permit access. Invalid credentials are rejected. Blocked accounts cannot sign in and receive an explanation. Logout removes access to protected actions until authentication is repeated. |
| FR-03 | Enforce role and ownership permissions. | Must | Buyers access only their own orders. Farmers modify only their own farm’s offers and orders. Administrator actions are unavailable to other roles. In the shared system, unauthorised direct API requests are rejected independently of interface visibility. |
| FR-04 | Display the available product catalog. | Must | Buyers can browse product types and open their available offers. Hidden offers and offers from blocked farmers are excluded. A product type with no purchasable offers is excluded from the available catalog. |
| FR-05 | Present comparable farmer offers. | Must | With at least three available offers for one product type, buyers can inspect each farmer, unit price, available quantity, minimum quantity, region, and fulfilment conditions before choosing an offer. |
| FR-06 | Calculate and display purchasing costs. | Must | Before submission, the interface displays quantity, unit price, subtotal, delivery fee, and total. A test order of 50 kg at KZT 190/kg with KZT 2,500 delivery produces a subtotal of KZT 9,500 and a total of KZT 12,000. Pickup produces a zero delivery fee. |
| FR-07 | Validate and create orders. | Must | Valid contact and fulfilment details create an order with a unique reference and Awaiting confirmation status. Invalid quantities, insufficient stock, missing required details, and unavailable offers are rejected without creating an order. A stale quote requires the buyer to review updated terms before submission. |
| FR-08 | Preserve accepted purchasing terms. | Must | An order retains its accepted product and farmer information, quantity, unit price, delivery fee, fulfilment details, and total. Editing or hiding the offer afterwards does not change these recorded terms. |
| FR-09 | Provide buyer order history and cancellation. | Must | Buyers can view their own order references, details, statuses, and recorded transition times. Cancelling an awaiting order changes its status to Cancelled and releases its stock reservation. Cancellation is refused once the order is confirmed. |
| FR-10 | Allow farmers to create and edit offers. | Must | A farmer can publish an offer under an existing or new product type and edit its price, stock, minimum quantity, description, region, and delivery conditions. Invalid values and stock below existing commitments are rejected. A published offer’s product type cannot be changed. |
| FR-11 | Support farmer order processing. | Must | A farmer can view their own incoming orders and perform the permitted confirmation, ready, and completion transitions. Rejection before Ready requires a reason of 5–300 characters, visible to the buyer. Invalid transitions are rejected without changing the order. |
| FR-12 | Maintain consistent stock commitments. | Must | Placing an order reduces available stock. Cancellation and rejection restore the reserved quantity exactly once. Completion does not make the quantity available again. With 80 kg available and two competing requests for 50 kg, at most one succeeds and the remaining availability is 30 kg. |
| FR-13 | Record and display offer-price history. | Must | Successful publication records initial terms. Subsequent price or delivery-term changes record previous and new values, the offer and farm identity, and a timestamp. Description-only or stock-only edits create no price-change event. Failed saves create no event. Buyers and the owning farmer can view recorded history; unavailable earlier history is not invented. |
| FR-14 | Moderate accounts and offers. | Must | Administrators can block or unblock buyer and farmer accounts and hide or restore offers, providing reasons. Administrator accounts cannot be blocked through this workflow. Unblocking does not restore separately hidden offers, and restoring an offer does not override a blocked farmer account. |
| FR-15 | Provide an administrator overview and moderation records. | Must | Administrators can inspect accounts, offers, orders, and moderation decisions. Each decision records the action, target, administrator, reason, and timestamp. Buyers and farmers cannot create, edit, or delete moderation records. |
| FR-16 | Share authoritative data across devices. | Must | An offer created by a farmer on one authenticated client becomes available to a buyer on another client after refresh. An order placed by the buyer appears in the farmer’s account. Committed changes remain available after client and server restarts. |
| FR-17 | Prevent duplicate order creation during retries. | Must | Repeating the same logical submission with the same request identifier creates one order and one stock reservation. Reusing the identifier with different order data is rejected. A client can retrieve the result after a response is interrupted. |
| FR-18 | Provide search, filtering, and sorting. | Should | Product-name search returns matching products. Category filters restrict the catalog, and offer sorting and delivery filtering update the displayed offers consistently. No-match results display an explanatory empty state. |

## 6.5. Non-Functional Requirements

The numerical thresholds below are initial acceptance targets. They must be evaluated under documented conditions rather than presented as achieved results.

| ID | Requirement | Priority | Acceptance criteria |
| --- | --- | --- | --- |
| NFR-01 | Platform compatibility | Must | The core buyer and farmer scenarios complete on Android, iOS, and the web version in Chrome and Safari. Tested operating-system and browser versions are recorded. Build success alone does not establish runtime acceptance. |
| NFR-02 | Responsive and accessible interaction | Must | At reference sizes of 360 × 800 and 1280 × 800, essential controls and purchasing information remain reachable. At 200% text scaling, essential content remains accessible through reflow or scrolling. Core web forms support keyboard operation and visible focus. |
| NFR-03 | Secure shared access | Must | Deployed clients communicate with the API through HTTPS. Passwords are not stored in plaintext or returned by the API. Unauthenticated and unauthorised requests are rejected. Role, ownership, and blocked-account checks are enforced by the backend. |
| NFR-04 | Transactional integrity | Must | A simulated failure during order creation leaves neither a partial order nor an unmatched stock reservation. A failed price update leaves both the offer and its history unchanged. Concurrent requests satisfy FR-12 and FR-17. |
| NFR-05 | Calculation accuracy | Must | Monetary calculations use exact representations rather than binary floating-point arithmetic. Automated tests verify valid totals, boundary values, minimum quantities, pickup, and delivery. Displayed totals match recorded accepted-order totals. |
| NFR-06 | Data persistence and recoverability | Must | Accepted records survive service restart. A backup can be restored into a separate test environment, preserving selected users, offers, orders, accepted prices, and history. Backup time and restoration results are documented. |
| NFR-07 | Response time | Should | With 10 concurrent test users and 1,000 seeded offers, at least 95% of catalog and offer API requests complete within two seconds during the documented test run. Hardware, network conditions, errors, and dataset are reported. This target excludes initial application download and image loading. |
| NFR-08 | Usability | Should | At least five representative participants, including at least two buyers and two farmers, attempt predefined role-appropriate tasks. At least 80% of task attempts succeed without moderator intervention. Buyer tasks include identifying the final total before submission. Results are reported separately by task and role. |
| NFR-09 | Maintainability and testability | Must | Shared-system code is organised into identifiable client, API, business-logic, and persistence components. Setup and test commands are documented. Each mandatory requirement is mapped to verification evidence; automated tests cover pricing, stock commitments, permissions, order transitions, and price-history rules. |

## 6.6. Current Implementation Status

| Requirement area | Current status |
| --- | --- |
| Registration, sign-in, and role workflows | Demonstrated locally. Trusted server authentication and authorisation remain planned. |
| Catalog, comparison, pricing, checkout, and order history | Demonstrated using fictional local data. |
| Farmer offer management and order lifecycle | Demonstrated locally, including validation, rejection reasons, and stock accounting. |
| Price history and moderation | Demonstrated locally. Historical records are not a server-authenticated audit trail. |
| Cross-device shared data — FR-16 | Not implemented. Requires the backend and shared database. |
| Retry-safe network submissions — FR-17 | Not implemented as a server API requirement. |
| Platform acceptance — NFR-01 | Some build and browser checks exist; the complete device and browser runtime matrix remains pending. |
| Production security, database integrity, recovery, performance, and usability targets | Require implementation or evaluation in the shared system. |

Existing prototype tests provide evidence for local behaviour. They do not establish compliance with server concurrency, cross-device consistency, or production security requirements.

## 6.7. Acceptance and Traceability

Each requirement will be linked to its implementation work, YouTrack task, and verification evidence. Evidence may include automated tests, recorded manual scenarios, API responses, screenshots, or evaluation results.

A requirement is accepted only when its stated criteria have been checked in the relevant environment. Demonstrating a workflow with local data is sufficient evidence for that prototype behaviour, while shared-system requirements require verification against the implemented backend.

## 6.8. Excluded from the Initial Release

The initial shared-system release excludes:

- Real online payment processing and settlement.

- Combined checkout across several farms.

- Automatic market-price prediction or price negotiation.

- Delivery-route optimisation and live courier tracking.

- Recurring procurement subscriptions.

- Product image uploads and public review or rating systems.

These exclusions keep the initial scope focused on offer comparison, transparent purchasing terms, and reliable order coordination.

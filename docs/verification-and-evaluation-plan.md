# 9. Verification and Evaluation Plan

[Documentation index](README.md) · [Complete report with figures](report/farm-direct-pre-defense-report.docx)

This is a readable copy of the corresponding section of the supplied English report. The complete Word report retains its original text, layout and figures.

## 9.1. Purpose and Scope

Verification will establish whether the system satisfies the functional and non-functional requirements defined in Section 6. Evaluation will investigate whether the proposed interface helps users compare farmer offers, understand the final purchasing cost, and manage procurement activities.

Testing will distinguish two implementation stages:

- Local prototype: verification of interface behaviour, calculations, order workflows, price history, and moderation using demonstration data.

- Integrated system: verification of API permissions, shared persistence, concurrent purchases, retry handling, security, and recovery after backend integration.

Successful prototype demonstrations will not be treated as evidence that shared-system requirements have been fulfilled.

## 9.2. Testing Strategy

| Test area | Planned checks | Related requirements |
| --- | --- | --- |
| Registration and access | Register buyer and farmer accounts; reject duplicate emails and invalid credentials; verify logout, blocked-account restrictions, role permissions, and ownership checks. | FR-01–FR-03; NFR-03 |
| Catalog and comparison | Check product availability, offer details, search, category filters, sorting, and exclusion of hidden offers or offers from blocked farmers. | FR-04–FR-05, FR-18 |
| Pricing and checkout | Verify quantity validation, minimum orders, stock limits, delivery charges, final totals, required contact details, and handling of changed offer terms. | FR-06–FR-08; NFR-05 |
| Order lifecycle | Check order creation, buyer history, permitted cancellation, farmer confirmation, readiness, completion, rejection reasons, and refusal of invalid transitions. | FR-07–FR-09, FR-11 |
| Offer management and history | Create and edit offers; reject invalid values; verify dated price-change records and confirm that stock-only or description-only edits do not create price-change events. | FR-10, FR-13 |
| Stock and concurrent requests | Verify reservations, cancellation and rejection releases, completion, and competing purchases without overselling. | FR-12; NFR-04 |
| Administration | Check account blocking and unblocking, offer hiding and restoration, protected administrator accounts, and complete moderation records. | FR-14–FR-15 |
| Integration and persistence | Verify data exchange between separate clients, persistence after restart, duplicate-submission protection, transaction rollback, and backup restoration. | FR-16–FR-17; NFR-04, NFR-06 |
| Compatibility and interaction | Execute core scenarios on the required platforms; check responsive layouts, text scaling, keyboard operation, and visible focus. | NFR-01–NFR-02 |
| Performance, usability, and maintainability | Measure API response times and task completion; verify documented setup, test commands, and requirement-to-evidence links. | NFR-07–NFR-09 |

Automated unit tests will cover business rules and calculations. Widget tests will check interface validation and interaction. Integration and API tests will verify communication between components. Manual scenario testing will supplement automated checks for layouts, accessibility, and complete user journeys.

## 9.3. Test Data and Measurement Conditions

Testing will use fictional accounts and a repeatable dataset containing buyers, farmers, an administrator, product types, farmer offers, orders, and historical records. At least one product type will have three comparable farmer offers.

Reference cases will include:

- Pricing: 50 kg at KZT 190/kg produces a subtotal of KZT 9,500. Adding KZT 2,500 delivery produces a total of KZT 12,000. Pickup produces no delivery charge.

- Stock competition: with 80 kg available, two concurrent requests for 50 kg must produce at most one accepted order, leaving 30 kg available.

- Preserved terms: changing an offer’s price after order placement must not change the accepted order total.

- Retry handling: repeating the same submission identifier must create one order and one stock reservation.

- Failed updates: an interrupted transaction must not leave partial orders, inconsistent stock, or unmatched price-history records.

Each test run will record the application version or commit, platform, operating system, browser version where applicable, dataset, and relevant hardware and network conditions.

Responsive checks will include reference viewports of 360 × 800 and 1280 × 800, together with 200% text scaling. Compatibility testing will cover Android, iOS, and the web application in Chrome and Safari.

Performance testing will use 1,000 seeded offers and 10 concurrent test users against the integrated backend. Request counts, test duration, response times, and errors will be recorded. Initial application download and image loading will be excluded from the API response-time measurement.

## 9.4. Metrics and Acceptance Targets

| Metric | Measurement method | Target |
| --- | --- | --- |
| Mandatory requirement coverage | Map every Must requirement to test cases and recorded evidence. | Every Must requirement has verification evidence and satisfies its acceptance criteria before final acceptance. |
| Calculation accuracy | Compare displayed and stored totals with independently calculated expected values. | All predefined pricing and boundary cases produce the correct result. |
| Order and inventory consistency | Inspect orders, reservations, and available stock after normal, concurrent, repeated, and failed operations. | No overselling, duplicate reservations, invalid transitions, or partial transactions in the defined cases. |
| Access-control correctness | Attempt protected actions using unauthenticated users, incorrect roles, blocked accounts, and non-owning accounts. | All predefined unauthorised requests are rejected by the backend. |
| API response time | Measure catalog and offer request durations under the documented workload. | At least 95% of requests complete within two seconds. |
| Usability task success | Divide successful task attempts completed without moderator intervention by all task attempts. | At least 80%, with results also reported separately by task and role. |
| Final-price comprehension | Ask buyers to identify the total before submitting an order; compare their answers with the expected amount. | Record the correct-answer rate and analyse every misunderstanding. |
| Persistence and recovery | Restart services and restore a backup into a separate test environment. | Selected accounts, offers, orders, accepted prices, and historical records remain correct. |

Any failed mandatory criterion will remain unresolved until corrected and successfully retested.

## 9.5. Baseline for Comparison

The baseline will represent manual offer comparison using separate supplier messages and a simple spreadsheet. This reflects the communication and comparison practices described in the interviews.

Buyers will complete equivalent tasks using the baseline and the prototype:

1. Compare three farmer offers.

2. Identify offers satisfying a specified quantity and fulfilment requirement.

3. Calculate the final purchasing cost, including delivery.

4. Select the lowest-total-cost offer among those meeting the stated conditions.

Both conditions will provide equivalent information about prices, stock, minimum quantities, and delivery. The same timing rules and access to a calculator will apply. Task order will be counterbalanced where practical to reduce learning effects.

The comparison will record completion time, calculation errors, offer-selection errors, and requests for assistance. Results will be reported descriptively. Faster completion or fewer errors will be claimed only if supported by the measurements.

## 9.6. User Evaluation Procedure

At least five representative participants, including at least two buyers and two farmers, will attempt predefined tasks.

Buyer tasks will cover finding a product, comparing offers, identifying the final total, placing a demonstration order, and locating its status. Farmer tasks will cover editing an offer, inspecting price history, and processing an incoming order. Administrator workflows will be checked through separate functional scenarios.

Participants will receive a brief introduction without step-by-step instructions. The evaluator will record task completion, time, errors, and assistance. A task requiring moderator intervention will not count as an independently successful attempt.

Brief follow-up questions will identify confusing terminology, missing information, and navigation difficulties. Participation will be voluntary, and results will use anonymous participant identifiers.

Because the evaluation sample is small, findings will be treated as exploratory rather than representative of all potential users.

## 9.7. Evidence and Final Assessment

Each test record will include the requirement identifier, preconditions, steps, expected result, actual result, execution environment, and status. Evidence may include automated test reports, screenshots, API responses, database checks, performance logs, and anonymised evaluation notes.

Tests will be marked as Passed, Failed, Blocked, or Not Run. Requirements awaiting backend implementation will not be marked as passed based on local screenshots.

The final assessment will combine requirement verification, baseline comparison, and user-evaluation findings. It will explain which project objectives have been demonstrated, which limitations remain, and what further development is required. Claims about farmer income, long-term trust, or commercial efficiency will require additional field evidence

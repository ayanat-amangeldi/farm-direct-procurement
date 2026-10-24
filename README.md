# Farm Direct Procurement System

**Diploma project:** Development of an information system for direct procurement
of agricultural products from small-scale farms with transparent pricing.

Farm Direct connects small-scale farms with individual and business buyers.
Farmers publish product offers and manage incoming orders; buyers compare offers
for the same product and review the full price before ordering. Administrators
manage account access and offer visibility.

[GitHub repository](https://github.com/ayanat-amangeldi/farm-direct-procurement)
· [YouTrack project](https://farm-direct-procurement.youtrack.cloud/projects/FARM)
· [Project documentation and complete English report](docs/README.md)
· [Prototype walkthrough and screenshots](docs/prototype/catalog-and-offers.md)

## Problem Statement

The project addresses the difficulty of comparing agricultural offers when unit
prices, available quantities, minimum orders and delivery terms are presented
separately. Small farms may also have limited channels for reaching buyers
directly and managing procurement requests.

Four reported interviews with two farmers and two buyers provide initial
qualitative evidence of these difficulties; the findings and limitations are
documented in [Evidence of Relevance](docs/evidence-of-relevance.md). Benefits such
as reduced comparison time or improved price comprehension have not yet been
measured.

## Aim and Objectives

The aim is to develop an information system that supports direct procurement from
small farms and makes agreed prices and order conditions clear to both parties.

- Identify farmer and buyer needs and translate them into verifiable requirements.
- Keep generic products separate from individual farmer offers so buyers can
  compare like-for-like prices, quantities and fulfillment terms.
- Show the item subtotal, delivery charge and final total before order placement.
- Support farmer offer management and a traceable order lifecycle while preserving
  accepted price terms and recording later offer-price changes.
- Provide buyer, farmer and administrator roles and evaluate the resulting
  workflows against defined functional checks and a user-evaluation plan.

## Target Users

| User group | Main needs |
| --- | --- |
| Small-scale farmers | Publish products, set prices and quantities, specify pickup/delivery terms, and manage incoming orders. |
| Individual and business buyers | Find agricultural products, compare farmer offers, understand the full cost, place orders and track their status. |
| Platform administrators | Review accounts, listings and orders; manage account restrictions and offer visibility with recorded reasons. |

## Team and Responsibilities

**Educational programme:** Software Engineering, Astana IT University.

| Team member | Agreed responsibility | GitHub account |
| --- | --- | --- |
| Ayanat Amangeldi | Backend and transparent-pricing module: procurement-process analysis, data modelling, API design, order rules, price calculation and price-history logic. | [ayanat-amangeldi](https://github.com/ayanat-amangeldi) |
| Dilyara Anetbayeva | Frontend and procurement scenarios: Flutter interface, buyer/farmer/admin screens, catalog and offer comparison, checkout, order-status presentation and usability. | [dilyara-anetbayeva](https://github.com/dilyara-anetbayeva) |

**Supervisor:** Aldiyar Salkenov, Senior Lecturer.

Requirements, architecture and technology decisions, integration, end-to-end
verification, documentation and demonstrations are shared responsibilities. The
module ownership above follows the project justification; it does not imply that
the planned backend has already been implemented. Actual changes are traceable
through commits, pull requests and assigned YouTrack tasks.

## Expected Outcomes

- An integrated procurement system in which farmers publish offers and buyers
  place orders using clearly disclosed prices and fulfillment terms.
- Preserved order-price snapshots and a dated history of offer-price changes,
  allowing participants to distinguish agreed terms from later updates.
- Documented requirements, architecture, technology decisions and verification
  evidence, followed by evaluation of task completion and price comprehension.

The current prototype demonstrates the main workflows on one device. A shared
backend and representative-user evaluation are planned outcomes for later stages.

## Scope and Current Status

**As of 24 October 2026:** the local Flutter demonstration prototype is complete
for its agreed scope and merged into `main`. It targets Android, iOS and web.
The [English report and readable documentation](docs/README.md) cover the initial
analysis, design and formal evaluation plan. [Editable architecture diagrams and
exports](diagrams/README.md) accompany the report. [Supervisor feedback dated
24 October 2026](docs/reviews/supervisor-feedback.md) is recorded with the team's
response and a [proposed backend migration plan](docs/backend-migration-plan.md)
for the meeting on 27 October. The final submission checklist/tag remains open.

### Implemented Prototype Features

| Role or area | Available functionality |
| --- | --- |
| Buyer | Local sign-in/registration, product search and category filters, separate offers from multiple farms, sorting and delivery filtering, quantity-based price preview, validated checkout, numbered confirmation, own order history and cancellation of awaiting orders. |
| Farmer | An account linked to one farm; create/edit offers and product types; manage price, stock, minimum quantity, pickup region and delivery terms; view own incoming orders; confirm, mark ready, complete or reject with a reason. |
| Administrator | Account/offer/order overview, block/unblock buyers and farmers, hide/restore individual offers, required moderation reasons and dated decision history. Administrator accounts are protected from blocking. |
| Pricing and data | Whole-kg validation, integer-KZT totals, separately disclosed delivery charges, fixed accepted-order snapshots, local stock accounting and dated unit-price/delivery-fee history. |

The order lifecycle is **Awaiting confirmation → Confirmed → Ready → Completed**.
Buyers can cancel awaiting orders. Farmers can reject awaiting or confirmed
orders with a reason. Cancellation and rejection release local stock; completed
quantities remain consumed. Existing orders retain their accepted terms when an
offer is edited, hidden or its farmer is blocked.

For the current single-offer order model:

```text
item subtotal = quantity in kg × agreed unit price in KZT/kg
total = item subtotal + disclosed per-order delivery fee
```

Pickup is free. No additional platform charge is applied in the prototype.
Prices are fixed when an order is placed. History records successful publications
and subsequent price/delivery-fee changes; earlier history is not invented.

### Prototype Boundaries

- Accounts, farms, offers, orders and moderation records are stored locally on the
  same device/browser. They survive restart, but sign-in sessions do not.
- Role checks and salted password hashes demonstrate local account workflows.
  Trusted authentication, authorization and shared inventory require a backend;
  the device owner can inspect or alter local data.
- All seeded farms, stock and prices are fictional. Use sample contact details and
  a demo password. No real payment or farmer notification is sent.
- Blocking a farmer excludes their offers from new purchases. Unblocking does not
  restore offers explicitly hidden by an administrator. Farmers see moderation
  reasons but cannot clear restrictions by editing their offers.
- Product photography is illustrative and generated. Custom product types use
  neutral placeholders; image upload is not connected.
- Server synchronization, email verification, password recovery and real
  transaction processing remain outside the current demonstration scope.

## Technologies

| Area | Current implementation |
| --- | --- |
| Client and language | Flutter with Dart; shared UI for Android, iOS and web. Verified with Flutter 3.41.9 and Dart 3.11.5. |
| Interface | Material 3 widgets and responsive layouts. |
| Local persistence | `shared_preferences`; versioned local JSON for accounts, catalog, orders, price history and moderation. |
| Demo password handling | `cryptography`: per-account salts and PBKDF2-HMAC-SHA256 hashes with 100,000 iterations. |
| Verification | `flutter_test` for calculation, state/persistence and widget checks; `flutter_lints` and `flutter analyze`. |
| Development tools | Flutter SDK, Android Studio with Flutter/Dart plugins, Xcode and iPhone Simulator on macOS. |
| Collaboration | Git, GitHub task branches/pull requests and YouTrack. |

Python/FastAPI, PostgreSQL and a REST-style JSON API are the recommended backend
baseline in the [technology comparison](docs/technology-comparison.md). They are
not connected to this prototype and still require implementation validation.

## Repository Structure and Documentation

```text
apps/mobile/
  lib/                 Flutter source: catalog, orders, accounts, moderation and UI
  test/                Automated calculation, business-rule and widget checks
  assets/products/     Illustrative product images
  android/ ios/ web/   Platform project files
  pubspec.yaml         Dependencies and SDK constraints
  pubspec.lock         Resolved dependency versions
docs/
  README.md            Documentation index, evidence status and outstanding items
  report/              Complete supplied English report with diagrams/screenshots
  *.md                 Readable analysis, requirements and planning sections
docs/prototype/
  catalog-and-offers.md Buyer, farmer and admin walkthroughs and check results
  image-sources.md     Image provenance and generation prompts
  screenshots/         Captured prototype screens
diagrams/
  *.drawio             Editable three-page architecture source
  *.svg / *.png        Readable context, use case and component diagram exports
  README.md            Figure index, editing/export instructions and status
FEATURES.md            System features and local implementation status
README.md              Project overview, setup and verification instructions
.gitignore             Generated/local-file exclusions
```

Available documentation:

- [Documentation index and complete English report](docs/README.md).
- [Project proposal and scope](docs/project-proposal.md).
- [Evidence of relevance](docs/evidence-of-relevance.md).
- [Literature review and source analysis](docs/literature-review.md).
- [Existing system comparison](docs/existing-system-comparison.md).
- [Technology comparison](docs/technology-comparison.md).
- [Requirements and acceptance criteria](docs/requirements-specification.md).
- [Architecture description and requirement mapping](docs/architecture.md).
- [Editable architecture diagrams and SVG/PNG exports](diagrams/README.md).
- [Verification and evaluation plan](docs/verification-and-evaluation-plan.md).
- [Responsibilities, milestones and risks](docs/project-management-and-risks.md).
- [First pre-defense submission checklist](docs/submission-checklist.md) and
  [submission summary](docs/submission-summary.md).
- [Supervisor feedback and response record](docs/reviews/supervisor-feedback.md).
- [Dated backend migration plan for the next meeting](docs/backend-migration-plan.md).
- [System features](FEATURES.md).
- [Prototype scenarios, expected results, limitations and screenshots](docs/prototype/catalog-and-offers.md).
- [Image sources and prompts](docs/prototype/image-sources.md).

Architecture descriptions and figure exports are included in Section 7 of the
complete report and linked separately above. The supervisor feedback and team
response are published separately as Section 11. Interview metadata publication,
complete platform acceptance and evaluation results are tracked separately.
The backend migration dates are proposed targets for discussion on 27 October;
the documented plan does not establish completed backend integration or evaluation.

## Setup and Execution

Install the Flutter SDK and confirm the available toolchains with `flutter doctor`.
Clone the repository and install the client dependencies:

```sh
git clone https://github.com/ayanat-amangeldi/farm-direct-procurement.git
cd farm-direct-procurement/apps/mobile
flutter pub get
```

All Flutter commands below run from `apps/mobile`.

### Android Studio and Android

Open `apps/mobile` in Android Studio with the Flutter/Dart plugins enabled.
Install the Android SDK and an emulator, accept the SDK licenses locally, and
select an emulator or connected device. Run `lib/main.dart` from the IDE, or:

```sh
flutter devices
flutter run -d <device-id>
```

### iPhone Simulator

On macOS, install Xcode, its command-line tools, an iOS Simulator runtime and
CocoaPods. Start Simulator, select the simulated iPhone in Android Studio, and run
the same Flutter project. The device ID can also be selected with `flutter run` as
above. Open `ios/Runner.xcworkspace` for work in Xcode.

### Browser Preview

```sh
flutter run -d chrome
```

For a web-server preview:

```sh
flutter run -d web-server --web-hostname 127.0.0.1 --web-port 8357
```

Open the printed localhost address in a browser. Keep the Flutter process running.

## Demo Accounts and Walkthrough

These are intentionally public, fictional accounts for this local demonstration.
Their shared demo password is `FarmDemo2026!`.

| Role | Email |
| --- | --- |
| Buyer | `buyer@farm.demo` |
| Farmer — Bereke | `bereke@farm.demo` |
| Administrator | `admin@farm.demo` |

The sign-in screen lists four additional fixture farmer accounts. Registration
creates an independent buyer account or a new farm; administrator accounts cannot
be self-registered. Clearing browser/app storage removes locally saved changes.

A short demonstration:

1. Sign in as the buyer, search for Potatoes, and compare the three farmer offers.
2. Select Bereke and 50 kg: pickup totals KZT 9,500; delivery adds KZT 2,500 for a
   total of KZT 12,000. Use sample contact details and place a demo order.
3. Sign out, sign in as Bereke, and advance the order through confirmation,
   readiness and completion. Sign in as the buyer again to view the saved status.
4. As the farmer, publish/edit an offer and inspect its dated price history.
5. As administrator, hide/restore an offer or block/unblock an account with a
   reason, then inspect History and the resulting buyer/farmer views.

The [full walkthrough](docs/prototype/catalog-and-offers.md) includes invalid
inputs, rejection, cancellation, persistence and moderation scenarios.

## Testing and Verification

```sh
flutter analyze
flutter test
```

Final version checks on **24 October 2026**: **66 tests passed**, and analysis
reported no issues. See the [version verification record](docs/reviews/pre-defense-1-verification.md).
The following platform builds succeeded earlier in prototype development; they
were not rerun for the catalog-availability correction or this version check:

```sh
flutter build web --release --no-wasm-dry-run
flutter build ios --simulator --debug
```

Manual browser checks used a 390 × 844 viewport; widget tests include 320 px layouts
with larger text. Section 8 of the complete report contains actual iPhone
Simulator and desktop web captures. These captures do not complete the full
platform/accessibility acceptance matrix or representative-user evaluation.
Android build and device/emulator runtime checks remain pending local
SDK-license/device setup.
Representative-user evaluation and backend/security testing have not been run.

## Project Tracking and Contribution Workflow

[YouTrack FARM project](https://farm-direct-procurement.youtrack.cloud/projects/FARM)
contains task owners, priorities, expected outcomes, acceptance criteria and
applicable deadlines. Key items are [FARM-1: README](https://farm-direct-procurement.youtrack.cloud/issue/FARM-1),
[FARM-8: buyer prototype](https://farm-direct-procurement.youtrack.cloud/issue/FARM-8),
[FARM-9: farmer/admin prototype](https://farm-direct-procurement.youtrack.cloud/issue/FARM-9),
[FARM-10: pricing and data contract](https://farm-direct-procurement.youtrack.cloud/issue/FARM-10),
[FARM-17: verification plan](https://farm-direct-procurement.youtrack.cloud/issue/FARM-17),
[FARM-20: catalog availability](https://farm-direct-procurement.youtrack.cloud/issue/FARM-20)
and [FARM-21: report publication](https://farm-direct-procurement.youtrack.cloud/issue/FARM-21).

Use a task branch such as `codex/FARM-1-complete-readme`, include the task ID in the
commit or PR description, link the change back to YouTrack, and describe its
validation. Each student should use their own identifiable GitHub account and
commit author details. Another team member should review changes before merging
into `main`. Record supervisor feedback at agreed checkpoints and address it
through traceable follow-up changes. Mark tasks complete when their acceptance
criteria are met. Keep real credentials, API keys and private user data out of Git.

The first submission version is [`pre-defense-1`](https://github.com/ayanat-amangeldi/farm-direct-procurement/tree/pre-defense-1),
verified on 24 October 2026. Its [verification record](docs/reviews/pre-defense-1-verification.md),
[checklist](docs/submission-checklist.md) and [summary](docs/submission-summary.md)
record completed work, known limitations and outstanding tasks. Later stages
will use `pre-defense-2` and `final-pre-defense`; previous submission tags must
remain fixed.

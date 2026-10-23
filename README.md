# Farm Direct Procurement System

## Project Description
This diploma project focuses on developing an information system for direct agricultural product procurement from small farms with transparent pricing.

## Main Objectives
- Connect small farmers directly with buyers.
- Ensure transparent pricing of agricultural products.
- Reduce intermediaries in the supply chain.
- Simplify the ordering and purchasing process.

## Project Status
First-stage Flutter prototype in development. The client lives in `apps/mobile`
and supports Android, iOS, and web. Prototype data is fictional; no live farmers,
payments, or orders are connected.

The current increment includes a searchable catalog, category filters, separate
farmer offers for each product, sorting, a delivery filter, and a quantity-based
price preview. Buyers can complete a demo checkout, view a numbered confirmation,
open local order history, inspect saved price terms, and cancel an order that is
awaiting confirmation. Orders survive a restart on the same device/browser;
there is no shared server inventory or real payment.

Signing in as a farmer opens farm-specific incoming orders, status filters and
order confirmation. Confirming an
awaiting order preserves its agreed terms and updates the buyer's local history.
Farmers can mark confirmed orders ready for pickup/delivery, then completed.
They can reject awaiting or confirmed orders with a required reason visible to
the buyer. Rejection releases local stock; completion keeps it consumed. The
signed-in farmer can manage only their own farm.

Under Manage products, farmers can publish an offer for an existing product type
or create a new product type. They can edit price, total stock, minimum quantity,
pickup region, product details and delivery availability/fee. The buyer catalog
uses those saved offers immediately. Stock already committed to orders cannot be
removed, and existing orders keep their accepted prices. Custom product types use
neutral image placeholders. Buyers and farmers can open Price history to inspect
dated unit-price and delivery-fee changes. Only successful publications and
price/fee edits are recorded; earlier history is not invented. These changes
remain local to this device/browser.

The app now starts with local sign-in and buyer/farmer registration. Registration
creates an independent buyer history or a new farm; it never grants administrator
access. Logout clears the navigation stack. Accounts, farms, offers and orders
persist together, but sessions do not: sign in again after restarting. Older demo
orders belong to the seeded Demo Buyer account.

Demo credentials (fictional, shared password `FarmDemo2026!`):

| Role | Email |
| --- | --- |
| Buyer | `buyer@farm.demo` |
| Farmer — Bereke | `bereke@farm.demo` |
| Administrator | `admin@farm.demo` |

Administrators can block or unblock buyer/farmer accounts and hide or restore
individual farmer offers, with a required reason of 5–300 characters. Blocked
accounts cannot sign in; a blocked farmer's offers leave the catalog. Explicitly
hidden offers stay hidden when their farmer is unblocked. A product type leaves
the catalog when it has no visible offers. Existing orders, prices and committed
stock are preserved, and cached checkout cannot order an unavailable offer.
Administrators are protected against blocking. Farmers see why an offer is hidden
and can edit it, but only an administrator can restore visibility. Restrictions
and their local history survive restart (persistence schema v5; v1–4 migration).

The sign-in screen also lists the other four fixture farmer accounts. Passwords
are stored as salted PBKDF2-HMAC-SHA256 hashes (100,000 iterations), using
[cryptography](https://pub.dev/packages/cryptography). This is a local prototype,
not server authentication: device/browser data can be inspected or changed by its
owner. Use sample data and a demo password. There is no email verification,
password recovery, real payment, backend authorization or cross-device sync.

[Prototype walkthrough and limitations](docs/prototype/catalog-and-offers.md)

## Run the Flutter Client

Requirements: Flutter 3.41.9 with Dart 3.11.5 or a compatible newer SDK.

```sh
cd apps/mobile
flutter pub get
flutter run
```

In Android Studio, open the `apps/mobile` folder, enable the Flutter/Dart plugins,
and select an Android emulator or connected device. Android SDK licenses must be
accepted locally before an Android build. For a browser preview, use
`flutter run -d chrome`.

For iPhone Simulator on macOS, install Xcode and an iOS simulator runtime, then
start Simulator, select its device in Android Studio, and run the same Flutter
project. You can also run `flutter run -d <simulator-id>` after `flutter devices`.
Open `apps/mobile/ios/Runner.xcworkspace` when working directly in Xcode.

## Check the Client

```sh
cd apps/mobile
flutter analyze
flutter test
```

## Project Tracking

[YouTrack FARM project](https://farm-direct-procurement.youtrack.cloud/projects/FARM)

The buyer prototype is tracked in FARM-8; farmer/admin prototype work is tracked
in FARM-9. The current farmer increment covers incoming orders, the full order lifecycle and
offer management. The administrator dashboard supports account blocking/unblocking,
hiding/restoring farmer offers, and a dated moderation history with reasons.
Each implementation stage is developed on a task branch and submitted for review.

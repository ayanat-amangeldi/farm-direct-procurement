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

The initial buyer prototype is tracked in FARM-8. Each implementation stage is
developed on a task branch and submitted for review.

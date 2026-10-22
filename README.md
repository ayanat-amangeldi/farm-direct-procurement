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

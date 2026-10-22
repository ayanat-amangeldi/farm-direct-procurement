# Catalog and Farmer Offers Prototype

This first implementation covers product discovery, comparison of farmer offers,
and an interactive price preview. It is a Flutter application with shared UI for
Android, iOS, and web. All farms, inventory, and prices are fictional fixtures.
Product photography is illustrative and generated; it does not depict real
listed stock. See [image sources and prompts](image-sources.md).

## Demonstration

1. Open the catalog and search for potatoes. Search ignores case and surrounding
   spaces. Category filters combine with the search; reset clears both.
2. Open Potatoes. Three distinct farmer offers appear, sorted by unit price.
3. Compare stock, minimum quantity, location, pickup, and delivery charges.
4. Select Delivery available to exclude the pickup-only offer. Use the sort menu
   to sort by farm name instead of unit price.
5. Open Bereke Family Farm. The minimum quantity is 50 kg at KZT 190 per kg.
6. Pickup totals KZT 9,500. Selecting delivery adds KZT 2,500 for KZT 12,000.
7. Enter 49 kg or 801 kg. The quantity is rejected and no misleading total is
   displayed. Enter 100 kg with delivery to see KZT 21,500.
8. Close the preview and return to the catalog. Search and category selection
   survive navigation back from the offers screen.

To demonstrate an empty delivery result, open Wheat and enable Delivery available.
Reset filters returns to its pickup offer.

## Pricing Scope

The demonstration uses whole kilograms and integer KZT amounts. Total equals
quantity times unit price plus the selected disclosed delivery fee. All offers
allow free pickup. A null delivery fee means that delivery is unavailable. Other
fees are explicitly zero in these fixtures. The displayed region is informational;
service-area validation is a later requirement.

## Current Boundaries

No order is submitted or stored. There is no authentication, live backend,
farmer dashboard, administrator dashboard, payment processing, or price history
in this increment. No real stock is reserved. Price history and immutable order
snapshots need server-side design and implementation in later tasks.

FARM-8 remains in progress: order confirmation and order status are not implemented.
This increment does not complete FARM-10's full data contract or price history.

## Screenshots

Captured from the running Flutter web client at a 390 by 844 viewport.

![Product catalog](screenshots/catalog.jpg)

![Farmer offers with delivery filter](screenshots/farmer-offers.jpg)

![Price preview with delivery](screenshots/price-preview.jpg)

## Structure and Checks

- `apps/mobile/lib/catalog`: product/offer models, fixtures, quantity and price rules.
- `apps/mobile/lib/ui`: catalog, offers, preview, and local vector artwork.
- `apps/mobile/test`: business-rule and user-interaction checks.

Run `flutter analyze` and `flutter test` from `apps/mobile`. Browser verification
uses the same Flutter source; Android runtime verification additionally requires
an emulator/device and locally accepted Android SDK licenses.

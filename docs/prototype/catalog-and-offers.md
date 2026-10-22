# Buyer Procurement Prototype

This implementation covers product discovery, comparison of farmer offers,
price calculation, demo checkout, confirmation, and local order history. It is a Flutter application with shared UI for
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
8. Choose Continue to checkout. Use sample details such as Demo Buyer,
   +7 700 000 00 00 and Demo city, Sample Street 1. Delivery requires an address;
   pickup does not. Quantity can still be changed before placing the order.
9. With 50 kg and delivery, place the demo order. Confirmation displays a unique
   local number and KZT 12,000 total with Awaiting confirmation status.
10. Open View all orders, then view the order details. The unit price, delivery fee,
    quantity and total are snapshots of the accepted offer.
11. Refresh/relaunch and use Orders in the catalog header. The same order remains
    on this device/browser. Clearing browser/app data removes this local history.
12. Cancel an awaiting order from its details, confirm the dialog, and use the
    Active / Cancelled history filters. The saved price stays visible and its
    quantity becomes available again in the local demo catalog.

Search and category selection survive navigation back from the offers screen.
Pickup and delivery are both supported through checkout. Validation prevents
missing contacts, invalid phone format, missing delivery address, below-minimum
quantities and ordering above the local remaining stock. Repeated clicks and
failed saves do not create duplicate orders or phantom stock reservations.

To demonstrate an empty delivery result, open Wheat and enable Delivery available.
Reset filters returns to its pickup offer.

## Pricing Scope

The demonstration uses whole kilograms and integer KZT amounts. Total equals
quantity times unit price plus the selected disclosed delivery fee. All offers
allow free pickup. A null delivery fee means that delivery is unavailable. Other
fees are explicitly zero in these fixtures. The displayed region is informational;
service-area validation is a later requirement.

## Current Boundaries

Orders are saved locally using shared_preferences for this demonstration. This is
not suitable as the authoritative store for real procurement or sensitive data;
use sample contact details. If history cannot be loaded, the app preserves it and
switches new orders to session-only mode with a visible notice. Failed writes
show an error and leave the previous order list and local stock unchanged.

No real order is sent to a farmer. There is no authentication, live backend,
farmer dashboard, administrator dashboard, payment processing, or price history.
Stock deductions exist only in one device's demo history; they do not synchronize
between buyers. The server must later enforce inventory, authorization, durable
order snapshots and status transitions.

FARM-8 remains in progress until its complete acceptance criteria are reviewed.
The buyer can create an Awaiting confirmation order or cancel it. Confirmed,
Ready and Completed are modeled for future integration, but the app does not
pretend that a farmer has progressed the order. Farmer confirmation is a later
workflow. This increment does not complete FARM-10's full data contract or price
history.

## Screenshots

Captured from the running Flutter web client at a 390 by 844 viewport.

![Product catalog](screenshots/catalog.jpg)

![Farmer offers with delivery filter](screenshots/farmer-offers.jpg)

![Price preview with delivery](screenshots/price-preview.jpg)

![Order confirmation](screenshots/order-confirmation.jpg)

![My orders](screenshots/my-orders.jpg)

![Saved order details](screenshots/order-details.jpg)

## Structure and Checks

- `apps/mobile/lib/catalog`: product/offer models, fixtures, quantity and price rules.
- `apps/mobile/lib/orders`: immutable order terms, validation, persistence and stock accounting.
- `apps/mobile/lib/ui`: catalog, offers, checkout, confirmation, order history and details.
- `apps/mobile/test`: business-rule and user-interaction checks.

Run `flutter analyze` and `flutter test` from `apps/mobile`. The 18 checks cover
pricing, filtering, narrow-screen catalog layout, checkout validation, creation,
history restoration, cancellation, overselling, concurrent saves and storage errors.
The web release and iOS Simulator debug builds also pass. Manual browser verification at 390 × 844 covers
creation of a 50 kg delivery order, restart persistence, saved terms, cancellation
and history filters. Android runtime verification still requires an emulator/device
and locally accepted Android SDK licenses.

# Buyer and Farmer Procurement Prototype

This implementation covers product discovery, comparison of farmer offers,
price calculation, demo checkout, local order history, farmer confirmation, and
farmer-managed product offers.
It is a Flutter application with shared UI for
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

## Farmer Confirmation Demonstration

1. Create another buyer order from Bereke Family Farm. Keep it awaiting confirmation.
2. Return to the catalog and open Farmer workspace · demo. The default farm is
   Bereke Family Farm; the selector also offers the other four fixture farms.
3. The Awaiting filter shows only orders belonging to the selected farm, with
   buyer name, product, quantity, fulfillment and saved total. Check Confirmed and
   All orders to see the other statuses, including cancelled orders.
4. Open the awaiting order. Inspect the original unit price, fees, contact details,
   address/pickup region and note. Select Confirm demo order and accept the dialog.
5. The status becomes Confirmed and a confirmation timestamp appears. Saved price,
   quantity, delivery terms and stock reservation are unchanged. Confirmation does
   not reserve the same stock a second time.
6. Return to the buyer's My orders. The same order now shows Confirmed, including
   after a refresh/relaunch. It can no longer be cancelled by the buyer in this
   prototype. Cancelled or confirmed orders cannot be confirmed again.
7. Select Saryarka Farm to verify that Bereke orders do not appear there. If no
   orders exist, the empty state explains how to create an order for that farm.

Older local orders are mapped to farms by their known offer IDs when loaded.
Unknown historical offers remain in buyer history but are not assigned to any
farm. The selector is a local demo role switch, not a security boundary or login;
real accounts and server authorization are still required.

## Farmer Product Management Demonstration

1. Open Farmer workspace, select Bereke Family Farm, then Manage products. The
   list shows its offers, current price, total stock, committed quantity and the
   quantity still available to new buyers.
2. Choose Add product. To join an existing comparison group, select a product type
   that this farm does not already list. Types already listed are disabled; edit
   their existing offers instead.
3. To create a new group, leave New product type selected. Enter Onions, category
   Vegetables, KZT 220/kg, total stock 100 kg, and minimum order 10 kg. Enable
   delivery and enter KZT 700. Add a pickup region and optional offer details.
4. Publish. The new product type and farm offer are saved together. Return to the
   buyer catalog and search for Onions: a new product card shows Bereke's offer.
5. Return to Manage products and edit Onions to KZT 240/kg. Save, then refresh.
   The buyer still sees Onions at KZT 240/kg. A quote for 10 kg with delivery is
   KZT 2,400 + KZT 700 = KZT 3,100.
6. Existing orders retain their original price, quantity and delivery fee. If an
   offer changes while an old quote is open, checkout rejects that stale quote
   and asks the buyer to reopen the offer before ordering.
7. Total stock includes saved, non-cancelled orders. It cannot be set below the
   committed quantity. Zero stock pauses an uncommitted offer; offers without
   enough remaining stock for the minimum order are unavailable to new buyers.
8. Switching to another farm shows that farm's product list. An offer cannot be
   edited on behalf of another selected farm. The product type of a published
   offer stays fixed to preserve comparison groups; all other listed terms can
   be edited. Product type names are unique, ignoring case and outer spaces.

Quantities are whole kg (up to 1,000,000); prices and per-order delivery fees are
whole KZT (up to 10,000,000). Price/minimum must be positive, stock and delivery
fee may be zero. Delivery can be disabled, while pickup is always free. Stock
must cover its minimum order unless zero. New types use a neutral image
placeholder; uploading product photography remains future work.

Catalog and orders share one versioned local save and one write lock. Version-1
order-only history migrates to version 2 with the original catalog, preserving
orders and their agreed terms. Failed writes publish neither a partial product
nor a partial offer. Unreadable saved data is preserved with session-only fallback.

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

No real order is sent to a farmer. The farmer workspace is a local demonstration.
There is no authentication, live backend, administrator dashboard, payment
processing, image upload, or price history.
Stock deductions exist only in one device's demo history; they do not synchronize
between buyers. The server must later enforce inventory, authorization, durable
order snapshots and status transitions.

FARM-8 remains in progress until its complete acceptance criteria are reviewed.
The buyer can create an Awaiting confirmation order or cancel it. The farmer can
confirm an awaiting order, with the change visible to the buyer on the same device.
Ready and Completed remain future transitions. FARM-9 remains open for its administrator requirements and acceptance review;
farmer incoming orders, confirmation and offer management are implemented. This does not complete FARM-10's full data contract
or price history.

## Screenshots

Captured from the running Flutter web client at a 390 by 844 viewport.

![Product catalog](screenshots/catalog.jpg)

![Farmer offers with delivery filter](screenshots/farmer-offers.jpg)

![Price preview with delivery](screenshots/price-preview.jpg)

![Order confirmation](screenshots/order-confirmation.jpg)

![My orders](screenshots/my-orders.jpg)

![Saved order details](screenshots/order-details.jpg)

![Farmer incoming orders](screenshots/farmer-incoming-orders.jpg)

![Farmer confirmed order](screenshots/farmer-confirmed-order.jpg)

![Confirmed status in buyer history](screenshots/buyer-confirmed-order.jpg)

![Farmer-created product in buyer catalog](screenshots/custom-product-catalog.jpg)

## Structure and Checks

- `apps/mobile/lib/catalog`: farm/product/offer models, fixtures, quantity and price rules.
- `apps/mobile/lib/orders`: immutable order terms, validation, persistence and stock accounting.
- `apps/mobile/lib/ui`: catalog, offers, checkout, confirmation, buyer/farmer order lists and details.
- `apps/mobile/test`: business-rule and user-interaction checks.

Run `flutter analyze` and `flutter test` from `apps/mobile`. The 34 checks cover
pricing, filtering, narrow-screen catalog layout, checkout validation, creation,
history restoration, cancellation, overselling, concurrent saves, storage errors,
farm ownership, confirmation, immutable terms, legacy history migration and
narrow-screen farmer layout, product publication/editing, catalog restoration,
stock-edit constraints, stale quotes, duplicate prevention, atomic save failures
and the publication form on a narrow screen with larger text.
The web release and iOS Simulator debug builds also pass. Manual browser verification at 390 × 844 covers
creation of a 50 kg delivery order, restart persistence, saved terms, cancellation
and history filters. Farmer verification adds role switching, farm-specific empty
states, confirmation and the persisted Confirmed status in buyer history.
Product-management verification publishes Onions, changes its price, refreshes,
and checks the updated catalog card and KZT 3,100 delivery quote.
Android runtime verification still requires an emulator/device
and locally accepted Android SDK licenses.

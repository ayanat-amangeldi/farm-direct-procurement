# 4. Existing System Comparison

[Documentation index](README.md) · [Complete report with figures](report/farm-direct-pre-defense-report.docx)

This is a readable copy of the corresponding section of the supplied English report. The complete Word report retains its original text, layout and figures.

## 4.1. Purpose and Method

This comparison examines existing systems that support agricultural sales, local food distribution, and direct procurement. Its purpose is to identify established approaches and determine which requirements need particular attention in the proposed system.

Four systems were selected:

- Open Food Network: supports producer shops and food hubs selling products from multiple producers. [Official overview](https://about.openfoodnetwork.org.uk/open-my-shop/)

- Local Food Marketplace: provides sales, inventory, and distribution software for farms, food hubs, cooperatives, and markets. [Official overview](https://home.localfoodmarketplace.com/)

- Local Line: supports farm storefronts, multi-vendor operations, and direct procurement by business buyers. [Supplier features](https://www.localline.co/suppliers), [Buyer features](https://www.localline.co/buyers)

- Barn2Door: supports individual farm businesses managing direct retail and wholesale sales through their own online stores. [Seller overview](https://www.barn2door.com/seller-faqs)

These systems are relevant functional comparators. Their inclusion does not imply that their services, payment integrations, or operating arrangements have been verified for Kazakhstan.

The assessment uses publicly available official documentation and product descriptions reviewed on 23 October 2026. No authenticated operational testing of the commercial systems was performed. Consequently, documented capabilities are distinguished from unverified features, and no comparative claims about usability, performance, or reliability are made.

## 4.2. Comparison Criteria

Nine criteria were selected to reflect the project’s procurement scenario and transparency objectives:

1. Primary users and operating model.

2. Support for multiple producers.

3. Comparison of products across suppliers.

4. Product and inventory management.

5. Price and additional-charge information.

6. Order management and fulfilment.

7. Payment support.

8. Buyer-visible history of offer-price changes.

9. Deployment and customisation model.

## 4.3. Comparison Matrix

ND — not documented in the reviewed sources. Feature availability may depend on configuration, subscription plan, or deployment.

| Criterion | Open Food Network | Local Food Marketplace | Local Line | Barn2Door |
| --- | --- | --- | --- | --- |
| 1. Primary users and operating model | Producer shops and community food hubs. [Source](https://about.openfoodnetwork.org.uk/open-my-shop/) | Farms, food hubs, markets, and retail or business customers. [Source](https://home.localfoodmarketplace.com/) | Farms, food hubs, and business procurement teams. [Sources](https://www.localline.co/suppliers), [buyers](https://www.localline.co/buyers) | Farm businesses selling directly to retail and wholesale customers. [Source](https://www.barn2door.com/seller-faqs) |
| 2. Multiple producers | Hubs can sell products from several producers. [Source](https://about.openfoodnetwork.org.uk/open-my-shop/) | Multi-producer operations and dedicated producer portals are documented. [Source](https://home.localfoodmarketplace.com/pricing/) | Connected and managed vendors are supported. [Source](https://www.localline.co/suppliers) | Reviewed materials describe separate farm stores; a shared multi-farm catalog is ND. [Source](https://www.barn2door.com/buyer-faqs) |
| 3. Cross-supplier product comparison | Shopfront search and filters are documented; a standard product page grouping competing offers is ND. [Source](https://guide.openfoodnetwork.org/basic-features/shopfront) | Multi-producer sales are documented; a dedicated same-product comparison interface is ND. [Source](https://home.localfoodmarketplace.com/) | Product search across approved suppliers explicitly supports comparing products from different suppliers. [Source](https://support.localline.ca/kb/buyers/placing-orders/browsing-and-searching-products) | Buyers find farms and browse their individual stores; cross-farm product comparison is ND. [Source](https://www.barn2door.com/buyer-faqs) |
| 4. Product and inventory management | Producer catalogs, variants, and hub-specific prices and stock are documented. [Source](https://guide.openfoodnetwork.org/basic-features/products-1) | Producers can update availability; inventory and harvest-to-order workflows are supported. [Source](https://home.localfoodmarketplace.com/) | Product variants, stock controls, and connected-vendor inventory management are documented. [Source](https://www.localline.co/suppliers) | Inventory synchronisation, packaging options, and multiple price lists are documented. [Source](https://www.barn2door.com/inventory) |
| 5. Price and additional-charge information | Customers can inspect product-price components; enterprise and shipping fees are configurable. [Sources](https://guide.openfoodnetwork.org/basic-features/shopfront/enterprise-fees), [shipping](https://guide.openfoodnetwork.org/basic-features/shopfront/shipping-methods) | Price lists and invoicing are documented; the exact buyer-facing fee breakdown is ND. [Source](https://home.localfoodmarketplace.com/) | Unit prices, supplier subtotals, and cart totals are documented; the reviewed ordering guide does not specify delivery-fee itemisation. [Source](https://support.localline.ca/kb/buyers/placing-orders/building-an-order) | Farmers set prices; separate delivery charges are supported. Subscription receipts show delivery fees and taxes separately. [Sources](https://www.barn2door.com/legal), [receipts](https://www.barn2door.com/blog-all/delivery-subscription-improvements-your-farm-cant-live-without) |
| 6. Orders and fulfilment | Order cycles, order editing, delivery, and collection methods are documented. [Source](https://about.openfoodnetwork.org.uk/open-my-shop/) | Live orders, packing lists, delivery sheets, and invoices are documented. [Source](https://home.localfoodmarketplace.com/) | Supplier-specific orders progress through submitted, scheduled, packed, delivery, and fulfilled states. [Source](https://support.localline.ca/kb/buyers/placing-orders/building-an-order) | Order confirmations, delivery or pickup selection, reminders, and farmer-managed order changes are documented. [Source](https://www.barn2door.com/buyer-faqs) |
| 7. Payments | Online payment providers and manually recorded cash or bank-transfer methods are documented; availability varies by instance. [Source](https://guide.openfoodnetwork.org/basic-features/shopfront/payment-methods) | Integrated payment processing, scheduled payments, and invoicing are documented. [Source](https://home.localfoodmarketplace.com/) | Card, bank-based payments, and supplier payment terms are documented, depending on configuration. [Source](https://support.localline.ca/kb/buyers/getting-started/how-wholesale-ordering-works) | Card, ACH, and farmer-approved cash or cheque payments are documented. [Source](https://www.barn2door.com/buyer-faqs) |
| 8. Buyer-visible dated offer-price history | ND. | ND. | ND; order history is documented, which is a different function. [Source](https://support.localline.ca/kb/your-account) | ND; customer order history is documented, which is a different function. [Source](https://www.barn2door.com/buyer-faqs) |
| 9. Deployment and customisation | Open-source software under the AGPL-3.0 licence; hosted regional services also exist. [Sources](https://github.com/openfoodfoundation/openfoodnetwork), [UK service](https://about.openfoodnetwork.org.uk/pricing/) | Commercial service with subscription plans and storefront customisation options. [Source](https://home.localfoodmarketplace.com/pricing/) | Commercial platform with subscription plans and storefront configuration. [Source](https://www.localline.co/suppliers/pricing) | Hosted farm stores with subscription plans and website services. [Source](https://www.barn2door.com/pricing) |

## 4.4. Critical Analysis

### Open Food Network

Open Food Network provides a relevant reference for both multi-producer selling and pricing transparency. Its documented price-component display demonstrates that transparency mechanisms already exist in agricultural commerce. Its configurable fees and open-source code also make it a potential adaptation option. Whether adopting it would meet the project’s exact interface and workflow requirements would require a separate fit assessment. [Enterprise fees](https://guide.openfoodnetwork.org/basic-features/shopfront/enterprise-fees), [Source repository](https://github.com/openfoodfoundation/openfoodnetwork)

### Local Food Marketplace

Local Food Marketplace demonstrates an operationally broader approach, connecting producer availability with packing, distribution, payments, and reporting. These capabilities provide useful references for future development. The proposed project has a narrower initial scope, concentrating on offer selection, explicit purchasing terms, and order progression. The reviewed public materials are insufficient to determine the exact behaviour of its comparison interface or historical price display. [Official features](https://home.localfoodmarketplace.com/)

### Local Line

Local Line is a close functional comparator because its documentation explicitly describes searching for a product across suppliers and placing supplier-specific orders. Its documented fulfilment states also overlap with the project’s order-management requirements. Therefore, cross-supplier purchasing and order tracking cannot be presented as unique project features. Further investigation would be needed to assess how its configurations match the intended users and operating context. [Product comparison](https://support.localline.ca/kb/buyers/placing-orders/browsing-and-searching-products), [Order workflow](https://support.localline.ca/kb/buyers/placing-orders/building-an-order)

### Barn2Door

Barn2Door illustrates a farm-centred sales model, with inventory, fulfilment, and customer communication organised around an individual farm’s store. This is a useful reference for the farmer workspace. The documented buyer journey begins with selecting a farm and entering its store, whereas the proposed application begins with a product type and then presents available farmer offers. [Buyer workflow](https://www.barn2door.com/buyer-faqs), [Inventory features](https://www.barn2door.com/inventory)

## 4.5. Implications for the Proposed System

The comparison shows that existing systems already address substantial parts of agricultural e-commerce. It supports implementing a focused procurement workflow and evaluating its suitability for the intended users.

The proposed system prioritises:

- Product-first navigation: buyers select a product type and inspect offers from several farmers.

- Consistent offer information: unit price in KZT/kg, available quantity, minimum quantity, and delivery or pickup conditions.

- Explicit totals: product subtotal, delivery charge, and final amount before order submission.

- Preserved order terms: later offer edits do not change the price and quantity recorded in an existing order.

- Dated price changes: records identify previous and updated prices and the time of change.

- Connected role workflows: buyers place orders, farmers manage fulfilment, and administrators moderate accounts and offers.

The absence of documented buyer-visible price history in the reviewed materials is an evidence limitation, not proof that the compared systems lack this capability. A stronger differentiation claim would require demonstrations, trial access, or confirmation from the providers.

The current project is a local Flutter prototype using fictional data and device-local persistence. It does not yet provide shared server storage, cross-device synchronisation, or real payment processing. Accordingly, this comparison establishes design references and requirements; it does not demonstrate that the prototype outperforms operational commercial platforms.

The need for the proposed solution is grounded in the reported needs of the interviewed users and the opportunity to implement and evaluate a workflow tailored to those needs. Its practical benefits must be established through subsequent user and system evaluation.

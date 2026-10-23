# 2. Evidence of Relevance

[Documentation index](README.md) · [Complete report with figures](report/farm-direct-pre-defense-report.docx)

This is a readable copy of the corresponding section of the supplied English report. The complete Word report retains its original text, layout and figures.

## 2.1. Method and Participants

Four interviews were conducted with representatives of the intended user groups: two farmers, one individual buyer, and one business buyer. Each interview covered five open-ended questions about current practices, information needs, pricing, supplier comparison, stock management, and order coordination.

Participants are identified using anonymous codes.

| Participant | User group | Profile |
| --- | --- | --- |
| F1 | Farmer | Sells agricultural products through regular customers, recommendations, phone calls, and WhatsApp. |
| F2 | Farmer | Supplies milk and dairy products to individual customers and small shops. |
| B1 | Individual buyer | Purchases vegetables and dairy products for household consumption in Astana. |
| B2 | Business buyer | Purchases agricultural products regularly for a small café in Astana. |

## 2.2. Main Findings

Communication and order management. Both farmers receive orders primarily through WhatsApp and phone calls. They use notebooks or phone records to manage orders rather than specialised software. F1 reported difficulties tracking orders across different conversations. Both buyers also described using calls and messages to communicate with suppliers.

Stock availability. F1 reported occasionally forgetting to update available quantities after receiving an order. F2 explained that dairy production varies daily, requiring available quantities to be checked against existing orders. These responses indicate a need to coordinate stock information with order commitments.

Supplier comparison. B1 compares sellers through market visits and sometimes checks advertisements on social media. B2 contacts several suppliers or requests price lists through WhatsApp. Both described difficulties comparing offers when information is incomplete or changes frequently.

Pricing and purchasing conditions. Both buyers reported that delivery charges and minimum order quantities are not always communicated at the beginning of a direct purchase. B2 sometimes calculates the final cost manually to compare suppliers. F1 also noted that updated prices do not always reach every regular customer.

Order confirmation and cancellation. Both farmers identified last-minute cancellations as a problem. F2 explained that cancellations and quantity changes are particularly difficult after perishable products have been prepared. Buyers described receiving confirmations through messages or calls, sometimes needing additional communication to obtain delivery updates.

Factors beyond price. Participants highlighted product quality, freshness, origin, available quantity, and delivery reliability. F2 also mentioned production dates and storage conditions for dairy products, while B2 emphasised consistent supply and the availability of necessary documents.

## 2.3. Implications for System Requirements

| Finding | Supporting interviews | Requirement or design implication |
| --- | --- | --- |
| Orders and communications are distributed across calls and messages. | F1, F2, B1, B2 | Provide a central workspace for placing, viewing, and managing orders. |
| Stock is maintained manually and may become outdated. | F1, F2 | Allow farmers to update available quantities and validate stock when orders are placed. |
| Comparing suppliers requires gathering information from separate sources. | B1, B2 | Display offers from multiple farmers for the same product using consistent comparison fields. |
| Delivery charges and minimum quantities may be communicated late. | B1, B2 | Display minimum order quantities, delivery charges, and the final total before order submission. |
| Updated prices do not always reach customers. | F1 | Maintain current offer prices and preserve the prices accepted in existing orders. |
| Cancellations and quantity changes complicate preparation. | F1, F2 | Define explicit order states and cancellation rules, recording the agreed quantity and updating stock commitments accordingly. |
| Buyers consider quality, origin, and fulfilment conditions alongside price. | F1, F2, B1, B2 | Include relevant product descriptions, farmer information, and delivery or pickup conditions. |

These requirements are the team’s interpretation of the reported problems. They translate user experiences into proposed system behaviour rather than imply that participants specified the technical solution.

## 2.4. Interpretation and Limitations

The interviews provide initial qualitative evidence that the proposed system addresses relevant procurement difficulties. In particular, the findings support comparable farmer offers, clear purchasing conditions, stock validation, and traceable order statuses.

Some features remain design decisions requiring further validation. For example, price history is proposed as a mechanism for improving transparency; participants did not explicitly request a historical price log. More specialised needs, such as dairy storage information and business purchasing documents, require further analysis before inclusion in the project scope.

The sample comprises four participants and does not represent all farmers or buyers. The interviews establish reported needs but do not demonstrate that the application reduces purchasing time or costs. Those outcomes, together with usability and administrator workflows, require separate evaluation.

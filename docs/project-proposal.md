# 1. Project Proposal

[Documentation index](README.md) · [Complete report with figures](report/farm-direct-pre-defense-report.docx)

This is a readable copy of the corresponding section of the supplied English report. The complete Word report retains its original text, layout and figures.

## Project Title

Development of an Information System for Direct Procurement of Agricultural Products from Small-Scale Farms with Transparent Pricing

## Team Members and Responsibilities

Ayanat Amangeldi — Backend and Transparent Pricing Module

Responsible for analysing procurement processes, designing the data model and API, and developing order-processing rules, price calculations and price-history functionality.

Dilyara Anetbayeva — Frontend and Procurement Scenarios

Responsible for designing and developing the Flutter interface, including the product catalog, farmer-offer comparison, checkout, order tracking, and farmer and administrator workspaces.

Requirements analysis, architecture decisions, integration, testing, documentation and preparation of demonstrations are shared responsibilities.

Supervisor: Aldiyar Salkenov <br>Educational Programme: Software Engineering<br>University: Astana IT University

## Problem Statement

Direct agricultural procurement requires buyers to compare more than the advertised product price. Available quantity, minimum order size, location and delivery charges also affect whether an offer meets their needs. When these details are provided separately, buyers must collect and combine the information before making a purchasing decision.

Farmers also need a consistent way to publish offers, update prices and quantities, and manage incoming orders. Changes to an offer create an additional requirement: both parties should be able to distinguish the terms accepted for an existing order from the conditions offered to new buyers.

The project proposes an information system that brings these activities into a shared procurement workflow. The initial problem assumptions will be validated through discussions with farmer and buyer representatives. Improvements in comparison time or price comprehension will be evaluated rather than assumed.

## Target Users

The system is intended for three user groups:

- Small-scale farmers who publish agricultural products, specify prices and fulfillment conditions, and manage incoming orders.

- Individual and business buyers who search for products, compare offers from different farms, place orders and track their progress.

- Platform administrators who oversee accounts, product offers and orders, and manage account restrictions and offer visibility.

## Project Aim

The aim is to develop and evaluate an information system that supports direct procurement of agricultural products from small-scale farms by enabling offer comparison, clear price calculation and traceable order management.

## Project Objectives

1. Identify and document functional and non-functional requirements, with priorities and verifiable acceptance criteria.

2. Design a data model covering users, farms, products, farmer offers, orders and price changes.

3. Develop a Flutter interface supporting buyer, farmer and administrator workflows.

4. Enable buyers to compare at least three offers for the same demonstration product using unit price, available quantity, minimum order and delivery conditions.

5. Display the item subtotal, delivery charge and final total before order placement, and preserve accepted prices throughout the order lifecycle.

6. Record offer-price changes with the previous value, new value, timestamp and responsible farm.

7. Verify calculations, quantity constraints, role permissions and order transitions through automated tests and repeatable demonstrations.

8. Evaluate task completion and understanding of the final price using representative-user feedback and a defined comparison baseline.

## Proposed Solution

The system separates generic products from individual farmer offers. For example, a buyer selects Potatoes from the catalog and then compares offers from several farms. Each offer presents its unit price, available quantity, minimum order, location and pickup or delivery conditions.

After selecting an offer, the buyer enters a quantity and reviews the price breakdown. The system validates the quantity and calculates the total before the order is placed. Accepted quantities, prices and delivery charges are saved with the order so that later offer changes do not alter the agreed terms.

Farmers manage their own offers and incoming orders. The supported order lifecycle progresses from awaiting confirmation to confirmed, ready and completed. Farmers may reject an order before readiness with a recorded reason. Buyers may cancel an order while it is awaiting confirmation.

Administrators can block or unblock buyer and farmer accounts and hide or restore individual offers. Moderation decisions include a reason and timestamp. Existing order records remain available to the appropriate users.

## Project Scope

The first-stage prototype covers:

- Local registration, sign-in and role-specific workspaces.

- Product search, category filters and comparison of farmer offers.

- Quantity validation and transparent price breakdowns.

- Demonstration checkout, order history and status tracking.

- Farmer product and offer management.

- Recorded price changes.

- Administrator account restrictions and offer moderation.

The current prototype uses fictional data and stores changes on one device or browser. It demonstrates the main workflows before backend integration.

A subsequent stage will introduce a shared database, API communication and server-side enforcement of authentication, permissions, inventory and order rules. Flutter is the selected client framework. Python/FastAPI and PostgreSQL are backend candidates whose final selection will be justified through a technology comparison.

Online payment processing, automated delivery routing, live logistics tracking and automatic market-price prediction are outside the proposed scope.

## Engineering Complexity

The main engineering challenges involve maintaining consistent relationships between products and farmer offers, preventing invalid quantities and order transitions, preserving accepted prices, and applying permissions across several roles.

Backend integration will additionally require handling concurrent purchases and ensuring that stock, order status and price history remain consistent when different users access the system. These requirements make data integrity and business-rule verification central parts of the project.

## Expected Outcomes

The project is expected to produce:

- A Flutter application demonstrating complete procurement workflows for buyers, farmers and administrators.

- A documented data model and, at the integration stage, an API connecting the client to shared storage.

- A transparent pricing module with preserved order terms and recorded offer-price changes.

- Automated tests and repeatable scenarios demonstrating whether mandatory requirements are satisfied.

- Project documentation covering requirements, architecture, technology decisions and evaluation results.

The intended practical benefit is clearer comparison of procurement conditions and more traceable communication of agreed prices. The extent of this benefit will be assessed through evaluation.

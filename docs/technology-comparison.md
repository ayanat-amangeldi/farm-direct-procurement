# 5. Technology Comparison

[Documentation index](README.md) · [Complete report with figures](report/farm-direct-pre-defense-report.docx)

This is a readable copy of the corresponding section of the supplied English report. The complete Word report retains its original text, layout and figures.

## 5.1. Purpose and Selection Criteria

This section compares alternatives for four key technical decisions: the client framework, server framework, shared database, and client–server communication approach.

The comparison is guided by the following project needs:

- Support mobile and browser-based access.

- Maintain consistent buyer, farmer, and administrator workflows.

- Validate prices, quantities, and order transitions.

- Preserve accepted purchasing terms and dated price changes.

- Prevent conflicting stock allocations when several buyers place orders.

- Provide documented interfaces and testable business rules.

- Keep development and maintenance manageable for a two-person team.

Technology capabilities are checked against official documentation. The selection is qualitative: no comparative performance benchmarks or development-time measurements have been conducted. Recommendations therefore represent engineering judgements based on the project requirements.

## 5.2. Client Framework

The client must support product browsing, offer comparison, checkout, farmer operations, and administrator functions on different screen sizes.

| Alternative | Relevant capabilities | Trade-offs for this project | Assessment |
| --- | --- | --- | --- |
| Flutter / Dart | Supports Android, iOS, and web, with shared application code and responsive or adaptive layouts. [Documentation](https://docs.flutter.dev/ui/adaptive-responsive) | Layouts, input methods, browser behaviour, and platform integrations still require separate verification. Flutter web is primarily intended for application experiences rather than text-heavy websites. [Web guidance](https://docs.flutter.dev/platform-integration/web/faq) | Selected and already used in the prototype. |
| React Native with Expo / TypeScript | Supports universal applications targeting Android, iOS, and web from a shared project. Platform-specific files and components can be used where necessary. [Documentation](https://docs.expo.dev/tutorial/introduction/) | Would require replacing the existing Dart implementation. Shared code would not eliminate platform-specific adjustments and testing. | A suitable alternative, particularly for a project organised around React and TypeScript. |
| Ionic with Capacitor | Uses web technologies to deliver web applications and packaged Android and iOS applications. Capacitor provides access to native functionality through plugins. [Documentation](https://capacitorjs.com/docs) | Native capabilities and browser fallbacks require checking across targets. Adopting it now would require rebuilding the client using a web technology stack. | A suitable alternative for a web-first implementation. |

### Decision and justification

Flutter is retained because it supports the intended mobile and browser interfaces and provides continuity with the working prototype. Existing catalog, order, pricing, and role workflows can be extended rather than reimplemented.

This decision does not assume that one layout will suit every device. Phone, tablet, and desktop layouts must be adapted and checked individually. Browser accessibility and navigation also require evaluation.

A separate public information website could be considered later if search-engine visibility or extensive editorial content becomes a requirement. It is outside the current procurement application scope.

## 5.3. Server Framework

The shared system requires an authoritative backend for account permissions, offer updates, order processing, stock allocation, and historical records.

| Alternative | Relevant capabilities | Trade-offs for this project | Assessment |
| --- | --- | --- | --- |
| FastAPI / Python | Provides request validation through Pydantic, dependency injection, OpenAPI generation, and interactive API documentation. [Documentation](https://fastapi.tiangolo.com/features/) | Database integration, migrations, account management, and business permissions must be assembled and implemented explicitly. | Recommended for the planned backend. |
| Django with Django REST Framework / Python | Combines Django’s application and data-management facilities with API serialization, authentication policies, and permissions. Django also provides an internal administration interface. [DRF documentation](https://www.django-rest-framework.org/), [Django admin](https://docs.djangoproject.com/en/stable/ref/contrib/admin/) | Introduces Django-specific application conventions. Its administration interface would supplement, rather than automatically replace, the planned Flutter administrator workflow. | A strong alternative when integrated administration and Django conventions are priorities. |
| NestJS / TypeScript | Provides modular server organisation, request-validation mechanisms, access-control guards, and OpenAPI tooling. [Validation](https://docs.nestjs.com/techniques/validation), [Guards](https://docs.nestjs.com/guards), [OpenAPI](https://docs.nestjs.com/openapi/introduction) | Requires a TypeScript backend and separate choices for database access, migrations, and authentication integration. | A suitable alternative for a TypeScript-based server architecture. |

### Decision and justification

FastAPI is recommended for an API-focused backend serving the Flutter client. Its validation and generated documentation fit the need to define explicit contracts for offers, quantities, prices, and order actions.

Django REST Framework remains a viable alternative, especially if built-in administrative facilities become a higher priority. NestJS also meets the general API requirements; this comparison does not establish a performance advantage for FastAPI.

Regardless of framework, project-specific rules require implementation. Authentication alone must not allow a farmer to edit another farm’s offers or a buyer to access another buyer’s orders. Framework validation also does not automatically enforce stock availability or permitted order transitions.

## 5.4. Shared Database

The data model contains relationships between users, farms, product types, offers, orders, and price changes. Several records may need to be updated together when an order is placed or cancelled.

| Alternative | Relevant capabilities | Trade-offs for this project | Assessment |
| --- | --- | --- | --- |
| PostgreSQL | Provides relational constraints, foreign keys, transactions, and concurrency-control mechanisms. These support connected procurement records and atomic updates. [Constraints](https://www.postgresql.org/docs/current/ddl-constraints.html), [Transaction isolation](https://www.postgresql.org/docs/current/transaction-iso.html) | Requires schema migrations, database operation, backups, and deliberate transaction design. | Recommended for the shared database. |
| MySQL with InnoDB | Supports transactions, row-level locking, and foreign-key constraints. It can also support the proposed relational model. [Documentation](https://dev.mysql.com/doc/refman/8.4/en/innodb-introduction.html) | Requires similar operational and transaction-design work. Database-specific behaviour must be considered during implementation. | A technically valid relational alternative. |
| Cloud Firestore | Stores documents in collections and supports atomic transactions across documents. [Data model](https://firebase.google.com/docs/firestore/data-model), [Transactions](https://firebase.google.com/docs/firestore/manage-data/transactions) | Relationships and cross-record consistency require document-oriented modelling and explicit validation. Transaction retries and managed-service usage limits must be considered. | A suitable alternative if a managed document-oriented architecture is preferred. |

### Decision and justification

PostgreSQL is recommended because the project has a clearly relational structure and needs explicit constraints, connected queries, and transactional order processing. It also allows the team to maintain a directly inspectable schema for requirements, diagrams, and integration tests.

MySQL with InnoDB could satisfy the same core requirements. PostgreSQL is a proposed baseline, not a conclusion that MySQL is incapable or slower.

Firestore also supports atomic operations. The reason for preferring PostgreSQL is the fit between the project’s relationships and a relational schema, rather than an assumption that document databases cannot maintain consistency.

For example, placing an order should validate the current offer, reserve the required quantity, and record accepted purchasing terms within a coordinated transaction. Preventing overselling depends on the implemented transaction strategy; choosing PostgreSQL alone does not guarantee it.

## 5.5. Client–Server Communication

The client needs to retrieve catalog information, submit orders, update offers, and request authorised state changes.

| Alternative | Relevant capabilities | Trade-offs for this project | Assessment |
| --- | --- | --- | --- |
| REST-style HTTP API with JSON | Resource-oriented endpoints can expose catalog, offer, and order operations. OpenAPI can describe request bodies, responses, and authentication requirements. [OpenAPI specification](https://spec.openapis.org/oas/latest.html) | Response structures, pagination, error handling, and retry behaviour require explicit design. | Recommended for initial integration. |
| GraphQL | A typed schema allows clients to request selected fields and related data. Queries and mutations support reading and changing application data. [Documentation](https://graphql.org/learn/) | Requires schema and resolver design, field-level authorisation, and control of query complexity. This adds work for the project’s relatively predictable initial screens. | A reasonable alternative if client data needs become more varied. |
| gRPC with Protocol Buffers and gRPC-Web | Uses defined service contracts and generated client code. Browser access can use gRPC-Web; the official example includes a proxy between the browser and backend. [Documentation](https://grpc.io/docs/platforms/web/basics/) | Adds code-generation and browser-integration infrastructure that must be maintained across targets. | A reasonable alternative for strongly service-oriented integration, but not preferred initially. |

### Decision and justification

A REST-style JSON API over HTTPS is recommended because the initial interactions are explicit and predictable: browse products, inspect offers, place an order, manage offers, and change order status. OpenAPI documentation would support agreement between frontend and backend work and provide a basis for integration tests.

GraphQL and gRPC remain capable alternatives. Their additional flexibility or service tooling is not currently necessary to express the planned workflows.

The API must enforce permissions and business rules on the server. It must also define how repeated order submissions, stale prices, unavailable stock, and conflicting status updates are handled. These behaviours are application responsibilities rather than automatic properties of REST.

## 5.6. Proposed Technology Baseline and Implementation Status

| Area | Technology | Current status |
| --- | --- | --- |
| Client application | Flutter / Dart | Implemented in the local prototype; continued use selected. |
| Server framework | FastAPI / Python | Recommended; not connected to the prototype. |
| Shared database | PostgreSQL | Recommended; not connected to the prototype. |
| Client–server interface | REST-style JSON API over HTTPS, documented with OpenAPI | Recommended; not implemented. |
| Prototype persistence | Local JSON stored through shared_preferences | Implemented for fictional demonstration data. |

The current prototype stores accounts, offers, orders, and historical records on one device. This demonstrates workflows but does not provide shared data between users on different devices.

shared_preferences is intended for simple local key-value storage, and its documentation states that it must not be used for critical data. It will therefore not serve as the authoritative store for real procurement transactions. [Package documentation](https://pub.dev/packages/shared_preferences)

The planned architecture places shared data and authoritative business rules on the backend. Mobile and browser clients would access the same service.

## 5.7. Validation of the Proposed Choices

The recommended backend stack remains subject to implementation validation. Initial integration should demonstrate that:

- Mobile and browser clients can use the same documented API.

- Permissions restrict access according to account ownership and role.

- Competing orders cannot allocate more stock than is available.

- Later offer changes preserve accepted order terms.

- Price changes and order transitions produce consistent historical records.

These checks will establish whether the proposed technologies have been integrated correctly. Detailed test cases, measurement conditions, and evaluation metrics are specified separately in the verification and evaluation plan.

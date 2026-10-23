# Architecture Diagrams

These are the diagrams prepared for Section 7 of the English pre-defense report.
The [architecture description](../docs/architecture.md) explains the components,
scenarios, data relationships and requirement mapping.

## Files

| Figure | Subject | Readable vector export | High-resolution image |
| --- | --- | --- | --- |
| 7.1 | System context and external roles | [SVG](figure-7-1-system-context.svg) | [PNG](figure-7-1-system-context.png) |
| 7.2 | Buyer, farmer and administrator use cases | [SVG](figure-7-2-use-cases.svg) | [PNG](figure-7-2-use-cases.png) |
| 7.3 | Draft component architecture | [SVG](figure-7-3-components.svg) | [PNG](figure-7-3-components.png) |

[farm-direct-architecture.drawio](farm-direct-architecture.drawio) is the editable
source for all three figures. It contains three named pages with individual
shapes, labels and connectors. The source is uncompressed diagrams.net XML.

## Editing and Exporting

1. Download the `.drawio` file and open it in diagrams.net or the draw.io desktop
   application.
2. Select the relevant page: System context, Use case diagram or Component
   diagram (draft).
3. Edit the shapes, labels and connectors. Keep the terminology aligned with the
   [requirements](../docs/requirements-specification.md) and
   [technology decisions](../docs/technology-comparison.md).
4. Save the edited `.drawio` source and export the affected page as both SVG and
   PNG, keeping the filenames in the table above. Include any title, legend and
   implementation-status notes needed to interpret the export.
5. Review the source and exports together, update the architecture description
   if the design changes, and include the FARM task ID in the change's branch
   and commit or PR description.

All visible figure titles, subtitles, workflow headings and explanatory notes
are individual text objects in the `.drawio` source. Edit these source objects
before exporting; captions are not added separately to the images.

## Reproducing the Published Exports

The exports are generated directly from the `.drawio` file with draw.io Desktop
32.6.1. From the repository root, run:

```sh
bash diagrams/export.sh
```

On macOS, point the script to the installed executable:

```sh
DRAWIO_BIN="/Applications/draw.io.app/Contents/MacOS/draw.io" bash diagrams/export.sh
```

The script exports pages 1–3 as light-theme SVG at scale 1 and PNG at scale 2,
using the page-size setting and embedding diagram data. SVG fonts are not
embedded. Its temporary application profile is separate from the normal editor
profile; `DRAWIO_PROFILE_DIR` can specify another temporary directory.
The source and all six exports must be reviewed and committed together after
changes. Layout details can depend on the draw.io version and available fonts;
check the rendered images for clipped labels and connector alignment.

## Implementation Status and Review

Flutter screens, `OrderStore`, `OrderPersistence` and `shared_preferences` JSON
form the current local prototype. The HTTP API client, FastAPI service,
PostgreSQL database and server-side transaction/permission enforcement are
planned components. The diagrams do not establish that backend integration or
production security is implemented.

Real payments, courier integration and combined checkout across several farms
are outside the initial scope. Diagram 7.2 treats authentication and ownership
checks as preconditions for protected operations; order placement includes
calculation and disclosure of the total.

Task coordination follows [FARM-16](https://farm-direct-procurement.youtrack.cloud/issue/FARM-16):
Ayanat coordinates the architecture publication, and Dilyara reviews the PR
before merging. The broader report remains joint work as recorded in the
[documentation index](../docs/README.md).

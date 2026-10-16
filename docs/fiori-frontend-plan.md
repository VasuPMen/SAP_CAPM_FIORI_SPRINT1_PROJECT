# Fiori Frontend Build Plan

## Baseline
- Start from `main`, not the previous Fiori PR.
- Remove the legacy frontend bootstrap and legacy Fiori annotations.
- Keep the existing CAP domain model and business services as the source of truth.

## Frontend architecture
- SAP Fiori elements with OData V4.
- SAPUI5 1.120.14.
- Main frontend model: `AnalyticsService` at `/analytics/`.
- Standard Fiori elements floorplans for list reports, object pages, and analytical list pages.
- Flexible Programming Model custom page only where the requirement needs behavior that a standard floorplan cannot provide.

## Build order
1. Application bootstrap, manifest, routing, and UI5 build.
2. Fleet Overview and Asset Detail.
3. Rental operations.
4. Inspection Review and damage evidence.
5. Damage Charge Approval and billing actions.
6. Repair Jobs and maintenance planner/calendar.
7. Configuration and pricing.
8. Integration Monitor and retry action.
9. Management Dashboard and analytical visualizations.
10. End-to-end packaging and final regression validation.

## Validation after each area
- CAP/CDS compilation.
- Fiori annotation compilation.
- Manifest JSON validation.
- UI5 application build.
- MTA packaging validation.
- Runtime smoke checks when a runnable deployment endpoint is available.

## Rules
- Use fields and relationships from `db/schema.cds` and the documented requirements.
- Do not invent unsupported backend fields.
- Keep business actions on the OData service so Fiori elements can generate their parameter dialogs and buttons.
- Do not merge this PR until the complete frontend and validation suite are ready.

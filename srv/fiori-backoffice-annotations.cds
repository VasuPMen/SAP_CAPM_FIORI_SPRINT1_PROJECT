using { AnalyticsService } from './service';

annotate AnalyticsService.Customers with @(
    UI.HeaderInfo: {
        TypeName: 'Customer',
        TypeNamePlural: 'Customers',
        Title: { $Type: 'UI.DataField', Value: companyName },
        Description: { $Type: 'UI.DataField', Value: contactPerson }
    },
    UI.SelectionFields: [companyName, contactPerson, email, phone],
    UI.LineItem: [
        { $Type: 'UI.DataField', Value: companyName, Label: 'Company' },
        { $Type: 'UI.DataField', Value: contactPerson, Label: 'Contact Person' },
        { $Type: 'UI.DataField', Value: email, Label: 'Email' },
        { $Type: 'UI.DataField', Value: phone, Label: 'Phone' },
        { $Type: 'UI.DataField', Value: city, Label: 'City' }
    ]
);

annotate AnalyticsService.Rentals with @(
    UI.HeaderInfo: {
        TypeName: 'Rental',
        TypeNamePlural: 'Rentals',
        Title: { $Type: 'UI.DataField', Value: ID },
        Description: { $Type: 'UI.DataField', Value: rentalStatus }
    },
    UI.SelectionFields: [rentalDate, expectedReturnDate, actualReturnDate, rentalStatus],
    UI.LineItem: [
        { $Type: 'UI.DataField', Value: ID, Label: 'Rental ID' },
        { $Type: 'UI.DataField', Value: customer_ID, Label: 'Customer' },
        { $Type: 'UI.DataField', Value: rentalDate, Label: 'Rental Date' },
        { $Type: 'UI.DataField', Value: expectedReturnDate, Label: 'Expected Return' },
        { $Type: 'UI.DataField', Value: actualReturnDate, Label: 'Actual Return' },
        { $Type: 'UI.DataField', Value: rentalStatus, Label: 'Status' },
        { $Type: 'UI.DataField', Value: totalRentalAmount, Label: 'Total Amount' }
    ]
);

annotate AnalyticsService.ConditionLogs with @(
    UI.HeaderInfo: {
        TypeName: 'Inspection',
        TypeNamePlural: 'Inspections',
        Title: { $Type: 'UI.DataField', Value: inspectionType },
        Description: { $Type: 'UI.DataField', Value: inspector }
    },
    UI.SelectionFields: [inspectionDate, inspectionType, conditionGrade, inspector, locked],
    UI.LineItem: [
        { $Type: 'UI.DataField', Value: equipment_ID, Label: 'Equipment' },
        { $Type: 'UI.DataField', Value: inspectionDate, Label: 'Inspection Date' },
        { $Type: 'UI.DataField', Value: inspectionType, Label: 'Inspection Type' },
        { $Type: 'UI.DataField', Value: conditionGrade, Label: 'Condition Grade' },
        { $Type: 'UI.DataField', Value: inspector, Label: 'Inspector' },
        { $Type: 'UI.DataField', Value: meterReading, Label: 'Meter Reading' },
        { $Type: 'UI.DataField', Value: customerAck, Label: 'Customer Acknowledged' },
        { $Type: 'UI.DataField', Value: locked, Label: 'Locked' }
    ],
    UI.Facets: [
        { $Type: 'UI.ReferenceFacet', Label: 'Inspection Details', Target: '@UI.FieldGroup#InspectionDetails' }
    ],
    UI.FieldGroup #InspectionDetails: {
        Data: [
            { $Type: 'UI.DataField', Value: inspectionDate, Label: 'Inspection Date' },
            { $Type: 'UI.DataField', Value: inspectionType, Label: 'Inspection Type' },
            { $Type: 'UI.DataField', Value: conditionGrade, Label: 'Condition Grade' },
            { $Type: 'UI.DataField', Value: inspector, Label: 'Inspector' },
            { $Type: 'UI.DataField', Value: meterReading, Label: 'Meter Reading' },
            { $Type: 'UI.DataField', Value: notes, Label: 'Notes' },
            { $Type: 'UI.DataField', Value: customerAck, Label: 'Customer Acknowledged' },
            { $Type: 'UI.DataField', Value: locked, Label: 'Locked' }
        ]
    }
);

annotate AnalyticsService.DamageRecords with @(
    UI.HeaderInfo: {
        TypeName: 'Damage',
        TypeNamePlural: 'Damage Records',
        Title: { $Type: 'UI.DataField', Value: damageType },
        Description: { $Type: 'UI.DataField', Value: severity }
    },
    UI.SelectionFields: [damageType, severity, damageStatus, customerLiable, preExisting],
    UI.LineItem: [
        { $Type: 'UI.DataField', Value: ID, Label: 'Damage ID' },
        { $Type: 'UI.DataField', Value: conditionLog_ID, Label: 'Inspection' },
        { $Type: 'UI.DataField', Value: damageType, Label: 'Damage Type' },
        { $Type: 'UI.DataField', Value: severity, Label: 'Severity' },
        { $Type: 'UI.DataField', Value: description, Label: 'Description' },
        { $Type: 'UI.DataField', Value: repairEstimate, Label: 'Repair Estimate' },
        { $Type: 'UI.DataField', Value: customerLiable, Label: 'Customer Liable' },
        { $Type: 'UI.DataField', Value: damageStatus, Label: 'Status' }
    ]
);

annotate AnalyticsService.MaintenanceRecords with @(
    UI.HeaderInfo: {
        TypeName: 'Maintenance Record',
        TypeNamePlural: 'Maintenance Records',
        Title: { $Type: 'UI.DataField', Value: maintenanceType },
        Description: { $Type: 'UI.DataField', Value: status }
    },
    UI.SelectionFields: [equipment_ID, maintenanceType, maintenanceDate, nextMaintenanceDate, status],
    UI.LineItem: [
        { $Type: 'UI.DataField', Value: ID, Label: 'Maintenance ID' },
        { $Type: 'UI.DataField', Value: equipment_ID, Label: 'Equipment' },
        { $Type: 'UI.DataField', Value: maintenanceType, Label: 'Type' },
        { $Type: 'UI.DataField', Value: maintenanceDate, Label: 'Maintenance Date' },
        { $Type: 'UI.DataField', Value: nextMaintenanceDate, Label: 'Next Maintenance' },
        { $Type: 'UI.DataField', Value: serviceProvider, Label: 'Service Provider' },
        { $Type: 'UI.DataField', Value: cost, Label: 'Cost' },
        { $Type: 'UI.DataField', Value: status, Label: 'Status' }
    ]
);

annotate AnalyticsService.RepairBills with @(
    UI.HeaderInfo: {
        TypeName: 'Repair Bill',
        TypeNamePlural: 'Repair Bills',
        Title: { $Type: 'UI.DataField', Value: ID },
        Description: { $Type: 'UI.DataField', Value: billingStatus }
    },
    UI.SelectionFields: [billDate, billingStatus, customer_ID, damage_ID],
    UI.LineItem: [
        { $Type: 'UI.DataField', Value: ID, Label: 'Repair Bill' },
        { $Type: 'UI.DataField', Value: billDate, Label: 'Bill Date' },
        { $Type: 'UI.DataField', Value: customer_ID, Label: 'Customer' },
        { $Type: 'UI.DataField', Value: damage_ID, Label: 'Damage' },
        { $Type: 'UI.DataField', Value: repairAmount, Label: 'Repair Amount' },
        { $Type: 'UI.DataField', Value: taxAmount, Label: 'Tax' },
        { $Type: 'UI.DataField', Value: totalAmount, Label: 'Total' },
        { $Type: 'UI.DataField', Value: billingStatus, Label: 'Billing Status' },
        { $Type: 'UI.DataField', Value: approvalReason, Label: 'Approval Reason' }
    ]
);

annotate AnalyticsService.PricingRules with @(
    UI.HeaderInfo: {
        TypeName: 'Pricing Rule',
        TypeNamePlural: 'Pricing Rules',
        Title: { $Type: 'UI.DataField', Value: damageType },
        Description: { $Type: 'UI.DataField', Value: severity }
    },
    UI.SelectionFields: [damageType, severity],
    UI.LineItem: [
        { $Type: 'UI.DataField', Value: damageType, Label: 'Damage Type' },
        { $Type: 'UI.DataField', Value: severity, Label: 'Severity' },
        { $Type: 'UI.DataField', Value: baseCharge, Label: 'Base Charge' },
        { $Type: 'UI.DataField', Value: labourRate, Label: 'Labour Rate' },
        { $Type: 'UI.DataField', Value: taxPercent, Label: 'Tax %' },
        { $Type: 'UI.DataField', Value: autoApproveLimit, Label: 'Auto Approval Limit' }
    ]
);

annotate AnalyticsService.OutboxMessages with @(
    UI.HeaderInfo: {
        TypeName: 'Integration Message',
        TypeNamePlural: 'Integration Messages',
        Title: { $Type: 'UI.DataField', Value: entityName },
        Description: { $Type: 'UI.DataField', Value: status }
    },
    UI.SelectionFields: [entityName, target, status, createdAt],
    UI.LineItem: [
        { $Type: 'UI.DataField', Value: ID, Label: 'Message ID' },
        { $Type: 'UI.DataField', Value: createdAt, Label: 'Created' },
        { $Type: 'UI.DataField', Value: target, Label: 'Target' },
        { $Type: 'UI.DataField', Value: entityName, Label: 'Entity' },
        { $Type: 'UI.DataField', Value: entityId, Label: 'Entity ID' },
        { $Type: 'UI.DataField', Value: status, Label: 'Status' },
        { $Type: 'UI.DataField', Value: attempts, Label: 'Attempts' },
        { $Type: 'UI.DataField', Value: lastError, Label: 'Error' },
        { $Type: 'UI.DataField', Value: idempotencyKey, Label: 'Idempotency Key' }
    ]
);

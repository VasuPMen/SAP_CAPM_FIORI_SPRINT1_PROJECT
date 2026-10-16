using { AnalyticsService } from '../../srv/service';

annotate AnalyticsService.Equipment with @(
    UI.HeaderInfo: {
        TypeName: 'Equipment',
        TypeNamePlural: 'Equipment',
        Title: { Value: equipmentName },
        Description: { Value: serialNumber }
    },
    UI.SelectionFields: [equipmentName, equipmentType, manufacturer, currentStatus, currentGrade],
    UI.LineItem: [
        { Value: equipmentName, Label: 'Equipment' },
        { Value: equipmentType, Label: 'Type' },
        { Value: manufacturer, Label: 'Manufacturer' },
        { Value: model, Label: 'Model' },
        { Value: serialNumber, Label: 'Serial Number' },
        { Value: currentStatus, Label: 'Status' },
        { Value: currentGrade, Label: 'Condition' },
        { Value: rentalRatePerDay, Label: 'Daily Rental Rate' }
    ],
    UI.Identification: [
        { Value: equipmentName, Label: 'Equipment' },
        { Value: serialNumber, Label: 'Serial Number' },
        { Value: currentStatus, Label: 'Status' }
    ],
    UI.Facets: [
        { $Type: 'UI.ReferenceFacet', Label: 'General', Target: '@UI.FieldGroup#General' },
        { $Type: 'UI.ReferenceFacet', Label: 'Rental', Target: '@UI.FieldGroup#Rental' }
    ],
    UI.FieldGroup #General: {
        Data: [
            { Value: equipmentName, Label: 'Equipment' },
            { Value: equipmentType, Label: 'Type' },
            { Value: manufacturer, Label: 'Manufacturer' },
            { Value: model, Label: 'Model' },
            { Value: serialNumber, Label: 'Serial Number' },
            { Value: currentStatus, Label: 'Status' },
            { Value: currentGrade, Label: 'Condition Grade' },
            { Value: custodian, Label: 'Custodian' },
            { Value: barcode, Label: 'Barcode' }
        ]
    },
    UI.FieldGroup #Rental: {
        Data: [
            { Value: rentalRatePerDay, Label: 'Daily Rental Rate' },
            { Value: purchaseDate, Label: 'Purchase Date' }
        ]
    },
    UI.PresentationVariant #FleetOverviewPV: {
        SortOrder: [{ Property: equipmentName, Descending: false }],
        Visualizations: ['@UI.LineItem']
    },
    UI.SelectionPresentationVariant #FleetOverviewSPV: {
        SelectionVariant: { $Type: 'UI.SelectionVariantType', SelectOptions: [] },
        PresentationVariant: {
            $Type: 'UI.PresentationVariantType',
            SortOrder: [{ Property: equipmentName, Descending: false }],
            Visualizations: ['@UI.LineItem']
        }
    }
);

annotate AnalyticsService.Customers with @(
    UI.HeaderInfo: {
        TypeName: 'Customer',
        TypeNamePlural: 'Customers',
        Title: { Value: companyName }
    },
    UI.SelectionFields: [companyName, contactPerson, email],
    UI.LineItem: [
        { Value: companyName, Label: 'Company' },
        { Value: contactPerson, Label: 'Contact Person' },
        { Value: email, Label: 'Email' },
        { Value: phone, Label: 'Phone' },
        { Value: address, Label: 'Address' }
    ]
);

annotate AnalyticsService.Rentals with @(
    UI.HeaderInfo: {
        TypeName: 'Rental',
        TypeNamePlural: 'Rentals',
        Title: { Value: rentalDate },
        Description: { Value: rentalStatus }
    },
    UI.SelectionFields: [rentalDate, expectedReturnDate, rentalStatus],
    UI.LineItem: [
        { Value: rentalDate, Label: 'Rental Date' },
        { Value: expectedReturnDate, Label: 'Expected Return' },
        { Value: actualReturnDate, Label: 'Actual Return' },
        { Value: rentalStatus, Label: 'Status' },
        { Value: totalRentalAmount, Label: 'Total Amount' }
    ],
    UI.Facets: [
        { $Type: 'UI.ReferenceFacet', Label: 'Rental Details', Target: '@UI.FieldGroup#RentalDetails' }
    ],
    UI.FieldGroup #RentalDetails: {
        Data: [
            { Value: rentalDate, Label: 'Rental Date' },
            { Value: expectedReturnDate, Label: 'Expected Return' },
            { Value: actualReturnDate, Label: 'Actual Return' },
            { Value: rentalStatus, Label: 'Status' },
            { Value: totalRentalAmount, Label: 'Total Amount' }
        ]
    },
    UI.Chart #RentalAmountByStatus: {
        $Type: 'UI.ChartDefinitionType',
        Title: 'Rental Amount by Status',
        ChartType: #Column,
        Dimensions: [rentalStatus],
        DimensionAttributes: [{ $Type: 'UI.ChartDimensionAttributeType', Dimension: rentalStatus, Role: #Category }],
        Measures: [totalRentalAmount],
        MeasureAttributes: [{ $Type: 'UI.ChartMeasureAttributeType', Measure: totalRentalAmount, Role: #Axis1 }]
    },
    UI.SelectionPresentationVariant #ManagementDashboardSPV: {
        SelectionVariant: { $Type: 'UI.SelectionVariantType', SelectOptions: [] },
        PresentationVariant: {
            $Type: 'UI.PresentationVariantType',
            SortOrder: [{ Property: rentalDate, Descending: true }],
            Visualizations: ['@UI.Chart#RentalAmountByStatus', '@UI.LineItem']
        }
    }
);

annotate AnalyticsService.ConditionLogs with @(
    UI.HeaderInfo: {
        TypeName: 'Inspection',
        TypeNamePlural: 'Inspections',
        Title: { Value: inspectionDate },
        Description: { Value: inspectionType }
    },
    UI.SelectionFields: [inspectionDate, inspectionType, conditionGrade, inspector, locked],
    UI.LineItem: [
        { Value: inspectionDate, Label: 'Inspection Date' },
        { Value: inspectionType, Label: 'Type' },
        { Value: conditionGrade, Label: 'Condition' },
        { Value: inspector, Label: 'Inspector' },
        { Value: customerAck, Label: 'Customer Acknowledged' },
        { Value: locked, Label: 'Locked' }
    ],
    UI.Facets: [
        { $Type: 'UI.ReferenceFacet', Label: 'Inspection', Target: '@UI.FieldGroup#Inspection' },
        { $Type: 'UI.ReferenceFacet', Label: 'Damage Records', Target: 'damages/@UI.LineItem' }
    ],
    UI.FieldGroup #Inspection: {
        Data: [
            { Value: inspectionDate, Label: 'Inspection Date' },
            { Value: inspectionType, Label: 'Inspection Type' },
            { Value: conditionGrade, Label: 'Condition Grade' },
            { Value: inspector, Label: 'Inspector' },
            { Value: meterReading, Label: 'Meter Reading' },
            { Value: notes, Label: 'Notes' },
            { Value: customerAck, Label: 'Customer Acknowledged' },
            { Value: locked, Label: 'Locked' }
        ]
    }
);

annotate AnalyticsService.DamageRecords with @(
    UI.HeaderInfo: {
        TypeName: 'Damage Record',
        TypeNamePlural: 'Damage Records',
        Title: { Value: damageType },
        Description: { Value: damageStatus }
    },
    UI.SelectionFields: [damageType, severity, customerLiable, preExisting, damageStatus],
    UI.LineItem: [
        { Value: damageType, Label: 'Damage Type' },
        { Value: severity, Label: 'Severity' },
        { Value: description, Label: 'Description' },
        { Value: repairEstimate, Label: 'Repair Estimate' },
        { Value: customerLiable, Label: 'Customer Liable' },
        { Value: damageStatus, Label: 'Status' }
    ]
);

annotate AnalyticsService.RepairBills with @(
    UI.HeaderInfo: {
        TypeName: 'Repair Bill',
        TypeNamePlural: 'Repair Bills',
        Title: { Value: billingStatus },
        Description: { Value: totalAmount }
    },
    UI.SelectionFields: [billDate, billingStatus],
    UI.LineItem: [
        { Value: billDate, Label: 'Bill Date' },
        { Value: repairAmount, Label: 'Repair Amount' },
        { Value: taxAmount, Label: 'Tax' },
        { Value: totalAmount, Label: 'Total Amount' },
        { Value: billingStatus, Label: 'Billing Status' },
        { Value: approvalReason, Label: 'Approval Reason' }
    ],
    UI.Facets: [
        { $Type: 'UI.ReferenceFacet', Label: 'Bill Details', Target: '@UI.FieldGroup#BillDetails' }
    ],
    UI.FieldGroup #BillDetails: {
        Data: [
            { Value: billDate, Label: 'Bill Date' },
            { Value: repairAmount, Label: 'Repair Amount' },
            { Value: taxAmount, Label: 'Tax Amount' },
            { Value: totalAmount, Label: 'Total Amount' },
            { Value: billingStatus, Label: 'Billing Status' },
            { Value: approvalReason, Label: 'Approval Reason' },
            { Value: s4BillingDoc, Label: 'S/4 Billing Document' }
        ]
    }
);

annotate AnalyticsService.MaintenanceRecords with @(
    UI.HeaderInfo: {
        TypeName: 'Maintenance Record',
        TypeNamePlural: 'Maintenance Records',
        Title: { Value: maintenanceType },
        Description: { Value: status }
    },
    UI.SelectionFields: [maintenanceType, maintenanceDate, nextMaintenanceDate, status],
    UI.LineItem: [
        { Value: maintenanceType, Label: 'Maintenance Type' },
        { Value: maintenanceDate, Label: 'Maintenance Date' },
        { Value: nextMaintenanceDate, Label: 'Next Maintenance' },
        { Value: status, Label: 'Status' },
        { Value: serviceProvider, Label: 'Service Provider' },
        { Value: cost, Label: 'Cost' }
    ],
    UI.Facets: [
        { $Type: 'UI.ReferenceFacet', Label: 'Maintenance Details', Target: '@UI.FieldGroup#MaintenanceDetails' }
    ],
    UI.FieldGroup #MaintenanceDetails: {
        Data: [
            { Value: maintenanceType, Label: 'Maintenance Type' },
            { Value: maintenanceDate, Label: 'Maintenance Date' },
            { Value: nextMaintenanceDate, Label: 'Next Maintenance' },
            { Value: status, Label: 'Status' },
            { Value: description, Label: 'Description' },
            { Value: serviceProvider, Label: 'Service Provider' },
            { Value: cost, Label: 'Cost' },
            { Value: s4Notification, Label: 'S/4 Notification' },
            { Value: s4Order, Label: 'S/4 Order' }
        ]
    }
);

annotate AnalyticsService.PricingRules with @(
    UI.HeaderInfo: {
        TypeName: 'Pricing Rule',
        TypeNamePlural: 'Pricing Rules',
        Title: { Value: damageType },
        Description: { Value: severity }
    },
    UI.SelectionFields: [damageType, severity],
    UI.LineItem: [
        { Value: damageType, Label: 'Damage Type' },
        { Value: severity, Label: 'Severity' },
        { Value: baseCharge, Label: 'Base Charge' },
        { Value: labourRate, Label: 'Labour Rate' },
        { Value: taxPercent, Label: 'Tax %' },
        { Value: autoApproveLimit, Label: 'Auto-Approve Limit' }
    ]
);

annotate AnalyticsService.OutboxMessages with @(
    UI.HeaderInfo: {
        TypeName: 'Integration Message',
        TypeNamePlural: 'Integration Messages',
        Title: { Value: entityName },
        Description: { Value: status }
    },
    UI.SelectionFields: [target, entityName, status],
    UI.LineItem: [
        { Value: target, Label: 'Target' },
        { Value: entityName, Label: 'Entity' },
        { Value: entityId, Label: 'Entity ID' },
        { Value: status, Label: 'Status' },
        { Value: attempts, Label: 'Attempts' },
        { Value: lastError, Label: 'Last Error' },
        { Value: modifiedAt, Label: 'Last Changed' }
    ]
);

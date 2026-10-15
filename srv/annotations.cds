using AnalyticsService from './service';

annotate AnalyticsService.Equipment with @(
    UI.HeaderInfo: {
        TypeName: 'Equipment',
        TypeNamePlural: 'Equipment',
        Title: {
            $Type: 'UI.DataField',
            Value: equipmentName
        },
        Description: {
            $Type: 'UI.DataField',
            Value: serialNumber
        }
    },

    UI.SelectionFields: [
        equipmentName,
        equipmentType,
        manufacturer,
        currentStatus,
        currentGrade,
        location_ID
    ],

    UI.LineItem: [
        {
            $Type: 'UI.DataField',
            Value: equipmentName,
            Label: 'Equipment Name'
        },
        {
            $Type: 'UI.DataField',
            Value: equipmentType,
            Label: 'Equipment Type'
        },
        {
            $Type: 'UI.DataField',
            Value: manufacturer,
            Label: 'Manufacturer'
        },
        {
            $Type: 'UI.DataField',
            Value: model,
            Label: 'Model'
        },
        {
            $Type: 'UI.DataField',
            Value: serialNumber,
            Label: 'Serial Number'
        },
        {
            $Type: 'UI.DataField',
            Value: currentStatus,
            Label: 'Status'
        },
        {
            $Type: 'UI.DataField',
            Value: currentGrade,
            Label: 'Condition Grade'
        },
        {
            $Type: 'UI.DataField',
            Value: rentalRatePerDay,
            Label: 'Rental Rate / Day'
        },
        {
            $Type: 'UI.DataField',
            Value: custodian,
            Label: 'Custodian'
        }
    ],

    UI.Facets: [
        {
            $Type: 'UI.ReferenceFacet',
            Label: 'Equipment Details',
            Target: '@UI.FieldGroup#EquipmentDetails'
        }
    ],

    UI.FieldGroup #EquipmentDetails: {
        Data: [
            {
                $Type: 'UI.DataField',
                Value: equipmentName,
                Label: 'Equipment Name'
            },
            {
                $Type: 'UI.DataField',
                Value: equipmentType,
                Label: 'Equipment Type'
            },
            {
                $Type: 'UI.DataField',
                Value: manufacturer,
                Label: 'Manufacturer'
            },
            {
                $Type: 'UI.DataField',
                Value: model,
                Label: 'Model'
            },
            {
                $Type: 'UI.DataField',
                Value: serialNumber,
                Label: 'Serial Number'
            },
            {
                $Type: 'UI.DataField',
                Value: purchaseDate,
                Label: 'Purchase Date'
            },
            {
                $Type: 'UI.DataField',
                Value: rentalRatePerDay,
                Label: 'Rental Rate / Day'
            },
            {
                $Type: 'UI.DataField',
                Value: currentStatus,
                Label: 'Current Status'
            },
            {
                $Type: 'UI.DataField',
                Value: currentGrade,
                Label: 'Condition Grade'
            },
            {
                $Type: 'UI.DataField',
                Value: custodian,
                Label: 'Custodian'
            },
            {
                $Type: 'UI.DataField',
                Value: barcode,
                Label: 'Barcode'
            }
        ]
    }
);

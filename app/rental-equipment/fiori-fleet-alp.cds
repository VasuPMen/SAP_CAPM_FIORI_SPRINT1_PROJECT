using { AnalyticsService } from '../../srv/service';

annotate AnalyticsService.Equipment with @(
    UI.Chart #FleetRateByStatus: {
        $Type: 'UI.ChartDefinitionType',
        Title: 'Daily Rental Rate by Status',
        ChartType: #Column,
        Dimensions: [currentStatus],
        DimensionAttributes: [
            {
                $Type: 'UI.ChartDimensionAttributeType',
                Dimension: currentStatus,
                Role: #Category
            }
        ],
        Measures: [rentalRatePerDay],
        MeasureAttributes: [
            {
                $Type: 'UI.ChartMeasureAttributeType',
                Measure: rentalRatePerDay,
                Role: #Axis1
            }
        ]
    },
    UI.SelectionPresentationVariant #FleetOverviewALP: {
        SelectionVariant: {
            $Type: 'UI.SelectionVariantType',
            SelectOptions: []
        },
        PresentationVariant: {
            $Type: 'UI.PresentationVariantType',
            SortOrder: [{ Property: equipmentName, Descending: false }],
            Visualizations: [
                '@UI.Chart#FleetRateByStatus',
                '@UI.LineItem'
            ]
        }
    }
);

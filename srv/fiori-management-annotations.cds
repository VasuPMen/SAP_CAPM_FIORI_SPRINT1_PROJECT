using { AnalyticsService } from './service';

annotate AnalyticsService.Equipment with @(
    UI.PresentationVariant #ManagementDashboardPV: {
        SortOrder: [{ Property: currentStatus, Descending: false }],
        Visualizations: ['@UI.Chart#ManagementStatusChart', '@UI.LineItem']
    },
    UI.Chart #ManagementStatusChart: {
        $Type: 'UI.ChartDefinitionType',
        Title: 'Equipment Status Overview',
        Description: 'Fleet distribution by current status',
        ChartType: #Column,
        Dimensions: [currentStatus],
        DimensionAttributes: [{
            $Type: 'UI.ChartDimensionAttributeType',
            Dimension: currentStatus,
            Role: #Category
        }],
        Measures: [rentalRatePerDay],
        MeasureAttributes: [{
            $Type: 'UI.ChartMeasureAttributeType',
            Measure: rentalRatePerDay,
            Role: #Axis1
        }]
    },
    UI.SelectionPresentationVariant #ManagementDashboardSPV: {
        SelectionVariant: {
            $Type: 'UI.SelectionVariantType',
            SelectOptions: []
        },
        PresentationVariant: {
            $Type: 'UI.PresentationVariantType',
            Visualizations: ['@UI.Chart#ManagementStatusChart', '@UI.LineItem']
        }
    }
);

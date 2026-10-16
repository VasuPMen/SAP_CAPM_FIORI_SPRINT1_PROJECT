using { AnalyticsService } from '../../srv/service';

annotate AnalyticsService.MaintenanceRecords with @UI.SelectionPresentationVariant #RepairJobsSPV: {
    SelectionVariant: {
        $Type: 'UI.SelectionVariantType',
        SelectOptions: [
            {
                $Type: 'UI.SelectOptionType',
                PropertyName: maintenanceType,
                Ranges: [
                    {
                        Sign: #I,
                        Option: #EQ,
                        Low: 'Corrective'
                    }
                ]
            }
        ]
    },
    PresentationVariant: {
        $Type: 'UI.PresentationVariantType',
        SortOrder: [{ Property: maintenanceDate, Descending: false }],
        Visualizations: ['@UI.LineItem']
    }
};

using { AnalyticsService } from '../../srv/service';

annotate AnalyticsService.ConditionLogs with @UI.Facets: [
    { $Type: 'UI.ReferenceFacet', Label: 'Inspection Details', Target: '@UI.FieldGroup#Inspection' },
    { $Type: 'UI.ReferenceFacet', Label: 'Damage Records', Target: 'damages/@UI.LineItem' }
];

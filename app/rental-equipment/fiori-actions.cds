using { AnalyticsService } from '../../srv/service';

annotate AnalyticsService.ConditionLogs with @UI.Identification: [
    { $Type: 'UI.DataFieldForAction', Action: 'AnalyticsService.lockInspection', Label: 'Lock Inspection', InvocationGrouping: #Isolated }
];

annotate AnalyticsService.RepairBills with @UI.Identification: [
    { $Type: 'UI.DataFieldForAction', Action: 'AnalyticsService.approve', Label: 'Approve', InvocationGrouping: #Isolated },
    { $Type: 'UI.DataFieldForAction', Action: 'AnalyticsService.adjust', Label: 'Adjust', InvocationGrouping: #Isolated },
    { $Type: 'UI.DataFieldForAction', Action: 'AnalyticsService.reject', Label: 'Reject', InvocationGrouping: #Isolated },
    { $Type: 'UI.DataFieldForAction', Action: 'AnalyticsService.dispute', Label: 'Dispute', InvocationGrouping: #Isolated }
];

annotate AnalyticsService.OutboxMessages with @UI.Identification: [
    { $Type: 'UI.DataFieldForAction', Action: 'AnalyticsService.retry', Label: 'Retry', InvocationGrouping: #Isolated }
];

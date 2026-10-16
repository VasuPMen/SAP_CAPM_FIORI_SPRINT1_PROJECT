using { AnalyticsService } from '../../srv/service';

annotate AnalyticsService.DamagePhotos with @(
    UI.LineItem: [
        { Value: fileName, Label: 'File Name' },
        { Value: mediaType, Label: 'Media Type' },
        { Value: mediaUrl, Label: 'Evidence URL' },
        { Value: uploadedAt, Label: 'Uploaded At' },
        { Value: uploadedBy, Label: 'Uploaded By' }
    ]
);

annotate AnalyticsService.DamageRecords with @(
    UI.Facets: [
        { $Type: 'UI.ReferenceFacet', Label: 'Damage Evidence', Target: 'photos/@UI.LineItem' }
    ]
);

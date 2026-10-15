namespace rental;
using {
    Currency,
    User,
    cuid,
    managed,
    sap.common.CodeList
} from '@sap/cds/common';
type ContractStatus : String enum {
    ACTIVE;
    EXPIRED;
    CANCELLED;
}
type ContractItemStatus : String enum {
    OPEN;
    CHECKED_OUT;
    RETURNED;
}
type InspectionStatus : String enum {
    DRAFT;
    SUBMITTED;
    AMENDED;
}
type ConditionGrade : String enum {
    A;
    B;
    C;
    D;
}
type ChecklistResult : String enum {
    PASS;
    FAIL;
    NA;
}
type DamageSeverity : String enum {
    LOW;
    MEDIUM;
    HIGH;
    CRITICAL;
}
type DamageOrigin : String enum {
    NEW;
    PRE_EXISTING;
}
type DamageStatus : String enum {
    OPEN;
    UNDER_REVIEW;
    APPROVED;
    REJECTED;
    REPAIRED;
    CLOSED;
}
type ChargeStatus : String enum {
    DRAFT;
    PENDING_APPROVAL;
    APPROVED;
    ADJUSTED;
    REJECTED;
    POSTED;
    POSTING_FAILED;
    DISPUTED;
    CANCELLED;
    CREDITED;
}
type ChargeLineType : String enum {
    PARTS;
    LABOUR;
    CLEANING;
    TRANSPORT;
    DOWNTIME;
    FIXED;
}
type RepairJobStatus : String enum {
    OPEN;
    ASSIGNED;
    IN_PROGRESS;
    ON_HOLD;
    COMPLETED;
    CANCELLED;
}
type AssetStatus : String enum {
    AVAILABLE;
    RESERVED;
    RENTED_OUT;
    PENDING_INSPECTION;
    DAMAGED;
    IN_REPAIR;
    QUARANTINED;
    RETIRED;
}
type LocationEventType : String enum {
    TRANSFER;
    CHECK_IN;
    CHECK_OUT;
    SCAN;
}
type LocationEventSource : String enum {
    SCAN;
    MANUAL;
    TELEMATICS;
}
type ServicePlanRule : String enum {
    DAYS;
    HOURS;
}
type DisputeStatus : String enum {
    OPEN;
    UNDER_REVIEW;
    RESOLVED;
    REJECTED;
}
type OutboxStatus : String enum {
    PENDING;
    PROCESSING;
    RETRYING;
    COMPLETED;
    FAILED;
}
type ApprovalTier : String enum {
    CLERK;
    MANAGER;
}
type InspectionOverrideType : String enum {
    NO_CONTRACT;
    SERVICE_OVERDUE;
}
type MediaUploadStatus : String enum {
    REQUESTED;
    UPLOADED;
    VERIFIED;
    REJECTED;
}
type NotificationChannel : String enum {
    PUSH;
    EMAIL;
}
type ConfigurationValueType : String enum {
    STRING;
    INTEGER;
    DECIMAL;
    BOOLEAN;
}
aspect createdOnly {
    createdAt : Timestamp @cds.on.insert: $now;
    createdBy : User @cds.on.insert: $user;
}
aspect softDeletable {
    isDeleted : Boolean default false;
}
@assert.unique: {
    categoryCode: [categoryCode]
}
entity AssetCategories : cuid, managed, softDeletable {
    categoryCode : String(50) not null;
    description : String(255);
    assets : Association to many Assets on assets.category = $self;
    templates : Association to many ChecklistTemplates on templates.category = $self;
    mandatoryShots : Composition of many CategoryMandatoryShots on mandatoryShots.category = $self;
    pricingRules : Association to many PricingRules on pricingRules.category = $self;
    approvalRules : Association to many ApprovalRules on approvalRules.category = $self;
    areas : Association to many AssetAreas on areas.category = $self;
}
@assert.unique: {
    businessPartnerNo: [businessPartnerNo]
}
entity Customers : cuid, managed, softDeletable {
    businessPartnerNo : String(10) not null;
    name : String(100) not null;
    email : String(100);
    address : String(255);
    s4ChangedAt : Timestamp;
    lastSyncedAt : Timestamp;
    contracts : Association to many Contracts on contracts.customer = $self;
}
@assert.unique: {
    contractNo: [contractNo]
}
entity Contracts : cuid, managed, softDeletable {
    contractNo : String(10) not null;
    customer : Association to one Customers not null;
    startDate : Date;
    endDate : Date;
    currency : Currency;
    lossOfUseAllowed : Boolean default false;
    status : ContractStatus default #ACTIVE;
    s4ChangedAt : Timestamp;
    lastSyncedAt : Timestamp;
    contractItems : Composition of many ContractItems on contractItems.contract = $self;
    inspections : Association to many Inspections on inspections.contract = $self;
}
@assert.unique: {
    contractItem: [contract, itemNo]
}
entity ContractItems : cuid, managed, softDeletable {
    contract : Association to one Contracts not null;
    itemNo : String(10) not null;
    asset : Association to one Assets not null;
    startDate : Date;
    endDate : Date;
    actualReturnDate : Date;
    currency : Currency;
    status : ContractItemStatus default #OPEN;
    s4ChangedAt : Timestamp;
    lastSyncedAt : Timestamp;
    inspections : Association to many Inspections on inspections.contractItem = $self;
}
@assert.unique: {
    equipmentNo: [equipmentNo],
    qrCode: [qrCode]
}
entity Assets : cuid, managed, softDeletable {
    equipmentNo : String(18) not null;
    equipmentName : String(100);
    serialNo : String(40);
    category : Association to one AssetCategories;
    status : AssetStatus default #AVAILABLE;
    plant : String(4);
    location : Association to one Locations;
    currentContractItem : Association to one ContractItems;
    lastLat : Decimal(9,6);
    lastLon : Decimal(9,6);
    lastLocationAt : Timestamp;
    meterReading : Decimal(12,2);
    nextServiceDate : Date;
    @Semantics.amount.currencyCode: 'currency'
    netBookValue : Decimal(15,2);
    @Semantics.amount.currencyCode: 'currency'
    dailyRate : Decimal(15,2);
    currency : Currency;
    qrCode : String(64);
    s4ChangedAt : Timestamp;
    lastSyncedAt : Timestamp;
    inspections : Association to many Inspections on inspections.asset = $self;
    repairJobs : Association to many RepairJobs on repairJobs.asset = $self;
    locationEvents : Association to many LocationEvents on locationEvents.asset = $self;
    statusHistory : Association to many StatusHistory on statusHistory.asset = $self;
    servicePlans : Association to many ServicePlans on servicePlans.asset = $self;
}
@assert.unique: {
    locationCode: [locationCode]
}
entity Locations : cuid, managed, softDeletable {
    locationCode : String(50) not null;
    locationName : String(100);
    locationType : String(50);
    plant : String(4);
    address : String(255);
    city : String(100);
    latitude : Decimal(9,6);
    longitude : Decimal(9,6);
    assets : Association to many Assets on assets.location = $self;
    locationEvents : Association to many LocationEvents on locationEvents.location = $self;
}
@assert.unique: {
    inspectionNo: [inspectionNo],
    clientUuid: [clientUuid]
}
entity Inspections : cuid, managed, softDeletable {
    inspectionNo : String(20) not null;
    asset : Association to one Assets not null;
    contract : Association to one Contracts;
    contractItem : Association to one ContractItems;
    inspectionType : Association to one InspectionTypes not null;
    status : InspectionStatus default #DRAFT;
    inspectorID : String(100);
    deviceID : String(100);
    plant : String(4);
    startedAt : Timestamp;
    submittedAt : Timestamp;
    latitude : Decimal(9,6);
    longitude : Decimal(9,6);
    meterReading : Decimal(12,2);
    fuelLevelPct : Decimal(5,2) @assert.range: [0, 100];
    suggestedGrade : ConditionGrade;
    finalGrade : ConditionGrade;
    gradeOverrideReason : String(500);
    signatureRef : String(500);
    signatureRefusalReason : String(500);
    clientUuid : UUID not null;
    amendmentOf : Association to one Inspections;
    amendmentReason : String(1000);
    amendmentApprovedBy : String(100);
    amendments : Association to many Inspections on amendments.amendmentOf = $self;
    reportDocumentId : String(500);
    reportSentAt : Timestamp;
    legalHold : Boolean default false;
    checklistResults : Composition of many ChecklistResults on checklistResults.inspection = $self;
    overrides : Composition of many InspectionOverrides on overrides.inspection = $self;
    damageItems : Composition of many DamageItems on damageItems.inspection = $self;
    media : Association to many Media on media.inspection = $self;
    charges : Association to many DamageCharges on charges.inspection = $self;
}
entity InspectionTypes : CodeList, managed {
    key code : String(20);
    name : String(100);
    active : Boolean default true;
    inspections : Association to many Inspections on inspections.inspectionType = $self;
}
entity InspectionOverrides : cuid, managed {
    inspection : Association to one Inspections not null;
    overrideType : InspectionOverrideType not null;
    reason : String(500) not null;
    overriddenBy : String(100) not null;
    overriddenAt : Timestamp @cds.on.insert: $now;
}
@assert.unique: {
    categoryVersion: [category, version]
}
entity ChecklistTemplates : cuid, managed, softDeletable {
    category : Association to one AssetCategories not null;
    templateName : String(100) not null;
    version : Integer default 1;
    active : Boolean default true;
    items : Composition of many ChecklistTemplateItems on items.template = $self;
}
@assert.unique: {
    templateSequence: [template, sequenceNo]
}
entity ChecklistTemplateItems : cuid, managed, softDeletable {
    template : Association to one ChecklistTemplates not null;
    itemText : String(500) not null;
    sequenceNo : Integer not null;
    mandatory : Boolean default false;
}
@assert.unique: {
    inspectionItem: [inspection, item]
}
entity ChecklistResults : cuid, createdOnly {
    inspection : Association to one Inspections not null;
    item : Association to one ChecklistTemplateItems;
    result : ChecklistResult;
    remarks : String(1000);
    checkedAt : Timestamp;
}
@assert.unique: {
    categoryShot: [category, shotType]
}
entity CategoryMandatoryShots : cuid, managed {
    category : Association to one AssetCategories not null;
    shotType : Association to one ShotTypes not null;
}
entity ShotTypes : CodeList, managed {
    key code : String(50);
    active : Boolean default true;
    validFrom : Date;
    validTo : Date;
    media : Association to many Media on media.shotType = $self;
    mandatoryFor : Association to many CategoryMandatoryShots on mandatoryFor.shotType = $self;
}
entity AssetAreas : CodeList, managed {
    key code : String(50);
    category : Association to one AssetCategories;
    active : Boolean default true;
    validFrom : Date;
    validTo : Date;
    damageItems : Association to many DamageItems on damageItems.area = $self;
}
entity DamageTypes : CodeList, managed {
    key code : String(50);
    category : Association to one AssetCategories;
    active : Boolean default true;
    validFrom : Date;
    validTo : Date;
    damageItems : Association to many DamageItems on damageItems.damageType = $self;
    pricingRules : Association to many PricingRules on pricingRules.damageType = $self;
}
entity DamageItems : cuid, managed, softDeletable {
    inspection : Association to one Inspections not null;
    area : Association to one AssetAreas;
    damageType : Association to one DamageTypes;
    severity : DamageSeverity;
    origin : DamageOrigin default #NEW;
    billable : Boolean default false;
    note : String(1000);
    status : DamageStatus default #OPEN;
    preExistingRef : Association to one DamageItems;
    preExistingOf : Association to many DamageItems on preExistingOf.preExistingRef = $self;
    media : Association to many Media on media.damage = $self;
    repairJobs : Association to many RepairJobs on repairJobs.damage = $self;
}
entity Media : cuid, managed, softDeletable {
    inspection : Association to one Inspections;
    damage : Association to one DamageItems;
    repairJob : Association to one RepairJobs;
    shotType : Association to one ShotTypes;
    mimeType : String(100);
    objectKey : String(500) not null;
    thumbKey : String(500);
    sha256 : String(64);
    sizeBytes : Integer64;
    capturedAt : Timestamp;
    latitude : Decimal(9,6);
    longitude : Decimal(9,6);
    manualUpload : Boolean default false;
    annotationJson : LargeString;
    uploadStatus : MediaUploadStatus default #REQUESTED;
    uploadedAt : Timestamp;
    hashVerifiedAt : Timestamp;
    legalHold : Boolean default false;
}
entity DamageCharges : cuid, managed, softDeletable {
    inspection : Association to one Inspections not null;
    plant : String(4);
    @Semantics.amount.currencyCode: 'currency'
    estimatedTotal : Decimal(15,2);
    @Semantics.amount.currencyCode: 'currency'
    totalAmount : Decimal(15,2);
    currency : Currency;
    status : ChargeStatus default #DRAFT;
    writeOffRecommended : Boolean default false;
    adjustmentReason : String(1000);
    rejectionReason : String(1000);
    approvedBy : String(100);
    approvedAt : Timestamp;
    rejectedBy : String(100);
    postedAt : Timestamp;
    s4DocumentNo : String(50);
    s4Status : String(30);
    s4StatusSyncedAt : Timestamp;
    chargeLines : Composition of many ChargeLines on chargeLines.charge = $self;
    disputes : Association to many Disputes on disputes.charge = $self;
}
entity ChargeLines : cuid, managed, softDeletable {
    charge : Association to one DamageCharges not null;
    damage : Association to one DamageItems;
    lineType : ChargeLineType;
    description : String(500);
    quantity : Decimal(15,3);
    @Semantics.amount.currencyCode: 'currency'
    unitPrice : Decimal(15,2);
    @Semantics.amount.currencyCode: 'currency'
    amount : Decimal(15,2);
    currency : Currency;
    pricingRule : Association to one PricingRules;
    ruleVersion : Integer;
    calcInputsJson : LargeString;
}
entity RepairJobs : cuid, managed, softDeletable {
    asset : Association to one Assets not null;
    damage : Association to one DamageItems;
    plant : String(4);
    assignedTo : String(100);
    status : RepairJobStatus default #OPEN;
    startedAt : Timestamp;
    completedAt : Timestamp;
    actionsTaken : LargeString;
    labourHours : Decimal(15,3);
    @Semantics.amount.currencyCode: 'currency'
    estimatedCost : Decimal(15,2);
    @Semantics.amount.currencyCode: 'currency'
    actualCost : Decimal(15,2);
    currency : Currency;
    s4NotificationNo : String(12);
    s4OrderNo : String(12);
    media : Association to many Media on media.repairJob = $self;
    parts : Composition of many RepairParts on parts.repairJob = $self;
}
entity RepairParts : cuid, managed, softDeletable {
    repairJob : Association to one RepairJobs not null;
    partNumber : String(50);
    description : String(255);
    quantity : Decimal(15,3);
    @Semantics.amount.currencyCode: 'currency'
    cost : Decimal(15,2);
    currency : Currency;
}
entity LocationEvents : cuid, createdOnly {
    asset : Association to one Assets not null;
    eventType : LocationEventType;
    source : LocationEventSource;
    location : Association to one Locations;
    latitude : Decimal(9,6);
    longitude : Decimal(9,6);
    accuracyM : Decimal(10,2);
    userID : String(100);
    deviceID : String(100);
    eventAt : Timestamp not null;
}
entity StatusHistory : cuid, createdOnly {
    asset : Association to one Assets not null;
    fromStatus : AssetStatus;
    toStatus : AssetStatus;
    reason : String(500);
    userID : String(100);
    eventAt : Timestamp not null;
}
@assert.unique: {
    statusTransition: [fromStatus, toStatus]
}
entity StatusTransitions : cuid, managed {
    fromStatus : AssetStatus;
    toStatus : AssetStatus;
    allowed : Boolean default true;
    reasonRequired : Boolean default false;
}
entity ServicePlans : cuid, managed, softDeletable {
    asset : Association to Assets not null;
    serviceRule : ServicePlanRule;
    serviceInterval : Decimal(15,3);
    lastExecutedAt : Date;
    nextDueAt : Date;
    lastServiceMeter : Decimal(12,2);
    nextDueMeter : Decimal(12,2);
    s4PlanNo : String(50);
    active : Boolean default true;
}
@assert.unique: {
    pricingVersion: [category, damageType, version]
}
entity PricingRules : cuid, managed, softDeletable {
    category : Association to one AssetCategories;
    damageType : Association to one DamageTypes;
    version : Integer default 1;
    @Semantics.amount.currencyCode: 'currency'
    fixedFee : Decimal(15,2);
    @Semantics.amount.currencyCode: 'currency'
    partPrice : Decimal(15,2);
    @Semantics.amount.currencyCode: 'currency'
    cleaningFee : Decimal(15,2);
    @Semantics.amount.currencyCode: 'currency'
    transportFee : Decimal(15,2);
    stdHours : Decimal(15,3);
    @Semantics.amount.currencyCode: 'currency'
    labourRate : Decimal(15,2);
    currency : Currency;
    validFrom : Date;
    validTo : Date;
    active : Boolean default true;
}
@assert.unique: {
    approvalRule: [category, tier, currency, validFrom]
}
entity ApprovalRules : cuid, managed, softDeletable {
    category : Association to one AssetCategories;
    tier : ApprovalTier;
    @Semantics.amount.currencyCode: 'currency'
    threshold : Decimal(15,2);
    currency : Currency;
    @assert.range: [0, 100]
    writeOffPct : Decimal(5,2) default 60;
    validFrom : Date;
    validTo : Date;
    active : Boolean default true;
}
entity Disputes : cuid, managed, softDeletable {
    charge : Association to one DamageCharges not null;
    reason : String(1000);
    status : DisputeStatus default #OPEN;
    comments : String(2000);
    @Semantics.amount.currencyCode: 'currency'
    creditAmount : Decimal(15,2);
    currency : Currency;
    resolvedBy : String(100);
    resolvedAt : Timestamp;
    s4CreditDocumentNo : String(50);
}
@assert.unique: {
    correlationID: [correlationID]
}
entity Outbox : cuid, managed {
    target : String(100) not null;
    operation : String(100) not null;
    payload : LargeString;
    status : OutboxStatus default #PENDING;
    attempts : Integer default 0;
    nextAttemptAt : Timestamp;
    lastError : LargeString;
    correlationID : String(100) not null;
    refEntity : String(100);
    refID : UUID;
}
entity Notifications : cuid, managed, softDeletable {
    notificationType : String(50);
    recipient : String(255);
    payload : LargeString;
    status : String(30);
    sentAt : Timestamp;
}
@assert.unique: {
    preference: [roleName, notificationType, channel]
}
entity NotificationPreferences : cuid, managed {
    roleName : String(50) not null;
    notificationType : String(100) not null;
    channel : NotificationChannel;
    enabled : Boolean default true;
}
@assert.unique: {
    configurationKey: [configKey]
}
entity Configuration : cuid, managed {
    configKey : String(100) not null;
    configValue : String(500);
    valueType : ConfigurationValueType default #STRING;
    description : String(1000);
    active : Boolean default true;
}
entity AuditLog : cuid, createdOnly {
    userID : String(100);
    action : String(50);
    entityName : String(100);
    entityID : UUID;
    eventAt : Timestamp;
    deviceID : String(100);
    details : LargeString;
}
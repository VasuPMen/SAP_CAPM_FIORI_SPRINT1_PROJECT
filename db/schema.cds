using { cuid, managed } from '@sap/cds/common';

namespace retcl;

type ConditionGrade : String(1) enum {
    A;
    B;
    C;
    D;
};

type Severity : String(10) enum {
    Low;
    Medium;
    High;
    Critical;
};

type InspectionType : String(15) enum {
    CheckOut;
    Return;
    Routine;
};

type EquipmentStatus : String(20) enum {
    Available;
    RentedOut;
    InTransit;
    UnderMaintenance;
    Quarantined;
    Retired;
};

type RentalStatus : String(15) enum {
    Booked;
    Active;
    Returned;
    Overdue;
    Closed;
    Cancelled;
};

type ItemStatus : String(15) enum {
    Reserved;
    OutOnRent;
    Returned;
};

type MaintenanceType : String(20) enum {
    Preventive;
    Corrective;
    Inspection;
    Calibration;
};

type MaintenanceStatus : String(15) enum {
    Planned;
    InProgress;
    Completed;
    Cancelled;
};

type DamageStatus : String(20) enum {
    Reported;
    Confirmed;
    InRepair;
    Repaired;
    Billed;
    Disputed;
    Closed;
};

type BillingStatus : String(20) enum {
    Draft;
    PendingApproval;
    Approved;
    Rejected;
    Adjusted;
    Posted;
    Billed;
    Disputed;
    Failed;
};

type OutboxStatus : String(15) enum {
    New;
    Processing;
    Done;
    Failed;
};

type Money : Decimal(12,2);

entity Customers : cuid, managed {
    companyName   : String(100) @mandatory;
    contactPerson : String(100);
    email         : String(100);
    phone         : String(20);
    address       : String(255);
    rentals       : Association to many Rentals
                       on rentals.customer = $self;
};

entity Locations : cuid, managed {
    locationName : String(100) @mandatory;
    locationType : String(50);
    plant        : String(10);
    address      : String(255);
    city         : String(100);
    latitude     : Decimal(9,6);
    longitude    : Decimal(9,6);
    equipment    : Association to many Equipment
                       on equipment.location = $self;
};

entity Equipment : cuid, managed {
    location         : Association to Locations @mandatory;
    equipmentName    : String(100) @mandatory;
    equipmentType    : String(50);
    manufacturer     : String(100);
    model            : String(100);
    serialNumber     : String(100) @mandatory;
    purchaseDate     : Date;
    rentalRatePerDay : Decimal(10,2);
    currentStatus    : EquipmentStatus default #Available;
    currentGrade     : ConditionGrade;
    custodian        : String(100);
    barcode          : String(100);
    maintenance      : Association to many MaintenanceRecords
                           on maintenance.equipment = $self;
    conditionLogs    : Association to many ConditionLogs
                           on conditionLogs.equipment = $self;
    transfers        : Composition of many EquipmentTransfers
                           on transfers.equipment = $self;
};

entity EquipmentTransfers : cuid, managed {
    equipment    : Association to Equipment @mandatory;
    fromLocation : Association to Locations;
    toLocation   : Association to Locations @mandatory;
    transferDate : DateTime @cds.on.insert: $now;
    reason       : String(255);
};

entity Rentals : cuid, managed {
    customer           : Association to Customers @mandatory;
    rentalDate         : Date @mandatory;
    expectedReturnDate : Date @mandatory;
    actualReturnDate   : Date;
    rentalStatus       : RentalStatus default #Booked;
    totalRentalAmount  : Money;
    items              : Composition of many RentalItems
                            on items.rental = $self;
    statusHistory      : Composition of many RentalStatusHistory
                            on statusHistory.rental = $self;
    conditionLogs      : Association to many ConditionLogs
                            on conditionLogs.rental = $self;
};

entity RentalItems : cuid, managed {
    rental          : Association to Rentals @mandatory;
    equipment       : Association to Equipment @mandatory;
    dailyRentalRate : Decimal(10,2);
    startDate       : Date @mandatory;
    endDate         : Date;
    itemStatus      : ItemStatus default #Reserved;
};

entity RentalStatusHistory : cuid {
    rental     : Association to Rentals @mandatory;
    oldStatus  : RentalStatus;
    newStatus  : RentalStatus;
    changedAt  : Timestamp @cds.on.insert: $now;
    changedBy  : String(100) @cds.on.insert: $user;
};

entity ConditionLogs : cuid, managed {
    equipment      : Association to Equipment @mandatory;
    rental         : Association to Rentals;
    inspectionDate : DateTime @mandatory;
    inspectionType : InspectionType @mandatory;
    conditionGrade : ConditionGrade @mandatory;
    inspector      : String(100);
    meterReading   : Decimal(10,2);
    notes          : String(500);
    customerAck    : Boolean default false;
    signatureUrl   : String(500);
    locked         : Boolean default false;
    damages        : Composition of many DamageRecords
                         on damages.conditionLog = $self;
};

entity DamageRecords : cuid, managed {
    conditionLog   : Association to ConditionLogs @mandatory;
    damageType     : String(50) @mandatory;
    description    : String(500);
    severity       : Severity @mandatory;
    repairEstimate : Money;
    customerLiable : Boolean default false;
    liableParty    : Association to Customers;
    preExisting    : Boolean default false;
    damageStatus   : DamageStatus default #Reported;
    photos         : Composition of many DamagePhotos
                        on photos.damage = $self;
    repairBills    : Association to many RepairBills
                        on repairBills.damage = $self;
};

entity DamagePhotos : cuid {
    damage      : Association to DamageRecords @mandatory;
    fileName    : String(255);
    mediaType   : String(100) @Core.IsMediaType;
    mediaUrl    : String(500) @Core.IsURL;
    publicId    : String(255);
    sha256      : String(64);
    uploadedAt  : Timestamp @cds.on.insert: $now;
    uploadedBy  : String(100) @cds.on.insert: $user;
};

entity MaintenanceRecords : cuid, managed {
    equipment           : Association to Equipment @mandatory;
    maintenanceType     : MaintenanceType @mandatory;
    maintenanceDate     : Date @mandatory;
    description         : String(500);
    serviceProvider     : String(150);
    cost                : Money;
    nextMaintenanceDate : Date;
    status              : MaintenanceStatus default #Planned;
    s4Notification      : String(50);
    s4Order             : String(50);
};

entity RepairBills : cuid, managed {
    rental         : Association to Rentals @mandatory;
    customer       : Association to Customers @mandatory;
    damage         : Association to DamageRecords @mandatory;
    billDate       : Date @mandatory;
    repairAmount   : Money;
    taxAmount      : Money;
    totalAmount    : Money;
    billingStatus  : BillingStatus default #Draft;
    approvalReason : String(255);
    s4BillingDoc   : String(50);
    idempotencyKey : String(64);
};

entity PricingRules : cuid, managed {
    damageType       : String(50) @mandatory;
    severity         : Severity @mandatory;
    baseCharge       : Money @mandatory;
    labourRate       : Decimal(10,2);
    taxPercent       : Decimal(5,2);
    autoApproveLimit : Money;
};

entity OutboxMessages : cuid, managed {
    target         : String(30);
    entityName     : String(50);
    entityId       : UUID;
    payload        : LargeString;
    status         : OutboxStatus default #New;
    attempts       : Integer default 0;
    lastError      : String(500);
    idempotencyKey : String(64);
};
using { retcl as db } from '../db/schema';

@impl: './service/rental-service.cjs'
@path: '/rental'
service RentalService {
    entity Customers as projection on db.Customers;
    entity Locations as projection on db.Locations;
    entity Equipment as projection on db.Equipment;
    entity EquipmentTransfers as projection on db.EquipmentTransfers;
    entity Rentals as projection on db.Rentals;
    entity RentalItems as projection on db.RentalItems;
    entity RentalStatusHistory as projection on db.RentalStatusHistory;
}

@path: '/inspection'
@impl: './service/inspection-service.cjs'
service InspectionService {
    entity Equipment as projection on db.Equipment;
    entity ConditionLogs as projection on db.ConditionLogs;
    entity DamageRecords as projection on db.DamageRecords;
    entity DamagePhotos as projection on db.DamagePhotos;
}

@path: '/maintenance'
@impl: './service/maintenance-service.cjs'
service MaintenanceService {
    entity Equipment as projection on db.Equipment;
    entity MaintenanceRecords as projection on db.MaintenanceRecords;
}

@path: '/billing'
@impl: './service/billing-service.cjs'
service BillingService {
    entity Customers as projection on db.Customers;
    entity Rentals as projection on db.Rentals;
    entity Equipment as projection on db.Equipment;
    entity DamageRecords as projection on db.DamageRecords;
    entity RepairBills as projection on db.RepairBills;
    entity PricingRules as projection on db.PricingRules;
}

@path: '/analytics'
service AnalyticsService {
    entity Customers as projection on db.Customers;
    entity Locations as projection on db.Locations;
    entity Equipment as projection on db.Equipment;
    entity EquipmentTransfers as projection on db.EquipmentTransfers;
    entity Rentals as projection on db.Rentals;
    entity RentalItems as projection on db.RentalItems;
    entity RentalStatusHistory as projection on db.RentalStatusHistory;
    entity ConditionLogs as projection on db.ConditionLogs;
    entity DamageRecords as projection on db.DamageRecords;
    entity DamagePhotos as projection on db.DamagePhotos;
    entity MaintenanceRecords as projection on db.MaintenanceRecords;
    entity RepairBills as projection on db.RepairBills;
    entity PricingRules as projection on db.PricingRules;
    entity OutboxMessages as projection on db.OutboxMessages;
}

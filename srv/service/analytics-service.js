const cds = require('@sap/cds');

module.exports = cds.service.impl(async function () {

    const {
        Customers,
        Locations,
        Equipment,
        Rentals,
        ConditionLogs,
        DamageRecords,
        MaintenanceRecords,
        RepairBills
    } = this.entities;

});
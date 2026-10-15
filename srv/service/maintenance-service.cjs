
const cds = require('@sap/cds');
const db = cds.db;
const { createOutboxMessage } = require('../worker/outbox-worker.cjs');

module.exports = cds.service.impl(async function () {
    const { Equipment, MaintenanceRecords } = this.entities;

    this.before('CREATE', MaintenanceRecords, async (req) => {
        if (!req.data.equipment_ID) {
            req.error(400, 'Equipment is required');
            return;
        }

        if (!req.data.maintenanceType) {
            req.error(400, 'Maintenance type is required');
        }

        if (!req.data.maintenanceDate) {
            req.error(400, 'Maintenance date is required');
        }

        const equipment = await SELECT.one
            .from(Equipment)
            .where({ ID: req.data.equipment_ID });

        if (!equipment) {
            req.error(404, 'Equipment not found');
            return;
        }

        if (['Quarantined', 'Retired', 'RentedOut', 'InTransit'].includes(equipment.currentStatus)) {
            req.error(409, `Equipment cannot enter maintenance from status ${equipment.currentStatus}`);
        }
    });

    this.before('UPDATE', MaintenanceRecords, async (req) => {
        const maintenanceId = req.data.ID || req.params?.[0]?.ID;

        if (!maintenanceId) {
            req.error(400, 'Maintenance record ID is required');
            return;
        }

        if (req.data.status === undefined) return;

        const maintenance = await SELECT.one
            .from(MaintenanceRecords)
            .where({ ID: maintenanceId });

        if (!maintenance) {
            req.error(404, 'Maintenance record not found');
            return;
        }

        const allowedTransitions = {
            Planned: ['InProgress', 'Cancelled'],
            InProgress: ['Completed', 'Cancelled'],
            Completed: [],
            Cancelled: []
        };

        if (
            req.data.status !== maintenance.status &&
            !allowedTransitions[maintenance.status]?.includes(req.data.status)
        ) {
            req.error(409, `Invalid maintenance status transition: ${maintenance.status} to ${req.data.status}`);
        }
    });

    this.after('CREATE', MaintenanceRecords, async (maintenance, req) => {
        const equipmentId = maintenance.equipment_ID || req.data.equipment_ID;
        const status = maintenance.status || req.data.status || 'Planned';

        if (status === 'InProgress') {
            await UPDATE(Equipment)
                .set({ currentStatus: 'UnderMaintenance' })
                .where({ ID: equipmentId, currentStatus: 'Available' });
        }

        await createOutboxMessage(db.tx(req), {
            target: 'INTERNAL',
            entityName: 'MaintenanceRecord',
            entityId: maintenance.ID,
            payload: {
                event: 'MaintenanceCreated',
                maintenanceId: maintenance.ID,
                equipmentId,
                maintenanceType: maintenance.maintenanceType,
                maintenanceDate: maintenance.maintenanceDate,
                description: maintenance.description,
                serviceProvider: maintenance.serviceProvider,
                cost: maintenance.cost,
                status
            },
            idempotencyKey: `MaintenanceCreated-${maintenance.ID}`
        });
    });


    this.after('UPDATE', MaintenanceRecords, async (maintenance, req) => {
        const maintenanceId = maintenance.ID || req.data.ID || req.params?.[0]?.ID;

        console.log('[MAINTENANCE] UPDATE handler reached');
        console.log('[MAINTENANCE] ID:', maintenanceId);
        console.log('[MAINTENANCE] Request data:', req.data);
        console.log('[MAINTENANCE] Result data:', maintenance);

        if (!maintenanceId) return;

        const record = await SELECT.one
            .from(MaintenanceRecords)
            .columns('ID', 'status', 'equipment_ID')
            .where({ ID: maintenanceId });

        console.log('[MAINTENANCE] Database record:', record);

        if (!record || !record.equipment_ID) return;

        const equipmentId = record.equipment_ID;

        if (record.status === 'InProgress') {
            await UPDATE(Equipment)
                .set({ currentStatus: 'UnderMaintenance' })
                .where({
                    ID: equipmentId,
                    currentStatus: 'Available'
                });
        } else if (['Completed', 'Cancelled'].includes(record.status)) {
            await UPDATE(Equipment)
                .set({ currentStatus: 'Available' })
                .where({
                    ID: equipmentId,
                    currentStatus: 'UnderMaintenance'
                });
        }

        await createOutboxMessage(db.tx(req), {
            target: 'INTERNAL',
            entityName: 'MaintenanceRecord',
            entityId: maintenanceId,
            payload: {
                event: 'MaintenanceUpdated',
                maintenanceId,
                equipmentId,
                status: record.status
            },
            idempotencyKey: `MaintUpdated-${maintenanceId}-${record.status}`
        });
    });


});

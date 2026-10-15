const cds = require('@sap/cds');

module.exports = cds.service.impl(async function () {

    const {
        Equipment,
        ConditionLogs,
        DamageRecords,
        DamagePhotos
    } = this.entities;

    const Customers = cds.model.definitions['retcl.Customers'];

    // ============================================================
    // CONDITION LOG VALIDATION
    // ============================================================

    this.before('CREATE', ConditionLogs, async (req) => {

        if (!req.data.equipment_ID) {
            req.error(400, 'Equipment is required');
        }

        if (!req.data.inspectionDate) {
            req.error(400, 'Inspection date is required');
        }

        if (!req.data.inspectionType) {
            req.error(400, 'Inspection type is required');
        }

        if (!req.data.conditionGrade) {
            req.error(400, 'Condition grade is required');
        }

        const equipment = await SELECT.one
            .from(Equipment)
            .where({ ID: req.data.equipment_ID });

        if (!equipment) {
            req.error(404, 'Equipment not found');
        }
    });


    // ============================================================
    // DAMAGE RECORD VALIDATION
    // ============================================================

    this.before('CREATE', DamageRecords, async (req) => {

        if (!req.data.conditionLog_ID) {
            req.error(400, 'Condition log is required');
        }

        if (!req.data.damageType) {
            req.error(400, 'Damage type is required');
        }

        if (!req.data.severity) {
            req.error(400, 'Damage severity is required');
        }

        const conditionLog = await SELECT.one
            .from(ConditionLogs)
            .where({ ID: req.data.conditionLog_ID });

        if (!conditionLog) {
            req.error(404, 'Condition log not found');
        }

        if (conditionLog.locked) {
            req.error(400, 'Cannot add damage to a locked condition log');
        }
    });


    // ============================================================
    // CUSTOMER LIABILITY VALIDATION
    // ============================================================

    this.before('CREATE', DamageRecords, async (req) => {

        if (req.data.customerLiable === true) {

            if (!req.data.liableParty_ID) {
                req.error(
                    400,
                    'Liable customer is required when damage is customer liable'
                );
            }

            const customer = await SELECT.one
                .from(Customers)
                .where({ ID: req.data.liableParty_ID });

            if (!customer) {
                req.error(404, 'Liable customer not found');
            }
        }
    });


    // ============================================================
    // PRE-EXISTING DAMAGE
    // ============================================================

    this.before('CREATE', DamageRecords, async (req) => {

        if (req.data.preExisting === true) {

            req.data.customerLiable = false;
            req.data.liableParty_ID = null;
        }
    });


    // ============================================================
    // DAMAGE PHOTO VALIDATION
    // ============================================================

    this.before('CREATE', DamagePhotos, async (req) => {

        if (!req.data.damage_ID) {
            req.error(400, 'Damage record is required');
        }

        if (!req.data.fileName) {
            req.error(400, 'File name is required');
        }

        if (!req.data.mediaType) {
            req.error(400, 'Media type is required');
        }

        if (!req.data.mediaUrl) {
            req.error(400, 'Media URL is required');
        }

        const damage = await SELECT.one
            .from(DamageRecords)
            .where({ ID: req.data.damage_ID });

        if (!damage) {
            req.error(404, 'Damage record not found');
        }
    });


    // ============================================================
    // CRITICAL DAMAGE → QUARANTINE EQUIPMENT
    // ============================================================

    this.after('CREATE', DamageRecords, async (_, req) => {

    const damage = req.data;

    console.log('[INSPECTION] AFTER CREATE DAMAGE');
    console.log('[INSPECTION] Damage data:', damage);

    if (
        damage.severity === 'Critical' &&
        damage.customerLiable === true
    ) {

        console.log('[INSPECTION] Critical customer-liable damage detected');

        const conditionLog = await SELECT.one
            .from(ConditionLogs)
            .where({
                ID: damage.conditionLog_ID
            });

        console.log('[INSPECTION] Condition Log:', conditionLog);

        if (conditionLog) {

            console.log(
                '[INSPECTION] Equipment ID:',
                conditionLog.equipment_ID
            );

            await UPDATE(Equipment)
                .set({
                    currentStatus: 'Quarantined'
                })
                .where({
                    ID: conditionLog.equipment_ID
                });

            console.log(
                '[INSPECTION] Equipment status updated to Quarantined'
            );
        }
    }
});

});
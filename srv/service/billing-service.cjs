const cds = require('@sap/cds');

module.exports = cds.service.impl(async function () {

    const {
        Customers,
        Rentals,
        Equipment,
        DamageRecords,
        RepairBills,
        PricingRules
    } = this.entities;


    // =========================================================
    // PRICING RULE VALIDATION
    // =========================================================

    this.before('CREATE', PricingRules, async (req) => {

        if (!req.data.damageType) {
            req.error(400, 'Damage type is required');
        }

        if (!req.data.severity) {
            req.error(400, 'Severity is required');
        }

        if (req.data.baseCharge == null) {
            req.error(400, 'Base charge is required');
        }

        if (req.data.baseCharge < 0) {
            req.error(400, 'Base charge cannot be negative');
        }

        if (
            req.data.labourRate != null &&
            req.data.labourRate < 0
        ) {
            req.error(
                400,
                'Labour rate cannot be negative'
            );
        }

        if (
            req.data.taxPercent != null &&
            (
                req.data.taxPercent < 0 ||
                req.data.taxPercent > 100
            )
        ) {
            req.error(
                400,
                'Tax percentage must be between 0 and 100'
            );
        }

        if (
            req.data.autoApproveLimit != null &&
            req.data.autoApproveLimit < 0
        ) {
            req.error(
                400,
                'Auto approve limit cannot be negative'
            );
        }
    });


    // =========================================================
    // REPAIR BILL VALIDATION & CALCULATION
    // =========================================================

    this.before('CREATE', RepairBills, async (req) => {

        // -----------------------------------------------------
        // Required fields
        // -----------------------------------------------------

        if (!req.data.rental_ID) {
            req.error(400, 'Rental is required');
        }

        if (!req.data.customer_ID) {
            req.error(400, 'Customer is required');
        }

        if (!req.data.damage_ID) {
            req.error(400, 'Damage record is required');
        }

        if (!req.data.billDate) {
            req.error(400, 'Bill date is required');
        }


        // -----------------------------------------------------
        // Generate idempotency key
        // -----------------------------------------------------

        if (!req.data.idempotencyKey) {
            req.data.idempotencyKey =
                `RB-${req.data.damage_ID}`;
        }


        // -----------------------------------------------------
        // Duplicate Repair Bill Protection
        // -----------------------------------------------------

        const existingBill = await SELECT.one
            .from(RepairBills)
            .where({
                idempotencyKey: req.data.idempotencyKey
            });

        if (existingBill) {
            req.error(
                409,
                'Repair bill already exists for this damage record'
            );
        }


        // -----------------------------------------------------
        // Validate Rental
        // -----------------------------------------------------

        const rental = await SELECT.one
            .from(Rentals)
            .where({
                ID: req.data.rental_ID
            });

        if (!rental) {
            req.error(404, 'Rental not found');
        }


        // -----------------------------------------------------
        // Validate Customer
        // -----------------------------------------------------

        const customer = await SELECT.one
            .from(Customers)
            .where({
                ID: req.data.customer_ID
            });

        if (!customer) {
            req.error(404, 'Customer not found');
        }


        // -----------------------------------------------------
        // Validate Damage Record
        // -----------------------------------------------------

        const damage = await SELECT.one
            .from(DamageRecords)
            .where({
                ID: req.data.damage_ID
            });

        if (!damage) {
            req.error(404, 'Damage record not found');
        }


        // -----------------------------------------------------
        // Customer Liability Validation
        // -----------------------------------------------------

        if (damage && !damage.customerLiable) {
            req.error(
                400,
                'Repair bill cannot be created for non-customer-liable damage'
            );
        }


        // -----------------------------------------------------
        // Find Pricing Rule
        // -----------------------------------------------------

        const pricingRule = await SELECT.one
            .from(PricingRules)
            .where({
                damageType: damage.damageType,
                severity: damage.severity
            });

        if (!pricingRule) {
            req.error(
                400,
                'No pricing rule found for this damage type and severity'
            );
        }


        // -----------------------------------------------------
        // Calculate Charges
        // -----------------------------------------------------

        const baseCharge =
            Number(pricingRule.baseCharge || 0);

        const labourRate =
            Number(pricingRule.labourRate || 0);

        const taxPercent =
            Number(pricingRule.taxPercent || 0);


        const repairAmount =
            baseCharge + labourRate;

        const taxAmount =
            repairAmount * taxPercent / 100;

        const totalAmount =
            repairAmount + taxAmount;


        // -----------------------------------------------------
        // Set Calculated Amounts
        // -----------------------------------------------------

        req.data.repairAmount =
            repairAmount;

        req.data.taxAmount =
            taxAmount;

        req.data.totalAmount =
            totalAmount;


        // -----------------------------------------------------
        // Automatic / Manual Approval
        // -----------------------------------------------------

        const autoApproveLimit =
            Number(pricingRule.autoApproveLimit || 0);


        if (
            autoApproveLimit > 0 &&
            totalAmount <= autoApproveLimit
        ) {

            req.data.billingStatus =
                'Approved';

            req.data.approvalReason =
                'Automatically approved within configured limit';

        } else {

            req.data.billingStatus =
                'Draft';

            req.data.approvalReason =
                'Manual approval required because amount exceeds auto approval limit';
        }

    });

});
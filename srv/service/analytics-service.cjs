const cds = require('@sap/cds');

module.exports = cds.service.impl(function () {
    const { ConditionLogs, RepairBills, OutboxMessages } = this.entities;

    this.on('lockInspection', ConditionLogs, async (req) => {
        const reason = (req.data.reason || '').trim();
        if (!reason) {
            req.error(400, 'Reason is required');
        }

        const ID = req.params[0].ID;
        const result = await UPDATE(ConditionLogs)
            .set({ locked: true, notes: reason })
            .where({ ID });

        if (result === 0) {
            req.error(404, 'Inspection not found');
        }

        return true;
    });

    this.on('approve', RepairBills, async (req) => {
        const reason = (req.data.reason || '').trim();
        if (!reason) {
            req.error(400, 'Approval reason is required');
        }

        const ID = req.params[0].ID;
        const result = await UPDATE(RepairBills)
            .set({
                billingStatus: 'Approved',
                approvalReason: reason
            })
            .where({ ID });

        if (result === 0) {
            req.error(404, 'Repair bill not found');
        }

        return true;
    });

    this.on('adjust', RepairBills, async (req) => {
        const reason = (req.data.reason || '').trim();
        const amount = Number(req.data.amount);

        if (!reason) {
            req.error(400, 'Adjustment reason is required');
        }
        if (!Number.isFinite(amount) || amount < 0) {
            req.error(400, 'Adjustment amount must be a non-negative number');
        }

        const ID = req.params[0].ID;
        const result = await UPDATE(RepairBills)
            .set({
                totalAmount: amount,
                billingStatus: 'Adjusted',
                approvalReason: reason
            })
            .where({ ID });

        if (result === 0) {
            req.error(404, 'Repair bill not found');
        }

        return true;
    });

    this.on('reject', RepairBills, async (req) => {
        const reason = (req.data.reason || '').trim();
        if (!reason) {
            req.error(400, 'Rejection reason is required');
        }

        const ID = req.params[0].ID;
        const result = await UPDATE(RepairBills)
            .set({
                billingStatus: 'Rejected',
                approvalReason: reason
            })
            .where({ ID });

        if (result === 0) {
            req.error(404, 'Repair bill not found');
        }

        return true;
    });

    this.on('dispute', RepairBills, async (req) => {
        const reason = (req.data.reason || '').trim();
        if (!reason) {
            req.error(400, 'Dispute reason is required');
        }

        const ID = req.params[0].ID;
        const result = await UPDATE(RepairBills)
            .set({
                billingStatus: 'Disputed',
                approvalReason: reason
            })
            .where({ ID });

        if (result === 0) {
            req.error(404, 'Repair bill not found');
        }

        return true;
    });

    this.on('retry', OutboxMessages, async (req) => {
        const ID = req.params[0].ID;
        const message = await SELECT.one.from(OutboxMessages).where({ ID });

        if (!message) {
            req.error(404, 'Integration message not found');
        }

        await UPDATE(OutboxMessages)
            .set({
                status: 'New',
                lastError: null,
                attempts: Number(message.attempts || 0) + 1
            })
            .where({ ID });

        return true;
    });
});

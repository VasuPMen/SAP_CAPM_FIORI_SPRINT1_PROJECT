const cds = require('@sap/cds');

module.exports = cds.service.impl(async function () {
    const { OutboxMessages, ConditionLogs, RepairBills } = this.entities;

    const getId = (req) => req.params?.[0]?.ID || req.params?.[0]?.id;
    const requireReason = (req) => {
        const reason = String(req.data?.reason || '').trim();
        if (!reason) req.error(400, 'Reason is mandatory');
        return reason;
    };

    // FRD: Inspection Review action.
    this.on('lockInspection', ConditionLogs, async (req) => {
        const id = getId(req);
        const reason = requireReason(req);
        const log = await SELECT.one.from(ConditionLogs).where({ ID: id });
        if (!log) req.error(404, 'Condition log not found');
        if (log.locked) req.error(400, 'Inspection is already locked');
        await UPDATE(ConditionLogs)
            .set({ locked: true, notes: log.notes ? `${log.notes}\nLocked: ${reason}` : `Locked: ${reason}` })
            .where({ ID: id });
        return true;
    });

    // FRD: Damage Charge Approval actions.
    this.on('approve', RepairBills, async (req) => {
        const id = getId(req);
        const reason = requireReason(req);
        const bill = await SELECT.one.from(RepairBills).where({ ID: id });
        if (!bill) req.error(404, 'Repair bill not found');
        if (['Posted', 'Rejected'].includes(bill.billingStatus)) req.error(400, `Cannot approve a bill in ${bill.billingStatus} status`);
        await UPDATE(RepairBills).set({ billingStatus: 'Approved', approvalReason: reason }).where({ ID: id });
        return true;
    });

    this.on('adjust', RepairBills, async (req) => {
        const id = getId(req);
        const reason = requireReason(req);
        const amount = Number(req.data?.amount);
        if (!Number.isFinite(amount) || amount < 0) req.error(400, 'Adjusted amount must be a non-negative number');
        const bill = await SELECT.one.from(RepairBills).where({ ID: id });
        if (!bill) req.error(404, 'Repair bill not found');
        await UPDATE(RepairBills).set({ totalAmount: amount, billingStatus: 'Adjusted', approvalReason: reason }).where({ ID: id });
        return true;
    });

    this.on('reject', RepairBills, async (req) => {
        const id = getId(req);
        const reason = requireReason(req);
        const bill = await SELECT.one.from(RepairBills).where({ ID: id });
        if (!bill) req.error(404, 'Repair bill not found');
        await UPDATE(RepairBills).set({ billingStatus: 'Rejected', approvalReason: reason }).where({ ID: id });
        return true;
    });

    this.on('dispute', RepairBills, async (req) => {
        const id = getId(req);
        const reason = requireReason(req);
        const bill = await SELECT.one.from(RepairBills).where({ ID: id });
        if (!bill) req.error(404, 'Repair bill not found');
        await UPDATE(RepairBills).set({ billingStatus: 'Disputed', approvalReason: reason }).where({ ID: id });
        return true;
    });

    // FRD: Integration Monitor retry action.
    this.on('retry', OutboxMessages, async (req) => {
        const id = getId(req);
        const message = await SELECT.one.from(OutboxMessages).where({ ID: id });
        if (!message) req.error(404, 'Outbox message not found');
        if (message.status === 'Processing') req.error(409, 'Message is currently processing');
        if (message.status === 'Done') req.error(400, 'Completed message does not require retry');
        await UPDATE(OutboxMessages)
            .set({ status: 'New', attempts: 0, lastError: null })
            .where({ ID: id });
        return true;
    });
});

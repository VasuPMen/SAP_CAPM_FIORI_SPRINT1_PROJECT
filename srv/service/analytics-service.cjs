const cds = require('@sap/cds');

module.exports = cds.service.impl(async function () {
    const { OutboxMessages } = this.entities;

    // FRD: Integration Monitor retry action.
    this.on('retry', OutboxMessages, async (req) => {
        const id = req.params?.[0]?.ID || req.params?.[0]?.id;
        const message = await SELECT.one.from(OutboxMessages).where({ ID: id });
        if (!message) req.error(404, 'Outbox message not found');
        if (message.status === 'Processing') req.error(409, 'Message is currently processing');
        if (message.status === 'Done') req.error(400, 'Completed message does not require retry');

        await UPDATE(OutboxMessages)
            .set({
                status: 'New',
                attempts: 0,
                lastError: null
            })
            .where({ ID: id });

        return true;
    });
});

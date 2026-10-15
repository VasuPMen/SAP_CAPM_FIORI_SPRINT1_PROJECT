const cds = require('@sap/cds');

const MAX_ATTEMPTS = 5;

async function createOutboxMessage(tx, {
    target,
    entityName,
    entityId,
    payload,
    idempotencyKey
}) {
    const OutboxMessages = cds.model.definitions['retcl.OutboxMessages'];

    const existing = await tx.run(
        SELECT.one
            .from(OutboxMessages)
            .where({ idempotencyKey })
    );

    if (existing) {
        return existing;
    }

    const message = {
        target,
        entityName,
        entityId,
        payload: JSON.stringify(payload),
        status: 'New',
        attempts: 0,
        idempotencyKey
    };

    await tx.run(
        INSERT.into(OutboxMessages).entries(message)
    );

    return message;
}

async function processOutboxMessage(db, message) {
    const OutboxMessages = cds.model.definitions['retcl.OutboxMessages'];

    try {
        const payload = JSON.parse(message.payload || '{}');

        console.log(`[OUTBOX] Processing ${message.entityName} ${message.entityId}`);
        console.log(`[OUTBOX] Target: ${message.target}`);
        console.log(`[OUTBOX] Event: ${payload.event}`);

        /*
         * S/4HANA call will be added here.
         *
         * For now we only validate the message structure.
         */

        await db.run(
            UPDATE(OutboxMessages)
                .set({
                    status: 'Done',
                    lastError: null
                })
                .where({ ID: message.ID })
        );

        console.log(`[OUTBOX] Processed successfully: ${message.ID}`);
    } catch (error) {
        const attempts = Number(message.attempts || 0) + 1;
        const status = attempts >= MAX_ATTEMPTS ? 'Failed' : 'New';

        await db.run(
            UPDATE(OutboxMessages)
                .set({
                    status,
                    attempts,
                    lastError: error.message
                })
                .where({ ID: message.ID })
        );

        console.error(`[OUTBOX] Failed: ${message.ID}`, error.message);
    }
}

async function processOutbox() {
    const db = cds.db;

    const OutboxMessages = cds.model.definitions['retcl.OutboxMessages'];

    const messages = await db.run(
        SELECT
            .from(OutboxMessages)
            .where({ status: 'New' })
            .limit(20)
    );

    if (!messages.length) {
        console.log('[OUTBOX] No pending messages');
        return;
    }

    console.log(`[OUTBOX] Found ${messages.length} pending message(s)`);

    for (const message of messages) {
        await processOutboxMessage(db, message);
    }
}

module.exports = {
    createOutboxMessage,
    processOutbox
};
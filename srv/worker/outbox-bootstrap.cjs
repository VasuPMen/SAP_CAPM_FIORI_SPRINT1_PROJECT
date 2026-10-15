const cds = require('@sap/cds');
const { processOutbox } = require('./outbox-worker.cjs');

cds.on('served', async () => {
    console.log('[OUTBOX] Worker started');

    try {
        await processOutbox();
    } catch (error) {
        console.error('[OUTBOX] Worker error:', error);
    }
});
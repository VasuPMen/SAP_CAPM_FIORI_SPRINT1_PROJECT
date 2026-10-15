const cds = require('@sap/cds');
const { processOutbox } = require('./outbox-worker');

const INTERVAL = 10000;

async function startWorker() {

    console.log('[OUTBOX WORKER] Starting...');

    await processOutbox();

    setInterval(async () => {

        try {
            await processOutbox();
        } catch (error) {
            console.error(
                '[OUTBOX WORKER] Unexpected error:',
                error.message
            );
        }

    }, INTERVAL);
}

cds.on('served', () => {
    startWorker().catch(error => {
        console.error(
            '[OUTBOX WORKER] Startup failed:',
            error
        );
    });
});
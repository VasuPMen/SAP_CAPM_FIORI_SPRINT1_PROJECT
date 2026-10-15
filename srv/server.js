import cds from '@sap/cds';
import { createRequire } from 'module';

const require = createRequire(import.meta.url);
const { processOutbox } = require('./worker/outbox-worker.cjs');

cds.on('served', async () => {
    console.log('[OUTBOX WORKER] Started');

    try {
        await processOutbox();
    } catch (error) {
        console.error('[OUTBOX WORKER] Startup failed:', error);
    }

    setInterval(async () => {
        try {
            await processOutbox();
        } catch (error) {
            console.error('[OUTBOX WORKER] Error:', error.message);
        }
    }, 10000);
});

export default cds.server;

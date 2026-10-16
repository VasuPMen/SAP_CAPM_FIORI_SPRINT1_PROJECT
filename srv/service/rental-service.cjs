const cds = require('@sap/cds');
const { createOutboxMessage } = require('../worker/outbox-worker.cjs');

module.exports = cds.service.impl(async function () {
    console.log('RENTAL SERVICE LOADED');

    const {
        Customers,
        Equipment,
        Rentals,
        RentalItems
    } = this.entities;

    // Validate rental header before creation.
    this.before('CREATE', Rentals, async (req) => {
        if (!req.data.customer_ID) {
            req.error(400, 'Customer is required');
        }
        if (!req.data.rentalDate) {
            req.error(400, 'Rental date is required');
        }
        if (!req.data.expectedReturnDate) {
            req.error(400, 'Expected return date is required');
        }
        if (
            req.data.rentalDate &&
            req.data.expectedReturnDate &&
            req.data.expectedReturnDate < req.data.rentalDate
        ) {
            req.error(400, 'Expected return date cannot be before rental date');
        }

        const customer = await SELECT.one
            .from(Customers)
            .where({ ID: req.data.customer_ID });

        if (!customer) {
            req.error(404, 'Customer not found');
        }
    });

    // Validate rental item and make sure equipment is available.
    this.before('CREATE', RentalItems, async (req) => {
        if (!req.data.rental_ID) {
            req.error(400, 'Rental is required');
        }
        if (!req.data.equipment_ID) {
            req.error(400, 'Equipment is required');
        }
        if (!req.data.startDate) {
            req.error(400, 'Start date is required');
        }
        if (
            req.data.startDate &&
            req.data.endDate &&
            req.data.endDate < req.data.startDate
        ) {
            req.error(400, 'End date cannot be before start date');
        }

        const equipment = await SELECT.one
            .from(Equipment)
            .where({ ID: req.data.equipment_ID });

        if (!equipment) {
            req.error(404, 'Equipment not found');
        }
        if (equipment.currentStatus !== 'Available') {
            req.error(400, 'Equipment is not available for rental');
        }
    });

    // Record the initial rental status and enqueue the integration event
    // in the same request transaction.
    this.after('CREATE', Rentals, async (rental, req) => {
        const rentalId = req.data.ID || rental.ID;
        const rentalStatus = req.data.rentalStatus || rental.rentalStatus || 'Booked';
        const tx = cds.tx(req);

        await tx.run(
            INSERT.into('retcl.RentalStatusHistory').entries({
                rental_ID: rentalId,
                oldStatus: null,
                newStatus: rentalStatus,
                changedAt: new Date(),
                changedBy: req.user?.id || 'system'
            })
        );

        await createOutboxMessage(tx, {
            target: 'INTERNAL',
            entityName: 'Rental',
            entityId: rentalId,
            payload: {
                event: 'RentalCreated',
                rentalId,
                customerId: req.data.customer_ID,
                rentalDate: req.data.rentalDate,
                expectedReturnDate: req.data.expectedReturnDate,
                rentalStatus
            },
            idempotencyKey: `RentalCreated-${rentalId}`
        });
    });

    // Validate return dates when a rental is updated.
    this.before('UPDATE', Rentals, async (req) => {
        if (
            req.data.actualReturnDate &&
            req.data.rentalDate &&
            req.data.actualReturnDate < req.data.rentalDate
        ) {
            req.error(400, 'Actual return date cannot be before rental date');
        }
    });

    // Synchronize rental-item and equipment status with the rental status.
    this.after('UPDATE', Rentals, async (rental, req) => {
        const rentalId = rental.ID || req.data.ID;
        if (!rentalId) {
            return;
        }

        const rentalStatus = req.data.rentalStatus ?? rental.rentalStatus;
        const actualReturnDate = req.data.actualReturnDate ?? rental.actualReturnDate;

        const items = await SELECT
            .from(RentalItems)
            .where({ rental_ID: rentalId });

        if (rentalStatus === 'Active') {
            for (const item of items) {
                await UPDATE(RentalItems)
                    .set({ itemStatus: 'OutOnRent' })
                    .where({ ID: item.ID });

                await UPDATE(Equipment)
                    .set({ currentStatus: 'RentedOut' })
                    .where({ ID: item.equipment_ID });
            }
        }

        if (rentalStatus === 'Returned' && actualReturnDate) {
            for (const item of items) {
                await UPDATE(RentalItems)
                    .set({ itemStatus: 'Returned' })
                    .where({ ID: item.ID });

                await UPDATE(Equipment)
                    .set({ currentStatus: 'Available' })
                    .where({ ID: item.equipment_ID });
            }
        }
    });
});

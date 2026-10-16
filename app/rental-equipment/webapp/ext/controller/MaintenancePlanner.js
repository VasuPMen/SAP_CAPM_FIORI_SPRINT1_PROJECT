sap.ui.define([
    "sap/fe/core/PageController",
    "sap/ui/model/json/JSONModel"
], function (PageController, JSONModel) {
    "use strict";

    return PageController.extend("rental.equipment.ext.controller.MaintenancePlanner", {
        onInit: function () {
            this.getView().setModel(new JSONModel({
                startDate: new Date(),
                rows: []
            }), "calendar");
            this._loadMaintenanceCalendar();
        },

        _loadMaintenanceCalendar: async function () {
            const oModel = this.getView().getModel();
            if (!oModel) {
                return;
            }

            try {
                const oBinding = oModel.bindList(
                    "/MaintenanceRecords",
                    null,
                    null,
                    null,
                    {
                        $select: "ID,equipment_ID,maintenanceType,maintenanceDate,nextMaintenanceDate,status,description,serviceProvider"
                    }
                );
                const aContexts = await oBinding.requestContexts(0, 1000);
                const mRows = new Map();

                aContexts.forEach((oContext) => {
                    const oRecord = oContext.getObject();
                    const sEquipment = oRecord.equipment_ID || "Unassigned Equipment";
                    const oStart = this._toDate(oRecord.maintenanceDate) || new Date();
                    const oEnd = this._toDate(oRecord.nextMaintenanceDate) || new Date(oStart.getTime() + 60 * 60 * 1000);
                    const oAppointment = {
                        title: oRecord.maintenanceType || "Maintenance",
                        text: [oRecord.status, oRecord.serviceProvider].filter(Boolean).join(" • "),
                        startDate: oStart,
                        endDate: oEnd > oStart ? oEnd : new Date(oStart.getTime() + 60 * 60 * 1000),
                        type: this._calendarType(oRecord.status)
                    };

                    if (!mRows.has(sEquipment)) {
                        mRows.set(sEquipment, {
                            title: sEquipment,
                            text: "Maintenance schedule",
                            appointments: []
                        });
                    }
                    mRows.get(sEquipment).appointments.push(oAppointment);
                });

                this.getView().getModel("calendar").setProperty("/rows", Array.from(mRows.values()));
            } catch (oError) {
                // The standard table remains available even if the calendar data cannot be loaded.
                console.error("Maintenance calendar load failed", oError);
            }
        },

        _toDate: function (vValue) {
            if (!vValue) {
                return null;
            }
            const oDate = vValue instanceof Date ? vValue : new Date(`${vValue}T00:00:00`);
            return Number.isNaN(oDate.getTime()) ? null : oDate;
        },

        _calendarType: function (sStatus) {
            switch (sStatus) {
                case "Completed": return "Type06";
                case "InProgress": return "Type08";
                case "Cancelled": return "Type02";
                default: return "Type01";
            }
        }
    });
});

sap.ui.define([
    "sap/fe/core/PageController",
    "sap/ui/model/json/JSONModel",
    "sap/m/MessageToast"
], function (PageController, JSONModel, MessageToast) {
    "use strict";

    return PageController.extend("rental.equipment.ext.controller.MaintenancePlanner", {
        onInit: function () {
            this.getView().setModel(new JSONModel({ appointments: [] }), "planner");
            this._loadMaintenance();
        },

        _loadMaintenance: async function () {
            const oModel = this.getView().getModel();
            if (!oModel) {
                return;
            }

            try {
                const oBinding = oModel.bindList("/MaintenanceRecords", undefined, undefined, undefined, {
                    $select: "ID,maintenanceType,maintenanceDate,nextMaintenanceDate,status,description,serviceProvider,equipment_equipmentName"
                });
                const aContexts = await oBinding.requestContexts(0, 500);
                const aAppointments = aContexts.map((oContext) => {
                    const oData = oContext.getObject();
                    const oStart = this._toDate(oData.maintenanceDate);
                    const oEnd = this._toDate(oData.nextMaintenanceDate || oData.maintenanceDate);
                    if (!oStart) {
                        return null;
                    }
                    const oSafeEnd = oEnd && oEnd > oStart ? oEnd : new Date(oStart.getTime() + 60 * 60 * 1000);
                    return {
                        ID: oData.ID,
                        start: oStart,
                        end: oSafeEnd,
                        title: oData.maintenanceType || "Maintenance",
                        text: [oData.status, oData.equipment_equipmentName].filter(Boolean).join(" • "),
                        type: this._appointmentType(oData.status),
                        description: oData.description,
                        serviceProvider: oData.serviceProvider
                    };
                }).filter(Boolean);

                this.getView().getModel("planner").setProperty("/appointments", aAppointments);
                this.getView().byId("maintenanceCalendar").bindAggregation("appointments", {
                    path: "planner>/appointments",
                    template: this.getView().byId("maintenanceCalendar").getBindingInfo("appointments").template
                });
            } catch (oError) {
                MessageToast.show("Unable to load maintenance records");
                // Keep the page usable even when the service is temporarily unavailable.
                // eslint-disable-next-line no-console
                console.error("Maintenance planner load failed", oError);
            }
        },

        _toDate: function (vValue) {
            if (!vValue) {
                return null;
            }
            if (vValue instanceof Date) {
                return vValue;
            }
            const oDate = new Date(vValue);
            return Number.isNaN(oDate.getTime()) ? null : oDate;
        },

        _appointmentType: function (sStatus) {
            switch (sStatus) {
                case "Completed":
                    return "Type04";
                case "InProgress":
                    return "Type06";
                case "Cancelled":
                    return "Type02";
                default:
                    return "Type01";
            }
        },

        onRefresh: function () {
            this._loadMaintenance();
        },

        onAppointmentSelect: function (oEvent) {
            const oAppointment = oEvent.getParameter("appointment");
            if (!oAppointment) {
                return;
            }
            const oContext = oAppointment.getBindingContext("planner");
            if (oContext) {
                const oData = oContext.getObject();
                MessageToast.show(oData.title + (oData.text ? " — " + oData.text : ""));
            }
        }
    });
});

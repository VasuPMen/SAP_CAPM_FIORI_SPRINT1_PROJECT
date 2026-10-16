sap.ui.define([
    "sap/fe/core/PageController",
    "sap/ui/model/json/JSONModel",
    "sap/ui/core/UIComponent"
], function (PageController, JSONModel, UIComponent) {
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
                    $select: "ID,maintenanceType,maintenanceDate,nextMaintenanceDate,status,description,serviceProvider,cost",
                    $expand: "equipment($select=equipmentName)"
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
                    const sEquipmentName = oData.equipment && oData.equipment.equipmentName;
                    return {
                        ID: oData.ID,
                        start: oStart,
                        end: oSafeEnd,
                        title: oData.maintenanceType || "Maintenance",
                        text: [oData.status, sEquipmentName].filter(Boolean).join(" • "),
                        type: this._appointmentType(oData.status),
                        maintenanceType: oData.maintenanceType,
                        maintenanceDate: oData.maintenanceDate,
                        nextMaintenanceDate: oData.nextMaintenanceDate,
                        status: oData.status,
                        equipmentName: sEquipmentName,
                        description: oData.description,
                        serviceProvider: oData.serviceProvider,
                        cost: oData.cost
                    };
                }).filter(Boolean);

                this.getView().getModel("planner").setProperty("/appointments", aAppointments);
            } catch (oError) {
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
            const oData = oContext && oContext.getObject();
            if (!oData || !oData.ID) {
                return;
            }

            const oRouter = UIComponent.getRouterFor(this.getView());
            oRouter.navTo("MaintenanceObjectPage", { key: oData.ID });
        }
    });
});

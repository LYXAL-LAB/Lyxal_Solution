-- ================================================================================
-- LYXAL SURREAL - AXELOR FLEET - MODULE 3 : SUPPORT & REFERENCE
-- ================================================================================
-- Entités : VehicleTag, VehicleServiceType, VehicleCost, RecurringCost, RepairCause
-- ================================================================================

-- Tag véhicule (VehicleTag.xml - 484 bytes)
DEFINE TABLE vehicle_tag SCHEMAFULL;
DEFINE FIELD name ON vehicle_tag TYPE string ASSERT $value != NONE;
DEFINE FIELD code ON vehicle_tag TYPE string UNIQUE;
DEFINE FIELD color ON vehicle_tag TYPE string DEFAULT '#3498db';
DEFINE FIELD description ON vehicle_tag TYPE string;
DEFINE FIELD is_active ON vehicle_tag TYPE bool DEFAULT true;
DEFINE FIELD created_at ON vehicle_tag TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON vehicle_tag TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON vehicle_tag TYPE int DEFAULT 0;

-- Type de service véhicule (VehicleServiceType.xml - 492 bytes)
DEFINE TABLE vehicle_service_type SCHEMAFULL;
DEFINE FIELD name ON vehicle_service_type TYPE string ASSERT $value != NONE;
DEFINE FIELD code ON vehicle_service_type TYPE string UNIQUE;
DEFINE FIELD category_select ON vehicle_service_type TYPE int DEFAULT 1; -- 1:Maintenance, 2:Repair, 3:Inspection, 4:Cleaning, 5:Insurance
DEFINE FIELD is_recurring ON vehicle_service_type TYPE bool DEFAULT false;
DEFINE FIELD default_frequency_days ON vehicle_service_type TYPE int; -- Fréquence par défaut en jours
DEFINE FIELD default_frequency_km ON vehicle_service_type TYPE int; -- Fréquence par défaut en km
DEFINE FIELD estimated_duration ON vehicle_service_type TYPE duration; -- Durée estimée
DEFINE FIELD description ON vehicle_service_type TYPE string;
DEFINE FIELD is_active ON vehicle_service_type TYPE bool DEFAULT true;
DEFINE FIELD created_at ON vehicle_service_type TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON vehicle_service_type TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON vehicle_service_type TYPE int DEFAULT 0;

-- Coût véhicule (VehicleCost.xml - 689 bytes)
DEFINE TABLE vehicle_cost SCHEMAFULL;
DEFINE FIELD name ON vehicle_cost TYPE string ASSERT $value != NONE;
DEFINE FIELD vehicle ON vehicle_cost TYPE record<vehicle> ASSERT $value != NONE;
DEFINE FIELD company ON vehicle_cost TYPE record<company>;
DEFINE FIELD cost_date ON vehicle_cost TYPE date ASSERT $value != NONE;
DEFINE FIELD cost_type_select ON vehicle_cost TYPE int DEFAULT 1; -- 1:Fuel, 2:Maintenance, 3:Repair, 4:Insurance, 5:Tax, 6:Registration, 7:Toll, 8:Parking, 9:Other
DEFINE FIELD cost_category ON vehicle_cost TYPE string;
DEFINE FIELD amount ON vehicle_cost TYPE decimal ASSERT $value != NONE;
DEFINE FIELD currency ON vehicle_cost TYPE record<currency>;
DEFINE FIELD description ON vehicle_cost TYPE string;
DEFINE FIELD supplier_partner ON vehicle_cost TYPE record<partner>; -- Fournisseur
DEFINE FIELD invoice_no ON vehicle_cost TYPE string;
DEFINE FIELD invoice_date ON vehicle_cost TYPE date;
DEFINE FIELD invoice_file ON vehicle_cost TYPE record<meta_file>;
DEFINE FIELD payment_method_select ON vehicle_cost TYPE int DEFAULT 1; -- 1:Cash, 2:Card, 3:Bank Transfer, 4:Check
DEFINE FIELD is_reimbursable ON vehicle_cost TYPE bool DEFAULT false;
DEFINE FIELD reimbursement_amount ON vehicle_cost TYPE decimal DEFAULT 0.0;
DEFINE FIELD reimbursement_status_select ON vehicle_cost TYPE int DEFAULT 1; -- 1:Pending, 2:Approved, 3:Rejected, 4:Paid
DEFINE FIELD odometer_at_cost ON vehicle_cost TYPE decimal; -- Compteur au moment du coût
DEFINE FIELD notes ON vehicle_cost TYPE string;
DEFINE FIELD is_recurring ON vehicle_cost TYPE bool DEFAULT false;
DEFINE FIELD recurring_cost ON vehicle_cost TYPE record<recurring_cost>;
DEFINE FIELD created_at ON vehicle_cost TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON vehicle_cost TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON vehicle_cost TYPE int DEFAULT 0;

-- Coût récurrent (RecurringCost.xml - 537 bytes)
DEFINE TABLE recurring_cost SCHEMAFULL;
DEFINE FIELD name ON recurring_cost TYPE string ASSERT $value != NONE;
DEFINE FIELD code ON recurring_cost TYPE string UNIQUE;
DEFINE FIELD vehicle ON recurring_cost TYPE record<vehicle>;
DEFINE FIELD company ON recurring_cost TYPE record<company>;
DEFINE FIELD cost_type_select ON recurring_cost TYPE int DEFAULT 1; -- 1:Fuel, 2:Maintenance, 3:Repair, 4:Insurance, 5:Tax, 6:Registration
DEFINE FIELD amount ON recurring_cost TYPE decimal ASSERT $value != NONE;
DEFINE FIELD currency ON recurring_cost TYPE record<currency>;
DEFINE FIELD frequency_select ON recurring_cost TYPE int DEFAULT 1; -- 1:Daily, 2:Weekly, 3:Monthly, 4:Quarterly, 5:Semi-annual, 6:Annual
DEFINE FIELD frequency_value ON recurring_cost TYPE int DEFAULT 1; -- Nombre d'unités de fréquence
DEFINE FIELD start_date ON recurring_cost TYPE date ASSERT $value != NONE;
DEFINE FIELD end_date ON recurring_cost TYPE date;
DEFINE FIELD next_cost_date ON recurring_cost TYPE date;
DEFINE FIELD total_occurrences ON recurring_cost TYPE int; -- Nombre total d'occurrences
DEFINE FIELD generated_occurrences ON recurring_cost TYPE int DEFAULT 0; -- Occurrences générées
DEFINE FIELD is_active ON recurring_cost TYPE bool DEFAULT true;
DEFINE FIELD is_auto_generate ON recurring_cost TYPE bool DEFAULT true;
DEFINE FIELD supplier_partner ON recurring_cost TYPE record<partner>;
DEFINE FIELD description ON recurring_cost TYPE string;
DEFINE FIELD alert_days_before ON recurring_cost TYPE int DEFAULT 7; -- Alerte X jours avant
DEFINE FIELD is_alert_sent ON recurring_cost TYPE bool DEFAULT false;
DEFINE FIELD created_at ON recurring_cost TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON recurring_cost TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON recurring_cost TYPE int DEFAULT 0;

-- Cause de réparation (RepairCause.xml - 469 bytes)
DEFINE TABLE repair_cause SCHEMAFULL;
DEFINE FIELD name ON repair_cause TYPE string ASSERT $value != NONE;
DEFINE FIELD code ON repair_cause TYPE string UNIQUE;
DEFINE FIELD category_select ON repair_cause TYPE int DEFAULT 1; -- 1:Engine, 2:Transmission, 3:Brakes, 4:Electrical, 5:Body, 6:Tires, 7:Suspension, 8:Accident, 9:Wear, 10:Other
DEFINE FIELD severity_select ON repair_cause TYPE int DEFAULT 2; -- 1:Low, 2:Medium, 3:High, 4:Critical
DEFINE FIELD is_warranty_applicable ON repair_cause TYPE bool DEFAULT false;
DEFINE FIELD typical_cost_min ON repair_cause TYPE decimal DEFAULT 0.0;
DEFINE FIELD typical_cost_max ON repair_cause TYPE decimal DEFAULT 0.0;
DEFINE FIELD typical_duration ON repair_cause TYPE duration; -- Durée typique de réparation
DEFINE FIELD description ON repair_cause TYPE string;
DEFINE FIELD prevention_tips ON repair_cause TYPE string;
DEFINE FIELD is_active ON repair_cause TYPE bool DEFAULT true;
DEFINE FIELD created_at ON repair_cause TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON repair_cause TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON repair_cause TYPE int DEFAULT 0;

-- Tables de configuration et support supplémentaires
-- Configuration globale Fleet
DEFINE TABLE fleet_config SCHEMAFULL;
DEFINE FIELD company ON fleet_config TYPE record<company> UNIQUE;
DEFINE FIELD default_currency ON fleet_config TYPE record<currency>;
DEFINE FIELD default_fuel_type ON fleet_config TYPE int DEFAULT 1;
DEFINE FIELD enable_gps_tracking ON fleet_config TYPE bool DEFAULT false;
DEFINE FIELD enable_fuel_management ON fleet_config TYPE bool DEFAULT true;
DEFINE FIELD enable_maintenance_alerts ON fleet_config TYPE bool DEFAULT true;
DEFINE FIELD enable_cost_tracking ON fleet_config TYPE bool DEFAULT true;
DEFINE FIELD alert_days_before_service ON fleet_config TYPE int DEFAULT 7;
DEFINE FIELD alert_km_before_service ON fleet_config TYPE int DEFAULT 500;
DEFINE FIELD alert_days_before_insurance ON fleet_config TYPE int DEFAULT 30;
DEFINE FIELD alert_days_before_permit ON fleet_config TYPE int DEFAULT 30;
DEFINE FIELD max_fuel_efficiency_variance ON fleet_config TYPE decimal DEFAULT 20.0; -- %
DEFINE FIELD odometer_update_frequency ON fleet_config TYPE int DEFAULT 1; -- 1:Daily, 2:Weekly, 3:Monthly
DEFINE FIELD created_at ON fleet_config TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON fleet_config TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON fleet_config TYPE int DEFAULT 0;

-- Rapport Fleet
DEFINE TABLE fleet_report SCHEMAFULL;
DEFINE FIELD name ON fleet_report TYPE string ASSERT $value != NONE;
DEFINE FIELD report_type_select ON fleet_report TYPE int DEFAULT 1; -- 1:Cost, 2:Fuel, 3:Maintenance, 4:Utilization, 5:Performance
DEFINE FIELD company ON fleet_report TYPE record<company>;
DEFINE FIELD date_from ON fleet_report TYPE date;
DEFINE FIELD date_to ON fleet_report TYPE date;
DEFINE FIELD vehicle_filter ON fleet_report TYPE array<record<vehicle>>;
DEFINE FIELD generated_date ON fleet_report TYPE datetime;
DEFINE FIELD generated_by ON fleet_report TYPE record<user>;
DEFINE FIELD report_file ON fleet_report TYPE record<meta_file>;
DEFINE FIELD total_vehicles ON fleet_report TYPE int DEFAULT 0;
DEFINE FIELD total_cost ON fleet_report TYPE decimal DEFAULT 0.0;
DEFINE FIELD total_fuel_cost ON fleet_report TYPE decimal DEFAULT 0.0;
DEFINE FIELD total_maintenance_cost ON fleet_report TYPE decimal DEFAULT 0.0;
DEFINE FIELD total_distance ON fleet_report TYPE decimal DEFAULT 0.0;
DEFINE FIELD average_fuel_efficiency ON fleet_report TYPE decimal DEFAULT 0.0;
DEFINE FIELD currency ON fleet_report TYPE record<currency>;
DEFINE FIELD created_at ON fleet_report TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON fleet_report TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON fleet_report TYPE int DEFAULT 0;

-- Alerte Fleet
DEFINE TABLE fleet_alert SCHEMAFULL;
DEFINE FIELD name ON fleet_alert TYPE string ASSERT $value != NONE;
DEFINE FIELD alert_type_select ON fleet_alert TYPE int DEFAULT 1; -- 1:Insurance Expiry, 2:Permit Expiry, 3:Service Due, 4:Fuel Efficiency, 5:Cost Overrun, 6:Accident
DEFINE FIELD vehicle ON fleet_alert TYPE record<vehicle>;
DEFINE FIELD company ON fleet_alert TYPE record<company>;
DEFINE FIELD priority_select ON fleet_alert TYPE int DEFAULT 2; -- 1:Low, 2:Medium, 3:High, 4:Critical
DEFINE FIELD status_select ON fleet_alert TYPE int DEFAULT 1; -- 1:New, 2:Acknowledged, 3:In Progress, 4:Resolved, 5:Dismissed
DEFINE FIELD alert_date ON fleet_alert TYPE datetime DEFAULT time::now();
DEFINE FIELD due_date ON fleet_alert TYPE date;
DEFINE FIELD message ON fleet_alert TYPE string;
DEFINE FIELD assigned_to ON fleet_alert TYPE record<user>;
DEFINE FIELD acknowledged_by ON fleet_alert TYPE record<user>;
DEFINE FIELD acknowledged_date ON fleet_alert TYPE datetime;
DEFINE FIELD resolved_by ON fleet_alert TYPE record<user>;
DEFINE FIELD resolved_date ON fleet_alert TYPE datetime;
DEFINE FIELD resolution_notes ON fleet_alert TYPE string;
DEFINE FIELD is_auto_generated ON fleet_alert TYPE bool DEFAULT true;
DEFINE FIELD recurring_cost ON fleet_alert TYPE record<recurring_cost>;
DEFINE FIELD vehicle_contract ON fleet_alert TYPE record<vehicle_contract>;
DEFINE FIELD created_at ON fleet_alert TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON fleet_alert TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON fleet_alert TYPE int DEFAULT 0;

-- Index d'optimisation
DEFINE INDEX idx_vehicle_tag_name ON vehicle_tag FIELDS name;
DEFINE INDEX idx_vehicle_tag_code ON vehicle_tag FIELDS code;
DEFINE INDEX idx_vehicle_tag_active ON vehicle_tag FIELDS is_active;

DEFINE INDEX idx_vehicle_service_type_name ON vehicle_service_type FIELDS name;
DEFINE INDEX idx_vehicle_service_type_code ON vehicle_service_type FIELDS code;
DEFINE INDEX idx_vehicle_service_type_category ON vehicle_service_type FIELDS category_select;
DEFINE INDEX idx_vehicle_service_type_recurring ON vehicle_service_type FIELDS is_recurring;
DEFINE INDEX idx_vehicle_service_type_active ON vehicle_service_type FIELDS is_active;

DEFINE INDEX idx_vehicle_cost_vehicle ON vehicle_cost FIELDS vehicle;
DEFINE INDEX idx_vehicle_cost_date ON vehicle_cost FIELDS cost_date;
DEFINE INDEX idx_vehicle_cost_type ON vehicle_cost FIELDS cost_type_select;
DEFINE INDEX idx_vehicle_cost_supplier ON vehicle_cost FIELDS supplier_partner;
DEFINE INDEX idx_vehicle_cost_recurring ON vehicle_cost FIELDS is_recurring;
DEFINE INDEX idx_vehicle_cost_reimbursable ON vehicle_cost FIELDS is_reimbursable;

DEFINE INDEX idx_recurring_cost_code ON recurring_cost FIELDS code;
DEFINE INDEX idx_recurring_cost_vehicle ON recurring_cost FIELDS vehicle;
DEFINE INDEX idx_recurring_cost_type ON recurring_cost FIELDS cost_type_select;
DEFINE INDEX idx_recurring_cost_frequency ON recurring_cost FIELDS frequency_select;
DEFINE INDEX idx_recurring_cost_next_date ON recurring_cost FIELDS next_cost_date;
DEFINE INDEX idx_recurring_cost_active ON recurring_cost FIELDS is_active;
DEFINE INDEX idx_recurring_cost_auto_generate ON recurring_cost FIELDS is_auto_generate;

DEFINE INDEX idx_repair_cause_name ON repair_cause FIELDS name;
DEFINE INDEX idx_repair_cause_code ON repair_cause FIELDS code;
DEFINE INDEX idx_repair_cause_category ON repair_cause FIELDS category_select;
DEFINE INDEX idx_repair_cause_severity ON repair_cause FIELDS severity_select;
DEFINE INDEX idx_repair_cause_warranty ON repair_cause FIELDS is_warranty_applicable;
DEFINE INDEX idx_repair_cause_active ON repair_cause FIELDS is_active;

DEFINE INDEX idx_fleet_config_company ON fleet_config FIELDS company;

DEFINE INDEX idx_fleet_report_type ON fleet_report FIELDS report_type_select;
DEFINE INDEX idx_fleet_report_company ON fleet_report FIELDS company;
DEFINE INDEX idx_fleet_report_date_range ON fleet_report FIELDS date_from, date_to;
DEFINE INDEX idx_fleet_report_generated_by ON fleet_report FIELDS generated_by;

DEFINE INDEX idx_fleet_alert_type ON fleet_alert FIELDS alert_type_select;
DEFINE INDEX idx_fleet_alert_vehicle ON fleet_alert FIELDS vehicle;
DEFINE INDEX idx_fleet_alert_priority ON fleet_alert FIELDS priority_select;
DEFINE INDEX idx_fleet_alert_status ON fleet_alert FIELDS status_select;
DEFINE INDEX idx_fleet_alert_assigned_to ON fleet_alert FIELDS assigned_to;
DEFINE INDEX idx_fleet_alert_due_date ON fleet_alert FIELDS due_date;
DEFINE INDEX idx_fleet_alert_auto_generated ON fleet_alert FIELDS is_auto_generated; 
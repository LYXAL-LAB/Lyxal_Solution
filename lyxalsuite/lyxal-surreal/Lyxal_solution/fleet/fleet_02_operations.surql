 -- ================================================================================
-- LYXAL SURREAL - AXELOR FLEET - MODULE 2 : OPERATIONS
-- ================================================================================
-- Entités : Booking, VehicleRent, VehicleService, VehicleFuelLog, VehicleServiceLog, VehicleOdometer, VehicleRepair
-- ================================================================================

-- Réservation véhicule (Booking.xml - 822 bytes)
DEFINE TABLE booking SCHEMAFULL;
DEFINE FIELD name ON booking TYPE string ASSERT $value != NONE;
DEFINE FIELD booking_no ON booking TYPE string UNIQUE;
DEFINE FIELD vehicle ON booking TYPE record<vehicle> ASSERT $value != NONE;
DEFINE FIELD partner ON booking TYPE record<partner>; -- Client/Utilisateur
DEFINE FIELD driver_partner ON booking TYPE record<partner>; -- Conducteur
DEFINE FIELD company ON booking TYPE record<company>;
DEFINE FIELD booking_date ON booking TYPE date ASSERT $value != NONE;
DEFINE FIELD from_date_time ON booking TYPE datetime ASSERT $value != NONE;
DEFINE FIELD to_date_time ON booking TYPE datetime ASSERT $value != NONE;
DEFINE FIELD duration ON booking TYPE duration; -- Durée calculée
DEFINE FIELD purpose ON booking TYPE string; -- Objet de la réservation
DEFINE FIELD destination ON booking TYPE string;
DEFINE FIELD pickup_location ON booking TYPE string;
DEFINE FIELD drop_location ON booking TYPE string;
DEFINE FIELD estimated_distance ON booking TYPE decimal DEFAULT 0.0; -- km
DEFINE FIELD actual_distance ON booking TYPE decimal DEFAULT 0.0; -- km
DEFINE FIELD status_select ON booking TYPE int DEFAULT 1; -- 1:Draft, 2:Confirmed, 3:In Progress, 4:Completed, 5:Cancelled
DEFINE FIELD booking_amount ON booking TYPE decimal DEFAULT 0.0;
DEFINE FIELD currency ON booking TYPE record<currency>;
DEFINE FIELD fuel_cost ON booking TYPE decimal DEFAULT 0.0;
DEFINE FIELD toll_cost ON booking TYPE decimal DEFAULT 0.0;
DEFINE FIELD other_cost ON booking TYPE decimal DEFAULT 0.0;
DEFINE FIELD total_cost ON booking TYPE decimal DEFAULT 0.0;
DEFINE FIELD notes ON booking TYPE string;
DEFINE FIELD is_fuel_reimbursement ON booking TYPE bool DEFAULT false;
DEFINE FIELD fuel_reimbursement_amount ON booking TYPE decimal DEFAULT 0.0;
DEFINE FIELD created_at ON booking TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON booking TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON booking TYPE int DEFAULT 0;

-- Location véhicule (VehicleRent.xml - 962 bytes)
DEFINE TABLE vehicle_rent SCHEMAFULL;
DEFINE FIELD name ON vehicle_rent TYPE string ASSERT $value != NONE;
DEFINE FIELD rent_no ON vehicle_rent TYPE string UNIQUE;
DEFINE FIELD vehicle ON vehicle_rent TYPE record<vehicle> ASSERT $value != NONE;
DEFINE FIELD partner ON vehicle_rent TYPE record<partner>; -- Locataire
DEFINE FIELD company ON vehicle_rent TYPE record<company>;
DEFINE FIELD from_date ON vehicle_rent TYPE date ASSERT $value != NONE;
DEFINE FIELD to_date ON vehicle_rent TYPE date ASSERT $value != NONE;
DEFINE FIELD duration_days ON vehicle_rent TYPE int; -- Durée en jours
DEFINE FIELD daily_rent ON vehicle_rent TYPE decimal DEFAULT 0.0;
DEFINE FIELD total_rent ON vehicle_rent TYPE decimal DEFAULT 0.0;
DEFINE FIELD currency ON vehicle_rent TYPE record<currency>;
DEFINE FIELD security_deposit ON vehicle_rent TYPE decimal DEFAULT 0.0;
DEFINE FIELD advance_payment ON vehicle_rent TYPE decimal DEFAULT 0.0;
DEFINE FIELD balance_amount ON vehicle_rent TYPE decimal DEFAULT 0.0;
DEFINE FIELD status_select ON vehicle_rent TYPE int DEFAULT 1; -- 1:Draft, 2:Active, 3:Completed, 4:Cancelled
DEFINE FIELD pickup_odometer ON vehicle_rent TYPE decimal DEFAULT 0.0;
DEFINE FIELD return_odometer ON vehicle_rent TYPE decimal DEFAULT 0.0;
DEFINE FIELD distance_travelled ON vehicle_rent TYPE decimal DEFAULT 0.0;
DEFINE FIELD fuel_level_pickup ON vehicle_rent TYPE decimal; -- Niveau carburant départ
DEFINE FIELD fuel_level_return ON vehicle_rent TYPE decimal; -- Niveau carburant retour
DEFINE FIELD damage_assessment ON vehicle_rent TYPE string;
DEFINE FIELD damage_cost ON vehicle_rent TYPE decimal DEFAULT 0.0;
DEFINE FIELD terms_conditions ON vehicle_rent TYPE string;
DEFINE FIELD contract_file ON vehicle_rent TYPE record<meta_file>;
DEFINE FIELD notes ON vehicle_rent TYPE string;
DEFINE FIELD created_at ON vehicle_rent TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON vehicle_rent TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON vehicle_rent TYPE int DEFAULT 0;

-- Service véhicule (VehicleService.xml - 556 bytes)
DEFINE TABLE vehicle_service SCHEMAFULL;
DEFINE FIELD name ON vehicle_service TYPE string ASSERT $value != NONE;
DEFINE FIELD code ON vehicle_service TYPE string UNIQUE;
DEFINE FIELD vehicle_service_type ON vehicle_service TYPE record<vehicle_service_type>;
DEFINE FIELD description ON vehicle_service TYPE string;
DEFINE FIELD estimated_cost ON vehicle_service TYPE decimal DEFAULT 0.0;
DEFINE FIELD currency ON vehicle_service TYPE record<currency>;
DEFINE FIELD frequency_in_days ON vehicle_service TYPE int; -- Fréquence en jours
DEFINE FIELD frequency_in_km ON vehicle_service TYPE int; -- Fréquence en km
DEFINE FIELD is_active ON vehicle_service TYPE bool DEFAULT true;
DEFINE FIELD created_at ON vehicle_service TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON vehicle_service TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON vehicle_service TYPE int DEFAULT 0;

-- Log carburant (VehicleFuelLog.xml - 1034 bytes)
DEFINE TABLE vehicle_fuel_log SCHEMAFULL;
DEFINE FIELD name ON vehicle_fuel_log TYPE string ASSERT $value != NONE;
DEFINE FIELD vehicle ON vehicle_fuel_log TYPE record<vehicle> ASSERT $value != NONE;
DEFINE FIELD driver_partner ON vehicle_fuel_log TYPE record<partner>;
DEFINE FIELD company ON vehicle_fuel_log TYPE record<company>;
DEFINE FIELD fuel_date ON vehicle_fuel_log TYPE date ASSERT $value != NONE;
DEFINE FIELD fuel_station ON vehicle_fuel_log TYPE string;
DEFINE FIELD fuel_type_select ON vehicle_fuel_log TYPE int DEFAULT 1; -- 1:Gasoline, 2:Diesel, 3:CNG, 4:LPG
DEFINE FIELD quantity ON vehicle_fuel_log TYPE decimal ASSERT $value != NONE; -- Litres
DEFINE FIELD price_per_liter ON vehicle_fuel_log TYPE decimal DEFAULT 0.0;
DEFINE FIELD total_amount ON vehicle_fuel_log TYPE decimal DEFAULT 0.0;
DEFINE FIELD currency ON vehicle_fuel_log TYPE record<currency>;
DEFINE FIELD odometer_at_fuel ON vehicle_fuel_log TYPE decimal; -- Compteur au moment du plein
DEFINE FIELD is_full_tank ON vehicle_fuel_log TYPE bool DEFAULT false;
DEFINE FIELD payment_method_select ON vehicle_fuel_log TYPE int DEFAULT 1; -- 1:Cash, 2:Card, 3:Company Account
DEFINE FIELD receipt_no ON vehicle_fuel_log TYPE string;
DEFINE FIELD receipt_file ON vehicle_fuel_log TYPE record<meta_file>;
DEFINE FIELD distance_since_last_fuel ON vehicle_fuel_log TYPE decimal; -- km depuis dernier plein
DEFINE FIELD fuel_efficiency ON vehicle_fuel_log TYPE decimal; -- km/L
DEFINE FIELD notes ON vehicle_fuel_log TYPE string;
DEFINE FIELD is_reimbursable ON vehicle_fuel_log TYPE bool DEFAULT false;
DEFINE FIELD reimbursement_amount ON vehicle_fuel_log TYPE decimal DEFAULT 0.0;
DEFINE FIELD created_at ON vehicle_fuel_log TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON vehicle_fuel_log TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON vehicle_fuel_log TYPE int DEFAULT 0;

-- Log service véhicule (VehicleServiceLog.xml - 953 bytes)
DEFINE TABLE vehicle_service_log SCHEMAFULL;
DEFINE FIELD name ON vehicle_service_log TYPE string ASSERT $value != NONE;
DEFINE FIELD vehicle ON vehicle_service_log TYPE record<vehicle> ASSERT $value != NONE;
DEFINE FIELD vehicle_service ON vehicle_service_log TYPE record<vehicle_service>;
DEFINE FIELD service_provider ON vehicle_service_log TYPE record<partner>; -- Garage/Prestataire
DEFINE FIELD company ON vehicle_service_log TYPE record<company>;
DEFINE FIELD service_date ON vehicle_service_log TYPE date ASSERT $value != NONE;
DEFINE FIELD service_type_select ON vehicle_service_log TYPE int DEFAULT 1; -- 1:Maintenance, 2:Repair, 3:Inspection, 4:Cleaning
DEFINE FIELD description ON vehicle_service_log TYPE string;
DEFINE FIELD odometer_at_service ON vehicle_service_log TYPE decimal;
DEFINE FIELD service_cost ON vehicle_service_log TYPE decimal DEFAULT 0.0;
DEFINE FIELD parts_cost ON vehicle_service_log TYPE decimal DEFAULT 0.0;
DEFINE FIELD labor_cost ON vehicle_service_log TYPE decimal DEFAULT 0.0;
DEFINE FIELD total_cost ON vehicle_service_log TYPE decimal DEFAULT 0.0;
DEFINE FIELD currency ON vehicle_service_log TYPE record<currency>;
DEFINE FIELD warranty_period ON vehicle_service_log TYPE int; -- Jours de garantie
DEFINE FIELD warranty_end_date ON vehicle_service_log TYPE date;
DEFINE FIELD next_service_date ON vehicle_service_log TYPE date;
DEFINE FIELD next_service_odometer ON vehicle_service_log TYPE decimal;
DEFINE FIELD invoice_no ON vehicle_service_log TYPE string;
DEFINE FIELD invoice_file ON vehicle_service_log TYPE record<meta_file>;
DEFINE FIELD parts_replaced ON vehicle_service_log TYPE string;
DEFINE FIELD technician_name ON vehicle_service_log TYPE string;
DEFINE FIELD is_warranty_service ON vehicle_service_log TYPE bool DEFAULT false;
DEFINE FIELD notes ON vehicle_service_log TYPE string;
DEFINE FIELD created_at ON vehicle_service_log TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON vehicle_service_log TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON vehicle_service_log TYPE int DEFAULT 0;

-- Compteur véhicule (VehicleOdometer.xml - 721 bytes)
DEFINE TABLE vehicle_odometer SCHEMAFULL;
DEFINE FIELD name ON vehicle_odometer TYPE string ASSERT $value != NONE;
DEFINE FIELD vehicle ON vehicle_odometer TYPE record<vehicle> ASSERT $value != NONE;
DEFINE FIELD driver_partner ON vehicle_odometer TYPE record<partner>;
DEFINE FIELD company ON vehicle_odometer TYPE record<company>;
DEFINE FIELD reading_date ON vehicle_odometer TYPE date ASSERT $value != NONE;
DEFINE FIELD odometer_reading ON vehicle_odometer TYPE decimal ASSERT $value != NONE;
DEFINE FIELD previous_reading ON vehicle_odometer TYPE decimal DEFAULT 0.0;
DEFINE FIELD distance_travelled ON vehicle_odometer TYPE decimal DEFAULT 0.0;
DEFINE FIELD reading_type_select ON vehicle_odometer TYPE int DEFAULT 1; -- 1:Manual, 2:Automatic, 3:GPS
DEFINE FIELD location ON vehicle_odometer TYPE string;
DEFINE FIELD notes ON vehicle_odometer TYPE string;
DEFINE FIELD is_verified ON vehicle_odometer TYPE bool DEFAULT false;
DEFINE FIELD verified_by ON vehicle_odometer TYPE record<user>;
DEFINE FIELD verification_date ON vehicle_odometer TYPE datetime;
DEFINE FIELD photo ON vehicle_odometer TYPE record<meta_file>; -- Photo du compteur
DEFINE FIELD created_at ON vehicle_odometer TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON vehicle_odometer TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON vehicle_odometer TYPE int DEFAULT 0;

-- Réparation véhicule (VehicleRepair.xml - 598 bytes)
DEFINE TABLE vehicle_repair SCHEMAFULL;
DEFINE FIELD name ON vehicle_repair TYPE string ASSERT $value != NONE;
DEFINE FIELD vehicle ON vehicle_repair TYPE record<vehicle> ASSERT $value != NONE;
DEFINE FIELD repair_cause ON vehicle_repair TYPE record<repair_cause>;
DEFINE FIELD service_provider ON vehicle_repair TYPE record<partner>; -- Garage
DEFINE FIELD company ON vehicle_repair TYPE record<company>;
DEFINE FIELD repair_date ON vehicle_repair TYPE date ASSERT $value != NONE;
DEFINE FIELD description ON vehicle_repair TYPE string;
DEFINE FIELD repair_cost ON vehicle_repair TYPE decimal DEFAULT 0.0;
DEFINE FIELD parts_cost ON vehicle_repair TYPE decimal DEFAULT 0.0;
DEFINE FIELD labor_cost ON vehicle_repair TYPE decimal DEFAULT 0.0;
DEFINE FIELD total_cost ON vehicle_repair TYPE decimal DEFAULT 0.0;
DEFINE FIELD currency ON vehicle_repair TYPE record<currency>;
DEFINE FIELD warranty_period ON vehicle_repair TYPE int; -- Jours
DEFINE FIELD warranty_end_date ON vehicle_repair TYPE date;
DEFINE FIELD is_warranty_repair ON vehicle_repair TYPE bool DEFAULT false;
DEFINE FIELD invoice_no ON vehicle_repair TYPE string;
DEFINE FIELD invoice_file ON vehicle_repair TYPE record<meta_file>;
DEFINE FIELD is_insurance_claim ON vehicle_repair TYPE bool DEFAULT false;
DEFINE FIELD insurance_claim_no ON vehicle_repair TYPE string;
DEFINE FIELD insurance_amount ON vehicle_repair TYPE decimal DEFAULT 0.0;
DEFINE FIELD notes ON vehicle_repair TYPE string;
DEFINE FIELD created_at ON vehicle_repair TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON vehicle_repair TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON vehicle_repair TYPE int DEFAULT 0;

-- Index d'optimisation
DEFINE INDEX idx_booking_no ON booking FIELDS booking_no;
DEFINE INDEX idx_booking_vehicle ON booking FIELDS vehicle;
DEFINE INDEX idx_booking_partner ON booking FIELDS partner;
DEFINE INDEX idx_booking_status ON booking FIELDS status_select;
DEFINE INDEX idx_booking_date ON booking FIELDS booking_date;
DEFINE INDEX idx_booking_from_date ON booking FIELDS from_date_time;
DEFINE INDEX idx_booking_to_date ON booking FIELDS to_date_time;

DEFINE INDEX idx_vehicle_rent_no ON vehicle_rent FIELDS rent_no;
DEFINE INDEX idx_vehicle_rent_vehicle ON vehicle_rent FIELDS vehicle;
DEFINE INDEX idx_vehicle_rent_partner ON vehicle_rent FIELDS partner;
DEFINE INDEX idx_vehicle_rent_status ON vehicle_rent FIELDS status_select;
DEFINE INDEX idx_vehicle_rent_from_date ON vehicle_rent FIELDS from_date;
DEFINE INDEX idx_vehicle_rent_to_date ON vehicle_rent FIELDS to_date;

DEFINE INDEX idx_vehicle_service_code ON vehicle_service FIELDS code;
DEFINE INDEX idx_vehicle_service_type ON vehicle_service FIELDS vehicle_service_type;
DEFINE INDEX idx_vehicle_service_active ON vehicle_service FIELDS is_active;

DEFINE INDEX idx_vehicle_fuel_log_vehicle ON vehicle_fuel_log FIELDS vehicle;
DEFINE INDEX idx_vehicle_fuel_log_date ON vehicle_fuel_log FIELDS fuel_date;
DEFINE INDEX idx_vehicle_fuel_log_driver ON vehicle_fuel_log FIELDS driver_partner;
DEFINE INDEX idx_vehicle_fuel_log_fuel_type ON vehicle_fuel_log FIELDS fuel_type_select;
DEFINE INDEX idx_vehicle_fuel_log_odometer ON vehicle_fuel_log FIELDS odometer_at_fuel;

DEFINE INDEX idx_vehicle_service_log_vehicle ON vehicle_service_log FIELDS vehicle;
DEFINE INDEX idx_vehicle_service_log_date ON vehicle_service_log FIELDS service_date;
DEFINE INDEX idx_vehicle_service_log_service ON vehicle_service_log FIELDS vehicle_service;
DEFINE INDEX idx_vehicle_service_log_provider ON vehicle_service_log FIELDS service_provider;
DEFINE INDEX idx_vehicle_service_log_type ON vehicle_service_log FIELDS service_type_select;
DEFINE INDEX idx_vehicle_service_log_next_service ON vehicle_service_log FIELDS next_service_date;

DEFINE INDEX idx_vehicle_odometer_vehicle ON vehicle_odometer FIELDS vehicle;
DEFINE INDEX idx_vehicle_odometer_date ON vehicle_odometer FIELDS reading_date;
DEFINE INDEX idx_vehicle_odometer_reading ON vehicle_odometer FIELDS odometer_reading;
DEFINE INDEX idx_vehicle_odometer_type ON vehicle_odometer FIELDS reading_type_select;
DEFINE INDEX idx_vehicle_odometer_verified ON vehicle_odometer FIELDS is_verified;

DEFINE INDEX idx_vehicle_repair_vehicle ON vehicle_repair FIELDS vehicle;
DEFINE INDEX idx_vehicle_repair_date ON vehicle_repair FIELDS repair_date;
DEFINE INDEX idx_vehicle_repair_cause ON vehicle_repair FIELDS repair_cause;
DEFINE INDEX idx_vehicle_repair_provider ON vehicle_repair FIELDS service_provider;
DEFINE INDEX idx_vehicle_repair_warranty ON vehicle_repair FIELDS is_warranty_repair;
DEFINE INDEX idx_vehicle_repair_insurance ON vehicle_repair FIELDS is_insurance_claim;
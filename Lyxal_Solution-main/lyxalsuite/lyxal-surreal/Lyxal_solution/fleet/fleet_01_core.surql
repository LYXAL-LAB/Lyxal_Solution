-- ================================================================================
-- LYXAL SURREAL - AXELOR FLEET - MODULE 1 : CORE FLEET
-- ================================================================================
-- Entités : Vehicle, VehicleModel, VehicleMake, VehicleContract
-- ================================================================================

-- Véhicule principal (Vehicle.xml - 2711 bytes)
DEFINE TABLE vehicle SCHEMAFULL;
DEFINE FIELD plate_no ON vehicle TYPE string; -- Plaque d'immatriculation
DEFINE FIELD name ON vehicle TYPE string; -- Nom computed
DEFINE FIELD company ON vehicle TYPE record<company>;
DEFINE FIELD chassis_no ON vehicle TYPE string; -- Numéro de châssis
DEFINE FIELD driver_partner ON vehicle TYPE record<partner>; -- Conducteur principal
DEFINE FIELD vehicle_model ON vehicle TYPE record<vehicle_model> ASSERT $value != NONE;
DEFINE FIELD vehicle_make ON vehicle TYPE record<vehicle_make>;
DEFINE FIELD registration_date ON vehicle TYPE date; -- Date d'immatriculation
DEFINE FIELD acquisition_date ON vehicle TYPE date; -- Date d'acquisition
DEFINE FIELD acquisition_cost ON vehicle TYPE decimal DEFAULT 0.0;
DEFINE FIELD currency ON vehicle TYPE record<currency>;
DEFINE FIELD vin_no ON vehicle TYPE string; -- Vehicle Identification Number
DEFINE FIELD color ON vehicle TYPE string;
DEFINE FIELD year ON vehicle TYPE int; -- Année de fabrication
DEFINE FIELD fuel_type_select ON vehicle TYPE int DEFAULT 1; -- 1:Gasoline, 2:Diesel, 3:Electric, 4:Hybrid
DEFINE FIELD engine_capacity ON vehicle TYPE decimal; -- Cylindrée
DEFINE FIELD horse_power ON vehicle TYPE decimal; -- Puissance
DEFINE FIELD transmission_select ON vehicle TYPE int DEFAULT 1; -- 1:Manual, 2:Automatic
DEFINE FIELD seating_capacity ON vehicle TYPE int DEFAULT 5;
DEFINE FIELD load_capacity ON vehicle TYPE decimal; -- Capacité de charge (kg)
DEFINE FIELD fuel_capacity ON vehicle TYPE decimal; -- Capacité réservoir (L)
DEFINE FIELD odometer ON vehicle TYPE decimal DEFAULT 0.0; -- Compteur kilométrique
DEFINE FIELD odometer_date ON vehicle TYPE date; -- Date compteur
DEFINE FIELD status_select ON vehicle TYPE int DEFAULT 1; -- 1:Active, 2:Inactive, 3:Sold, 4:Scrapped
DEFINE FIELD is_rental ON vehicle TYPE bool DEFAULT false;
DEFINE FIELD rental_price_per_day ON vehicle TYPE decimal DEFAULT 0.0;
DEFINE FIELD insurance_company ON vehicle TYPE string;
DEFINE FIELD insurance_policy_no ON vehicle TYPE string;
DEFINE FIELD insurance_start_date ON vehicle TYPE date;
DEFINE FIELD insurance_end_date ON vehicle TYPE date;
DEFINE FIELD insurance_amount ON vehicle TYPE decimal DEFAULT 0.0;
DEFINE FIELD tax_paid_date ON vehicle TYPE date;
DEFINE FIELD tax_amount ON vehicle TYPE decimal DEFAULT 0.0;
DEFINE FIELD fitness_certificate_date ON vehicle TYPE date;
DEFINE FIELD fitness_certificate_end_date ON vehicle TYPE date;
DEFINE FIELD permit_date ON vehicle TYPE date;
DEFINE FIELD permit_end_date ON vehicle TYPE date;
DEFINE FIELD pollution_certificate_date ON vehicle TYPE date;
DEFINE FIELD pollution_certificate_end_date ON vehicle TYPE date;
DEFINE FIELD notes ON vehicle TYPE string;
DEFINE FIELD vehicle_tag_set ON vehicle TYPE array<record<vehicle_tag>>;
DEFINE FIELD vehicle_service_log_list ON vehicle TYPE array<record<vehicle_service_log>>;
DEFINE FIELD vehicle_fuel_log_list ON vehicle TYPE array<record<vehicle_fuel_log>>;
DEFINE FIELD booking_list ON vehicle TYPE array<record<booking>>;
DEFINE FIELD vehicle_cost_list ON vehicle TYPE array<record<vehicle_cost>>;
DEFINE FIELD created_at ON vehicle TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON vehicle TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON vehicle TYPE int DEFAULT 0;

-- Modèle de véhicule (VehicleModel.xml - 954 bytes)
DEFINE TABLE vehicle_model SCHEMAFULL;
DEFINE FIELD name ON vehicle_model TYPE string ASSERT $value != NONE;
DEFINE FIELD code ON vehicle_model TYPE string UNIQUE;
DEFINE FIELD vehicle_make ON vehicle_model TYPE record<vehicle_make> ASSERT $value != NONE;
DEFINE FIELD vehicle_category_select ON vehicle_model TYPE int DEFAULT 1; -- 1:Car, 2:Truck, 3:Bus, 4:Motorcycle, 5:Van
DEFINE FIELD fuel_type_select ON vehicle_model TYPE int DEFAULT 1; -- 1:Gasoline, 2:Diesel, 3:Electric, 4:Hybrid
DEFINE FIELD transmission_select ON vehicle_model TYPE int DEFAULT 1; -- 1:Manual, 2:Automatic
DEFINE FIELD engine_capacity ON vehicle_model TYPE decimal; -- Cylindrée standard
DEFINE FIELD horse_power ON vehicle_model TYPE decimal; -- Puissance standard
DEFINE FIELD seating_capacity ON vehicle_model TYPE int DEFAULT 5;
DEFINE FIELD load_capacity ON vehicle_model TYPE decimal; -- Capacité de charge standard
DEFINE FIELD fuel_capacity ON vehicle_model TYPE decimal; -- Capacité réservoir standard
DEFINE FIELD average_fuel_consumption ON vehicle_model TYPE decimal; -- Consommation moyenne (L/100km)
DEFINE FIELD is_active ON vehicle_model TYPE bool DEFAULT true;
DEFINE FIELD description ON vehicle_model TYPE string;
DEFINE FIELD created_at ON vehicle_model TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON vehicle_model TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON vehicle_model TYPE int DEFAULT 0;

-- Marque de véhicule (VehicleMake.xml - 566 bytes)
DEFINE TABLE vehicle_make SCHEMAFULL;
DEFINE FIELD name ON vehicle_make TYPE string ASSERT $value != NONE;
DEFINE FIELD code ON vehicle_make TYPE string UNIQUE;
DEFINE FIELD country ON vehicle_make TYPE record<country>; -- Pays d'origine
DEFINE FIELD is_active ON vehicle_make TYPE bool DEFAULT true;
DEFINE FIELD logo ON vehicle_make TYPE record<meta_file>; -- Logo de la marque
DEFINE FIELD website ON vehicle_make TYPE string;
DEFINE FIELD description ON vehicle_make TYPE string;
DEFINE FIELD created_at ON vehicle_make TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON vehicle_make TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON vehicle_make TYPE int DEFAULT 0;

-- Contrat véhicule (VehicleContract.xml - 1722 bytes)
DEFINE TABLE vehicle_contract SCHEMAFULL;
DEFINE FIELD name ON vehicle_contract TYPE string ASSERT $value != NONE;
DEFINE FIELD contract_no ON vehicle_contract TYPE string UNIQUE;
DEFINE FIELD vehicle ON vehicle_contract TYPE record<vehicle> ASSERT $value != NONE;
DEFINE FIELD partner ON vehicle_contract TYPE record<partner>; -- Contractant (fournisseur, assureur, etc.)
DEFINE FIELD company ON vehicle_contract TYPE record<company>;
DEFINE FIELD contract_type_select ON vehicle_contract TYPE int DEFAULT 1; -- 1:Insurance, 2:Lease, 3:Purchase, 4:Maintenance, 5:Fuel
DEFINE FIELD start_date ON vehicle_contract TYPE date ASSERT $value != NONE;
DEFINE FIELD end_date ON vehicle_contract TYPE date;
DEFINE FIELD contract_amount ON vehicle_contract TYPE decimal DEFAULT 0.0;
DEFINE FIELD currency ON vehicle_contract TYPE record<currency>;
DEFINE FIELD payment_frequency_select ON vehicle_contract TYPE int DEFAULT 1; -- 1:Monthly, 2:Quarterly, 3:Semi-annual, 4:Annual, 5:One-time
DEFINE FIELD payment_amount ON vehicle_contract TYPE decimal DEFAULT 0.0;
DEFINE FIELD next_payment_date ON vehicle_contract TYPE date;
DEFINE FIELD status_select ON vehicle_contract TYPE int DEFAULT 1; -- 1:Draft, 2:Active, 3:Expired, 4:Terminated
DEFINE FIELD auto_renewal ON vehicle_contract TYPE bool DEFAULT false;
DEFINE FIELD renewal_period ON vehicle_contract TYPE int DEFAULT 12; -- Mois
DEFINE FIELD notice_period ON vehicle_contract TYPE int DEFAULT 30; -- Jours
DEFINE FIELD terms_conditions ON vehicle_contract TYPE string;
DEFINE FIELD contract_file ON vehicle_contract TYPE record<meta_file>;
DEFINE FIELD is_recurring ON vehicle_contract TYPE bool DEFAULT false;
DEFINE FIELD recurring_cost ON vehicle_contract TYPE record<recurring_cost>;
DEFINE FIELD alert_days_before_expiry ON vehicle_contract TYPE int DEFAULT 30;
DEFINE FIELD is_expired_alert_sent ON vehicle_contract TYPE bool DEFAULT false;
DEFINE FIELD notes ON vehicle_contract TYPE string;
DEFINE FIELD created_at ON vehicle_contract TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON vehicle_contract TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON vehicle_contract TYPE int DEFAULT 0;

-- Index d'optimisation
DEFINE INDEX idx_vehicle_plate_no ON vehicle FIELDS plate_no;
DEFINE INDEX idx_vehicle_chassis_no ON vehicle FIELDS chassis_no;
DEFINE INDEX idx_vehicle_vin_no ON vehicle FIELDS vin_no;
DEFINE INDEX idx_vehicle_company ON vehicle FIELDS company;
DEFINE INDEX idx_vehicle_driver ON vehicle FIELDS driver_partner;
DEFINE INDEX idx_vehicle_model ON vehicle FIELDS vehicle_model;
DEFINE INDEX idx_vehicle_make ON vehicle FIELDS vehicle_make;
DEFINE INDEX idx_vehicle_status ON vehicle FIELDS status_select;
DEFINE INDEX idx_vehicle_fuel_type ON vehicle FIELDS fuel_type_select;
DEFINE INDEX idx_vehicle_is_rental ON vehicle FIELDS is_rental;
DEFINE INDEX idx_vehicle_registration_date ON vehicle FIELDS registration_date;
DEFINE INDEX idx_vehicle_acquisition_date ON vehicle FIELDS acquisition_date;

DEFINE INDEX idx_vehicle_model_name ON vehicle_model FIELDS name;
DEFINE INDEX idx_vehicle_model_code ON vehicle_model FIELDS code;
DEFINE INDEX idx_vehicle_model_make ON vehicle_model FIELDS vehicle_make;
DEFINE INDEX idx_vehicle_model_category ON vehicle_model FIELDS vehicle_category_select;
DEFINE INDEX idx_vehicle_model_fuel_type ON vehicle_model FIELDS fuel_type_select;
DEFINE INDEX idx_vehicle_model_active ON vehicle_model FIELDS is_active;

DEFINE INDEX idx_vehicle_make_name ON vehicle_make FIELDS name;
DEFINE INDEX idx_vehicle_make_code ON vehicle_make FIELDS code;
DEFINE INDEX idx_vehicle_make_country ON vehicle_make FIELDS country;
DEFINE INDEX idx_vehicle_make_active ON vehicle_make FIELDS is_active;

DEFINE INDEX idx_vehicle_contract_no ON vehicle_contract FIELDS contract_no;
DEFINE INDEX idx_vehicle_contract_vehicle ON vehicle_contract FIELDS vehicle;
DEFINE INDEX idx_vehicle_contract_partner ON vehicle_contract FIELDS partner;
DEFINE INDEX idx_vehicle_contract_type ON vehicle_contract FIELDS contract_type_select;
DEFINE INDEX idx_vehicle_contract_status ON vehicle_contract FIELDS status_select;
DEFINE INDEX idx_vehicle_contract_start_date ON vehicle_contract FIELDS start_date;
DEFINE INDEX idx_vehicle_contract_end_date ON vehicle_contract FIELDS end_date;
DEFINE INDEX idx_vehicle_contract_next_payment ON vehicle_contract FIELDS next_payment_date;
DEFINE INDEX idx_vehicle_contract_auto_renewal ON vehicle_contract FIELDS auto_renewal;
DEFINE INDEX idx_vehicle_contract_recurring ON vehicle_contract FIELDS is_recurring;
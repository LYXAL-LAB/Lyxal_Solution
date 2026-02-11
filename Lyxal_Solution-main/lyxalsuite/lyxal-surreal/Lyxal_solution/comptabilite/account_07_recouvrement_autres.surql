-- ================================================================================
-- LYXAL SURREAL - AXELOR ACCOUNT - MODULE 7 : RECOUVREMENT ET AUTRES
-- ================================================================================
-- Entités de recouvrement, créances irrécouvrables, notifications et autres entités
-- ================================================================================

-- ================================================================================
-- RECOUVREMENT DE CRÉANCES
-- ================================================================================

-- Recouvrement de créances
DEFINE TABLE debt_recovery SCHEMAFULL;
DEFINE FIELD debt_recovery_seq ON debt_recovery TYPE string;
DEFINE FIELD company ON debt_recovery TYPE record<company>;
DEFINE FIELD partner ON debt_recovery TYPE record<partner>;
DEFINE FIELD debt_recovery_method ON debt_recovery TYPE record<debt_recovery_method>;
DEFINE FIELD reference_date ON debt_recovery TYPE date;
DEFINE FIELD balance_due ON debt_recovery TYPE decimal;
DEFINE FIELD balance_due_recovery_currency ON debt_recovery TYPE decimal;
DEFINE FIELD currency ON debt_recovery TYPE record<currency>;
DEFINE FIELD debt_recovery_method_line ON debt_recovery TYPE record<debt_recovery_method_line>;
DEFINE FIELD waiting_for_next_level ON debt_recovery TYPE bool DEFAULT false;
DEFINE FIELD debt_recovery_history_list ON debt_recovery TYPE array<record<debt_recovery_history>>;
DEFINE FIELD invoice_debt_recovery_set ON debt_recovery TYPE array<record<invoice>>;
DEFINE FIELD payment_schedule_line_debt_recovery_set ON debt_recovery TYPE array<record<payment_schedule_line>>;
DEFINE FIELD move_line_set ON debt_recovery TYPE array<record<move_line>>;
DEFINE FIELD status_select ON debt_recovery TYPE int DEFAULT 1;
DEFINE FIELD created_at ON debt_recovery TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON debt_recovery TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON debt_recovery TYPE int DEFAULT 0;

-- Méthodes de recouvrement
DEFINE TABLE debt_recovery_method SCHEMAFULL;
DEFINE FIELD name ON debt_recovery_method TYPE string;
DEFINE FIELD code ON debt_recovery_method TYPE string;
DEFINE FIELD company ON debt_recovery_method TYPE record<company>;
DEFINE FIELD debt_recovery_method_line_list ON debt_recovery_method TYPE array<record<debt_recovery_method_line>>;
DEFINE FIELD created_at ON debt_recovery_method TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON debt_recovery_method TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON debt_recovery_method TYPE int DEFAULT 0;

-- Lignes de méthode de recouvrement
DEFINE TABLE debt_recovery_method_line SCHEMAFULL;
DEFINE FIELD debt_recovery_method ON debt_recovery_method_line TYPE record<debt_recovery_method>;
DEFINE FIELD sequence ON debt_recovery_method_line TYPE int;
DEFINE FIELD debt_recovery_level_select ON debt_recovery_method_line TYPE int;
DEFINE FIELD debt_recovery_type_select ON debt_recovery_method_line TYPE int;
DEFINE FIELD standard_delay ON debt_recovery_method_line TYPE int;
DEFINE FIELD message_template ON debt_recovery_method_line TYPE record<template>;
DEFINE FIELD mail_template ON debt_recovery_method_line TYPE record<template>;
DEFINE FIELD created_at ON debt_recovery_method_line TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON debt_recovery_method_line TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON debt_recovery_method_line TYPE int DEFAULT 0;

-- Historique de recouvrement
DEFINE TABLE debt_recovery_history SCHEMAFULL;
DEFINE FIELD debt_recovery ON debt_recovery_history TYPE record<debt_recovery>;
DEFINE FIELD debt_recovery_method_line ON debt_recovery_history TYPE record<debt_recovery_method_line>;
DEFINE FIELD debt_recovery_date ON debt_recovery_history TYPE date;
DEFINE FIELD balance_due ON debt_recovery_history TYPE decimal;
DEFINE FIELD balance_due_recovery_currency ON debt_recovery_history TYPE decimal;
DEFINE FIELD user_debt_recovery ON debt_recovery_history TYPE record<user>;
DEFINE FIELD reference_date ON debt_recovery_history TYPE date;
DEFINE FIELD created_at ON debt_recovery_history TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON debt_recovery_history TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON debt_recovery_history TYPE int DEFAULT 0;

-- Lignes de configuration de recouvrement
DEFINE TABLE debt_recovery_config_line SCHEMAFULL;
DEFINE FIELD company ON debt_recovery_config_line TYPE record<company>;
DEFINE FIELD partner_category ON debt_recovery_config_line TYPE record<partner_category>;
DEFINE FIELD debt_recovery_method ON debt_recovery_config_line TYPE record<debt_recovery_method>;
DEFINE FIELD created_at ON debt_recovery_config_line TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON debt_recovery_config_line TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON debt_recovery_config_line TYPE int DEFAULT 0;

-- ================================================================================
-- CRÉANCES IRRÉCOUVRABLES
-- ================================================================================

-- Créances irrécouvrables
DEFINE TABLE irrecoverable SCHEMAFULL;
DEFINE FIELD name ON irrecoverable TYPE string;
DEFINE FIELD company ON irrecoverable TYPE record<company>;
DEFINE FIELD move_line_set ON irrecoverable TYPE array<record<move_line>>;
DEFINE FIELD invoice_set ON irrecoverable TYPE array<record<invoice>>;
DEFINE FIELD payment_schedule_line_set ON irrecoverable TYPE array<record<payment_schedule_line>>;
DEFINE FIELD irrecoverable_report_line_list ON irrecoverable TYPE array<record<irrecoverable_report_line>>;
DEFINE FIELD management_object ON irrecoverable TYPE record<management_object>;
DEFINE FIELD pass_reason ON irrecoverable TYPE string;
DEFINE FIELD not_pass_reason ON irrecoverable TYPE string;
DEFINE FIELD created_at ON irrecoverable TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON irrecoverable TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON irrecoverable TYPE int DEFAULT 0;

-- Lignes de rapport d'irrécouvrable
DEFINE TABLE irrecoverable_report_line SCHEMAFULL;
DEFINE FIELD irrecoverable ON irrecoverable_report_line TYPE record<irrecoverable>;
DEFINE FIELD partner ON irrecoverable_report_line TYPE record<partner>;
DEFINE FIELD irrecoverable_customer_line_list ON irrecoverable_report_line TYPE array<record<irrecoverable_customer_line>>;
DEFINE FIELD created_at ON irrecoverable_report_line TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON irrecoverable_report_line TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON irrecoverable_report_line TYPE int DEFAULT 0;

-- Lignes client d'irrécouvrable
DEFINE TABLE irrecoverable_customer_line SCHEMAFULL;
DEFINE FIELD irrecoverable_report_line ON irrecoverable_customer_line TYPE record<irrecoverable_report_line>;
DEFINE FIELD irrecoverable_invoice_line_list ON irrecoverable_customer_line TYPE array<record<irrecoverable_invoice_line>>;
DEFINE FIELD irrecoverable_payment_schedule_line_line_list ON irrecoverable_customer_line TYPE array<record<irrecoverable_payment_schedule_line_line>>;
DEFINE FIELD created_at ON irrecoverable_customer_line TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON irrecoverable_customer_line TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON irrecoverable_customer_line TYPE int DEFAULT 0;

-- Lignes de facture d'irrécouvrable
DEFINE TABLE irrecoverable_invoice_line SCHEMAFULL;
DEFINE FIELD irrecoverable_customer_line ON irrecoverable_invoice_line TYPE record<irrecoverable_customer_line>;
DEFINE FIELD invoice ON irrecoverable_invoice_line TYPE record<invoice>;
DEFINE FIELD invoice_line_tax_amount ON irrecoverable_invoice_line TYPE decimal;
DEFINE FIELD irrecoverable_report_line_list ON irrecoverable_invoice_line TYPE array<record<irrecoverable_report_line>>;
DEFINE FIELD created_at ON irrecoverable_invoice_line TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON irrecoverable_invoice_line TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON irrecoverable_invoice_line TYPE int DEFAULT 0;

-- Lignes d'échéancier d'irrécouvrable
DEFINE TABLE irrecoverable_payment_schedule_line_line SCHEMAFULL;
DEFINE FIELD irrecoverable_customer_line ON irrecoverable_payment_schedule_line_line TYPE record<irrecoverable_customer_line>;
DEFINE FIELD payment_schedule_line ON irrecoverable_payment_schedule_line_line TYPE record<payment_schedule_line>;
DEFINE FIELD irrecoverable_tax_amount ON irrecoverable_payment_schedule_line_line TYPE decimal;
DEFINE FIELD created_at ON irrecoverable_payment_schedule_line_line TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON irrecoverable_payment_schedule_line_line TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON irrecoverable_payment_schedule_line_line TYPE int DEFAULT 0;

-- ================================================================================
-- NOTIFICATIONS
-- ================================================================================

-- Notifications
DEFINE TABLE notification SCHEMAFULL;
DEFINE FIELD message ON notification TYPE string;
DEFINE FIELD user ON notification TYPE record<user>;
DEFINE FIELD subject ON notification TYPE string;
DEFINE FIELD media_type_select ON notification TYPE int DEFAULT 0;
DEFINE FIELD popup_ok ON notification TYPE bool DEFAULT false;
DEFINE FIELD email_ok ON notification TYPE bool DEFAULT false;
DEFINE FIELD mobile_ok ON notification TYPE bool DEFAULT false;
DEFINE FIELD is_read ON notification TYPE bool DEFAULT false;
DEFINE FIELD notification_item_list ON notification TYPE array<record<notification_item>>;
DEFINE FIELD created_at ON notification TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON notification TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON notification TYPE int DEFAULT 0;

-- Éléments de notification
DEFINE TABLE notification_item SCHEMAFULL;
DEFINE FIELD notification ON notification_item TYPE record<notification>;
DEFINE FIELD meta_model ON notification_item TYPE string;
DEFINE FIELD meta_model_id ON notification_item TYPE string;
DEFINE FIELD created_at ON notification_item TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON notification_item TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON notification_item TYPE int DEFAULT 0;

-- ================================================================================
-- GESTION DES OBJETS
-- ================================================================================

-- Objets de gestion
DEFINE TABLE management_object SCHEMAFULL;
DEFINE FIELD name ON management_object TYPE string;
DEFINE FIELD code ON management_object TYPE string;
DEFINE FIELD type_select ON management_object TYPE int;
DEFINE FIELD created_at ON management_object TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON management_object TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON management_object TYPE int DEFAULT 0;

-- ================================================================================
-- SUBROGATION
-- ================================================================================

-- Délégation de subrogation
DEFINE TABLE subrogation_release SCHEMAFULL;
DEFINE FIELD sequence ON subrogation_release TYPE string;
DEFINE FIELD company ON subrogation_release TYPE record<company>;
DEFINE FIELD partner ON subrogation_release TYPE record<partner>;
DEFINE FIELD substitute_partner ON subrogation_release TYPE record<partner>;
DEFINE FIELD created_at ON subrogation_release TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON subrogation_release TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON subrogation_release TYPE int DEFAULT 0;

-- ================================================================================
-- VALIDATEURS PFP
-- ================================================================================

-- Validateur PFP de substitution
DEFINE TABLE substitute_pfp_validator SCHEMAFULL;
DEFINE FIELD substitute_user ON substitute_pfp_validator TYPE record<user>;
DEFINE FIELD pfp_validator_user ON substitute_pfp_validator TYPE record<user>;
DEFINE FIELD substitute_start_date ON substitute_pfp_validator TYPE date;
DEFINE FIELD substitute_end_date ON substitute_pfp_validator TYPE date;
DEFINE FIELD created_at ON substitute_pfp_validator TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON substitute_pfp_validator TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON substitute_pfp_validator TYPE int DEFAULT 0;

-- ================================================================================
-- RAISONS PARTIELLES PFP
-- ================================================================================

-- Raisons partielles PFP
DEFINE TABLE pfp_partial_reason SCHEMAFULL;
DEFINE FIELD name ON pfp_partial_reason TYPE string;
DEFINE FIELD code ON pfp_partial_reason TYPE string;
DEFINE FIELD created_at ON pfp_partial_reason TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON pfp_partial_reason TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON pfp_partial_reason TYPE int DEFAULT 0;

-- ================================================================================
-- RETARDS DE PAIEMENT
-- ================================================================================

-- Raisons de retard de paiement
DEFINE TABLE payment_delay_reason SCHEMAFULL;
DEFINE FIELD name ON payment_delay_reason TYPE string;
DEFINE FIELD code ON payment_delay_reason TYPE string;
DEFINE FIELD created_at ON payment_delay_reason TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON payment_delay_reason TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON payment_delay_reason TYPE int DEFAULT 0;

-- ================================================================================
-- LIGNE DE CONFIGURATION QUALITÉ PAYEUR
-- ================================================================================

-- Ligne de configuration qualité payeur
DEFINE TABLE payer_quality_config_line SCHEMAFULL;
DEFINE FIELD company ON payer_quality_config_line TYPE record<company>;
DEFINE FIELD partner_category ON payer_quality_config_line TYPE record<partner_category>;
DEFINE FIELD include_other_partner_type ON payer_quality_config_line TYPE bool DEFAULT false;
DEFINE FIELD created_at ON payer_quality_config_line TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON payer_quality_config_line TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON payer_quality_config_line TYPE int DEFAULT 0;

-- ================================================================================
-- TYPES DE SERVICE
-- ================================================================================

-- Types de service
DEFINE TABLE service_type SCHEMAFULL;
DEFINE FIELD name ON service_type TYPE string;
DEFINE FIELD code ON service_type TYPE string;
DEFINE FIELD created_at ON service_type TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON service_type TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON service_type TYPE int DEFAULT 0;

-- ================================================================================
-- ACTIVITÉS DAS2
-- ================================================================================

-- Activités DAS2
DEFINE TABLE das2_activity SCHEMAFULL;
DEFINE FIELD name ON das2_activity TYPE string;
DEFINE FIELD code ON das2_activity TYPE string;
DEFINE FIELD created_at ON das2_activity TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON das2_activity TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON das2_activity TYPE int DEFAULT 0;

-- ================================================================================
-- LIGNES D'HISTORIQUE DES TAUX D'INTÉRÊT
-- ================================================================================

-- Lignes d'historique des taux d'intérêt
DEFINE TABLE interest_rate_history_line SCHEMAFULL;
DEFINE FIELD start_date ON interest_rate_history_line TYPE date;
DEFINE FIELD end_date ON interest_rate_history_line TYPE date;
DEFINE FIELD rate ON interest_rate_history_line TYPE decimal;
DEFINE FIELD created_at ON interest_rate_history_line TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON interest_rate_history_line TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON interest_rate_history_line TYPE int DEFAULT 0;

-- ================================================================================
-- LIGNE DE PAIEMENT DE TAXE
-- ================================================================================

-- Ligne de paiement de taxe
DEFINE TABLE tax_payment_move_line SCHEMAFULL;
DEFINE FIELD move_line ON tax_payment_move_line TYPE record<move_line>;
DEFINE FIELD tax_line ON tax_payment_move_line TYPE record<tax_line>;
DEFINE FIELD detail_payment_date ON tax_payment_move_line TYPE date;
DEFINE FIELD amount_paid ON tax_payment_move_line TYPE decimal;
DEFINE FIELD type_select ON tax_payment_move_line TYPE int;
DEFINE FIELD reconcile_group ON tax_payment_move_line TYPE record<reconcile_group>;
DEFINE FIELD created_at ON tax_payment_move_line TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON tax_payment_move_line TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON tax_payment_move_line TYPE int DEFAULT 0;

-- ================================================================================
-- REQUÊTES DE LIGNES D'ÉCRITURE
-- ================================================================================

-- Requêtes de lignes d'écriture
DEFINE TABLE move_line_query SCHEMAFULL;
DEFINE FIELD company ON move_line_query TYPE record<company>;
DEFINE FIELD date_from ON move_line_query TYPE date;
DEFINE FIELD date_to ON move_line_query TYPE date;
DEFINE FIELD journal_set ON move_line_query TYPE array<record<journal>>;
DEFINE FIELD account_set ON move_line_query TYPE array<record<account>>;
DEFINE FIELD partner_set ON move_line_query TYPE array<record<partner>>;
DEFINE FIELD move_line_query_line_list ON move_line_query TYPE array<record<move_line_query_line>>;
DEFINE FIELD created_at ON move_line_query TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON move_line_query TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON move_line_query TYPE int DEFAULT 0;

-- Lignes de requête de lignes d'écriture
DEFINE TABLE move_line_query_line SCHEMAFULL;
DEFINE FIELD move_line_query ON move_line_query_line TYPE record<move_line_query>;
DEFINE FIELD move_line ON move_line_query_line TYPE record<move_line>;
DEFINE FIELD created_at ON move_line_query_line TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON move_line_query_line TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON move_line_query_line TYPE int DEFAULT 0;

-- ================================================================================
-- REMISES FINANCIÈRES
-- ================================================================================

-- Remises financières
DEFINE TABLE financial_discount SCHEMAFULL;
DEFINE FIELD name ON financial_discount TYPE string;
DEFINE FIELD discount_rate ON financial_discount TYPE decimal;
DEFINE FIELD delay_to_pay ON financial_discount TYPE int;
DEFINE FIELD discount_base_select ON financial_discount TYPE int;
DEFINE FIELD company ON financial_discount TYPE record<company>;
DEFINE FIELD created_at ON financial_discount TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON financial_discount TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON financial_discount TYPE int DEFAULT 0;

-- ================================================================================
-- INDEX POUR OPTIMISATION
-- ================================================================================

-- Index pour DebtRecovery
DEFINE INDEX idx_debt_recovery_seq ON debt_recovery FIELDS debt_recovery_seq;
DEFINE INDEX idx_debt_recovery_company ON debt_recovery FIELDS company;
DEFINE INDEX idx_debt_recovery_partner ON debt_recovery FIELDS partner;
DEFINE INDEX idx_debt_recovery_status ON debt_recovery FIELDS status_select;

-- Index pour Irrecoverable
DEFINE INDEX idx_irrecoverable_company ON irrecoverable FIELDS company;
DEFINE INDEX idx_irrecoverable_name ON irrecoverable FIELDS name;

-- Index pour Notification
DEFINE INDEX idx_notification_user ON notification FIELDS user;
DEFINE INDEX idx_notification_is_read ON notification FIELDS is_read;

-- Index pour ManagementObject
DEFINE INDEX idx_management_object_type ON management_object FIELDS type_select;
DEFINE INDEX idx_management_object_code ON management_object FIELDS code;

-- Index pour TaxPaymentMoveLine
DEFINE INDEX idx_tax_payment_move_line_move_line ON tax_payment_move_line FIELDS move_line;
DEFINE INDEX idx_tax_payment_move_line_tax_line ON tax_payment_move_line FIELDS tax_line;
DEFINE INDEX idx_tax_payment_move_line_date ON tax_payment_move_line FIELDS detail_payment_date;

-- ================================================================================
-- FIN DU MODULE 7 - RECOUVREMENT ET AUTRES
-- ================================================================================ 
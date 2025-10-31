-- ======================================================================
-- MIGRATION MODULE AXELOR-PURCHASE VERS SURREALDB - PARTIE 1/2
-- ======================================================================
-- Module : axelor-purchase - Entités principales
-- Description : Gestion des commandes d'achat et demandes d'achat
-- Date : 2024
-- Entités : 8 entités principales sur 16 totales
-- ======================================================================

-- Nettoyage des tables existantes
REMOVE TABLE IF EXISTS app_purchase;
REMOVE TABLE IF EXISTS purchase_config;
REMOVE TABLE IF EXISTS purchase_order;
REMOVE TABLE IF EXISTS purchase_order_line;
REMOVE TABLE IF EXISTS purchase_order_line_tax;
REMOVE TABLE IF EXISTS purchase_request;
REMOVE TABLE IF EXISTS purchase_request_line;
REMOVE TABLE IF EXISTS supplier_catalog;

-- ======================================================================
-- 1. TABLE : APP_PURCHASE
-- ======================================================================
DEFINE TABLE app_purchase SCHEMAFULL
    COMMENT "Configuration principale de l'application achat";

-- Champs principaux
DEFINE FIELD id ON app_purchase TYPE record<app_purchase>;
DEFINE FIELD app_id ON app_purchase TYPE option<record<app>>;
DEFINE FIELD created_on ON app_purchase TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON app_purchase TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON app_purchase TYPE int DEFAULT 0;

-- Configuration des fonctionnalités
DEFINE FIELD manage_purchase_order_version ON app_purchase TYPE bool DEFAULT false;
DEFINE FIELD manage_purchases_units ON app_purchase TYPE bool DEFAULT false;
DEFINE FIELD manage_multiple_purchase_quantity ON app_purchase TYPE bool DEFAULT false;
DEFINE FIELD is_enabled_product_description_copy ON app_purchase TYPE bool DEFAULT false;
DEFINE FIELD manage_supplier_catalog ON app_purchase TYPE bool DEFAULT false;
DEFINE FIELD is_display_purchase_order_line_number ON app_purchase TYPE bool DEFAULT false;
DEFINE FIELD enable_purchases_product_by_trad_name ON app_purchase TYPE bool DEFAULT false;

-- Configuration par défaut
DEFINE FIELD purchase_unit_id ON app_purchase TYPE option<record<unit>>;

-- Index
DEFINE INDEX idx_app_purchase_app ON app_purchase COLUMNS app_id UNIQUE;

-- ======================================================================
-- 2. TABLE : PURCHASE_CONFIG
-- ======================================================================
DEFINE TABLE purchase_config SCHEMAFULL
    COMMENT "Configuration des achats par entreprise";

-- Champs principaux
DEFINE FIELD id ON purchase_config TYPE record<purchase_config>;
DEFINE FIELD company_id ON purchase_config TYPE option<record<company>>;
DEFINE FIELD created_on ON purchase_config TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON purchase_config TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON purchase_config TYPE int DEFAULT 0;

-- Configuration des commandes d'achat
DEFINE FIELD purchase_order_in_ati_select ON purchase_config TYPE int DEFAULT 1;
DEFINE FIELD purchase_order_supplier_box ON purchase_config TYPE string;
DEFINE FIELD display_price_on_quotation_request ON purchase_config TYPE bool DEFAULT false;
DEFINE FIELD display_buyer_on_printing ON purchase_config TYPE bool DEFAULT false;
DEFINE FIELD display_product_code_on_printing ON purchase_config TYPE bool DEFAULT false;
DEFINE FIELD display_tax_detail_on_printing ON purchase_config TYPE bool DEFAULT false;
DEFINE FIELD display_supplier_code_on_printing ON purchase_config TYPE bool DEFAULT false;
DEFINE FIELD display_product_detail_on_printing ON purchase_config TYPE bool DEFAULT false;

-- Messages et templates
DEFINE FIELD price_request ON purchase_config TYPE string;
DEFINE FIELD purchase_order_print_template_id ON purchase_config TYPE option<record<printing_template>>;

-- Configuration analytique
DEFINE FIELD is_analytic_distribution_required ON purchase_config TYPE bool DEFAULT false;

-- Index
DEFINE INDEX idx_purchase_config_company ON purchase_config COLUMNS company_id UNIQUE;

-- ======================================================================
-- 3. TABLE : PURCHASE_ORDER
-- ======================================================================
DEFINE TABLE purchase_order SCHEMAFULL
    COMMENT "Commande d'achat - entité centrale";

-- Champs principaux
DEFINE FIELD id ON purchase_order TYPE record<purchase_order>;
DEFINE FIELD created_on ON purchase_order TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON purchase_order TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON purchase_order TYPE int DEFAULT 0;

-- Identification
DEFINE FIELD purchase_order_seq ON purchase_order TYPE string;
DEFINE FIELD full_name ON purchase_order TYPE string;
DEFINE FIELD external_reference ON purchase_order TYPE string;
DEFINE FIELD internal_reference ON purchase_order TYPE string;

-- Relations principales
DEFINE FIELD company_id ON purchase_order TYPE option<record<company>>;
DEFINE FIELD supplier_partner_id ON purchase_order TYPE option<record<partner>>;
DEFINE FIELD contact_partner_id ON purchase_order TYPE option<record<partner>>;
DEFINE FIELD buyer_user_id ON purchase_order TYPE option<record<user>>;
DEFINE FIELD team_id ON purchase_order TYPE option<record<team>>;

-- Dates
DEFINE FIELD order_date ON purchase_order TYPE date;
DEFINE FIELD estimated_receipt_date ON purchase_order TYPE date;

-- Devise et tarification
DEFINE FIELD currency_id ON purchase_order TYPE option<record<currency>>;
DEFINE FIELD price_list_id ON purchase_order TYPE option<record<price_list>>;
DEFINE FIELD in_ati ON purchase_order TYPE bool DEFAULT false;

-- Statuts
DEFINE FIELD status_select ON purchase_order TYPE int DEFAULT 1;
DEFINE FIELD receipt_state ON purchase_order TYPE int DEFAULT 1;

-- Totaux
DEFINE FIELD ex_tax_total ON purchase_order TYPE decimal DEFAULT 0;
DEFINE FIELD tax_total ON purchase_order TYPE decimal DEFAULT 0;
DEFINE FIELD in_tax_total ON purchase_order TYPE decimal DEFAULT 0;
DEFINE FIELD company_ex_tax_total ON purchase_order TYPE decimal DEFAULT 0;
DEFINE FIELD advance_total ON purchase_order TYPE decimal DEFAULT 0;
DEFINE FIELD amount_to_be_spread_over_timetable ON purchase_order TYPE decimal DEFAULT 0;

-- Validation
DEFINE FIELD validated_by_user_id ON purchase_order TYPE option<record<user>>;
DEFINE FIELD validation_date_time ON purchase_order TYPE datetime;

-- Configuration fiscale
DEFINE FIELD tax_number_id ON purchase_order TYPE option<record<tax_number>>;
DEFINE FIELD fiscal_position_id ON purchase_order TYPE option<record<fiscal_position>>;

-- Informations bancaires
DEFINE FIELD company_bank_details_id ON purchase_order TYPE option<record<bank_details>>;

-- Notes et description
DEFINE FIELD notes ON purchase_order TYPE string;
DEFINE FIELD internal_note ON purchase_order TYPE string;
DEFINE FIELD specific_notes ON purchase_order TYPE string;
DEFINE FIELD price_request ON purchase_order TYPE string;

-- Configuration d'affichage
DEFINE FIELD display_price_on_quotation_request ON purchase_order TYPE bool DEFAULT false;
DEFINE FIELD group_products_on_printings ON purchase_order TYPE bool DEFAULT false;

-- Versioning
DEFINE FIELD version_number ON purchase_order TYPE int DEFAULT 1;

-- Relations techniques
DEFINE FIELD trading_name_id ON purchase_order TYPE option<record<trading_name>>;
DEFINE FIELD printing_settings_id ON purchase_order TYPE option<record<printing_settings>>;
DEFINE FIELD company_currency_id ON purchase_order TYPE option<record<currency>>;

-- Type de commande
DEFINE FIELD type_select ON purchase_order TYPE int DEFAULT 1;

-- Relations One-to-Many
DEFINE FIELD purchase_order_line_list ON purchase_order TYPE array<record<purchase_order_line>>;
DEFINE FIELD purchase_order_line_tax_list ON purchase_order TYPE array<record<purchase_order_line_tax>>;

-- Index
DEFINE INDEX idx_purchase_order_company ON purchase_order COLUMNS company_id;
DEFINE INDEX idx_purchase_order_supplier ON purchase_order COLUMNS supplier_partner_id;
DEFINE INDEX idx_purchase_order_buyer ON purchase_order COLUMNS buyer_user_id;
DEFINE INDEX idx_purchase_order_seq ON purchase_order COLUMNS purchase_order_seq;
DEFINE INDEX idx_purchase_order_status ON purchase_order COLUMNS status_select;
DEFINE INDEX idx_purchase_order_receipt_state ON purchase_order COLUMNS receipt_state;
DEFINE INDEX idx_purchase_order_dates ON purchase_order COLUMNS order_date, estimated_receipt_date;
DEFINE INDEX idx_purchase_order_seq_company ON purchase_order COLUMNS purchase_order_seq, company_id UNIQUE;

-- ======================================================================
-- 4. TABLE : PURCHASE_ORDER_LINE
-- ======================================================================
DEFINE TABLE purchase_order_line SCHEMAFULL
    COMMENT "Ligne de commande d'achat";

-- Champs principaux
DEFINE FIELD id ON purchase_order_line TYPE record<purchase_order_line>;
DEFINE FIELD created_on ON purchase_order_line TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON purchase_order_line TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON purchase_order_line TYPE int DEFAULT 0;

-- Relation principale
DEFINE FIELD purchase_order_id ON purchase_order_line TYPE option<record<purchase_order>>;
DEFINE FIELD sequence ON purchase_order_line TYPE int DEFAULT 0;

-- Produit
DEFINE FIELD product_id ON purchase_order_line TYPE option<record<product>>;
DEFINE FIELD product_name ON purchase_order_line TYPE string;
DEFINE FIELD product_code ON purchase_order_line TYPE string;
DEFINE FIELD description ON purchase_order_line TYPE string;

-- Quantités et unités
DEFINE FIELD qty ON purchase_order_line TYPE decimal DEFAULT 1;
DEFINE FIELD received_qty ON purchase_order_line TYPE decimal DEFAULT 0;
DEFINE FIELD unit_id ON purchase_order_line TYPE option<record<unit>>;

-- Prix
DEFINE FIELD price ON purchase_order_line TYPE decimal DEFAULT 0;
DEFINE FIELD in_tax_price ON purchase_order_line TYPE decimal DEFAULT 0;
DEFINE FIELD price_discounted ON purchase_order_line TYPE decimal DEFAULT 0;
DEFINE FIELD max_purchase_price ON purchase_order_line TYPE decimal DEFAULT 0;

-- Remises
DEFINE FIELD discount_amount ON purchase_order_line TYPE decimal DEFAULT 0;
DEFINE FIELD discount_type_select ON purchase_order_line TYPE int DEFAULT 0;

-- Totaux
DEFINE FIELD ex_tax_total ON purchase_order_line TYPE decimal DEFAULT 0;
DEFINE FIELD in_tax_total ON purchase_order_line TYPE decimal DEFAULT 0;
DEFINE FIELD company_ex_tax_total ON purchase_order_line TYPE decimal DEFAULT 0;
DEFINE FIELD company_in_tax_total ON purchase_order_line TYPE decimal DEFAULT 0;

-- Dates
DEFINE FIELD desired_receipt_date ON purchase_order_line TYPE date;
DEFINE FIELD estimated_receipt_date ON purchase_order_line TYPE date;

-- Statuts et flags
DEFINE FIELD is_ordered ON purchase_order_line TYPE bool DEFAULT false;
DEFINE FIELD is_title_line ON purchase_order_line TYPE bool DEFAULT false;
DEFINE FIELD fixed_assets ON purchase_order_line TYPE bool DEFAULT false;
DEFINE FIELD enable_freeze_fields ON purchase_order_line TYPE bool DEFAULT false;

-- Commentaires
DEFINE FIELD supplier_comment ON purchase_order_line TYPE string;

-- Relations fiscales
DEFINE FIELD tax_line_set ON purchase_order_line TYPE array<record<tax_line>>;
DEFINE FIELD tax_equiv_id ON purchase_order_line TYPE option<record<tax_equiv>>;

-- Relations techniques
DEFINE FIELD currency_id ON purchase_order_line TYPE option<record<currency>>;
DEFINE FIELD company_currency_id ON purchase_order_line TYPE option<record<currency>>;
DEFINE FIELD full_name ON purchase_order_line TYPE string;

-- Index
DEFINE INDEX idx_purchase_order_line_order ON purchase_order_line COLUMNS purchase_order_id;
DEFINE INDEX idx_purchase_order_line_product ON purchase_order_line COLUMNS product_id;
DEFINE INDEX idx_purchase_order_line_sequence ON purchase_order_line COLUMNS sequence;
DEFINE INDEX idx_purchase_order_line_dates ON purchase_order_line COLUMNS desired_receipt_date, estimated_receipt_date;

-- ======================================================================
-- 5. TABLE : PURCHASE_ORDER_LINE_TAX
-- ======================================================================
DEFINE TABLE purchase_order_line_tax SCHEMAFULL
    COMMENT "Ligne de taxe sur commande d'achat";

-- Champs principaux
DEFINE FIELD id ON purchase_order_line_tax TYPE record<purchase_order_line_tax>;
DEFINE FIELD created_on ON purchase_order_line_tax TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON purchase_order_line_tax TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON purchase_order_line_tax TYPE int DEFAULT 0;

-- Relations
DEFINE FIELD purchase_order_id ON purchase_order_line_tax TYPE option<record<purchase_order>>;
DEFINE FIELD tax_line_id ON purchase_order_line_tax TYPE option<record<tax_line>>;
DEFINE FIELD tax_type_id ON purchase_order_line_tax TYPE option<record<tax_type>>;

-- Montants
DEFINE FIELD ex_tax_base ON purchase_order_line_tax TYPE decimal DEFAULT 0;
DEFINE FIELD tax_total ON purchase_order_line_tax TYPE decimal DEFAULT 0;
DEFINE FIELD percentage_tax_total ON purchase_order_line_tax TYPE decimal DEFAULT 0;
DEFINE FIELD in_tax_total ON purchase_order_line_tax TYPE decimal DEFAULT 0;

-- Configuration
DEFINE FIELD reverse_charged ON purchase_order_line_tax TYPE bool DEFAULT false;

-- Index
DEFINE INDEX idx_purchase_order_line_tax_order ON purchase_order_line_tax COLUMNS purchase_order_id;
DEFINE INDEX idx_purchase_order_line_tax_line ON purchase_order_line_tax COLUMNS tax_line_id;
DEFINE INDEX idx_purchase_order_line_tax_type ON purchase_order_line_tax COLUMNS tax_type_id;

-- ======================================================================
-- 6. TABLE : PURCHASE_REQUEST
-- ======================================================================
DEFINE TABLE purchase_request SCHEMAFULL
    COMMENT "Demande d'achat";

-- Champs principaux
DEFINE FIELD id ON purchase_request TYPE record<purchase_request>;
DEFINE FIELD created_on ON purchase_request TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON purchase_request TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON purchase_request TYPE int DEFAULT 0;

-- Identification
DEFINE FIELD purchase_request_seq ON purchase_request TYPE string;
DEFINE FIELD description ON purchase_request TYPE string;

-- Relations
DEFINE FIELD company_id ON purchase_request TYPE option<record<company>>;
DEFINE FIELD supplier_partner_id ON purchase_request TYPE option<record<partner>>;
DEFINE FIELD purchase_order_id ON purchase_request TYPE option<record<purchase_order>>;

-- Utilisateurs
DEFINE FIELD requester_user_id ON purchase_request TYPE option<record<user>>;
DEFINE FIELD validator_user_id ON purchase_request TYPE option<record<user>>;

-- Statut
DEFINE FIELD status_select ON purchase_request TYPE int DEFAULT 1;

-- Relations One-to-Many
DEFINE FIELD purchase_request_line_list ON purchase_request TYPE array<record<purchase_request_line>>;

-- Index
DEFINE INDEX idx_purchase_request_company ON purchase_request COLUMNS company_id;
DEFINE INDEX idx_purchase_request_supplier ON purchase_request COLUMNS supplier_partner_id;
DEFINE INDEX idx_purchase_request_requester ON purchase_request COLUMNS requester_user_id;
DEFINE INDEX idx_purchase_request_validator ON purchase_request COLUMNS validator_user_id;
DEFINE INDEX idx_purchase_request_status ON purchase_request COLUMNS status_select;
DEFINE INDEX idx_purchase_request_seq ON purchase_request COLUMNS purchase_request_seq UNIQUE;

-- ======================================================================
-- 7. TABLE : PURCHASE_REQUEST_LINE
-- ======================================================================
DEFINE TABLE purchase_request_line SCHEMAFULL
    COMMENT "Ligne de demande d'achat";

-- Champs principaux
DEFINE FIELD id ON purchase_request_line TYPE record<purchase_request_line>;
DEFINE FIELD created_on ON purchase_request_line TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON purchase_request_line TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON purchase_request_line TYPE int DEFAULT 0;

-- Relation principale
DEFINE FIELD purchase_request_id ON purchase_request_line TYPE option<record<purchase_request>>;

-- Produit
DEFINE FIELD product_id ON purchase_request_line TYPE option<record<product>>;
DEFINE FIELD product_title ON purchase_request_line TYPE string;
DEFINE FIELD new_product ON purchase_request_line TYPE bool DEFAULT false;

-- Quantité et unité
DEFINE FIELD quantity ON purchase_request_line TYPE decimal DEFAULT 1;
DEFINE FIELD unit_id ON purchase_request_line TYPE option<record<unit>>;

-- Index
DEFINE INDEX idx_purchase_request_line_request ON purchase_request_line COLUMNS purchase_request_id;
DEFINE INDEX idx_purchase_request_line_product ON purchase_request_line COLUMNS product_id;

-- ======================================================================
-- 8. TABLE : SUPPLIER_CATALOG
-- ======================================================================
DEFINE TABLE supplier_catalog SCHEMAFULL
    COMMENT "Catalogue fournisseur";

-- Champs principaux
DEFINE FIELD id ON supplier_catalog TYPE record<supplier_catalog>;
DEFINE FIELD created_on ON supplier_catalog TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON supplier_catalog TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON supplier_catalog TYPE int DEFAULT 0;

-- Relations principales
DEFINE FIELD product_id ON supplier_catalog TYPE option<record<product>>;
DEFINE FIELD supplier_partner_id ON supplier_catalog TYPE option<record<partner>>;

-- Informations produit
DEFINE FIELD product_supplier_name ON supplier_catalog TYPE string;
DEFINE FIELD product_supplier_code ON supplier_catalog TYPE string;
DEFINE FIELD description ON supplier_catalog TYPE string;

-- Prix et unité
DEFINE FIELD price ON supplier_catalog TYPE decimal DEFAULT 0;
DEFINE FIELD calculated_price ON supplier_catalog TYPE decimal DEFAULT 0;
DEFINE FIELD unit_id ON supplier_catalog TYPE option<record<unit>>;

-- Quantités
DEFINE FIELD min_qty ON supplier_catalog TYPE decimal DEFAULT 0;
DEFINE FIELD max_qty ON supplier_catalog TYPE decimal DEFAULT 0;

-- Configuration
DEFINE FIELD is_take_product_multiple_qty ON supplier_catalog TYPE bool DEFAULT false;
DEFINE FIELD is_taking_product_purchase_price ON supplier_catalog TYPE bool DEFAULT false;

-- Dates
DEFINE FIELD update_date ON supplier_catalog TYPE date;

-- Relations One-to-Many
DEFINE FIELD shipping_coef_list ON supplier_catalog TYPE array<record<shipping_coef>>;
DEFINE FIELD product_multiple_qty_list ON supplier_catalog TYPE array<record<product_multiple_qty>>;

-- Index
DEFINE INDEX idx_supplier_catalog_product ON supplier_catalog COLUMNS product_id;
DEFINE INDEX idx_supplier_catalog_supplier ON supplier_catalog COLUMNS supplier_partner_id;
DEFINE INDEX idx_supplier_catalog_code ON supplier_catalog COLUMNS product_supplier_code;
DEFINE INDEX idx_supplier_catalog_update ON supplier_catalog COLUMNS update_date;

-- ======================================================================
-- FONCTIONS UTILITAIRES
-- ======================================================================

-- Fonction pour calculer le total HT d'une commande
DEFINE FUNCTION fn::calculate_purchase_order_total($purchase_order_id: record<purchase_order>) {
    RETURN SELECT SUM(ex_tax_total) as total_ex_tax
           FROM purchase_order_line 
           WHERE purchase_order_id = $purchase_order_id;
};

-- Fonction pour obtenir les commandes en retard
DEFINE FUNCTION fn::get_overdue_purchase_orders($company_id: option<record<company>>) {
    RETURN SELECT * FROM purchase_order 
           WHERE estimated_receipt_date < time::date() 
           AND status_select = 3 
           AND receipt_state != 3
           AND ($company_id IS NONE OR company_id = $company_id);
};

-- Fonction pour obtenir les commandes par statut
DEFINE FUNCTION fn::get_purchase_orders_by_status($status: int, $company_id: option<record<company>>) {
    RETURN SELECT * FROM purchase_order 
           WHERE status_select = $status
           AND ($company_id IS NONE OR company_id = $company_id);
};

-- Fonction pour obtenir les demandes d'achat en attente
DEFINE FUNCTION fn::get_pending_purchase_requests($company_id: option<record<company>>) {
    RETURN SELECT * FROM purchase_request 
           WHERE status_select IN [1, 2] 
           AND ($company_id IS NONE OR company_id = $company_id);
};

-- Fonction pour obtenir le catalogue fournisseur d'un produit
DEFINE FUNCTION fn::get_supplier_catalog_by_product($product_id: record<product>, $supplier_id: option<record<partner>>) {
    RETURN SELECT * FROM supplier_catalog 
           WHERE product_id = $product_id 
           AND ($supplier_id IS NONE OR supplier_partner_id = $supplier_id)
           ORDER BY price ASC;
};

-- Fonction pour calculer le prix unitaire avec remise
DEFINE FUNCTION fn::calculate_discounted_price($price: decimal, $discount_amount: decimal, $discount_type: int) {
    RETURN CASE 
        WHEN $discount_type = 1 THEN $price - $discount_amount
        WHEN $discount_type = 2 THEN $price * (1 - $discount_amount / 100)
        ELSE $price
    END;
};

-- ======================================================================
-- ÉVÉNEMENTS ET TRIGGERS
-- ======================================================================

-- Trigger pour mettre à jour les dates de modification
DEFINE EVENT purchase_order_updated ON TABLE purchase_order WHEN $event = "UPDATE" THEN {
    UPDATE purchase_order SET updated_on = time::now() WHERE id = $after.id;
};

DEFINE EVENT purchase_order_line_updated ON TABLE purchase_order_line WHEN $event = "UPDATE" THEN {
    UPDATE purchase_order_line SET updated_on = time::now() WHERE id = $after.id;
};

DEFINE EVENT purchase_request_updated ON TABLE purchase_request WHEN $event = "UPDATE" THEN {
    UPDATE purchase_request SET updated_on = time::now() WHERE id = $after.id;
};

-- Trigger pour calculer le nom complet de la commande
DEFINE EVENT purchase_order_full_name ON TABLE purchase_order WHEN $event = "CREATE" OR $event = "UPDATE" THEN {
    IF $after.purchase_order_seq IS NOT NONE THEN {
        LET $supplier_name = (SELECT name FROM partner WHERE id = $after.supplier_partner_id);
        UPDATE purchase_order SET full_name = string::concat($after.purchase_order_seq, "-", $supplier_name) WHERE id = $after.id;
    };
};

-- Trigger pour calculer le nom complet de la ligne
DEFINE EVENT purchase_order_line_full_name ON TABLE purchase_order_line WHEN $event = "CREATE" OR $event = "UPDATE" THEN {
    LET $order_seq = (SELECT purchase_order_seq FROM purchase_order WHERE id = $after.purchase_order_id);
    LET $product_name = IF string::length($after.product_name) > 100 THEN
        string::substr($after.product_name, 0, 100)
    ELSE
        $after.product_name
    END;
    UPDATE purchase_order_line SET full_name = string::concat($order_seq, "-", $product_name) WHERE id = $after.id;
};

-- Trigger pour calculer les prix avec remise
DEFINE EVENT purchase_order_line_price_calculation ON TABLE purchase_order_line WHEN $event = "CREATE" OR $event = "UPDATE" THEN {
    LET $discounted_price = fn::calculate_discounted_price($after.price, $after.discount_amount, $after.discount_type_select);
    UPDATE purchase_order_line SET 
        price_discounted = $discounted_price,
        ex_tax_total = $discounted_price * $after.qty 
    WHERE id = $after.id;
};

-- ======================================================================
-- DONNÉES DE RÉFÉRENCE
-- ======================================================================

-- Statuts de commande d'achat
LET $PURCHASE_ORDER_STATUS_DRAFT = 1;
LET $PURCHASE_ORDER_STATUS_REQUESTED = 2;
LET $PURCHASE_ORDER_STATUS_VALIDATED = 3;
LET $PURCHASE_ORDER_STATUS_FINISHED = 4;
LET $PURCHASE_ORDER_STATUS_CANCELED = 5;

-- États de réception
LET $PURCHASE_ORDER_RECEIPT_NOT_RECEIVED = 1;
LET $PURCHASE_ORDER_RECEIPT_PARTIALLY_RECEIVED = 2;
LET $PURCHASE_ORDER_RECEIPT_RECEIVED = 3;

-- Statuts de demande d'achat
LET $PURCHASE_REQUEST_STATUS_DRAFT = 1;
LET $PURCHASE_REQUEST_STATUS_REQUESTED = 2;
LET $PURCHASE_REQUEST_STATUS_ACCEPTED = 3;
LET $PURCHASE_REQUEST_STATUS_PURCHASED = 4;
LET $PURCHASE_REQUEST_STATUS_REFUSED = 5;
LET $PURCHASE_REQUEST_STATUS_CANCELED = 6;

-- Types de remise
LET $DISCOUNT_TYPE_NONE = 0;
LET $DISCOUNT_TYPE_FIXED = 1;
LET $DISCOUNT_TYPE_PERCENTAGE = 2;

-- Types de commande
LET $PURCHASE_ORDER_TYPE_STANDARD = 1;

-- Configuration ATI/HT
LET $PURCHASE_ORDER_IN_ATI_WT = 1;
LET $PURCHASE_ORDER_IN_ATI_ATI = 2;

-- ======================================================================
-- COMMENTAIRES ET DOCUMENTATION
-- ======================================================================

/*
MIGRATION AXELOR-PURCHASE VERS SURREALDB - PARTIE 1/2: ENTITÉS PRINCIPALES

ENTITÉS MIGRÉES (8/16):
1. AppPurchase - Configuration application
2. PurchaseConfig - Configuration des achats
3. PurchaseOrder - Commande d'achat (entité centrale)
4. PurchaseOrderLine - Ligne de commande d'achat
5. PurchaseOrderLineTax - Ligne de taxe
6. PurchaseRequest - Demande d'achat
7. PurchaseRequestLine - Ligne de demande d'achat
8. SupplierCatalog - Catalogue fournisseur

FONCTIONNALITÉS CLÉS:
- Gestion complète des commandes d'achat
- Workflow de demandes d'achat
- Gestion des fournisseurs et catalogues
- Calcul automatique des prix et taxes
- Gestion des réceptions et livraisons
- Configuration par entreprise

RELATIONS PRINCIPALES:
- PurchaseOrder 1:N PurchaseOrderLine
- PurchaseOrder 1:N PurchaseOrderLineTax
- PurchaseRequest 1:N PurchaseRequestLine
- SupplierCatalog N:1 Product
- SupplierCatalog N:1 Partner
- PurchaseOrder N:1 Partner (fournisseur)
- PurchaseConfig 1:1 Company

FONCTIONS UTILITAIRES:
- Calcul des totaux de commande
- Recherche des commandes en retard
- Filtrage par statut
- Gestion des catalogues fournisseurs
- Calcul des prix avec remises

PERFORMANCE:
- Index sur les relations critiques
- Index sur les statuts et dates
- Index uniques sur les séquences
- Optimisation des requêtes fréquentes
*/
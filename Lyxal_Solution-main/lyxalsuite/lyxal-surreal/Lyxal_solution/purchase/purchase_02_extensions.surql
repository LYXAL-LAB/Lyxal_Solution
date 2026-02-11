-- ======================================================================
-- MIGRATION MODULE AXELOR-PURCHASE VERS SURREALDB - PARTIE 2/2
-- ======================================================================
-- Module : axelor-purchase - Extensions et Analyses
-- Description : Extensions produits, partenaires, analyses et configurations avancées
-- Date : 2024
-- Entités : 8 entités finales sur 16 totales
-- ======================================================================

-- Nettoyage des tables existantes
REMOVE TABLE IF EXISTS product_multiple_qty;
REMOVE TABLE IF EXISTS shipping_coef;
REMOVE TABLE IF EXISTS abc_analysis;
REMOVE TABLE IF EXISTS product_purchase_extension;
REMOVE TABLE IF EXISTS partner_purchase_extension;
REMOVE TABLE IF EXISTS company_purchase_extension;
REMOVE TABLE IF EXISTS sequence_purchase;
REMOVE TABLE IF EXISTS app_purchase_extension;

-- ======================================================================
-- 9. TABLE : PRODUCT_MULTIPLE_QTY
-- ======================================================================
DEFINE TABLE product_multiple_qty SCHEMAFULL
    COMMENT "Gestion des quantités multiples pour les produits";

-- Champs principaux
DEFINE FIELD id ON product_multiple_qty TYPE record<product_multiple_qty>;
DEFINE FIELD created_on ON product_multiple_qty TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON product_multiple_qty TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON product_multiple_qty TYPE int DEFAULT 0;

-- Relations
DEFINE FIELD supplier_catalog_id ON product_multiple_qty TYPE option<record<supplier_catalog>>;
DEFINE FIELD product_id ON product_multiple_qty TYPE option<record<product>>;

-- Quantités multiples
DEFINE FIELD multiple_qty ON product_multiple_qty TYPE decimal DEFAULT 1;
DEFINE FIELD price ON product_multiple_qty TYPE decimal DEFAULT 0;

-- Configuration
DEFINE FIELD is_default ON product_multiple_qty TYPE bool DEFAULT false;

-- Index
DEFINE INDEX idx_product_multiple_qty_catalog ON product_multiple_qty COLUMNS supplier_catalog_id;
DEFINE INDEX idx_product_multiple_qty_product ON product_multiple_qty COLUMNS product_id;
DEFINE INDEX idx_product_multiple_qty_qty ON product_multiple_qty COLUMNS multiple_qty;

-- ======================================================================
-- 10. TABLE : SHIPPING_COEF
-- ======================================================================
DEFINE TABLE shipping_coef SCHEMAFULL
    COMMENT "Coefficient de livraison pour les fournisseurs";

-- Champs principaux
DEFINE FIELD id ON shipping_coef TYPE record<shipping_coef>;
DEFINE FIELD created_on ON shipping_coef TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON shipping_coef TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON shipping_coef TYPE int DEFAULT 0;

-- Relations
DEFINE FIELD supplier_catalog_id ON shipping_coef TYPE option<record<supplier_catalog>>;

-- Coefficients
DEFINE FIELD shipping_coef_by_partner ON shipping_coef TYPE decimal DEFAULT 1;
DEFINE FIELD shipping_threshold ON shipping_coef TYPE decimal DEFAULT 0;
DEFINE FIELD shipping_coef_select ON shipping_coef TYPE int DEFAULT 1;

-- Configuration
DEFINE FIELD start_date ON shipping_coef TYPE date;
DEFINE FIELD end_date ON shipping_coef TYPE date;

-- Index
DEFINE INDEX idx_shipping_coef_catalog ON shipping_coef COLUMNS supplier_catalog_id;
DEFINE INDEX idx_shipping_coef_dates ON shipping_coef COLUMNS start_date, end_date;
DEFINE INDEX idx_shipping_coef_threshold ON shipping_coef COLUMNS shipping_threshold;

-- ======================================================================
-- 11. TABLE : ABC_ANALYSIS
-- ======================================================================
DEFINE TABLE abc_analysis SCHEMAFULL
    COMMENT "Analyse ABC des achats";

-- Champs principaux
DEFINE FIELD id ON abc_analysis TYPE record<abc_analysis>;
DEFINE FIELD created_on ON abc_analysis TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON abc_analysis TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON abc_analysis TYPE int DEFAULT 0;

-- Période d'analyse
DEFINE FIELD start_date ON abc_analysis TYPE date;
DEFINE FIELD end_date ON abc_analysis TYPE date;

-- Configuration
DEFINE FIELD company_id ON abc_analysis TYPE option<record<company>>;
DEFINE FIELD analysis_type_select ON abc_analysis TYPE int DEFAULT 1;

-- Résultats d'analyse
DEFINE FIELD total_value ON abc_analysis TYPE decimal DEFAULT 0;
DEFINE FIELD analysis_date ON abc_analysis TYPE datetime;
DEFINE FIELD status_select ON abc_analysis TYPE int DEFAULT 1;

-- Seuils ABC
DEFINE FIELD threshold_a ON abc_analysis TYPE decimal DEFAULT 80;
DEFINE FIELD threshold_b ON abc_analysis TYPE decimal DEFAULT 15;
DEFINE FIELD threshold_c ON abc_analysis TYPE decimal DEFAULT 5;

-- Index
DEFINE INDEX idx_abc_analysis_company ON abc_analysis COLUMNS company_id;
DEFINE INDEX idx_abc_analysis_dates ON abc_analysis COLUMNS start_date, end_date;
DEFINE INDEX idx_abc_analysis_status ON abc_analysis COLUMNS status_select;
DEFINE INDEX idx_abc_analysis_type ON abc_analysis COLUMNS analysis_type_select;

-- ======================================================================
-- 12. TABLE : PRODUCT_PURCHASE_EXTENSION
-- ======================================================================
DEFINE TABLE product_purchase_extension SCHEMAFULL
    COMMENT "Extension produit pour les achats";

-- Champs principaux
DEFINE FIELD id ON product_purchase_extension TYPE record<product_purchase_extension>;
DEFINE FIELD created_on ON product_purchase_extension TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON product_purchase_extension TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON product_purchase_extension TYPE int DEFAULT 0;

-- Relation produit
DEFINE FIELD product_id ON product_purchase_extension TYPE option<record<product>>;

-- Configuration d'achat
DEFINE FIELD default_supplier_partner_id ON product_purchase_extension TYPE option<record<partner>>;
DEFINE FIELD purchase_unit_id ON product_purchase_extension TYPE option<record<unit>>;
DEFINE FIELD purchase_currency_id ON product_purchase_extension TYPE option<record<currency>>;

-- Prix d'achat
DEFINE FIELD last_purchase_price ON product_purchase_extension TYPE decimal DEFAULT 0;
DEFINE FIELD average_purchase_price ON product_purchase_extension TYPE decimal DEFAULT 0;
DEFINE FIELD max_purchase_price ON product_purchase_extension TYPE decimal DEFAULT 0;

-- Quantités
DEFINE FIELD minimum_purchase_qty ON product_purchase_extension TYPE decimal DEFAULT 1;
DEFINE FIELD economic_purchase_qty ON product_purchase_extension TYPE decimal DEFAULT 1;

-- Configuration
DEFINE FIELD is_purchase_product ON product_purchase_extension TYPE bool DEFAULT true;
DEFINE FIELD manage_multiple_purchase_qty ON product_purchase_extension TYPE bool DEFAULT false;

-- Classification ABC
DEFINE FIELD abc_analysis_class ON product_purchase_extension TYPE string;
DEFINE FIELD abc_analysis_value ON product_purchase_extension TYPE decimal DEFAULT 0;

-- Index
DEFINE INDEX idx_product_purchase_extension_product ON product_purchase_extension COLUMNS product_id UNIQUE;
DEFINE INDEX idx_product_purchase_extension_supplier ON product_purchase_extension COLUMNS default_supplier_partner_id;
DEFINE INDEX idx_product_purchase_extension_abc ON product_purchase_extension COLUMNS abc_analysis_class;

-- ======================================================================
-- 13. TABLE : PARTNER_PURCHASE_EXTENSION
-- ======================================================================
DEFINE TABLE partner_purchase_extension SCHEMAFULL
    COMMENT "Extension partenaire pour les achats";

-- Champs principaux
DEFINE FIELD id ON partner_purchase_extension TYPE record<partner_purchase_extension>;
DEFINE FIELD created_on ON partner_purchase_extension TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON partner_purchase_extension TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON partner_purchase_extension TYPE int DEFAULT 0;

-- Relation partenaire
DEFINE FIELD partner_id ON partner_purchase_extension TYPE option<record<partner>>;

-- Configuration fournisseur
DEFINE FIELD is_supplier ON partner_purchase_extension TYPE bool DEFAULT false;
DEFINE FIELD supplier_type_select ON partner_purchase_extension TYPE int DEFAULT 1;
DEFINE FIELD quality_rating ON partner_purchase_extension TYPE decimal DEFAULT 0;
DEFINE FIELD delivery_rating ON partner_purchase_extension TYPE decimal DEFAULT 0;
DEFINE FIELD price_rating ON partner_purchase_extension TYPE decimal DEFAULT 0;

-- Conditions commerciales
DEFINE FIELD payment_condition_id ON partner_purchase_extension TYPE option<record<payment_condition>>;
DEFINE FIELD delivery_condition_id ON partner_purchase_extension TYPE option<record<payment_condition>>;
DEFINE FIELD price_list_id ON partner_purchase_extension TYPE option<record<price_list>>;

-- Délais
DEFINE FIELD delivery_delay ON partner_purchase_extension TYPE int DEFAULT 0;
DEFINE FIELD order_delay ON partner_purchase_extension TYPE int DEFAULT 0;

-- Montants
DEFINE FIELD min_order_amount ON partner_purchase_extension TYPE decimal DEFAULT 0;
DEFINE FIELD last_order_date ON partner_purchase_extension TYPE datetime;
DEFINE FIELD total_order_amount ON partner_purchase_extension TYPE decimal DEFAULT 0;

-- Configuration
DEFINE FIELD is_subcontractor ON partner_purchase_extension TYPE bool DEFAULT false;
DEFINE FIELD subcontracting_type_select ON partner_purchase_extension TYPE int DEFAULT 1;

-- Index
DEFINE INDEX idx_partner_purchase_extension_partner ON partner_purchase_extension COLUMNS partner_id UNIQUE;
DEFINE INDEX idx_partner_purchase_extension_supplier ON partner_purchase_extension COLUMNS is_supplier;
DEFINE INDEX idx_partner_purchase_extension_type ON partner_purchase_extension COLUMNS supplier_type_select;
DEFINE INDEX idx_partner_purchase_extension_rating ON partner_purchase_extension COLUMNS quality_rating;

-- ======================================================================
-- 14. TABLE : COMPANY_PURCHASE_EXTENSION
-- ======================================================================
DEFINE TABLE company_purchase_extension SCHEMAFULL
    COMMENT "Extension entreprise pour les achats";

-- Champs principaux
DEFINE FIELD id ON company_purchase_extension TYPE record<company_purchase_extension>;
DEFINE FIELD created_on ON company_purchase_extension TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON company_purchase_extension TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON company_purchase_extension TYPE int DEFAULT 0;

-- Relation entreprise
DEFINE FIELD company_id ON company_purchase_extension TYPE option<record<company>>;

-- Configuration générale
DEFINE FIELD auto_generate_purchase_order ON company_purchase_extension TYPE bool DEFAULT false;
DEFINE FIELD auto_validate_purchase_order ON company_purchase_extension TYPE bool DEFAULT false;
DEFINE FIELD purchase_order_numbering_auto ON company_purchase_extension TYPE bool DEFAULT true;

-- Configuration workflow
DEFINE FIELD purchase_request_workflow ON company_purchase_extension TYPE bool DEFAULT false;
DEFINE FIELD purchase_validation_threshold ON company_purchase_extension TYPE decimal DEFAULT 0;
DEFINE FIELD require_purchase_approval ON company_purchase_extension TYPE bool DEFAULT false;

-- Configuration par défaut
DEFINE FIELD default_purchase_currency_id ON company_purchase_extension TYPE option<record<currency>>;
DEFINE FIELD default_purchase_unit_id ON company_purchase_extension TYPE option<record<unit>>;
DEFINE FIELD default_payment_condition_id ON company_purchase_extension TYPE option<record<payment_condition>>;

-- Configuration analytique
DEFINE FIELD enable_purchase_analytics ON company_purchase_extension TYPE bool DEFAULT false;
DEFINE FIELD default_analytic_account_id ON company_purchase_extension TYPE option<record<analytic_account>>;

-- Configuration catalogue
DEFINE FIELD auto_update_supplier_catalog ON company_purchase_extension TYPE bool DEFAULT false;
DEFINE FIELD catalog_update_frequency ON company_purchase_extension TYPE int DEFAULT 30;

-- Index
DEFINE INDEX idx_company_purchase_extension_company ON company_purchase_extension COLUMNS company_id UNIQUE;
DEFINE INDEX idx_company_purchase_extension_currency ON company_purchase_extension COLUMNS default_purchase_currency_id;
DEFINE INDEX idx_company_purchase_extension_workflow ON company_purchase_extension COLUMNS purchase_request_workflow;

-- ======================================================================
-- 15. TABLE : SEQUENCE_PURCHASE
-- ======================================================================
DEFINE TABLE sequence_purchase SCHEMAFULL
    COMMENT "Séquences pour les achats";

-- Champs principaux
DEFINE FIELD id ON sequence_purchase TYPE record<sequence_purchase>;
DEFINE FIELD created_on ON sequence_purchase TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON sequence_purchase TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON sequence_purchase TYPE int DEFAULT 0;

-- Identification
DEFINE FIELD name ON sequence_purchase TYPE string;
DEFINE FIELD code ON sequence_purchase TYPE string;
DEFINE FIELD prefix ON sequence_purchase TYPE string;
DEFINE FIELD suffix ON sequence_purchase TYPE string;

-- Configuration séquence
DEFINE FIELD padding ON sequence_purchase TYPE int DEFAULT 5;
DEFINE FIELD next_num ON sequence_purchase TYPE int DEFAULT 1;
DEFINE FIELD increment ON sequence_purchase TYPE int DEFAULT 1;

-- Relations
DEFINE FIELD company_id ON sequence_purchase TYPE option<record<company>>;

-- Configuration avancée
DEFINE FIELD year_reset ON sequence_purchase TYPE bool DEFAULT false;
DEFINE FIELD month_reset ON sequence_purchase TYPE bool DEFAULT false;

-- Index
DEFINE INDEX idx_sequence_purchase_code ON sequence_purchase COLUMNS code UNIQUE;
DEFINE INDEX idx_sequence_purchase_company ON sequence_purchase COLUMNS company_id;
DEFINE INDEX idx_sequence_purchase_name ON sequence_purchase COLUMNS name;

-- ======================================================================
-- 16. TABLE : APP_PURCHASE_EXTENSION
-- ======================================================================
DEFINE TABLE app_purchase_extension SCHEMAFULL
    COMMENT "Extension application pour les achats";

-- Champs principaux
DEFINE FIELD id ON app_purchase_extension TYPE record<app_purchase_extension>;
DEFINE FIELD created_on ON app_purchase_extension TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_on ON app_purchase_extension TYPE datetime DEFAULT time::now();
DEFINE FIELD version ON app_purchase_extension TYPE int DEFAULT 0;

-- Relation application
DEFINE FIELD app_id ON app_purchase_extension TYPE option<record<app>>;

-- Configuration avancée
DEFINE FIELD enable_purchase_forecasting ON app_purchase_extension TYPE bool DEFAULT false;
DEFINE FIELD enable_supplier_portal ON app_purchase_extension TYPE bool DEFAULT false;
DEFINE FIELD enable_purchase_analytics ON app_purchase_extension TYPE bool DEFAULT false;
DEFINE FIELD enable_contract_management ON app_purchase_extension TYPE bool DEFAULT false;

-- Intégrations
DEFINE FIELD enable_edi_integration ON app_purchase_extension TYPE bool DEFAULT false;
DEFINE FIELD enable_email_notifications ON app_purchase_extension TYPE bool DEFAULT true;
DEFINE FIELD enable_mobile_approval ON app_purchase_extension TYPE bool DEFAULT false;

-- Configuration IA
DEFINE FIELD enable_ai_price_optimization ON app_purchase_extension TYPE bool DEFAULT false;
DEFINE FIELD enable_ai_supplier_recommendation ON app_purchase_extension TYPE bool DEFAULT false;

-- Index
DEFINE INDEX idx_app_purchase_extension_app ON app_purchase_extension COLUMNS app_id UNIQUE;

-- ======================================================================
-- FONCTIONS UTILITAIRES
-- ======================================================================

-- Fonction pour calculer la classification ABC
DEFINE FUNCTION fn::calculate_abc_classification($product_id: record<product>, $start_date: date, $end_date: date) {
    LET $total_value = (SELECT SUM(pol.ex_tax_total) 
                       FROM purchase_order_line pol
                       JOIN purchase_order po ON po.id = pol.purchase_order_id
                       WHERE pol.product_id = $product_id
                       AND po.order_date >= $start_date 
                       AND po.order_date <= $end_date);
    
    LET $company_total = (SELECT SUM(pol.ex_tax_total) 
                         FROM purchase_order_line pol
                         JOIN purchase_order po ON po.id = pol.purchase_order_id
                         WHERE po.order_date >= $start_date 
                         AND po.order_date <= $end_date);
    
    LET $percentage = ($total_value / $company_total) * 100;
    
    RETURN CASE 
        WHEN $percentage >= 80 THEN "A"
        WHEN $percentage >= 15 THEN "B"
        ELSE "C"
    END;
};

-- Fonction pour obtenir les meilleurs fournisseurs par produit
DEFINE FUNCTION fn::get_best_suppliers_by_product($product_id: record<product>, $limit: int) {
    RETURN SELECT 
        sc.supplier_partner_id,
        AVG(sc.price) as avg_price,
        COUNT(*) as order_count,
        AVG(ppe.quality_rating) as quality_rating,
        AVG(ppe.delivery_rating) as delivery_rating
    FROM supplier_catalog sc
    LEFT JOIN partner_purchase_extension ppe ON ppe.partner_id = sc.supplier_partner_id
    WHERE sc.product_id = $product_id
    GROUP BY sc.supplier_partner_id
    ORDER BY quality_rating DESC, delivery_rating DESC, avg_price ASC
    LIMIT $limit;
};

-- Fonction pour calculer les quantités économiques
DEFINE FUNCTION fn::calculate_economic_order_quantity($annual_demand: decimal, $order_cost: decimal, $holding_cost: decimal) {
    RETURN math::sqrt((2 * $annual_demand * $order_cost) / $holding_cost);
};

-- Fonction pour analyser les performances fournisseur
DEFINE FUNCTION fn::analyze_supplier_performance($supplier_id: record<partner>, $period_months: int) {
    LET $start_date = time::date() - duration::days($period_months * 30);
    LET $orders = (SELECT * FROM purchase_order 
                  WHERE supplier_partner_id = $supplier_id 
                  AND order_date >= $start_date);
    
    LET $total_orders = array::length($orders);
    LET $on_time_deliveries = array::length(array::filter($orders, |$order| 
        $order.estimated_receipt_date >= $order.order_date
    ));
    
    RETURN {
        total_orders: $total_orders,
        on_time_rate: IF $total_orders > 0 THEN ($on_time_deliveries / $total_orders) * 100 ELSE 0 END,
        average_order_value: array::reduce($orders, 0, |$acc, $order| $acc + $order.ex_tax_total) / $total_orders
    };
};

-- Fonction pour obtenir les produits à commander
DEFINE FUNCTION fn::get_products_to_reorder($company_id: record<company>) {
    RETURN SELECT 
        p.*,
        ppe.minimum_purchase_qty,
        ppe.economic_purchase_qty,
        ppe.last_purchase_price,
        sc.price as current_supplier_price
    FROM product p
    LEFT JOIN product_purchase_extension ppe ON ppe.product_id = p.id
    LEFT JOIN supplier_catalog sc ON sc.product_id = p.id AND sc.supplier_partner_id = ppe.default_supplier_partner_id
    WHERE p.purchase_ok = true
    AND p.current_stock <= p.reorder_level;
};

-- Fonction pour calculer les coûts de transport
DEFINE FUNCTION fn::calculate_shipping_cost($supplier_catalog_id: record<supplier_catalog>, $quantity: decimal, $order_amount: decimal) {
    LET $shipping_coefs = (SELECT * FROM shipping_coef 
                          WHERE supplier_catalog_id = $supplier_catalog_id
                          AND ($order_amount >= shipping_threshold OR shipping_threshold = 0)
                          ORDER BY shipping_threshold DESC
                          LIMIT 1);
    
    RETURN IF array::length($shipping_coefs) > 0 THEN
        $quantity * $shipping_coefs[0].shipping_coef_by_partner
    ELSE
        0
    END;
};

-- ======================================================================
-- ÉVÉNEMENTS ET TRIGGERS
-- ======================================================================

-- Trigger pour mettre à jour les dates de modification
DEFINE EVENT abc_analysis_updated ON TABLE abc_analysis WHEN $event = "UPDATE" THEN {
    UPDATE abc_analysis SET updated_on = time::now() WHERE id = $after.id;
};

DEFINE EVENT product_purchase_extension_updated ON TABLE product_purchase_extension WHEN $event = "UPDATE" THEN {
    UPDATE product_purchase_extension SET updated_on = time::now() WHERE id = $after.id;
};

-- Trigger pour calculer automatiquement la classification ABC
DEFINE EVENT product_abc_classification ON TABLE product_purchase_extension WHEN $event = "CREATE" OR $event = "UPDATE" THEN {
    IF $after.product_id IS NOT NONE THEN {
        LET $classification = fn::calculate_abc_classification($after.product_id, time::date() - duration::days(365), time::date());
        UPDATE product_purchase_extension SET abc_analysis_class = $classification WHERE id = $after.id;
    };
};

-- Trigger pour mettre à jour les performances fournisseur
DEFINE EVENT supplier_performance_update ON TABLE purchase_order WHEN $event = "UPDATE" AND $after.status_select = 4 THEN {
    LET $performance = fn::analyze_supplier_performance($after.supplier_partner_id, 12);
    UPDATE partner_purchase_extension SET 
        delivery_rating = $performance.on_time_rate,
        last_order_date = $after.validation_date_time,
        total_order_amount = total_order_amount + $after.ex_tax_total
    WHERE partner_id = $after.supplier_partner_id;
};

-- Trigger pour générer les séquences
DEFINE EVENT generate_purchase_sequence ON TABLE purchase_order WHEN $event = "CREATE" AND $after.purchase_order_seq IS NONE THEN {
    LET $sequence = (SELECT * FROM sequence_purchase WHERE code = "PURCHASE_ORDER" AND company_id = $after.company_id);
    IF $sequence IS NOT NONE THEN {
        LET $next_value = string::concat(
            $sequence.prefix ?? "",
            string::repeat("0", $sequence.padding - string::length(string::from($sequence.next_num))),
            string::from($sequence.next_num),
            $sequence.suffix ?? ""
        );
        UPDATE purchase_order SET purchase_order_seq = $next_value WHERE id = $after.id;
        UPDATE sequence_purchase SET next_num = next_num + increment WHERE id = $sequence.id;
    };
};

-- ======================================================================
-- DONNÉES DE RÉFÉRENCE
-- ======================================================================

-- Types de fournisseurs
LET $SUPPLIER_TYPE_STANDARD = 1;
LET $SUPPLIER_TYPE_PREFERRED = 2;
LET $SUPPLIER_TYPE_STRATEGIC = 3;
LET $SUPPLIER_TYPE_BLACKLISTED = 4;

-- Types d'analyse ABC
LET $ABC_ANALYSIS_TYPE_VALUE = 1;
LET $ABC_ANALYSIS_TYPE_QUANTITY = 2;
LET $ABC_ANALYSIS_TYPE_FREQUENCY = 3;

-- Statuts d'analyse ABC
LET $ABC_ANALYSIS_STATUS_DRAFT = 1;
LET $ABC_ANALYSIS_STATUS_IN_PROGRESS = 2;
LET $ABC_ANALYSIS_STATUS_COMPLETED = 3;

-- Types de sous-traitance
LET $SUBCONTRACTING_TYPE_NONE = 1;
LET $SUBCONTRACTING_TYPE_PARTIAL = 2;
LET $SUBCONTRACTING_TYPE_FULL = 3;

-- Coefficients de livraison
LET $SHIPPING_COEF_FIXED = 1;
LET $SHIPPING_COEF_PERCENTAGE = 2;
LET $SHIPPING_COEF_PROGRESSIVE = 3;

-- ======================================================================
-- VUES COMPLEXES
-- ======================================================================

-- Vue pour les fournisseurs avec performances
DEFINE TABLE supplier_performance_dashboard AS SELECT 
    p.*,
    ppe.quality_rating,
    ppe.delivery_rating,
    ppe.price_rating,
    ppe.total_order_amount,
    ppe.last_order_date,
    ppe.supplier_type_select,
    array::length((SELECT * FROM supplier_catalog WHERE supplier_partner_id = p.id)) as catalog_products_count
FROM partner p
LEFT JOIN partner_purchase_extension ppe ON ppe.partner_id = p.id
WHERE ppe.is_supplier = true;

-- Vue pour l'analyse ABC des produits
DEFINE TABLE product_abc_dashboard AS SELECT 
    p.*,
    ppe.abc_analysis_class,
    ppe.abc_analysis_value,
    ppe.last_purchase_price,
    ppe.average_purchase_price,
    ppe.minimum_purchase_qty,
    ppe.economic_purchase_qty,
    sp.name as default_supplier_name
FROM product p
LEFT JOIN product_purchase_extension ppe ON ppe.product_id = p.id
LEFT JOIN partner sp ON sp.id = ppe.default_supplier_partner_id
WHERE ppe.is_purchase_product = true;

-- Vue pour les catalogues fournisseurs enrichis
DEFINE TABLE supplier_catalog_enriched AS SELECT 
    sc.*,
    p.name as product_name,
    p.code as product_code,
    sp.name as supplier_name,
    ppe.quality_rating as supplier_quality,
    array::length(sc.product_multiple_qty_list) as multiple_qty_count,
    array::length(sc.shipping_coef_list) as shipping_coef_count
FROM supplier_catalog sc
LEFT JOIN product p ON p.id = sc.product_id
LEFT JOIN partner sp ON sp.id = sc.supplier_partner_id
LEFT JOIN partner_purchase_extension ppe ON ppe.partner_id = sp.id;

-- Vue pour les analyses ABC avec détails
DEFINE TABLE abc_analysis_dashboard AS SELECT 
    abc.*,
    c.name as company_name,
    array::length((SELECT * FROM product_purchase_extension WHERE abc_analysis_class = "A")) as class_a_count,
    array::length((SELECT * FROM product_purchase_extension WHERE abc_analysis_class = "B")) as class_b_count,
    array::length((SELECT * FROM product_purchase_extension WHERE abc_analysis_class = "C")) as class_c_count
FROM abc_analysis abc
LEFT JOIN company c ON c.id = abc.company_id;

-- ======================================================================
-- COMMENTAIRES ET DOCUMENTATION
-- ======================================================================

/*
MIGRATION AXELOR-PURCHASE VERS SURREALDB - PARTIE 2/2: EXTENSIONS ET ANALYSES

ENTITÉS MIGRÉES (8/16) - FINALES:
9. ProductMultipleQty - Quantités multiples
10. ShippingCoef - Coefficients de livraison
11. ABCAnalysis - Analyse ABC des achats
12. ProductPurchaseExtension - Extension produit
13. PartnerPurchaseExtension - Extension partenaire
14. CompanyPurchaseExtension - Extension entreprise
15. SequencePurchase - Séquences d'achat
16. AppPurchaseExtension - Extension application

TOTAL: 16/16 ENTITÉS MIGRÉES COMPLÈTEMENT

FONCTIONNALITÉS CLÉS:
- Gestion des quantités multiples et prix dégressifs
- Coefficients de livraison et frais de transport
- Analyse ABC pour optimisation des achats
- Extensions complètes pour produits et fournisseurs
- Configuration avancée par entreprise
- Génération automatique de séquences
- Fonctionnalités d'analyse et de reporting

RELATIONS FINALES:
- ProductMultipleQty N:1 SupplierCatalog
- ShippingCoef N:1 SupplierCatalog
- ProductPurchaseExtension 1:1 Product
- PartnerPurchaseExtension 1:1 Partner
- CompanyPurchaseExtension 1:1 Company
- SequencePurchase N:1 Company

FONCTIONS UTILITAIRES:
- Classification ABC automatique
- Recherche des meilleurs fournisseurs
- Calcul des quantités économiques
- Analyse des performances fournisseur
- Gestion des coûts de transport
- Alertes de réapprovisionnement

PERFORMANCE ET OPTIMISATION:
- Index sur les classifications ABC
- Index sur les performances fournisseur
- Index sur les seuils et quantités
- Vues complexes pour tableaux de bord
- Triggers pour calculs automatiques

MIGRATION COMPLÈTE DU MODULE AXELOR-PURCHASE:
✓ Toutes les 16 entités migrées
✓ Relations préservées et optimisées
✓ Fonctions d'analyse avancées
✓ Configuration flexible par entreprise
✓ Workflows automatisés
✓ Tableaux de bord complets
*/
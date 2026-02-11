# MIGRATION MODULE AXELOR-PURCHASE VERS SURREALDB

## Vue d'ensemble

**Module :** axelor-purchase  
**Description :** Gestion complète des achats et fournisseurs  
**Date de migration :** 2024  
**Statut :** ✅ COMPLET - 16/16 entités migrées  

## Structure de la migration

La migration du module axelor-purchase a été organisée en **2 fichiers logiques** pour une meilleure lisibilité et maintenance :

### 1. purchase_01_core.surql - Entités principales (8/16)
Gestion de base des commandes et demandes d'achat
- **AppPurchase** - Configuration principale de l'application achat
- **PurchaseConfig** - Configuration des achats par entreprise
- **PurchaseOrder** - Commande d'achat (entité centrale)
- **PurchaseOrderLine** - Ligne de commande d'achat
- **PurchaseOrderLineTax** - Ligne de taxe sur commande d'achat
- **PurchaseRequest** - Demande d'achat
- **PurchaseRequestLine** - Ligne de demande d'achat
- **SupplierCatalog** - Catalogue fournisseur

### 2. purchase_02_extensions.surql - Extensions et Analyses (8/16)
Extensions produits, partenaires, analyses et configurations avancées
- **ProductMultipleQty** - Gestion des quantités multiples
- **ShippingCoef** - Coefficient de livraison pour les fournisseurs
- **ABCAnalysis** - Analyse ABC des achats
- **ProductPurchaseExtension** - Extension produit pour les achats
- **PartnerPurchaseExtension** - Extension partenaire pour les achats
- **CompanyPurchaseExtension** - Extension entreprise pour les achats
- **SequencePurchase** - Séquences pour les achats
- **AppPurchaseExtension** - Extension application pour les achats

## Fonctionnalités clés migrées

### 🛒 Gestion des commandes d'achat
- Cycle complet de commande (brouillon → demandé → validé → terminé)
- Gestion des statuts et workflow personnalisable
- Calcul automatique des totaux HT/TTC
- Gestion des devises et taux de change
- Validation hiérarchique et approbation

### 📋 Demandes d'achat
- Workflow de demandes d'achat interne
- Validation par des utilisateurs autorisés
- Conversion automatique en commandes
- Suivi des demandes en attente
- Gestion des nouveaux produits

### 👥 Gestion des fournisseurs
- Catalogue fournisseur complet
- Évaluation des performances (qualité, délais, prix)
- Classification des fournisseurs (standard, préféré, stratégique)
- Gestion des conditions commerciales
- Sous-traitance et partenariats

### 📊 Analyse et optimisation
- Analyse ABC des achats
- Classification automatique des produits
- Calcul des quantités économiques
- Optimisation des coûts de transport
- Tableaux de bord de performance

### 💰 Gestion financière
- Calcul automatique des taxes
- Gestion des remises et conditions tarifaires
- Suivi des avances et acomptes
- Intégration comptable complète
- Multi-devises

### ⚙️ Configuration avancée
- Configuration par entreprise
- Séquences automatiques personnalisables
- Templates d'impression
- Workflow configurable
- Extensions modulaires

## Relations principales

### Relations centrales
- **PurchaseOrder** 1:N **PurchaseOrderLine** (Commande vers Lignes)
- **PurchaseOrder** 1:N **PurchaseOrderLineTax** (Commande vers Taxes)
- **PurchaseRequest** 1:N **PurchaseRequestLine** (Demande vers Lignes)
- **PurchaseOrder** N:1 **Partner** (Commande vers Fournisseur)
- **PurchaseConfig** 1:1 **Company** (Configuration par entreprise)

### Relations catalogue
- **SupplierCatalog** N:1 **Product** (Catalogue vers Produit)
- **SupplierCatalog** N:1 **Partner** (Catalogue vers Fournisseur)
- **ProductMultipleQty** N:1 **SupplierCatalog** (Quantités multiples)
- **ShippingCoef** N:1 **SupplierCatalog** (Coûts de transport)

### Relations d'extension
- **ProductPurchaseExtension** 1:1 **Product** (Extension produit)
- **PartnerPurchaseExtension** 1:1 **Partner** (Extension partenaire)
- **CompanyPurchaseExtension** 1:1 **Company** (Extension entreprise)
- **AppPurchaseExtension** 1:1 **App** (Extension application)

### Relations de workflow
- **PurchaseRequest** N:1 **PurchaseOrder** (Demande vers Commande)
- **SequencePurchase** N:1 **Company** (Séquences par entreprise)
- **ABCAnalysis** N:1 **Company** (Analyse par entreprise)

## Fonctions utilitaires

### Calculs financiers
- `fn::calculate_purchase_order_total()` - Calcul total commande
- `fn::calculate_discounted_price()` - Calcul prix avec remise
- `fn::calculate_shipping_cost()` - Calcul coûts de transport
- `fn::calculate_economic_order_quantity()` - Quantité économique

### Gestion des fournisseurs
- `fn::get_best_suppliers_by_product()` - Meilleurs fournisseurs par produit
- `fn::analyze_supplier_performance()` - Analyse performance fournisseur
- `fn::get_supplier_catalog_by_product()` - Catalogue fournisseur produit

### Analyse et reporting
- `fn::calculate_abc_classification()` - Classification ABC automatique
- `fn::get_overdue_purchase_orders()` - Commandes en retard
- `fn::get_pending_purchase_requests()` - Demandes en attente
- `fn::get_products_to_reorder()` - Produits à réapprovisionner

### Workflow et statuts
- `fn::get_purchase_orders_by_status()` - Commandes par statut

## Triggers et événements

### Mise à jour automatique
- **purchase_order_updated** - Mise à jour date modification
- **purchase_order_line_updated** - Mise à jour ligne
- **purchase_request_updated** - Mise à jour demande

### Calculs automatiques
- **purchase_order_full_name** - Calcul nom complet commande
- **purchase_order_line_full_name** - Calcul nom complet ligne
- **purchase_order_line_price_calculation** - Calcul prix avec remise

### Classification et analyse
- **product_abc_classification** - Classification ABC automatique
- **supplier_performance_update** - Mise à jour performance fournisseur

### Génération automatique
- **generate_purchase_sequence** - Génération séquences automatique

## Vues complexes et tableaux de bord

### Tableaux de bord fournisseurs
- **supplier_performance_dashboard** - Fournisseurs avec performances
- **supplier_catalog_enriched** - Catalogues enrichis avec détails

### Tableaux de bord produits
- **product_abc_dashboard** - Produits avec classification ABC

### Tableaux de bord analyses
- **abc_analysis_dashboard** - Analyses ABC avec détails

## Index et optimisations

### Index principaux
- Relations critiques (purchase_order_id, supplier_partner_id, product_id)
- Statuts et états (status_select, receipt_state)
- Dates importantes (order_date, estimated_receipt_date)
- Séquences uniques (purchase_order_seq, purchase_request_seq)
- Classifications (abc_analysis_class, supplier_type_select)

### Optimisations performance
- Index composites sur entreprise et séquence
- Index sur classifications et performances
- Index sur seuils et quantités
- Index sur dates et périodes d'analyse

## Constantes et paramètres

### Statuts de commande
- `$PURCHASE_ORDER_STATUS_DRAFT` = 1 (Brouillon)
- `$PURCHASE_ORDER_STATUS_REQUESTED` = 2 (Demandé)
- `$PURCHASE_ORDER_STATUS_VALIDATED` = 3 (Validé)
- `$PURCHASE_ORDER_STATUS_FINISHED` = 4 (Terminé)
- `$PURCHASE_ORDER_STATUS_CANCELED` = 5 (Annulé)

### États de réception
- `$PURCHASE_ORDER_RECEIPT_NOT_RECEIVED` = 1 (Non reçu)
- `$PURCHASE_ORDER_RECEIPT_PARTIALLY_RECEIVED` = 2 (Partiellement reçu)
- `$PURCHASE_ORDER_RECEIPT_RECEIVED` = 3 (Reçu)

### Statuts de demande d'achat
- `$PURCHASE_REQUEST_STATUS_DRAFT` = 1 (Brouillon)
- `$PURCHASE_REQUEST_STATUS_REQUESTED` = 2 (Demandé)
- `$PURCHASE_REQUEST_STATUS_ACCEPTED` = 3 (Accepté)
- `$PURCHASE_REQUEST_STATUS_PURCHASED` = 4 (Acheté)
- `$PURCHASE_REQUEST_STATUS_REFUSED` = 5 (Refusé)
- `$PURCHASE_REQUEST_STATUS_CANCELED` = 6 (Annulé)

### Types de fournisseurs
- `$SUPPLIER_TYPE_STANDARD` = 1 (Standard)
- `$SUPPLIER_TYPE_PREFERRED` = 2 (Préféré)
- `$SUPPLIER_TYPE_STRATEGIC` = 3 (Stratégique)
- `$SUPPLIER_TYPE_BLACKLISTED` = 4 (Liste noire)

### Classification ABC
- `$ABC_ANALYSIS_TYPE_VALUE` = 1 (Par valeur)
- `$ABC_ANALYSIS_TYPE_QUANTITY` = 2 (Par quantité)
- `$ABC_ANALYSIS_TYPE_FREQUENCY` = 3 (Par fréquence)

## Utilisation et intégration

### Création d'une commande d'achat
```sql
-- Création d'une commande d'achat
CREATE purchase_order SET
    purchase_order_seq = "CMD001",
    company_id = company:acme,
    supplier_partner_id = partner:supplier_xyz,
    buyer_user_id = user:buyer1,
    currency_id = currency:eur,
    order_date = "2024-01-15",
    status_select = 1;
```

### Ajout de lignes de commande
```sql
-- Ajout d'une ligne de commande
CREATE purchase_order_line SET
    purchase_order_id = purchase_order:CMD001,
    product_id = product:laptop,
    product_name = "Ordinateur portable",
    qty = 10,
    price = 800.00,
    unit_id = unit:piece;
```

### Création d'une demande d'achat
```sql
-- Création d'une demande d'achat
CREATE purchase_request SET
    purchase_request_seq = "REQ001",
    company_id = company:acme,
    requester_user_id = user:employee1,
    description = "Demande d'équipement informatique",
    status_select = 1;
```

### Gestion du catalogue fournisseur
```sql
-- Ajout au catalogue fournisseur
CREATE supplier_catalog SET
    product_id = product:laptop,
    supplier_partner_id = partner:supplier_xyz,
    product_supplier_code = "LAP-XYZ-001",
    price = 750.00,
    min_qty = 5,
    unit_id = unit:piece;
```

### Requêtes analytiques
```sql
-- Commandes en retard
SELECT 
    po.purchase_order_seq,
    sp.name as supplier_name,
    po.estimated_receipt_date,
    po.ex_tax_total
FROM purchase_order po
LEFT JOIN partner sp ON sp.id = po.supplier_partner_id
WHERE po.estimated_receipt_date < time::date()
AND po.status_select = 3
AND po.receipt_state != 3;

-- Analyse ABC des produits
SELECT 
    p.name,
    ppe.abc_analysis_class,
    ppe.last_purchase_price,
    ppe.average_purchase_price
FROM product p
LEFT JOIN product_purchase_extension ppe ON ppe.product_id = p.id
WHERE ppe.abc_analysis_class IS NOT NONE
ORDER BY ppe.abc_analysis_class, ppe.abc_analysis_value DESC;

-- Performance des fournisseurs
SELECT 
    p.name,
    ppe.quality_rating,
    ppe.delivery_rating,
    ppe.total_order_amount,
    ppe.supplier_type_select
FROM partner p
LEFT JOIN partner_purchase_extension ppe ON ppe.partner_id = p.id
WHERE ppe.is_supplier = true
ORDER BY ppe.quality_rating DESC;
```

### Workflow automatique
```sql
-- Validation automatique des petites commandes
UPDATE purchase_order 
SET status_select = 3, 
    validated_by_user_id = user:system,
    validation_date_time = time::now()
WHERE ex_tax_total < 1000 
AND status_select = 2;

-- Génération de commandes depuis demandes
CREATE purchase_order SET
    company_id = $request.company_id,
    supplier_partner_id = $request.supplier_partner_id,
    buyer_user_id = $request.requester_user_id,
    status_select = 1
FROM purchase_request $request
WHERE $request.status_select = 3;
```

## Migration et compatibilité

### Données préservées
- ✅ Toutes les entités Axelor migrées
- ✅ Relations et contraintes maintenues
- ✅ Logique métier préservée
- ✅ Calculs automatiques fonctionnels
- ✅ Workflow configurable

### Améliorations SurrealDB
- 🚀 Requêtes analytiques plus performantes
- 🔄 Relations directes sans jointures complexes
- 📊 Fonctions d'analyse intégrées
- 🔒 Contrôles de cohérence automatiques
- ⚡ Calculs temps réel

### Compatibilité
- Support des fonctionnalités Axelor existantes
- Extensions natives SurrealDB
- API REST automatique
- Intégration temps réel
- Tableaux de bord interactifs

## Analyse comparative

### Avant (Axelor + PostgreSQL)
- Requêtes complexes avec nombreuses jointures
- Calculs manuels des classifications
- Triggers SQL basiques
- Vues limitées
- Configuration rigide

### Après (SurrealDB)
- Requêtes directes avec relations natives
- Classification ABC automatique
- Fonctions d'analyse avancées
- Vues complexes dynamiques
- Configuration flexible et extensible

## Exemples d'utilisation avancée

### Optimisation des achats
```sql
-- Recommandation de fournisseurs optimaux
SELECT 
    fn::get_best_suppliers_by_product(product:laptop, 3) as recommended_suppliers,
    fn::calculate_economic_order_quantity(1200, 50, 15) as optimal_quantity;

-- Produits nécessitant un réapprovisionnement
SELECT * FROM fn::get_products_to_reorder(company:acme);
```

### Analyse de performance
```sql
-- Performance globale des fournisseurs
SELECT 
    supplier_name,
    fn::analyze_supplier_performance(supplier_id, 6) as performance_6_months
FROM supplier_performance_dashboard;

-- Évolution des prix par fournisseur
SELECT 
    sc.supplier_partner_id,
    AVG(sc.price) as average_price,
    MIN(sc.update_date) as first_price_date,
    MAX(sc.update_date) as last_price_date
FROM supplier_catalog sc
GROUP BY sc.supplier_partner_id, sc.product_id;
```

## Conclusion

La migration du module **axelor-purchase** vers SurrealDB est **100% complète** avec :

- ✅ **16/16 entités migrées** dans 2 fichiers logiques
- ✅ **Toutes les relations préservées** et optimisées
- ✅ **Fonctions d'analyse avancées** pour l'optimisation des achats
- ✅ **Classification ABC automatique** des produits et fournisseurs
- ✅ **Tableaux de bord complets** pour le pilotage
- ✅ **Workflow configurable** par entreprise
- ✅ **Performance optimisée** avec index appropriés
- ✅ **Extensions modulaires** pour personnalisation

Cette migration offre une base solide pour la gestion des achats dans l'écosystème LYXAL avec toutes les fonctionnalités avancées de SurrealDB et des capacités d'analyse en temps réel. 
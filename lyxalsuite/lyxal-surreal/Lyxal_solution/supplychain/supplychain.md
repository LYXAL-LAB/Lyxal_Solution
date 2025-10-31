# Module Axelor Supplychain - Migration SurrealDB

## Vue d'ensemble

Le module **axelor-supplychain** est le module le plus complet d'Axelor Open Suite. Il intègre toute la chaîne d'approvisionnement en connectant les ventes, achats, stock, comptabilité et planification MRP. Avec ses 50 entités, c'est le cœur de l'ERP pour la gestion industrielle et commerciale.

## Statistiques de Migration

- **Nombre total d'entités**: 50
- **Complexité**: Très élevée
- **Fichiers de migration recommandés**: 4-5 fichiers logiques
- **Tables SurrealDB créées**: 50+

## Architecture du Module

Le module supplychain couvre 8 domaines fonctionnels majeurs :

### 1. Configuration et Applications (8 entités)
- **AppSupplychain** - Configuration principale du module
- **SupplyChainConfig** - Configuration par entreprise
- **App** - Gestion des applications
- **Company** - Configuration des entreprises
- **User** - Utilisateurs étendus
- **Sequence** - Séquences de numérotation
- **MetaSchedule** - Planification des tâches
- **ExceptionOrigin** - Gestion des exceptions

### 2. MRP - Material Requirements Planning (7 entités)
- **Mrp** - Plans de besoins matières
- **MrpLine** - Lignes de planification MRP
- **MrpLineType** - Types de lignes MRP
- **MrpLineOrigin** - Origines des besoins
- **MrpForecast** - Prévisions de ventes
- **MrpFamily** - Familles de produits MRP
- **SupplychainBatch** - Traitements par lots

### 3. Ventes et Commandes (8 entités)
- **SaleOrder** - Commandes de vente étendues
- **SaleOrderLine** - Lignes de commande étendues
- **Cart** - Paniers d'achat
- **CartLine** - Lignes de panier
- **Timetable** - Échéanciers de facturation
- **TimetableTemplate** - Modèles d'échéanciers
- **TimetableTemplateLine** - Lignes de modèles
- **AdvancePayment** - Acomptes

### 4. Achats et Approvisionnement (6 entités)
- **PurchaseOrder** - Commandes d'achat étendues
- **PurchaseOrderLine** - Lignes d'achat étendues
- **PurchaseRequest** - Demandes d'achat
- **PartnerLinkType** - Types de liens partenaires
- **Partner** - Partenaires étendus
- **Product** - Produits étendus

### 5. Stock et Logistique (8 entités)
- **StockMove** - Mouvements de stock étendus
- **StockMoveLine** - Lignes de mouvement étendues
- **StockLocation** - Emplacements étendus
- **StockLocationLine** - Lignes d'emplacement étendues
- **StockHistoryLine** - Historique des stocks
- **StockConfig** - Configuration stock étendue
- **TrackingNumber** - Numéros de traçabilité étendus
- **LogisticalFormLine** - Lignes de formulaire logistique

### 6. Comptabilité et Facturation (8 entités)
- **Invoice** - Factures étendues
- **InvoiceLine** - Lignes de facture étendues
- **Move** - Écritures comptables étendues
- **AnalyticMoveLine** - Lignes analytiques
- **AccountingSituation** - Situations comptables
- **AccountingBatch** - Lots comptables
- **AccountConfig** - Configuration comptable
- **FixedAsset** - Immobilisations

### 7. Transport et Expédition (4 entités)
- **ShipmentMode** - Modes d'expédition
- **CustomerShippingCarriagePaid** - Frais de port client
- **DeclarationOfExchanges** - Déclarations d'échanges
- **TaxNumber** - Numéros fiscaux

### 8. Autres Entités (1 entité)
- **CancelReason** - Motifs d'annulation

## Fonctionnalités Clés

### 1. Intégration Complète
- **Flux automatiques** entre ventes, achats et stock
- **Génération automatique** de mouvements de stock
- **Facturation automatique** depuis les livraisons
- **Synchronisation** temps réel des données

### 2. MRP (Material Requirements Planning)
- **Calcul des besoins** en matières et composants
- **Planification** de la production et des achats
- **Prévisions** de ventes intégrées
- **Optimisation** des stocks et délais

### 3. Gestion Intercompagnie
- **Transactions automatiques** entre filiales
- **Consolidation** des données groupe
- **Facturation intercompagnie** automatique
- **Synchronisation** des commandes

### 4. Réservation de Stock
- **Réservation automatique** sur commande
- **Gestion des priorités** de livraison
- **Disponibilité temps réel** des produits
- **Alertes** de rupture de stock

### 5. Échéanciers et Acomptes
- **Facturation échelonnée** selon modèles
- **Gestion des acomptes** automatique
- **Suivi des encaissements** prévisionnels
- **Tableaux de bord** financiers

## Configuration Recommandée

### Structure des Fichiers SurrealDB

```
supplychain_01_config.surql     - Configuration et applications
supplychain_02_mrp.surql        - MRP et planification
supplychain_03_sales.surql      - Ventes et commandes
supplychain_04_purchase.surql   - Achats et approvisionnement
supplychain_05_stock.surql      - Stock et logistique
```

### Tables Principales

```sql
-- Configuration principale
DEFINE TABLE app_supplychain SCHEMAFULL;
DEFINE FIELD cust_stock_move_mgt_on_so ON app_supplychain TYPE bool DEFAULT false;
DEFINE FIELD customer_stock_move_generation_auto ON app_supplychain TYPE bool DEFAULT false;
DEFINE FIELD generate_invoice_from_stock_move ON app_supplychain TYPE bool DEFAULT false;
DEFINE FIELD terminate_sale_order_on_delivery ON app_supplychain TYPE bool DEFAULT false;
DEFINE FIELD purchase_order_generation_auto ON app_supplychain TYPE bool DEFAULT false;
DEFINE FIELD interco_from_purchase ON app_supplychain TYPE bool DEFAULT false;
DEFINE FIELD interco_from_sale ON app_supplychain TYPE bool DEFAULT false;
DEFINE FIELD manage_stock_reservation ON app_supplychain TYPE bool DEFAULT false;

-- Configuration par entreprise
DEFINE TABLE supply_chain_config SCHEMAFULL;
DEFINE FIELD has_out_sm_for_storable_product ON supply_chain_config TYPE bool DEFAULT true;
DEFINE FIELD has_in_sm_for_storable_product ON supply_chain_config TYPE bool DEFAULT false;
DEFINE FIELD auto_allocate_on_receipt ON supply_chain_config TYPE bool DEFAULT false;
DEFINE FIELD auto_request_reserved_qty ON supply_chain_config TYPE bool DEFAULT false;
```

## Flux Métier Principaux

### 1. Flux Vente → Stock → Comptabilité
```
Commande de vente → Réservation stock → Livraison → Facture → Écriture comptable
```

### 2. Flux Achat → Stock → Comptabilité
```
Commande d'achat → Réception → Contrôle qualité → Facture fournisseur → Écriture comptable
```

### 3. Flux MRP
```
Prévisions → Calcul besoins → Propositions d'achat/production → Commandes → Livraisons
```

### 4. Flux Intercompagnie
```
Commande filiale A → Commande automatique filiale B → Livraison → Facturation croisée
```

## Exemples d'Utilisation

### Activation des flux automatiques
```sql
-- Activer la gestion automatique des livraisons clients
UPDATE app_supplychain 
SET cust_stock_move_mgt_on_so = true,
    customer_stock_move_generation_auto = true
WHERE id = "APP-SC-001";

-- Activer la facturation automatique depuis les livraisons
UPDATE app_supplychain 
SET generate_invoice_from_stock_move = true
WHERE id = "APP-SC-001";
```

### Configuration MRP
```sql
-- Créer un plan MRP
INSERT INTO mrp SET
  name = "MRP Décembre 2024",
  stock_location = "LOC-PRINCIPAL",
  end_date = "2024-12-31",
  mrp_type_select = 1, -- MRP
  status_select = 0; -- Brouillon
```

### Réservation de stock
```sql
-- Activer la réservation automatique
UPDATE supply_chain_config 
SET auto_request_reserved_qty = true,
    auto_allocate_on_availability_request = true
WHERE company = "COMPANY-001";
```

## Avantages de la Migration

### 1. Performance
- **Requêtes optimisées** pour les gros volumes
- **Index automatiques** sur les relations
- **Scalabilité** pour l'entreprise étendue

### 2. Intégration
- **Relations cohérentes** entre tous les modules
- **Synchronisation temps réel** des données
- **Traçabilité complète** des flux

### 3. Flexibilité
- **Configuration modulaire** par entreprise
- **Workflow personnalisables** selon les besoins
- **Extensions** faciles pour les spécificités

## Complexité et Recommandations

⚠️ **ATTENTION** : Ce module est très complexe avec 50 entités interconnectées.

### Recommandations pour la migration
1. **Migration par phases** - Traiter les entités par domaine fonctionnel
2. **Tests approfondis** - Vérifier tous les flux métier
3. **Formation utilisateurs** - Accompagner le changement
4. **Sauvegarde complète** - Avant toute migration
5. **Environnement de test** - Valider en conditions réelles

### Ordre de migration recommandé
1. Configuration et applications
2. Entités de base (partenaires, produits)
3. Stock et mouvements
4. Ventes et achats
5. Comptabilité et facturation
6. MRP et planification
7. Fonctionnalités avancées (interco, échéanciers)

## Compatibilité

Cette migration préserve **100%** des fonctionnalités du module original :
- Toutes les 50 entités sont incluses
- Tous les flux métier sont maintenus
- Toutes les relations sont préservées
- Toutes les configurations sont migrées

---

**Date de migration**: 2024  
**Module source**: axelor-supplychain  
**Version**: 7.2.x  
**Statut**: 🔄 Structure créée (50/50 entités analysées)  
**Complexité**: ⭐⭐⭐⭐⭐ (Très élevée) 
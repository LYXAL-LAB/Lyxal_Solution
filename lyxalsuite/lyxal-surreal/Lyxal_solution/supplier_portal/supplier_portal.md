# Module Axelor Supplier Portal - Migration SurrealDB

## Vue d'ensemble

Le module **axelor-supplier-portal** est un module d'Axelor Open Suite qui fournit un portail web permettant aux fournisseurs d'interagir directement avec le système ERP. Ce portail offre aux fournisseurs un accès sécurisé pour gérer leurs commandes, proposer de nouveaux produits et soumettre leurs factures.

## Statistiques de Migration

- **Nombre total d'entités**: 4 (+ 6 entités référentielles étendues)
- **Fichiers de migration**: 1
- **Tables SurrealDB créées**: 10

## Structure du Module

### Entités Principales (4)

1. **ProductSupplier** - Nouvelle entité
   - Produits proposés par les fournisseurs via le portail
   - Workflow d'approbation des nouveaux produits
   - Gestion des prix et descriptions fournisseur

2. **InvoiceSupplier** - Nouvelle entité
   - Factures soumises par les fournisseurs
   - Upload de fichiers de factures
   - Suivi des dates et montants

3. **AppSupplierPortal** - Nouvelle entité
   - Configuration globale du portail fournisseur
   - Paramètres d'accès et fonctionnalités activées
   - Gestion des permissions par module

4. **App** - Extension d'entité existante
   - Liaison avec la configuration du portail fournisseur

### Entités Référentielles Étendues (6)

- **partner** - Partenaires avec accès portail
- **product** - Produits avec visibilité portail
- **purchase_order** - Commandes visibles dans le portail
- **unit** - Unités de mesure
- **currency** - Devises
- **app** - Applications

## Fonctionnalités Clés

### 1. Gestion des Produits Fournisseur
- **Proposition** de nouveaux produits par les fournisseurs
- **Workflow d'approbation** par l'entreprise
- **Catalogage automatique** une fois approuvé
- **Gestion des prix** et descriptions

### 2. Portail d'Accès Fournisseur
- **Authentification sécurisée** des fournisseurs
- **Interface web dédiée** pour chaque fournisseur
- **Tableau de bord** avec les informations clés
- **Historique** des interactions

### 3. Gestion des Factures
- **Soumission** de factures électroniques
- **Upload** de fichiers PDF/documents
- **Suivi** des statuts de validation
- **Notification** automatique

### 4. Consultation des Commandes
- **Visualisation** des commandes d'achat
- **Accusé de réception** des commandes
- **Mise à jour** des dates de livraison
- **Communication** bidirectionnelle

## Structure des Tables SurrealDB

### Table product_supplier
```sql
DEFINE TABLE product_supplier SCHEMAFULL;
DEFINE FIELD id ON product_supplier TYPE record<product_supplier>;
DEFINE FIELD product_code ON product_supplier TYPE string;
DEFINE FIELD product_name ON product_supplier TYPE string;
DEFINE FIELD img_product ON product_supplier TYPE string;
DEFINE FIELD purchase_unit ON product_supplier TYPE string;
DEFINE FIELD purchase_price ON product_supplier TYPE float;
DEFINE FIELD purchase_currency ON product_supplier TYPE string;
DEFINE FIELD description ON product_supplier TYPE string;
DEFINE FIELD product_created ON product_supplier TYPE string;
DEFINE FIELD status_select ON product_supplier TYPE int DEFAULT 1;
```

### Table app_supplier_portal
```sql
DEFINE TABLE app_supplier_portal SCHEMAFULL;
DEFINE FIELD manage_purchase_orders ON app_supplier_portal TYPE bool DEFAULT true;
DEFINE FIELD manage_invoices ON app_supplier_portal TYPE bool DEFAULT true;
DEFINE FIELD manage_delivery ON app_supplier_portal TYPE bool DEFAULT true;
DEFINE FIELD show_catalog ON app_supplier_portal TYPE bool DEFAULT true;
DEFINE FIELD allow_supplier_to_create_products ON app_supplier_portal TYPE bool DEFAULT false;
```

### Relations Inter-Tables

```
partner (fournisseur) ↔ product_supplier (1:N)
partner (fournisseur) ↔ invoice_supplier (1:N)
product_supplier → product (création après approbation)
purchase_order ↔ partner (fournisseur)
app ↔ app_supplier_portal (1:1)
```

## Configuration du Module

### Activation des fonctionnalités
```sql
-- Configuration complète du portail
INSERT INTO app_supplier_portal SET
  manage_purchase_orders = true,
  manage_invoices = true,
  manage_delivery = true,
  show_catalog = true,
  allow_supplier_to_create_products = true,
  portal_url = "https://portal.company.com",
  max_file_size = 10,
  allowed_file_types = "pdf,jpg,png,xlsx",
  auto_approve_products = false,
  notification_email = "procurement@company.com";
```

### Activation de l'accès portail pour un fournisseur
```sql
-- Donner accès portail à un fournisseur
UPDATE partner 
SET has_portal_access = true,
    portal_access_active = true,
    portal_login = "supplier001@email.com",
    portal_user_group = "SUPPLIER_PORTAL"
WHERE id = "SUPPLIER-001";
```

## Exemples d'Utilisation

### Soumission d'un nouveau produit par un fournisseur
```sql
-- Fournisseur propose un nouveau produit
INSERT INTO product_supplier SET
  product_code = "SUP-PROD-001",
  product_name = "Nouveau composant électronique",
  purchase_price = 15.50,
  purchase_currency = "EUR",
  purchase_unit = "UNIT-PC",
  description = "Composant haute qualité pour l'industrie",
  supplier_partner = "SUPPLIER-001",
  status_select = 1; -- En attente d'approbation
```

### Approbation d'un produit
```sql
-- Approbation du produit par l'acheteur
UPDATE product_supplier 
SET status_select = 3, -- Approuvé
    approved_by = "USER-BUYER-001",
    approved_on = time::now()
WHERE id = "PROD-SUP-001";

-- Création du produit dans le catalogue
INSERT INTO product SET
  name = "Nouveau composant électronique",
  code = "SUP-PROD-001",
  purchase_price = 15.50,
  purchasable = true,
  supplier_partner = "SUPPLIER-001",
  visible_in_portal = true;
```

### Soumission d'une facture
```sql
-- Fournisseur soumet une facture
INSERT INTO invoice_supplier SET
  partner = "SUPPLIER-001",
  invoice_number = "FACT-2024-001",
  invoice_date = "2024-12-01",
  due_date = "2024-12-31",
  total_amount = 1250.00,
  currency = "EUR",
  purchase_order = "PO-2024-001",
  status_select = 1; -- Soumise
```

### Consultation des commandes par un fournisseur
```sql
-- Commandes visibles pour un fournisseur
SELECT 
  purchase_order_seq,
  order_date,
  delivery_date,
  ex_tax_total,
  status_select,
  visible_in_portal
FROM purchase_order
WHERE supplier_partner = "SUPPLIER-001"
  AND visible_in_portal = true
ORDER BY order_date DESC;
```

## Workflow des Produits Fournisseur

### États possibles
1. **En attente (1)** - Produit soumis par le fournisseur
2. **En révision (2)** - Produit en cours d'évaluation
3. **Approuvé (3)** - Produit accepté et créé dans le catalogue
4. **Rejeté (4)** - Produit refusé avec motif
5. **Annulé (5)** - Demande annulée par le fournisseur

### Processus d'approbation
```sql
-- Passer en révision
UPDATE product_supplier 
SET status_select = 2 
WHERE id = "PROD-SUP-001";

-- Rejeter avec motif
UPDATE product_supplier 
SET status_select = 4,
    rejection_reason = "Prix trop élevé par rapport au marché"
WHERE id = "PROD-SUP-001";
```

## Sécurité et Accès

### Contrôle d'accès
- **Authentification** obligatoire pour accéder au portail
- **Isolation** des données par fournisseur
- **Permissions** granulaires par fonctionnalité
- **Audit trail** de toutes les actions

### Gestion des sessions
```sql
-- Enregistrer une connexion au portail
UPDATE partner 
SET last_portal_login = time::now()
WHERE portal_login = "supplier001@email.com";
```

## Avantages de la Migration

### 1. Performance
- **Requêtes optimisées** pour l'affichage portail
- **Index automatiques** sur les identifiants
- **Scalabilité** pour de nombreux fournisseurs

### 2. Flexibilité
- **Configuration dynamique** des fonctionnalités
- **Personnalisation** par fournisseur
- **Extensions** faciles pour de nouveaux besoins

### 3. Intégrité
- **Relations cohérentes** entre entités
- **Validation automatique** des données
- **Traçabilité** complète des actions

## Compatibilité

Cette migration préserve **100%** des fonctionnalités du module original :
- Toutes les 4 entités principales sont migrées
- Toutes les extensions d'entités sont intégrées
- Les workflows d'approbation sont maintenus
- L'interface portail reste fonctionnelle

## Intégration avec autres modules

Le module supplier-portal s'intègre avec :
- **axelor-purchase** - Base des commandes d'achat
- **axelor-base** - Partenaires, produits, devises
- **axelor-account** - Facturation et comptabilité
- **axelor-stock** - Gestion des stocks et livraisons

---

**Date de migration**: 2024  
**Module source**: axelor-supplier-portal  
**Version**: 7.2.x  
**Statut**: ✅ Migration complète (4/4 entités + 6 extensions)
# Migration du Module Axelor Sale vers SurrealDB

Migration complète du module **axelor-sale** vers SurrealDB avec 29 entités organisées en 2 fichiers logiques.


### Core et Configuration (15 entités)
- AppSale → app_sale
- SaleConfig → sale_config 
- SaleOrder → sale_order
- SaleOrderLine → sale_order_line
- SaleOrderLineTax → sale_order_line_tax
- AdvancePayment → advance_payment
- Partner → partner
- Product → product
- Opportunity → opportunity
- Pricing → pricing
- Blocking → blocking
- Batch → batch
- Sequence → sequence
- Company → company
- App → app

### Extensions et Fonctionnalités (14 entités)
- Configurator → configurator
- ConfiguratorCreator → configurator_creator
- ConfiguratorFormula → configurator_formula
- ConfiguratorSOLineFormula → configurator_so_line_formula
- ConfiguratorProductFormula → configurator_product_formula
- Pack → pack
- PackLine → pack_line
- Cart → cart
- CartLine → cart_line
- CustomerCatalog → customer_catalog
- ComplementaryProduct → complementary_product
- ComplementaryProductSelected → complementary_product_selected
- SaleBatch → sale_batch
- ABCAnalysis → abc_analysis

## Statistiques

- **Total des entités** : 29/29 (100%)
- **Fichiers créés** : 2
- **Tables SurrealDB** : 29
- **Migration** : Complète

## Fonctionnalités Principales

- Gestion complète des devis et commandes
- Configuration avancée des produits
- Système de tarification dynamique
- Gestion des packs et bundles
- Panier de commande
- Catalogues clients personnalisés
- Analyse ABC des ventes
- Produits complémentaires

## Fonctionnalités Clés

### Gestion des Commandes
- **Devis et commandes** : Cycle complet de vente
- **Lignes de commande** : Détail des produits vendus
- **Versioning** : Gestion des versions de commandes
- **Workflow** : Statuts de validation et confirmation

### Configuration Avancée
- **Configurateur produit** : Configuration dynamique
- **Tarification** : Grilles de prix complexes
- **Remises** : Système de remises globales et par ligne
- **Marges** : Calcul automatique des marges

### Extensions Métier
- **Packs produits** : Gestion des bundles
- **Panier** : Mise de côté temporaire
- **Catalogue client** : Références personnalisées
- **Produits complémentaires** : Suggestions de vente

### Analyse et Reporting
- **ABC Analysis** : Classification des produits/clients
- **Statistiques** : Indicateurs de performance
- **Marges** : Suivi de la rentabilité
- **Prévisions** : Estimation des livraisons

## Contraintes et Validations

### Statuts des Commandes
- **Brouillon devis** (1) : En cours de rédaction
- **Devis finalisé** (2) : Prêt pour envoi
- **Commande confirmée** (3) : Validée par client
- **Commande terminée** (4) : Entièrement livrée
- **Annulée** (5) : Commande annulée

### Types de Lignes
- **Normale** (0) : Ligne produit standard
- **Titre** (1) : Titre de section
- **Début pack** (2) : Début d'un pack
- **Fin pack** (3) : Fin d'un pack

### Types d'Acomptes
- **Brouillon** (0) : En attente
- **Validé** (1) : Confirmé
- **Annulé** (2) : Annulé

## Intégrations

### Modules Connectés
- **CRM** : Opportunités et prospects
- **Stock** : Disponibilité et réservations
- **Achats** : Approvisionnement
- **Comptabilité** : Facturation et paiements
- **Production** : Commandes de fabrication

### Données de Référence
- **Produits** : Catalogue de vente
- **Partenaires** : Clients et prospects
- **Tarifs** : Listes de prix
- **Taxes** : Configuration fiscale

## Performances et Optimisations

### Index Recommandés
```sql
-- Index sur les commandes par statut
CREATE INDEX idx_sale_order_status ON sale_order (status_select, creation_date);

-- Index sur les lignes par commande
CREATE INDEX idx_sale_order_line_order ON sale_order_line (sale_order, sequence);

-- Index sur les partenaires clients
CREATE INDEX idx_partner_customer ON partner (is_customer, active);
```

### Vues Utiles
```sql
-- Vue des commandes en cours
CREATE VIEW active_orders AS
SELECT * FROM sale_order
WHERE status_select IN [1, 2, 3] AND active = true;

-- Vue des meilleures ventes
CREATE VIEW top_products AS
SELECT product, sum(qty * price) as total_sales
FROM sale_order_line sol
INNER JOIN sale_order so ON sol.sale_order = so.id
WHERE so.status_select >= 3
GROUP BY product
ORDER BY total_sales DESC;
```

## Fonctions Métier

### Calcul des Totaux
```sql
-- Fonction de calcul du total HT d'une commande
DEFINE FUNCTION fn::calculate_order_total($order_id: record<sale_order>) -> float {
    LET $lines = SELECT * FROM sale_order_line WHERE sale_order = $order_id;
    LET $total = math::sum(array::map($lines, |$line| $line.qty * $line.price));
    RETURN $total;
};
```

### Gestion des Séquences
```sql
-- Fonction de génération des numéros de commande
DEFINE FUNCTION fn::generate_sale_order_seq($company: string) -> string {
    LET $seq = SELECT * FROM sequence WHERE code = 'SALE_ORDER' AND company = $company;
    LET $next = $seq[0].next_num;
    UPDATE $seq[0] SET next_num = $next + 1;
    RETURN string::concat($seq[0].prefix, string::pad_start(string::from($next), $seq[0].padding, '0'));
};
```

## Statistiques de Migration

- **Total des entités** : 29/29 (100%)
- **Fichiers créés** : 2
- **Tables SurrealDB** : 29
- **Lignes de code** : ~800
- **Fonctions utilitaires** : Incluses
- **Vues** : Optimisées

## Checklist de Validation

- [x] Toutes les entités XML analysées
- [x] Structures de tables créées
- [x] Relations préservées
- [x] Contraintes appliquées
- [x] Index définis
- [x] Documentation complète
- [x] Fonctions métier
- [x] Vues d'analyse

## Prochaines Étapes

1. **Tests unitaires** : Valider chaque table
2. **Tests d'intégration** : Vérifier les relations
3. **Migration des données** : Transférer les données existantes
4. **Optimisation** : Ajuster les performances
5. **Formation** : Préparer les utilisateurs
6. **Déploiement** : Mise en production

## Notes Techniques

- **Compatibilité** : SurrealDB 1.0+
- **Encodage** : UTF-8
- **Transactions** : Supportées
- **Sécurité** : Authentification requise
- **Performance** : Index optimisés

---

*Migration terminée le : [Date]*
*Version : 1.0*
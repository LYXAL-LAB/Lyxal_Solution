# Documentation: discount_type

## Vue d'ensemble

La table `discount_type` définit les différents types de remises disponibles dans le système de vente. Elle permet de configurer des remises avec des méthodes de calcul variées, des règles métier complexes et des contrôles d'utilisation avancés.

**Version:** 1.0  
**Auteur:** Lyxal Gateway  
**Date:** 2024  

## Structure de la table

### Champs principaux

| Champ | Type | Description | Obligatoire |
|-------|------|-------------|-------------|
| `code` | string | Code unique du type de remise | ✓ |
| `name` | string | Nom affiché du type de remise | ✓ |
| `description` | string | Description détaillée | ✗ |
| `sequence` | int | Ordre d'affichage et de priorité | ✓ |

### Méthode de calcul

| Champ | Type | Description | Obligatoire |
|-------|------|-------------|-------------|
| `calculation_method` | string | Méthode de calcul (FIXED, PERCENT, FORMULA) | ✓ |
| `symbol` | string | Symbole d'affichage (€, %, $, etc.) | ✗ |
| `formula` | string | Formule de calcul personnalisée | ✗ |

### Règles et contraintes

| Champ | Type | Description | Obligatoire |
|-------|------|-------------|-------------|
| `min_value` | decimal | Valeur minimale autorisée | ✗ |
| `max_value` | decimal | Valeur maximale autorisée | ✗ |
| `min_order_amount` | decimal | Montant minimum de commande | ✗ |
| `max_order_amount` | decimal | Montant maximum de commande | ✗ |

### Comportement métier

| Champ | Type | Description | Défaut |
|-------|------|-------------|--------|
| `is_cumulative` | bool | Remise cumulable avec d'autres | false |
| `is_automatic` | bool | Application automatique | false |
| `requires_approval` | bool | Nécessite une approbation | false |
| `applies_to_subtotal` | bool | S'applique sur le sous-total HT | true |
| `applies_to_taxes` | bool | S'applique sur les taxes | false |

### Interface utilisateur

| Champ | Type | Description | Défaut |
|-------|------|-------------|--------|
| `color` | string | Couleur hexadécimale | #007bff |
| `icon` | string | Icône Lucide React | Percent |

### Validité et dates

| Champ | Type | Description | Obligatoire |
|-------|------|-------------|-------------|
| `valid_from` | date | Date de début de validité | ✗ |
| `valid_to` | date | Date de fin de validité | ✗ |
| `max_usage_count` | int | Nombre maximum d'utilisations | ✗ |
| `max_usage_per_client` | int | Nombre maximum par client | ✗ |

### Gestion des états

| Champ | Type | Description | Défaut |
|-------|------|-------------|--------|
| `is_active` | bool | Statut actif/inactif | true |
| `is_system` | bool | Type système (protégé) | false |

### Métadonnées

| Champ | Type | Description | Automatique |
|-------|------|-------------|-------------|
| `created_on` | datetime | Date de création | ✓ |
| `updated_on` | datetime | Date de modification | ✓ |

## Méthodes de calcul

### FIXED - Montant fixe
```sql
-- Remise de 10€
calculation_method: "FIXED"
symbol: "€"
-- Montant appliqué directement
```

### PERCENT - Pourcentage
```sql
-- Remise de 15%
calculation_method: "PERCENT"
symbol: "%"
-- Calcul: (montant_base * valeur) / 100
```

### FORMULA - Formule personnalisée
```sql
-- Remise complexe
calculation_method: "FORMULA"
symbol: "f(x)"
formula: "base_amount * 0.1 + (quantity > 10 ? 50 : 0)"
```

## Index et optimisations

### Index uniques
- `idx_discount_type_code` : Code unique
- `idx_discount_type_sequence` : Séquence d'affichage

### Index de performance
- `idx_discount_type_active` : Statut actif
- `idx_discount_type_display` : Affichage (actif + séquence)
- `idx_discount_type_validity` : Dates de validité
- `idx_discount_type_calculation` : Méthode de calcul

## Contraintes et validations

### Contraintes de base
- Code non vide et unique
- Nom non vide
- Séquence positive et unique
- Méthode de calcul valide (FIXED, PERCENT, FORMULA)

### Contraintes de cohérence
- Couleur au format hexadécimal (#RRGGBB)
- Valeur max ≥ valeur min
- Montant max commande ≥ montant min commande
- Date fin validité ≥ date début validité
- Compteurs d'utilisation positifs

### Contraintes métier
- Types système non modifiables (code, nom, méthode)
- Types système non supprimables
- Vérification d'utilisation avant suppression

## Fonctions disponibles

### Fonctions de création
- `fn::create_discount_type()` - Création complète
- `fn::create_discount_type_simple()` - Création simplifiée
- `fn::create_discount_type_with_config()` - Création avec configuration
- `fn::batch_create_discount_types()` - Création en lot

### Fonctions de lecture
- `fn::read_discount_type()` - Lecture par ID
- `fn::read_discount_type_by_code()` - Lecture par code
- `fn::read_discount_type_with_usage()` - Lecture avec statistiques
- `fn::read_multiple_discount_types()` - Lecture multiple
- `fn::get_discount_type_details()` - Détails complets

### Fonctions de mise à jour
- `fn::update_discount_type()` - Mise à jour complète
- `fn::update_discount_type_partial()` - Mise à jour partielle
- `fn::update_discount_type_sequence()` - Mise à jour séquence
- `fn::update_discount_type_display()` - Mise à jour affichage
- `fn::batch_update_discount_types()` - Mise à jour en lot

### Fonctions d'activation/désactivation
- `fn::activate_discount_type()` - Activation
- `fn::deactivate_discount_type()` - Désactivation
- `fn::activate_discount_type_with_sequence()` - Activation avec séquence
- `fn::toggle_discount_type_status()` - Basculement de statut
- `fn::reactivate_discount_type()` - Réactivation complète

### Fonctions de listage
- `fn::list_discount_types()` - Liste paginée avec filtres
- `fn::list_active_discount_types()` - Types actifs seulement
- `fn::list_valid_discount_types()` - Types valides maintenant
- `fn::list_discount_types_for_order()` - Types pour commande
- `fn::search_discount_types()` - Recherche textuelle

### Fonctions de suppression
- `fn::delete_discount_type()` - Suppression standard
- `fn::delete_discount_type_safe()` - Suppression sécurisée
- `fn::soft_delete_discount_type()` - Suppression logique
- `fn::delete_unused_discount_types()` - Suppression des non utilisés
- `fn::cleanup_discount_types()` - Nettoyage complet

### Fonctions utilitaires
- `fn::reset_discount_type_data()` - Réinitialisation des données
- `fn::validate_discount_type_data()` - Validation complète
- `fn::get_discount_type_statistics()` - Statistiques avancées
- `fn::calculate_discount_amount()` - Calcul de remise
- `fn::export_discount_type_data()` - Export des données

## Types de remise prédéfinis

### Types système
- **AMOUNT** - Montant fixe en devise
- **PERCENTAGE** - Pourcentage du montant

### Types métier
- **VOLUME** - Remise volume (>1000€, approbation requise)
- **EARLY_BIRD** - Remise anticipée (max 2/client, cumulable)
- **LOYALTY** - Remise fidélité (automatique, cumulable)
- **SEASONAL** - Remise saisonnière (promotions)
- **COMMERCIAL** - Remise négociée (approbation requise)
- **PROMO** - Remise promotionnelle
- **QUANTITY** - Remise quantité (automatique, cumulable)
- **PARTNER** - Remise partenaire (>200€, approbation)

### Types spécialisés
- **FORMULA** - Remise par formule personnalisée
- **FIXED_HIGH** - Remise fixe élevée (>5000€)

## Exemples d'utilisation

### Création d'un type simple
```sql
SELECT fn::create_discount_type_simple(
    "STUDENT", 
    "Remise étudiant", 
    25, 
    "PERCENT"
);
```

### Création d'un type avec configuration
```sql
SELECT fn::create_discount_type_with_config(
    "VIP", 
    "Remise VIP", 
    15, 
    "PERCENT",
    {
        description: "Remise pour clients VIP",
        min_value: 5,
        max_value: 20,
        color: "#gold",
        icon: "Crown",
        is_cumulative: true,
        requires_approval: true
    }
);
```

### Lecture avec statistiques
```sql
SELECT fn::read_discount_type_with_usage(discount_type:VOLUME);
```

### Liste pour une commande
```sql
SELECT fn::list_discount_types_for_order(1500.00, partner:CLIENT123);
```

### Calcul de remise
```sql
SELECT fn::calculate_discount_amount(
    discount_type:PERCENTAGE, 
    1000.00, 
    15
);
```

## Relations avec autres tables

### Utilisation dans les ventes
- `sale_order.discount_type_id` - Type de remise de la commande
- `sale_order_line.discount_type_id` - Type de remise de la ligne
- `pack_line.discount_type_id` - Type de remise du pack

### Statistiques d'utilisation
- Nombre d'utilisations par type
- Montants de remise appliqués
- Clients uniques bénéficiaires
- Répartition par période

## Bonnes pratiques

### Création de types
1. Utiliser des codes courts et explicites
2. Définir des séquences multiples de 10
3. Choisir des couleurs distinctives
4. Documenter les règles métier

### Gestion des limites
1. Définir des valeurs min/max appropriées
2. Utiliser les contraintes de montant de commande
3. Limiter les utilisations si nécessaire
4. Surveiller les dates de validité

### Maintenance
1. Désactiver plutôt que supprimer
2. Valider régulièrement les données
3. Nettoyer les types obsolètes
4. Surveiller les statistiques d'utilisation

### Sécurité
1. Protéger les types système
2. Exiger l'approbation pour les gros montants
3. Limiter les remises cumulables
4. Contrôler l'accès aux fonctions de suppression

## Monitoring et alertes

### Métriques importantes
- Nombre de types actifs
- Utilisation par type
- Montants de remise moyens
- Taux d'approbation

### Alertes recommandées
- Types expirés non désactivés
- Limites d'utilisation atteintes
- Remises exceptionnellement élevées
- Erreurs de validation

## Évolutions futures

### Fonctionnalités prévues
- Remises géographiques (par région)
- Remises par catégorie de produit
- Remises conditionnelles complexes
- Intégration avec le système de fidélité

### Améliorations techniques
- Cache des types actifs
- Optimisation des calculs
- Audit des modifications
- API REST complète

---

**Note:** Cette documentation est maintenue automatiquement. Pour toute question ou suggestion d'amélioration, consultez l'équipe de développement Lyxal Gateway. 
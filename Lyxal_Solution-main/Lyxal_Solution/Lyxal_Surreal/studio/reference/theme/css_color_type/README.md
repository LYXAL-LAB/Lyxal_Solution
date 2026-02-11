# Types de Couleurs CSS - Seeds

## Vue d'ensemble

Ce dossier contient les données de base (seeds) pour les types de couleurs CSS utilisés dans le système Database-Driven.

## Fichiers

### `color_types_base.surql`
**22 types de couleurs de base** organisés par catégories :

#### Semantic Colors (7 types)
- `primary` - Couleur principale de l'interface
- `secondary` - Couleur secondaire complémentaire
- `error` - Couleur pour les erreurs et problèmes
- `warning` - Couleur pour les avertissements
- `success` - Couleur pour les succès et validations
- `info` - Couleur pour les informations générales
- `accent` - Couleur d'accentuation complémentaire

#### UI Colors (4 types)
- `background` - Couleur de fond principale
- `surface` - Couleur des surfaces élevées (cartes, panneaux)
- `border` - Couleur des bordures et séparateurs
- `text` - Couleur du texte principal

#### State Colors (4 types)
- `hover` - État au survol de la souris
- `focus` - Élément focalisé au clavier
- `active` - Élément actuellement actif/sélectionné
- `disabled` - Éléments non interactifs

#### Neutral Colors (4 types)
- `gray` - Échelle de gris (50-900)
- `white` - Blanc pur
- `black` - Noir pur
- `transparent` - Valeur complètement transparente

#### Brand Colors (2 types)
- `brand_primary` - Couleur principale de la marque
- `brand_secondary` - Couleur secondaire de la marque

#### Custom Colors (1 type)
- `custom` - Couleur personnalisée définie par l'utilisateur

## Utilisation

### Import des données de base
```bash
# Importer les types de couleurs de base
surreal import color_types_base.surql
```

### Vérifications post-import
```sql
-- Nombre total de types
SELECT count() FROM css_color_type;

-- Répartition par catégorie
SELECT context.category, count() FROM css_color_type GROUP BY context.category;

-- Types système actifs
SELECT identity.value FROM css_color_type WHERE config.is_system_type = true ORDER BY status.order;
```

## Structure des données

Chaque type de couleur définit :
- **Identity** : nom technique et slug URL-friendly
- **Presentation** : clés i18n pour l'interface
- **Context** : catégorie, usage, signification sémantique
- **Config** : propriétés techniques (variants, alpha, système)
- **Status** : état actif, ordre d'affichage

## Évolution

### Ajouter un nouveau type de couleur
```sql
CREATE css_color_type:my_custom_color SET
  identity = { value = "my_custom", slug = "my-custom" },
  context = { category = "custom" },
  config = { is_system_type = false },
  status = { is_active = true, order = 99 };
```

### Modifier un type existant
```sql
UPDATE css_color_type:primary SET
  context.usage_hints = array::push(context.usage_hints, "new_usage");
```

## Intégration

Ces types de couleurs sont utilisés par :
- `css_theme_color_mapping` : pour définir les palettes de couleurs des thèmes
- `css_design_token` : pour typer les tokens de couleur
- L'interface d'administration : pour présenter les options de couleur

## Maintenance

- **Types système** (`is_system_type = true`) : ne pas modifier sans migration
- **Ordre d'affichage** (`status.order`) : définit l'ordre dans les interfaces
- **Clés i18n** : nécessaires pour l'internationalisation

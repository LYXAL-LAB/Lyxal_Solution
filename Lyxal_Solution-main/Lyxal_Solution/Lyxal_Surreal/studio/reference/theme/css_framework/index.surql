-- ============================================================================
-- INDEX : Frameworks CSS Disponibles
-- Description : Catalogue complet des frameworks CSS supportés
-- Usage : Import ce fichier pour charger tous les frameworks
-- ============================================================================

-- ============================================================================
-- TAILWIND CSS - Framework par défaut
-- ============================================================================

-- Import du framework Tailwind
-- (Contenu dans tailwind.surql)

-- ============================================================================
-- BOOTSTRAP - Framework alternatif
-- ============================================================================

-- Import du framework Bootstrap
-- (Contenu dans bootstrap.surql)

-- ============================================================================
-- MATERIAL DESIGN - Framework alternatif
-- ============================================================================

-- Import du framework Material Design
-- (Contenu dans material_design.surql)

-- ============================================================================
-- VÉRIFICATIONS POST-IMPORT
-- ============================================================================

-- Vérifier que tous les frameworks sont importés
-- SELECT
--   identity.value as framework,
--   status.is_default as is_default,
--   status.is_active as is_active,
--   metadata.order as display_order
-- FROM css_framework
-- ORDER BY metadata.order;

-- ============================================================================
-- STATISTIQUES
-- ============================================================================

-- Nombre total de frameworks : 3
-- Framework par défaut : tailwind
-- Frameworks actifs : 3
-- Types représentés : utility_first (1), component_based (2)

-- ============================================================================
-- FICHIERS DE RÉFÉRENCE TECHNIQUE - SYSTÈME CSS DATABASE-DRIVEN
-- ============================================================================

-- Documentation i18n intégrée
-- Fichier : README.md (section dédiée)
-- Description : Documentation complète des 6 clés i18n et 30 traductions
-- Statut : Documentation centralisée - voir README.md

-- Clés i18n (prêtes à importer)
-- Fichier : ../i18n/css_framework_keys.surql
-- Description : 6 clés i18n pour les noms et descriptions des frameworks
-- Statut : Prêt à importer - RELATE dans i18n_key

-- Traductions i18n (prêtes à importer)
-- Fichier : ../i18n/css_framework_translations.surql
-- Description : 30 traductions i18n (6 clés × 5 langues)
-- Statut : Prêt à importer - RELATE dans translation

-- Tables de Classification (prêtes à importer)
-- Fichier : ../token_categories_base.surql
-- Description : 5 catégories de base (spacing, typography, layout, component, utility)
-- Statut : Prêt à importer - CREATE dans css_token_category
--
-- Fichier : ../token_subcategories_base.surql
-- Description : 17 sous-catégories (font-size, padding, border-radius, etc.)
-- Statut : Prêt à importer - CREATE dans css_token_subcategory
--
-- Fichier : ../css_color_type.surql
-- Description : Types de couleur CSS (primary, error, info, success, etc.)
-- Statut : Définition de table - prêt à créer
--
-- Fichier : ../css_theme_color_mapping.surql
-- Description : Mapping thèmes ↔ types de couleurs
-- Statut : Définition de table - prêt à créer
--
-- Fichier : ../theme_mode.surql
-- Description : Modes de thème (light, dark, auto)
-- Statut : Définition de table - prêt à créer

-- Design Tokens (prêts à importer)
-- Fichier : design_tokens_default.surql
-- Description : 61 design tokens CSS globaux (espacement, typo, layout, composants, utilitaires)
-- Statut : Prêt à importer - CREATE dans css_token_design (tokens globaux is_default=true)

-- Éléments CSS Dictionary (prêts à importer)
-- Fichier : css_dictionary_elements.surql
-- Description : 47 éléments UI abstraits (boutons, inputs, cards, etc.)
-- Statut : Prêt à importer - CREATE dans css_dictionary

-- Composants UI (approche "riche et stricte")
-- Fichier : ../css/components_base.surql
-- Description : 23 composants UI de base (interactive, layout, content, navigation, feedback, data_display)
-- Statut : Prêt à importer - CREATE dans css_component (normalisation des composants)
--
-- Design Tokens par Composant (approche "riche et stricte")
-- Fichier : ../css/component_tokens_base.surql
-- Description : 37 design tokens dédiés par composant (14 button + 11 card + 12 layout)
-- Statut : Prêt à importer - CREATE dans css_token_design (tokens spécialisés par composant)
--
-- Documentation : ../css/component_tokens_README.md
-- Description : Documentation complète de l'approche "riche et stricte" par composant
-- Statut : Documentation technique - Décision architecturale validée
--
-- Refactorisation : ../css/REFACTORING_STRING_TO_RECORD.md
-- Description : Explication de la refactorisation string→record pour les composants
-- Statut : Documentation technique - Amélioration architecturale majeure

-- Index des icônes à créer (documentation)
-- Fichier : icons_to_create.surql
-- Description : Liste des 6 icônes framework à créer sur Bunny CDN
-- Statut : Documentation technique - À créer quand logos uploadés

-- Index des URLs à créer (documentation)
-- Fichier : urls_to_create.surql
-- Description : Liste des ~15 URLs (CDN + Bunny) à créer
-- Statut : Documentation technique - À créer après configuration CDN

-- ============================================================================
-- ÉVOLUTION FUTURE
-- ============================================================================

-- Frameworks à ajouter potentiellement :
-- - Bulma (component_based)
-- - Foundation (component_based)
-- - Semantic UI (component_based)
-- - Chakra UI (component_based)
-- - Ant Design (component_based)
-- - Custom CSS (css_variables)

-- Pour ajouter un nouveau framework :
-- 1. Créer les icônes et URLs (voir icons_to_create.surql et urls_to_create.surql)
-- 2. Créer les clés i18n (framework_[name]_name, framework_[name]_description)
-- 3. Créer le fichier [framework].surql
-- 4. L'ajouter dans cet index
-- 5. Tester l'intégration avec css_framework_mapping

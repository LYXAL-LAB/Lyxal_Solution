-- ============================================================================
-- CLÉS I18N : Frameworks CSS
-- Description : Clés de traduction pour les frameworks CSS supportés
-- Context : css_framework
-- ============================================================================

-- ============================================================================
-- TAILWIND CSS
-- ============================================================================

-- Nom du framework Tailwind
CREATE i18n_key:framework_tailwind_name SET
  context = "css_framework",
  description = "Nom d'affichage du framework Tailwind CSS";

-- Description du framework Tailwind
CREATE i18n_key:framework_tailwind_description SET
  context = "css_framework",
  description = "Description détaillée du framework Tailwind CSS";

-- ============================================================================
-- BOOTSTRAP CSS
-- ============================================================================

-- Nom du framework Bootstrap
CREATE i18n_key:framework_bootstrap_name SET
  context = "css_framework",
  description = "Nom d'affichage du framework Bootstrap CSS";

-- Description du framework Bootstrap
CREATE i18n_key:framework_bootstrap_description SET
  context = "css_framework",
  description = "Description détaillée du framework Bootstrap CSS";

-- ============================================================================
-- MATERIAL DESIGN
-- ============================================================================

-- Nom du framework Material Design
CREATE i18n_key:framework_material_name SET
  context = "css_framework",
  description = "Nom d'affichage du framework Material Design";

-- Description du framework Material Design
CREATE i18n_key:framework_material_description SET
  context = "css_framework",
  description = "Description détaillée du framework Material Design";

-- ============================================================================
-- VÉRIFICATIONS POST-IMPORT
-- ============================================================================

-- Lister toutes les clés i18n des frameworks CSS
-- SELECT
--   id,
--   context,
--   description
-- FROM i18n_key
-- WHERE context = "css_framework"
-- ORDER BY id;

-- Compter les clés créées
-- SELECT count() FROM i18n_key WHERE context = "css_framework";

-- ============================================================================
-- TRADUCTIONS À CRÉER (dans i18n_translation)
-- ============================================================================

-- Pour chaque langue supportée (fr, en, es, etc.), créer :
--
-- Français (fr) :
-- framework_tailwind_name → "Tailwind CSS"
-- framework_tailwind_description → "Framework CSS utility-first moderne"
-- framework_bootstrap_name → "Bootstrap"
-- framework_bootstrap_description → "Framework CSS component-based populaire"
-- framework_material_name → "Material Design"
-- framework_material_description → "Framework basé sur les guidelines Google"
--
-- Anglais (en) :
-- framework_tailwind_name → "Tailwind CSS"
-- framework_tailwind_description → "Modern utility-first CSS framework"
-- framework_bootstrap_name → "Bootstrap"
-- framework_bootstrap_description → "Popular component-based CSS framework"
-- framework_material_name → "Material Design"
-- framework_material_description → "Framework based on Google guidelines"
--
-- Etc. pour les autres langues supportées

-- ============================================================================
-- USAGE DANS LES FRAMEWORKS
-- ============================================================================

-- Ces clés sont utilisées dans css_framework.presentation :
--
-- presentation = {
--   name_i18n = i18n_key:framework_tailwind_name,
--   description_i18n = i18n_key:framework_tailwind_description
-- }

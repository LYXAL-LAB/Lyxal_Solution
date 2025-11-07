-- ============================================================================
-- TRADUCTIONS : Frameworks CSS
-- Description : Traductions i18n pour les frameworks CSS supportés
-- Langues : Français, Anglais, Italien, Espagnol, Allemand
-- Syntaxe : RELATE (table relation)
-- ============================================================================

-- ============================================================================
-- FRANÇAIS (fr)
-- ============================================================================

-- Tailwind CSS - Nom
RELATE i18n_key:framework_tailwind_name->translation->language:fr SET text = "Tailwind CSS";

-- Tailwind CSS - Description
RELATE i18n_key:framework_tailwind_description->translation->language:fr SET text = "Framework CSS utility-first moderne et flexible";

-- Bootstrap - Nom
RELATE i18n_key:framework_bootstrap_name->translation->language:fr SET text = "Bootstrap";

-- Bootstrap - Description
RELATE i18n_key:framework_bootstrap_description->translation->language:fr SET text = "Framework CSS component-based populaire avec JavaScript";

-- Material Design - Nom
RELATE i18n_key:framework_material_name->translation->language:fr SET text = "Material Design";

-- Material Design - Description
RELATE i18n_key:framework_material_description->translation->language:fr SET text = "Framework basé sur les guidelines Material Design de Google";

-- ============================================================================
-- ANGLAIS (en)
-- ============================================================================

-- Tailwind CSS - Nom
RELATE i18n_key:framework_tailwind_name->translation->language:en SET text = "Tailwind CSS";

-- Tailwind CSS - Description
RELATE i18n_key:framework_tailwind_description->translation->language:en SET text = "Modern and flexible utility-first CSS framework";

-- Bootstrap - Nom
RELATE i18n_key:framework_bootstrap_name->translation->language:en SET text = "Bootstrap";

-- Bootstrap - Description
RELATE i18n_key:framework_bootstrap_description->translation->language:en SET text = "Popular component-based CSS framework with JavaScript";

-- Material Design - Nom
RELATE i18n_key:framework_material_name->translation->language:en SET text = "Material Design";

-- Material Design - Description
RELATE i18n_key:framework_material_description->translation->language:en SET text = "Framework based on Google's Material Design guidelines";

-- ============================================================================
-- ITALIEN (it)
-- ============================================================================

-- Tailwind CSS - Nom
RELATE i18n_key:framework_tailwind_name->translation->language:it SET text = "Tailwind CSS";

-- Tailwind CSS - Description
RELATE i18n_key:framework_tailwind_description->translation->language:it SET text = "Framework CSS utility-first moderno e flessibile";

-- Bootstrap - Nom
RELATE i18n_key:framework_bootstrap_name->translation->language:it SET text = "Bootstrap";

-- Bootstrap - Description
RELATE i18n_key:framework_bootstrap_description->translation->language:it SET text = "Framework CSS basato su componenti popolare con JavaScript";

-- Material Design - Nom
RELATE i18n_key:framework_material_name->translation->language:it SET text = "Material Design";

-- Material Design - Description
RELATE i18n_key:framework_material_description->translation->language:it SET text = "Framework basato sulle linee guida Material Design di Google";

-- ============================================================================
-- ESPAGNOL (es)
-- ============================================================================

-- Tailwind CSS - Nom
RELATE i18n_key:framework_tailwind_name->translation->language:es SET text = "Tailwind CSS";

-- Tailwind CSS - Description
RELATE i18n_key:framework_tailwind_description->translation->language:es SET text = "Framework CSS utility-first moderno y flexible";

-- Bootstrap - Nom
RELATE i18n_key:framework_bootstrap_name->translation->language:es SET text = "Bootstrap";

-- Bootstrap - Description
RELATE i18n_key:framework_bootstrap_description->translation->language:es SET text = "Framework CSS basado en componentes popular con JavaScript";

-- Material Design - Nom
RELATE i18n_key:framework_material_name->translation->language:es SET text = "Material Design";

-- Material Design - Description
RELATE i18n_key:framework_material_description->translation->language:es SET text = "Framework basado en las directrices de Material Design de Google";

-- ============================================================================
-- ALLEMAND (de)
-- ============================================================================

-- Tailwind CSS - Nom
RELATE i18n_key:framework_tailwind_name->translation->language:de SET text = "Tailwind CSS";

-- Tailwind CSS - Description
RELATE i18n_key:framework_tailwind_description->translation->language:de SET text = "Modernes und flexibles Utility-First CSS Framework";

-- Bootstrap - Nom
RELATE i18n_key:framework_bootstrap_name->translation->language:de SET text = "Bootstrap";

-- Bootstrap - Description
RELATE i18n_key:framework_bootstrap_description->translation->language:de SET text = "Beliebtes komponentenbasiertes CSS Framework mit JavaScript";

-- Material Design - Nom
RELATE i18n_key:framework_material_name->translation->language:de SET text = "Material Design";

-- Material Design - Description
RELATE i18n_key:framework_material_description->translation->language:de SET text = "Framework basierend auf Googles Material Design Richtlinien";

-- ============================================================================
-- VÉRIFICATIONS POST-IMPORT
-- ============================================================================

-- Compter les traductions créées (30 relations attendues)
-- SELECT count() FROM translation
-- WHERE string::starts_with(in.id, "framework_");
-- Résultat attendu : 30 (6 clés × 5 langues)

-- Lister toutes les traductions des frameworks CSS
-- SELECT
--   in.id as i18n_key,
--   out.code as language,
--   text as translation
-- FROM translation
-- WHERE string::starts_with(in.id, "framework_")
-- ORDER BY in.id, out.code;

-- Vérifier l'intégrité par clé i18n
-- SELECT
--   in.id as i18n_key,
--   count(out) as translations_count,
--   array::distinct(out.code) as languages
-- FROM translation
-- WHERE string::starts_with(in.id, "framework_")
-- GROUP BY in.id
-- ORDER BY in.id;
-- Résultat attendu : 6 clés, chacune avec 5 traductions (fr, en, it, es, de)

-- Vérifier par langue
-- SELECT
--   out.code as language,
--   count(in) as translations_count,
--   array::distinct(in.id) as keys
-- FROM translation
-- WHERE string::starts_with(in.id, "framework_")
-- GROUP BY out.code
-- ORDER BY out.code;
-- Résultat attendu : 5 langues, chacune avec 6 traductions

-- ============================================================================
-- NOTES D'UTILISATION
-- ============================================================================

-- Ces traductions sont créées via des RELATE statements car `translation`
-- est une table RELATION entre `i18n_key` (in) et `language` (out).
--
-- Syntaxe : RELATE [clé_i18n]->translation->[langue] SET text = "..."
--
-- Utilisation automatique :
-- - Sélecteur de framework CSS : noms traduits selon langue utilisateur
-- - Info-bulles : descriptions traduites automatiquement
-- - Interface admin : contenu multilingue natif

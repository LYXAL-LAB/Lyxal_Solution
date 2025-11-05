-- ===== AFFINITY I18N TRANSLATIONS =====
-- ===== Date: 2025-11-05 =====
-- ===== Langues: FR, EN, IT, DE, ES =====
-- ===== Total: 5 traductions =====

BEGIN

-- AFFINITY PROVIDER
-- AFFINITY NAME
RELATE i18n_key:provider_affinity_name->translation->language:fr SET text = "AFFINITY";
RELATE i18n_key:provider_affinity_name->translation->language:en SET text = "AFFINITY";
RELATE i18n_key:provider_affinity_name->translation->language:it SET text = "AFFINITY";
RELATE i18n_key:provider_affinity_name->translation->language:de SET text = "AFFINITY";
RELATE i18n_key:provider_affinity_name->translation->language:es SET text = "AFFINITY";

-- AFFINITY DESCRIPTION
RELATE i18n_key:provider_affinity_description->translation->language:fr SET text = "AFFINITY Provider";
RELATE i18n_key:provider_affinity_description->translation->language:en SET text = "AFFINITY Provider";
RELATE i18n_key:provider_affinity_description->translation->language:it SET text = "AFFINITY Provider";
RELATE i18n_key:provider_affinity_description->translation->language:de SET text = "AFFINITY Provider";
RELATE i18n_key:provider_affinity_description->translation->language:es SET text = "AFFINITY Provider";

-- AFFINITY TOOLTIP
RELATE i18n_key:provider_affinity_tooltip->translation->language:fr SET text = "Pour AFFINITY";
RELATE i18n_key:provider_affinity_tooltip->translation->language:en SET text = "For AFFINITY";
RELATE i18n_key:provider_affinity_tooltip->translation->language:it SET text = "Per AFFINITY";
RELATE i18n_key:provider_affinity_tooltip->translation->language:de SET text = "Für AFFINITY";
RELATE i18n_key:provider_affinity_tooltip->translation->language:es SET text = "Para AFFINITY";

COMMIT;
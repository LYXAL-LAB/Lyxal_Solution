-- ===== BOX I18N TRANSLATIONS =====
-- ===== Date: 2025-11-05 =====
-- ===== Langues: FR, EN, IT, DE, ES =====
-- ===== Total: 5 traductions =====

BEGIN

-- BOX PROVIDER
-- BOX NAME
RELATE i18n_key:provider_box_name->translation->language:fr SET text = "BOX";
RELATE i18n_key:provider_box_name->translation->language:en SET text = "BOX";
RELATE i18n_key:provider_box_name->translation->language:it SET text = "BOX";
RELATE i18n_key:provider_box_name->translation->language:de SET text = "BOX";
RELATE i18n_key:provider_box_name->translation->language:es SET text = "BOX";

-- BOX DESCRIPTION
RELATE i18n_key:provider_box_description->translation->language:fr SET text = "BOX Provider";
RELATE i18n_key:provider_box_description->translation->language:en SET text = "BOX Provider";
RELATE i18n_key:provider_box_description->translation->language:it SET text = "BOX Provider";
RELATE i18n_key:provider_box_description->translation->language:de SET text = "BOX Provider";
RELATE i18n_key:provider_box_description->translation->language:es SET text = "BOX Provider";

-- BOX TOOLTIP
RELATE i18n_key:provider_box_tooltip->translation->language:fr SET text = "Pour BOX";
RELATE i18n_key:provider_box_tooltip->translation->language:en SET text = "For BOX";
RELATE i18n_key:provider_box_tooltip->translation->language:it SET text = "Per BOX";
RELATE i18n_key:provider_box_tooltip->translation->language:de SET text = "Für BOX";
RELATE i18n_key:provider_box_tooltip->translation->language:es SET text = "Para BOX";

COMMIT;
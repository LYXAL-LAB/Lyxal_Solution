-- ===== CAL I18N TRANSLATIONS =====
-- ===== Date: 2025-11-05 =====
-- ===== Langues: FR, EN, IT, DE, ES =====
-- ===== Total: 5 traductions =====

BEGIN

-- CAL PROVIDER
-- CAL NAME
RELATE i18n_key:provider_cal_name->translation->language:fr SET text = "CAL";
RELATE i18n_key:provider_cal_name->translation->language:en SET text = "CAL";
RELATE i18n_key:provider_cal_name->translation->language:it SET text = "CAL";
RELATE i18n_key:provider_cal_name->translation->language:de SET text = "CAL";
RELATE i18n_key:provider_cal_name->translation->language:es SET text = "CAL";

-- CAL DESCRIPTION
RELATE i18n_key:provider_cal_description->translation->language:fr SET text = "CAL Provider";
RELATE i18n_key:provider_cal_description->translation->language:en SET text = "CAL Provider";
RELATE i18n_key:provider_cal_description->translation->language:it SET text = "CAL Provider";
RELATE i18n_key:provider_cal_description->translation->language:de SET text = "CAL Provider";
RELATE i18n_key:provider_cal_description->translation->language:es SET text = "CAL Provider";

-- CAL TOOLTIP
RELATE i18n_key:provider_cal_tooltip->translation->language:fr SET text = "Pour CAL";
RELATE i18n_key:provider_cal_tooltip->translation->language:en SET text = "For CAL";
RELATE i18n_key:provider_cal_tooltip->translation->language:it SET text = "Per CAL";
RELATE i18n_key:provider_cal_tooltip->translation->language:de SET text = "Für CAL";
RELATE i18n_key:provider_cal_tooltip->translation->language:es SET text = "Para CAL";

COMMIT;
-- ===== AMQP I18N TRANSLATIONS =====
-- ===== Date: 2025-11-05 =====
-- ===== Langues: FR, EN, IT, DE, ES =====
-- ===== Total: 5 traductions =====

BEGIN

-- AMQP PROVIDER
-- AMQP NAME
RELATE i18n_key:provider_amqp_name->translation->language:fr SET text = "AMQP";
RELATE i18n_key:provider_amqp_name->translation->language:en SET text = "AMQP";
RELATE i18n_key:provider_amqp_name->translation->language:it SET text = "AMQP";
RELATE i18n_key:provider_amqp_name->translation->language:de SET text = "AMQP";
RELATE i18n_key:provider_amqp_name->translation->language:es SET text = "AMQP";

-- AMQP DESCRIPTION
RELATE i18n_key:provider_amqp_description->translation->language:fr SET text = "AMQP Provider";
RELATE i18n_key:provider_amqp_description->translation->language:en SET text = "AMQP Provider";
RELATE i18n_key:provider_amqp_description->translation->language:it SET text = "AMQP Provider";
RELATE i18n_key:provider_amqp_description->translation->language:de SET text = "AMQP Provider";
RELATE i18n_key:provider_amqp_description->translation->language:es SET text = "AMQP Provider";

-- AMQP TOOLTIP
RELATE i18n_key:provider_amqp_tooltip->translation->language:fr SET text = "Pour AMQP";
RELATE i18n_key:provider_amqp_tooltip->translation->language:en SET text = "For AMQP";
RELATE i18n_key:provider_amqp_tooltip->translation->language:it SET text = "Per AMQP";
RELATE i18n_key:provider_amqp_tooltip->translation->language:de SET text = "Für AMQP";
RELATE i18n_key:provider_amqp_tooltip->translation->language:es SET text = "Para AMQP";

COMMIT;
-- ===== AWS I18N TRANSLATIONS =====
-- ===== Date: 2025-11-05 =====
-- ===== Langues: FR, EN, IT, DE, ES =====
-- ===== Total: 5 traductions =====

BEGIN

-- AWS PROVIDER
-- AWS NAME
RELATE i18n_key:provider_aws_name->translation->language:fr SET text = "AWS";
RELATE i18n_key:provider_aws_name->translation->language:en SET text = "AWS";
RELATE i18n_key:provider_aws_name->translation->language:it SET text = "AWS";
RELATE i18n_key:provider_aws_name->translation->language:de SET text = "AWS";
RELATE i18n_key:provider_aws_name->translation->language:es SET text = "AWS";

-- AWS DESCRIPTION
RELATE i18n_key:provider_aws_description->translation->language:fr SET text = "AWS Provider";
RELATE i18n_key:provider_aws_description->translation->language:en SET text = "AWS Provider";
RELATE i18n_key:provider_aws_description->translation->language:it SET text = "AWS Provider";
RELATE i18n_key:provider_aws_description->translation->language:de SET text = "AWS Provider";
RELATE i18n_key:provider_aws_description->translation->language:es SET text = "AWS Provider";

-- AWS TOOLTIP
RELATE i18n_key:provider_aws_tooltip->translation->language:fr SET text = "Pour AWS";
RELATE i18n_key:provider_aws_tooltip->translation->language:en SET text = "For AWS";
RELATE i18n_key:provider_aws_tooltip->translation->language:it SET text = "Per AWS";
RELATE i18n_key:provider_aws_tooltip->translation->language:de SET text = "Für AWS";
RELATE i18n_key:provider_aws_tooltip->translation->language:es SET text = "Para AWS";

COMMIT;
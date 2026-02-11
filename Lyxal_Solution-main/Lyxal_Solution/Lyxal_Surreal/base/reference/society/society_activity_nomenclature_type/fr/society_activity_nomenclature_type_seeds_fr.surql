-- =================================================================================================
-- SEEDS: society_activity_nomenclature_type
-- =================================================================================================

CREATE society_activity_nomenclature_type:nafrev2 SET
    code = 'NAFRev2',
    name_i18n_key = i18n_key:society_activity_nomenclature_type_nafrev2_name,
    description_i18n_key = i18n_key:society_activity_nomenclature_type_nafrev2_description,
    period_start = 2008,
    period_end = NONE,
    is_active = true,
    sort_order = 1,
    pays_reference = country:fr;

CREATE society_activity_nomenclature_type:nafrev1 SET
    code = 'NAFRev1',
    name_i18n_key = i18n_key:society_activity_nomenclature_type_nafrev1_name,
    description_i18n_key = i18n_key:society_activity_nomenclature_type_nafrev1_description,
    period_start = 2003,
    period_end = 2008,
    is_active = false,
    sort_order = 2,
    pays_reference = country:fr;

CREATE society_activity_nomenclature_type:naf1993 SET
    code = 'NAF1993',
    name_i18n_key = i18n_key:society_activity_nomenclature_type_naf1993_name,
    description_i18n_key = i18n_key:society_activity_nomenclature_type_naf1993_description,
    period_start = 1993,
    period_end = 2003,
    is_active = false,
    sort_order = 3,
    pays_reference = country:fr;

CREATE society_activity_nomenclature_type:nap SET
    code = 'NAP',
    name_i18n_key = i18n_key:society_activity_nomenclature_type_nap_name,
    description_i18n_key = i18n_key:society_activity_nomenclature_type_nap_description,
    period_start = 1973,
    period_end = 1993,
    is_active = false,
    sort_order = 4,
    pays_reference = country:fr;
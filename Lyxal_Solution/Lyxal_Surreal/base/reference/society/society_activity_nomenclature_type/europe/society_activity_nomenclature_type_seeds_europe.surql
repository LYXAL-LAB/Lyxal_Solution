-- =================================================================================================
-- SEEDS: society_activity_nomenclature_type (EUROPE - NACE)
-- Nomenclature statistique des Activités économiques dans la Communauté Européenne (Eurostat)
-- =================================================================================================

CREATE society_activity_nomenclature_type:nace_rev2_1 SET
    code = 'NACE_Rev2.1',
    name_i18n_key = i18n_key:society_activity_nomenclature_type_nace_rev2_1_name,
    description_i18n_key = i18n_key:society_activity_nomenclature_type_nace_rev2_1_description,
    period_start = 2008,
    period_end = NONE,
    is_active = true,
    sort_order = 1,
    pays_reference = NONE;

CREATE society_activity_nomenclature_type:nace_rev1_1 SET
    code = 'NACE_Rev1.1',
    name_i18n_key = i18n_key:society_activity_nomenclature_type_nace_rev1_1_name,
    description_i18n_key = i18n_key:society_activity_nomenclature_type_nace_rev1_1_description,
    period_start = 2002,
    period_end = 2008,
    is_active = false,
    sort_order = 2,
    pays_reference = NONE;

CREATE society_activity_nomenclature_type:nace_rev1 SET
    code = 'NACE_Rev1',
    name_i18n_key = i18n_key:society_activity_nomenclature_type_nace_rev1_name,
    description_i18n_key = i18n_key:society_activity_nomenclature_type_nace_rev1_description,
    period_start = 1990,
    period_end = 2002,
    is_active = false,
    sort_order = 3,
    pays_reference = NONE;


-- =================================================================================================
-- SEEDS: society_activity_nomenclature (INTERNATIONAL - ISIC)
-- International Standard Industrial Classification of All Economic Activities (UN)
-- =================================================================================================

CREATE society_activity_nomenclature_type:isic_rev4 SET
    code = 'ISIC_Rev4',
    name_i18n_key = i18n_key:society_activity_nomenclature_type_isic_rev4_name,
    description_i18n_key = i18n_key:society_activity_nomenclature_type_isic_rev4_description,
    period_start = 2008,
    period_end = NONE,
    is_active = true,
    sort_order = 1,
    pays_reference = NONE;

CREATE society_activity_nomenclature_type:isic_rev3_1 SET
    code = 'ISIC_Rev3.1',
    name_i18n_key = i18n_key:society_activity_nomenclature_type_isic_rev3_1_name,
    description_i18n_key = i18n_key:society_activity_nomenclature_type_isic_rev3_1_description,
    period_start = 2002,
    period_end = 2008,
    is_active = false,
    sort_order = 2,
    pays_reference = NONE;

CREATE society_activity_nomenclature_type:isic_rev3 SET
    code = 'ISIC_Rev3',
    name_i18n_key = i18n_key:society_activity_nomenclature_type_isic_rev3_name,
    description_i18n_key = i18n_key:society_activity_nomenclature_type_isic_rev3_description,
    period_start = 1990,
    period_end = 2002,
    is_active = false,
    sort_order = 3,
    pays_reference = NONE;

CREATE society_activity_nomenclature_type:isic_rev2 SET
    code = 'ISIC_Rev2',
    name_i18n_key = i18n_key:society_activity_nomenclature_type_isic_rev2_name,
    description_i18n_key = i18n_key:society_activity_nomenclature_type_isic_rev2_description,
    period_start = 1968,
    period_end = 1990,
    is_active = false,
    sort_order = 4,
    pays_reference = NONE;
-- =================================================================================================
-- SEEDS: business_administrative_status
-- Total: 2 statuts
-- =================================================================================================

CREATE business_administrative_status:status_a SET
    code = 'A',
    name_i18n_key = i18n_key:i18n_admin_status_a_name,
    description_i18n_key = i18n_key:i18n_admin_status_a_description,
    is_active = true,
    sort_order = 1;

CREATE business_administrative_status:status_c SET
    code = 'C',
    name_i18n_key = i18n_key:i18n_admin_status_c_name,
    description_i18n_key = i18n_key:i18n_admin_status_c_description,
    is_active = false,
    sort_order = 2;


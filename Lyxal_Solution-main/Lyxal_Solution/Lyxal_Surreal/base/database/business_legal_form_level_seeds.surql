-- =================================================================================================
-- SEEDS: business_legal_form_level
-- =================================================================================================

CREATE business_legal_form_level:level_1 SET
    code = 'level_1',
    name_i18n_key = i18n_key:i18n_legal_form_level_level_1_name,
    description_i18n_key = i18n_key:i18n_legal_form_level_level_1_description,
    level_number = 1,
    code_length = 1,
    is_terminal = false,
    sort_order = 1;

CREATE business_legal_form_level:level_2 SET
    code = 'level_2',
    name_i18n_key = i18n_key:i18n_legal_form_level_level_2_name,
    description_i18n_key = i18n_key:i18n_legal_form_level_level_2_description,
    level_number = 2,
    code_length = 2,
    is_terminal = false,
    sort_order = 2;

CREATE business_legal_form_level:level_3 SET
    code = 'level_3',
    name_i18n_key = i18n_key:i18n_legal_form_level_level_3_name,
    description_i18n_key = i18n_key:i18n_legal_form_level_level_3_description,
    level_number = 3,
    code_length = 4,
    is_terminal = true,
    sort_order = 3;


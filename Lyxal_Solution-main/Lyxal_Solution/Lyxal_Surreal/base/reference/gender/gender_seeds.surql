-- =================================================================================================
-- SEEDS: gender
-- Total: 3 genres
-- =================================================================================================

CREATE gender:gender_m SET
    code = 'M',
    name_i18n_key = i18n_key:gender_m_name,
    sort_order = 1;

CREATE gender:gender_f SET
    code = 'F',
    name_i18n_key = i18n_key:gender_f_name,
    sort_order = 2;

CREATE gender:gender_nd SET
    code = 'ND',
    name_i18n_key = i18n_key:gender_nd_name,
    sort_order = 3;


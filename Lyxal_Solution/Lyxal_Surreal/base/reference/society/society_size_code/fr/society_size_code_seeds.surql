-- =================================================================================================
-- SEEDS: society_size_code (France - TEFET)
-- Total: 14 tranches d'effectifs (nomenclature officielle TEFET INSEE)
-- Source: Documentation INSEE - Champ TEFET
-- =================================================================================================

-- Non diffusé / Non déterminé
CREATE society_size_code:fr_tefet_nn SET
    code = 'NN',
    size_nomenclature_code = society_size_nomenclature:tefet,
    name_i18n_key = i18n_key:society_size_code_nn_name,
    min_employees = NONE,
    max_employees = NONE,
    sort_order = 0;

-- 0 salarié (entrepreneur individuel sans salarié)
CREATE society_size_code:fr_tefet_00 SET
    code = '00',
    size_nomenclature_code = society_size_nomenclature:tefet,
    name_i18n_key = i18n_key:society_size_code_00_name,
    min_employees = 0,
    max_employees = 0,
    sort_order = 1;

-- 1 ou 2 salariés
CREATE society_size_code:fr_tefet_01 SET
    code = '01',
    size_nomenclature_code = society_size_nomenclature:tefet,
    name_i18n_key = i18n_key:society_size_code_01_name,
    min_employees = 1,
    max_employees = 2,
    sort_order = 2;

-- 3 à 5 salariés
CREATE society_size_code:fr_tefet_02 SET
    code = '02',
    size_nomenclature_code = society_size_nomenclature:tefet,
    name_i18n_key = i18n_key:society_size_code_02_name,
    min_employees = 3,
    max_employees = 5,
    sort_order = 3;

-- 6 à 9 salariés
CREATE society_size_code:fr_tefet_03 SET
    code = '03',
    size_nomenclature_code = society_size_nomenclature:tefet,
    name_i18n_key = i18n_key:society_size_code_03_name,
    min_employees = 6,
    max_employees = 9,
    sort_order = 4;

-- 10 à 19 salariés
CREATE society_size_code:fr_tefet_11 SET
    code = '11',
    size_nomenclature_code = society_size_nomenclature:tefet,
    name_i18n_key = i18n_key:society_size_code_11_name,
    min_employees = 10,
    max_employees = 19,
    sort_order = 5;

-- 20 à 49 salariés
CREATE society_size_code:fr_tefet_12 SET
    code = '12',
    size_nomenclature_code = society_size_nomenclature:tefet,
    name_i18n_key = i18n_key:society_size_code_12_name,
    min_employees = 20,
    max_employees = 49,
    sort_order = 6;

-- 50 à 99 salariés
CREATE society_size_code:fr_tefet_21 SET
    code = '21',
    size_nomenclature_code = society_size_nomenclature:tefet,
    name_i18n_key = i18n_key:society_size_code_21_name,
    min_employees = 50,
    max_employees = 99,
    sort_order = 7;

-- 100 à 199 salariés
CREATE society_size_code:fr_tefet_22 SET
    code = '22',
    size_nomenclature_code = society_size_nomenclature:tefet,
    name_i18n_key = i18n_key:society_size_code_22_name,
    min_employees = 100,
    max_employees = 199,
    sort_order = 8;

-- 200 à 499 salariés
CREATE society_size_code:fr_tefet_31 SET
    code = '31',
    size_nomenclature_code = society_size_nomenclature:tefet,
    name_i18n_key = i18n_key:society_size_code_31_name,
    min_employees = 200,
    max_employees = 499,
    sort_order = 9;

-- 500 à 999 salariés
CREATE society_size_code:fr_tefet_41 SET
    code = '41',
    size_nomenclature_code = society_size_nomenclature:tefet,
    name_i18n_key = i18n_key:society_size_code_41_name,
    min_employees = 500,
    max_employees = 999,
    sort_order = 10;

-- 1 000 à 1 999 salariés
CREATE society_size_code:fr_tefet_42 SET
    code = '42',
    size_nomenclature_code = society_size_nomenclature:tefet,
    name_i18n_key = i18n_key:society_size_code_42_name,
    min_employees = 1000,
    max_employees = 1999,
    sort_order = 11;

-- 2 000 à 4 999 salariés
CREATE society_size_code:fr_tefet_51 SET
    code = '51',
    size_nomenclature_code = society_size_nomenclature:tefet,
    name_i18n_key = i18n_key:society_size_code_51_name,
    min_employees = 2000,
    max_employees = 4999,
    sort_order = 12;

-- 5 000 salariés ou plus
CREATE society_size_code:fr_tefet_52 SET
    code = '52',
    size_nomenclature_code = society_size_nomenclature:tefet,
    name_i18n_key = i18n_key:society_size_code_52_name,
    min_employees = 5000,
    max_employees = NONE,
    sort_order = 13;

-- =================================================================================================
-- SEEDS: society_activity_code (INTERNATIONAL - ISIC)
-- Total: 2,108 codes
-- =================================================================================================

-- -------------------------------------------------------------------------------------------------
-- ISIC_Rev4 (766 codes)
-- -------------------------------------------------------------------------------------------------

CREATE society_activity_code:isic_rev4_a SET
    code = 'A',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:section,
    pays_reference = NONE,
    parent_code = NONE,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_a_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_01 SET
    code = '01',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_a,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_01_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_011 SET
    code = '011',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_01,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_011_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_0111 SET
    code = '0111',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_011,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_0111_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_0112 SET
    code = '0112',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_011,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_0112_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_0113 SET
    code = '0113',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_011,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_0113_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_0114 SET
    code = '0114',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_011,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_0114_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_0115 SET
    code = '0115',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_011,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_0115_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_0116 SET
    code = '0116',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_011,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_0116_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_0119 SET
    code = '0119',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_011,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_0119_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_012 SET
    code = '012',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_01,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_012_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_0121 SET
    code = '0121',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_012,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_0121_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_0122 SET
    code = '0122',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_012,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_0122_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_0123 SET
    code = '0123',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_012,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_0123_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_0124 SET
    code = '0124',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_012,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_0124_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_0125 SET
    code = '0125',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_012,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_0125_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_0126 SET
    code = '0126',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_012,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_0126_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_0127 SET
    code = '0127',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_012,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_0127_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_0128 SET
    code = '0128',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_012,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_0128_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_0129 SET
    code = '0129',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_012,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_0129_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_013 SET
    code = '013',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_01,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_013_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_0130 SET
    code = '0130',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_013,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_0130_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_014 SET
    code = '014',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_01,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_014_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_0141 SET
    code = '0141',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_014,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_0141_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_0142 SET
    code = '0142',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_014,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_0142_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_0143 SET
    code = '0143',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_014,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_0143_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_0144 SET
    code = '0144',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_014,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_0144_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_0145 SET
    code = '0145',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_014,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_0145_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_0146 SET
    code = '0146',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_014,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_0146_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_0149 SET
    code = '0149',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_014,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_0149_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_015 SET
    code = '015',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_01,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_015_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_0150 SET
    code = '0150',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_015,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_0150_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_016 SET
    code = '016',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_01,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_016_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_0161 SET
    code = '0161',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_016,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_0161_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_0162 SET
    code = '0162',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_016,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_0162_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_0163 SET
    code = '0163',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_016,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_0163_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_0164 SET
    code = '0164',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_016,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_0164_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_017 SET
    code = '017',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_01,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_017_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_0170 SET
    code = '0170',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_017,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_0170_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_02 SET
    code = '02',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_a,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_02_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_021 SET
    code = '021',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_02,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_021_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_0210 SET
    code = '0210',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_021,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_0210_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_022 SET
    code = '022',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_02,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_022_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_0220 SET
    code = '0220',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_022,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_0220_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_023 SET
    code = '023',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_02,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_023_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_0230 SET
    code = '0230',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_023,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_0230_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_024 SET
    code = '024',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_02,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_024_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_0240 SET
    code = '0240',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_024,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_0240_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_03 SET
    code = '03',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_a,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_03_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_031 SET
    code = '031',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_03,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_031_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_0311 SET
    code = '0311',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_031,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_0311_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_0312 SET
    code = '0312',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_031,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_0312_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_032 SET
    code = '032',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_03,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_032_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_0321 SET
    code = '0321',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_032,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_0321_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_0322 SET
    code = '0322',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_032,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_0322_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_b SET
    code = 'B',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:section,
    pays_reference = NONE,
    parent_code = NONE,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_b_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_05 SET
    code = '05',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_b,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_05_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_051 SET
    code = '051',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_05,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_051_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_0510 SET
    code = '0510',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_051,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_0510_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_052 SET
    code = '052',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_05,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_052_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_0520 SET
    code = '0520',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_052,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_0520_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_06 SET
    code = '06',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_b,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_06_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_061 SET
    code = '061',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_06,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_061_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_0610 SET
    code = '0610',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_061,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_0610_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_062 SET
    code = '062',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_06,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_062_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_0620 SET
    code = '0620',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_062,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_0620_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_07 SET
    code = '07',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_b,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_07_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_071 SET
    code = '071',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_07,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_071_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_0710 SET
    code = '0710',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_071,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_0710_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_072 SET
    code = '072',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_07,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_072_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_0721 SET
    code = '0721',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_072,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_0721_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_0729 SET
    code = '0729',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_072,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_0729_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_08 SET
    code = '08',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_b,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_08_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_081 SET
    code = '081',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_08,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_081_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_0810 SET
    code = '0810',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_081,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_0810_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_089 SET
    code = '089',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_08,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_089_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_0891 SET
    code = '0891',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_089,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_0891_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_0892 SET
    code = '0892',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_089,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_0892_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_0893 SET
    code = '0893',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_089,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_0893_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_0899 SET
    code = '0899',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_089,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_0899_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_09 SET
    code = '09',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_b,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_09_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_091 SET
    code = '091',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_09,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_091_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_0910 SET
    code = '0910',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_091,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_0910_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_099 SET
    code = '099',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_09,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_099_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_0990 SET
    code = '0990',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_099,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_0990_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_c SET
    code = 'C',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:section,
    pays_reference = NONE,
    parent_code = NONE,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_c_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_10 SET
    code = '10',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_c,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_10_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_101 SET
    code = '101',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_10,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_101_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_1010 SET
    code = '1010',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_101,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_1010_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_102 SET
    code = '102',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_10,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_102_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_1020 SET
    code = '1020',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_102,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_1020_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_103 SET
    code = '103',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_10,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_103_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_1030 SET
    code = '1030',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_103,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_1030_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_104 SET
    code = '104',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_10,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_104_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_1040 SET
    code = '1040',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_104,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_1040_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_105 SET
    code = '105',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_10,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_105_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_1050 SET
    code = '1050',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_105,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_1050_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_106 SET
    code = '106',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_10,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_106_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_1061 SET
    code = '1061',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_106,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_1061_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_1062 SET
    code = '1062',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_106,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_1062_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_107 SET
    code = '107',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_10,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_107_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_1071 SET
    code = '1071',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_107,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_1071_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_1072 SET
    code = '1072',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_107,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_1072_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_1073 SET
    code = '1073',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_107,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_1073_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_1074 SET
    code = '1074',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_107,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_1074_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_1075 SET
    code = '1075',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_107,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_1075_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_1079 SET
    code = '1079',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_107,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_1079_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_108 SET
    code = '108',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_10,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_108_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_1080 SET
    code = '1080',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_108,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_1080_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_11 SET
    code = '11',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_c,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_11_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_110 SET
    code = '110',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_11,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_110_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_1101 SET
    code = '1101',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_110,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_1101_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_1102 SET
    code = '1102',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_110,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_1102_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_1103 SET
    code = '1103',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_110,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_1103_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_1104 SET
    code = '1104',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_110,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_1104_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_12 SET
    code = '12',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_c,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_12_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_120 SET
    code = '120',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_12,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_120_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_1200 SET
    code = '1200',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_120,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_1200_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_13 SET
    code = '13',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_c,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_13_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_131 SET
    code = '131',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_13,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_131_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_1311 SET
    code = '1311',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_131,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_1311_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_1312 SET
    code = '1312',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_131,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_1312_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_1313 SET
    code = '1313',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_131,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_1313_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_139 SET
    code = '139',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_13,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_139_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_1391 SET
    code = '1391',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_139,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_1391_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_1392 SET
    code = '1392',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_139,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_1392_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_1393 SET
    code = '1393',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_139,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_1393_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_1394 SET
    code = '1394',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_139,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_1394_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_1399 SET
    code = '1399',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_139,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_1399_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_14 SET
    code = '14',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_c,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_14_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_141 SET
    code = '141',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_14,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_141_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_1410 SET
    code = '1410',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_141,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_1410_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_142 SET
    code = '142',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_14,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_142_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_1420 SET
    code = '1420',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_142,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_1420_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_143 SET
    code = '143',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_14,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_143_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_1430 SET
    code = '1430',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_143,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_1430_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_15 SET
    code = '15',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_c,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_15_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_151 SET
    code = '151',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_15,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_151_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_1511 SET
    code = '1511',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_151,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_1511_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_1512 SET
    code = '1512',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_151,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_1512_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_152 SET
    code = '152',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_15,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_152_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_1520 SET
    code = '1520',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_152,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_1520_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_16 SET
    code = '16',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_c,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_16_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_161 SET
    code = '161',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_16,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_161_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_1610 SET
    code = '1610',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_161,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_1610_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_162 SET
    code = '162',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_16,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_162_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_1621 SET
    code = '1621',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_162,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_1621_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_1622 SET
    code = '1622',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_162,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_1622_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_1623 SET
    code = '1623',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_162,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_1623_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_1629 SET
    code = '1629',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_162,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_1629_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_17 SET
    code = '17',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_c,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_17_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_170 SET
    code = '170',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_17,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_170_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_1701 SET
    code = '1701',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_170,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_1701_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_1702 SET
    code = '1702',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_170,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_1702_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_1709 SET
    code = '1709',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_170,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_1709_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_18 SET
    code = '18',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_c,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_18_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_181 SET
    code = '181',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_18,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_181_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_1811 SET
    code = '1811',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_181,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_1811_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_1812 SET
    code = '1812',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_181,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_1812_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_182 SET
    code = '182',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_18,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_182_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_1820 SET
    code = '1820',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_182,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_1820_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_19 SET
    code = '19',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_c,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_19_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_191 SET
    code = '191',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_19,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_191_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_1910 SET
    code = '1910',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_191,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_1910_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_192 SET
    code = '192',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_19,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_192_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_1920 SET
    code = '1920',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_192,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_1920_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_20 SET
    code = '20',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_c,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_20_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_201 SET
    code = '201',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_20,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_201_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_2011 SET
    code = '2011',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_201,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_2011_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_2012 SET
    code = '2012',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_201,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_2012_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_2013 SET
    code = '2013',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_201,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_2013_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_202 SET
    code = '202',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_20,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_202_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_2021 SET
    code = '2021',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_202,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_2021_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_2022 SET
    code = '2022',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_202,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_2022_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_2023 SET
    code = '2023',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_202,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_2023_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_2029 SET
    code = '2029',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_202,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_2029_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_203 SET
    code = '203',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_20,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_203_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_2030 SET
    code = '2030',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_203,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_2030_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_21 SET
    code = '21',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_c,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_21_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_210 SET
    code = '210',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_21,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_210_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_2100 SET
    code = '2100',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_210,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_2100_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_22 SET
    code = '22',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_c,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_22_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_221 SET
    code = '221',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_22,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_221_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_2211 SET
    code = '2211',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_221,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_2211_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_2219 SET
    code = '2219',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_221,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_2219_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_222 SET
    code = '222',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_22,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_222_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_2220 SET
    code = '2220',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_222,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_2220_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_23 SET
    code = '23',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_c,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_23_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_231 SET
    code = '231',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_23,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_231_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_2310 SET
    code = '2310',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_231,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_2310_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_239 SET
    code = '239',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_23,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_239_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_2391 SET
    code = '2391',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_239,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_2391_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_2392 SET
    code = '2392',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_239,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_2392_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_2393 SET
    code = '2393',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_239,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_2393_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_2394 SET
    code = '2394',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_239,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_2394_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_2395 SET
    code = '2395',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_239,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_2395_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_2396 SET
    code = '2396',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_239,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_2396_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_2399 SET
    code = '2399',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_239,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_2399_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_24 SET
    code = '24',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_c,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_24_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_241 SET
    code = '241',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_24,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_241_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_2410 SET
    code = '2410',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_241,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_2410_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_242 SET
    code = '242',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_24,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_242_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_2420 SET
    code = '2420',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_242,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_2420_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_243 SET
    code = '243',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_24,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_243_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_2431 SET
    code = '2431',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_243,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_2431_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_2432 SET
    code = '2432',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_243,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_2432_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_25 SET
    code = '25',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_c,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_25_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_251 SET
    code = '251',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_25,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_251_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_2511 SET
    code = '2511',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_251,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_2511_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_2512 SET
    code = '2512',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_251,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_2512_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_2513 SET
    code = '2513',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_251,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_2513_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_252 SET
    code = '252',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_25,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_252_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_2520 SET
    code = '2520',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_252,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_2520_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_259 SET
    code = '259',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_25,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_259_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_2591 SET
    code = '2591',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_259,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_2591_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_2592 SET
    code = '2592',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_259,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_2592_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_2593 SET
    code = '2593',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_259,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_2593_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_2599 SET
    code = '2599',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_259,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_2599_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_26 SET
    code = '26',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_c,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_26_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_261 SET
    code = '261',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_26,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_261_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_2610 SET
    code = '2610',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_261,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_2610_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_262 SET
    code = '262',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_26,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_262_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_2620 SET
    code = '2620',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_262,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_2620_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_263 SET
    code = '263',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_26,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_263_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_2630 SET
    code = '2630',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_263,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_2630_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_264 SET
    code = '264',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_26,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_264_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_2640 SET
    code = '2640',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_264,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_2640_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_265 SET
    code = '265',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_26,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_265_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_2651 SET
    code = '2651',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_265,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_2651_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_2652 SET
    code = '2652',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_265,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_2652_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_266 SET
    code = '266',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_26,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_266_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_2660 SET
    code = '2660',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_266,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_2660_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_267 SET
    code = '267',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_26,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_267_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_2670 SET
    code = '2670',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_267,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_2670_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_268 SET
    code = '268',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_26,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_268_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_2680 SET
    code = '2680',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_268,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_2680_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_27 SET
    code = '27',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_c,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_27_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_271 SET
    code = '271',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_27,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_271_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_2710 SET
    code = '2710',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_271,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_2710_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_272 SET
    code = '272',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_27,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_272_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_2720 SET
    code = '2720',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_272,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_2720_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_273 SET
    code = '273',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_27,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_273_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_2731 SET
    code = '2731',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_273,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_2731_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_2732 SET
    code = '2732',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_273,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_2732_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_2733 SET
    code = '2733',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_273,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_2733_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_274 SET
    code = '274',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_27,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_274_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_2740 SET
    code = '2740',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_274,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_2740_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_275 SET
    code = '275',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_27,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_275_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_2750 SET
    code = '2750',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_275,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_2750_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_279 SET
    code = '279',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_27,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_279_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_2790 SET
    code = '2790',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_279,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_2790_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_28 SET
    code = '28',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_c,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_28_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_281 SET
    code = '281',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_28,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_281_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_2811 SET
    code = '2811',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_281,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_2811_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_2812 SET
    code = '2812',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_281,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_2812_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_2813 SET
    code = '2813',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_281,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_2813_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_2814 SET
    code = '2814',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_281,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_2814_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_2815 SET
    code = '2815',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_281,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_2815_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_2816 SET
    code = '2816',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_281,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_2816_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_2817 SET
    code = '2817',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_281,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_2817_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_2818 SET
    code = '2818',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_281,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_2818_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_2819 SET
    code = '2819',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_281,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_2819_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_282 SET
    code = '282',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_28,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_282_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_2821 SET
    code = '2821',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_282,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_2821_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_2822 SET
    code = '2822',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_282,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_2822_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_2823 SET
    code = '2823',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_282,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_2823_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_2824 SET
    code = '2824',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_282,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_2824_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_2825 SET
    code = '2825',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_282,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_2825_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_2826 SET
    code = '2826',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_282,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_2826_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_2829 SET
    code = '2829',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_282,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_2829_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_29 SET
    code = '29',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_c,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_29_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_291 SET
    code = '291',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_29,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_291_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_2910 SET
    code = '2910',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_291,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_2910_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_292 SET
    code = '292',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_29,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_292_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_2920 SET
    code = '2920',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_292,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_2920_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_293 SET
    code = '293',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_29,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_293_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_2930 SET
    code = '2930',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_293,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_2930_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_30 SET
    code = '30',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_c,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_30_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_301 SET
    code = '301',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_30,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_301_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_3011 SET
    code = '3011',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_301,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_3011_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_3012 SET
    code = '3012',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_301,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_3012_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_302 SET
    code = '302',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_30,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_302_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_3020 SET
    code = '3020',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_302,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_3020_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_303 SET
    code = '303',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_30,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_303_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_3030 SET
    code = '3030',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_303,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_3030_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_304 SET
    code = '304',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_30,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_304_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_3040 SET
    code = '3040',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_304,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_3040_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_309 SET
    code = '309',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_30,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_309_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_3091 SET
    code = '3091',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_309,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_3091_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_3092 SET
    code = '3092',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_309,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_3092_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_3099 SET
    code = '3099',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_309,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_3099_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_31 SET
    code = '31',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_c,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_31_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_310 SET
    code = '310',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_31,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_310_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_3100 SET
    code = '3100',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_310,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_3100_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_32 SET
    code = '32',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_c,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_32_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_321 SET
    code = '321',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_32,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_321_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_3211 SET
    code = '3211',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_321,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_3211_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_3212 SET
    code = '3212',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_321,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_3212_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_322 SET
    code = '322',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_32,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_322_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_3220 SET
    code = '3220',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_322,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_3220_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_323 SET
    code = '323',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_32,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_323_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_3230 SET
    code = '3230',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_323,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_3230_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_324 SET
    code = '324',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_32,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_324_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_3240 SET
    code = '3240',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_324,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_3240_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_325 SET
    code = '325',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_32,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_325_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_3250 SET
    code = '3250',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_325,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_3250_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_329 SET
    code = '329',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_32,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_329_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_3290 SET
    code = '3290',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_329,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_3290_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_33 SET
    code = '33',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_c,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_33_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_331 SET
    code = '331',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_33,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_331_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_3311 SET
    code = '3311',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_331,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_3311_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_3312 SET
    code = '3312',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_331,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_3312_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_3313 SET
    code = '3313',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_331,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_3313_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_3314 SET
    code = '3314',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_331,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_3314_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_3315 SET
    code = '3315',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_331,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_3315_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_3319 SET
    code = '3319',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_331,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_3319_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_332 SET
    code = '332',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_33,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_332_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_3320 SET
    code = '3320',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_332,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_3320_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_d SET
    code = 'D',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:section,
    pays_reference = NONE,
    parent_code = NONE,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_d_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_35 SET
    code = '35',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_d,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_35_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_351 SET
    code = '351',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_35,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_351_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_3510 SET
    code = '3510',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_351,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_3510_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_352 SET
    code = '352',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_35,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_352_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_3520 SET
    code = '3520',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_352,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_3520_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_353 SET
    code = '353',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_35,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_353_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_3530 SET
    code = '3530',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_353,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_3530_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_e SET
    code = 'E',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:section,
    pays_reference = NONE,
    parent_code = NONE,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_e_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_36 SET
    code = '36',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_e,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_36_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_360 SET
    code = '360',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_36,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_360_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_3600 SET
    code = '3600',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_360,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_3600_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_37 SET
    code = '37',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_e,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_37_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_370 SET
    code = '370',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_37,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_370_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_3700 SET
    code = '3700',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_370,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_3700_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_38 SET
    code = '38',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_e,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_38_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_381 SET
    code = '381',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_38,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_381_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_3811 SET
    code = '3811',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_381,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_3811_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_3812 SET
    code = '3812',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_381,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_3812_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_382 SET
    code = '382',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_38,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_382_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_3821 SET
    code = '3821',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_382,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_3821_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_3822 SET
    code = '3822',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_382,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_3822_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_383 SET
    code = '383',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_38,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_383_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_3830 SET
    code = '3830',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_383,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_3830_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_39 SET
    code = '39',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_e,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_39_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_390 SET
    code = '390',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_39,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_390_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_3900 SET
    code = '3900',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_390,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_3900_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_f SET
    code = 'F',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:section,
    pays_reference = NONE,
    parent_code = NONE,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_f_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_41 SET
    code = '41',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_f,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_41_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_410 SET
    code = '410',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_41,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_410_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_4100 SET
    code = '4100',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_410,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_4100_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_42 SET
    code = '42',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_f,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_42_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_421 SET
    code = '421',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_42,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_421_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_4210 SET
    code = '4210',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_421,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_4210_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_422 SET
    code = '422',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_42,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_422_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_4220 SET
    code = '4220',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_422,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_4220_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_429 SET
    code = '429',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_42,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_429_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_4290 SET
    code = '4290',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_429,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_4290_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_43 SET
    code = '43',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_f,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_43_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_431 SET
    code = '431',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_43,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_431_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_4311 SET
    code = '4311',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_431,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_4311_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_4312 SET
    code = '4312',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_431,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_4312_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_432 SET
    code = '432',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_43,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_432_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_4321 SET
    code = '4321',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_432,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_4321_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_4322 SET
    code = '4322',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_432,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_4322_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_4329 SET
    code = '4329',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_432,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_4329_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_433 SET
    code = '433',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_43,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_433_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_4330 SET
    code = '4330',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_433,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_4330_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_439 SET
    code = '439',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_43,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_439_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_4390 SET
    code = '4390',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_439,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_4390_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_g SET
    code = 'G',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:section,
    pays_reference = NONE,
    parent_code = NONE,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_g_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_45 SET
    code = '45',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_g,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_45_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_451 SET
    code = '451',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_45,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_451_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_4510 SET
    code = '4510',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_451,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_4510_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_452 SET
    code = '452',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_45,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_452_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_4520 SET
    code = '4520',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_452,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_4520_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_453 SET
    code = '453',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_45,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_453_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_4530 SET
    code = '4530',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_453,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_4530_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_454 SET
    code = '454',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_45,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_454_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_4540 SET
    code = '4540',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_454,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_4540_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_46 SET
    code = '46',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_g,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_46_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_461 SET
    code = '461',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_46,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_461_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_4610 SET
    code = '4610',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_461,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_4610_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_462 SET
    code = '462',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_46,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_462_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_4620 SET
    code = '4620',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_462,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_4620_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_463 SET
    code = '463',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_46,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_463_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_4630 SET
    code = '4630',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_463,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_4630_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_464 SET
    code = '464',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_46,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_464_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_4641 SET
    code = '4641',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_464,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_4641_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_4649 SET
    code = '4649',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_464,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_4649_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_465 SET
    code = '465',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_46,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_465_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_4651 SET
    code = '4651',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_465,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_4651_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_4652 SET
    code = '4652',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_465,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_4652_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_4653 SET
    code = '4653',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_465,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_4653_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_4659 SET
    code = '4659',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_465,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_4659_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_466 SET
    code = '466',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_46,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_466_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_4661 SET
    code = '4661',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_466,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_4661_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_4662 SET
    code = '4662',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_466,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_4662_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_4663 SET
    code = '4663',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_466,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_4663_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_4669 SET
    code = '4669',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_466,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_4669_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_469 SET
    code = '469',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_46,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_469_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_4690 SET
    code = '4690',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_469,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_4690_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_47 SET
    code = '47',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_g,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_47_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_471 SET
    code = '471',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_47,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_471_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_4711 SET
    code = '4711',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_471,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_4711_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_4719 SET
    code = '4719',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_471,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_4719_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_472 SET
    code = '472',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_47,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_472_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_4721 SET
    code = '4721',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_472,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_4721_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_4722 SET
    code = '4722',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_472,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_4722_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_4723 SET
    code = '4723',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_472,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_4723_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_473 SET
    code = '473',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_47,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_473_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_4730 SET
    code = '4730',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_473,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_4730_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_474 SET
    code = '474',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_47,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_474_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_4741 SET
    code = '4741',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_474,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_4741_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_4742 SET
    code = '4742',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_474,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_4742_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_475 SET
    code = '475',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_47,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_475_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_4751 SET
    code = '4751',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_475,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_4751_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_4752 SET
    code = '4752',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_475,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_4752_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_4753 SET
    code = '4753',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_475,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_4753_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_4759 SET
    code = '4759',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_475,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_4759_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_476 SET
    code = '476',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_47,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_476_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_4761 SET
    code = '4761',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_476,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_4761_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_4762 SET
    code = '4762',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_476,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_4762_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_4763 SET
    code = '4763',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_476,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_4763_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_4764 SET
    code = '4764',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_476,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_4764_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_477 SET
    code = '477',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_47,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_477_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_4771 SET
    code = '4771',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_477,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_4771_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_4772 SET
    code = '4772',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_477,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_4772_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_4773 SET
    code = '4773',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_477,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_4773_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_4774 SET
    code = '4774',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_477,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_4774_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_478 SET
    code = '478',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_47,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_478_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_4781 SET
    code = '4781',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_478,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_4781_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_4782 SET
    code = '4782',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_478,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_4782_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_4789 SET
    code = '4789',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_478,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_4789_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_479 SET
    code = '479',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_47,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_479_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_4791 SET
    code = '4791',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_479,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_4791_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_4799 SET
    code = '4799',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_479,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_4799_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_h SET
    code = 'H',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:section,
    pays_reference = NONE,
    parent_code = NONE,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_h_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_49 SET
    code = '49',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_h,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_49_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_491 SET
    code = '491',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_49,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_491_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_4911 SET
    code = '4911',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_491,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_4911_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_4912 SET
    code = '4912',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_491,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_4912_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_492 SET
    code = '492',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_49,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_492_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_4921 SET
    code = '4921',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_492,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_4921_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_4922 SET
    code = '4922',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_492,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_4922_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_4923 SET
    code = '4923',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_492,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_4923_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_493 SET
    code = '493',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_49,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_493_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_4930 SET
    code = '4930',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_493,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_4930_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_50 SET
    code = '50',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_h,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_50_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_501 SET
    code = '501',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_50,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_501_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_5011 SET
    code = '5011',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_501,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_5011_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_5012 SET
    code = '5012',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_501,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_5012_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_502 SET
    code = '502',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_50,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_502_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_5021 SET
    code = '5021',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_502,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_5021_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_5022 SET
    code = '5022',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_502,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_5022_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_51 SET
    code = '51',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_h,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_51_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_511 SET
    code = '511',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_51,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_511_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_5110 SET
    code = '5110',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_511,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_5110_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_512 SET
    code = '512',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_51,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_512_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_5120 SET
    code = '5120',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_512,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_5120_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_52 SET
    code = '52',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_h,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_52_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_521 SET
    code = '521',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_52,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_521_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_5210 SET
    code = '5210',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_521,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_5210_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_522 SET
    code = '522',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_52,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_522_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_5221 SET
    code = '5221',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_522,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_5221_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_5222 SET
    code = '5222',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_522,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_5222_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_5223 SET
    code = '5223',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_522,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_5223_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_5224 SET
    code = '5224',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_522,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_5224_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_5229 SET
    code = '5229',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_522,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_5229_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_53 SET
    code = '53',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_h,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_53_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_531 SET
    code = '531',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_53,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_531_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_5310 SET
    code = '5310',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_531,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_5310_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_532 SET
    code = '532',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_53,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_532_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_5320 SET
    code = '5320',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_532,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_5320_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_i SET
    code = 'I',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:section,
    pays_reference = NONE,
    parent_code = NONE,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_i_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_55 SET
    code = '55',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_i,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_55_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_551 SET
    code = '551',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_55,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_551_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_5510 SET
    code = '5510',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_551,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_5510_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_552 SET
    code = '552',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_55,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_552_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_5520 SET
    code = '5520',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_552,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_5520_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_559 SET
    code = '559',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_55,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_559_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_5590 SET
    code = '5590',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_559,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_5590_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_56 SET
    code = '56',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_i,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_56_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_561 SET
    code = '561',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_56,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_561_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_5610 SET
    code = '5610',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_561,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_5610_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_562 SET
    code = '562',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_56,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_562_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_5621 SET
    code = '5621',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_562,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_5621_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_5629 SET
    code = '5629',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_562,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_5629_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_563 SET
    code = '563',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_56,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_563_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_5630 SET
    code = '5630',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_563,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_5630_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_j SET
    code = 'J',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:section,
    pays_reference = NONE,
    parent_code = NONE,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_j_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_58 SET
    code = '58',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_j,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_58_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_581 SET
    code = '581',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_58,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_581_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_5811 SET
    code = '5811',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_581,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_5811_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_5812 SET
    code = '5812',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_581,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_5812_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_5813 SET
    code = '5813',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_581,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_5813_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_5819 SET
    code = '5819',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_581,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_5819_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_582 SET
    code = '582',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_58,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_582_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_5820 SET
    code = '5820',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_582,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_5820_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_59 SET
    code = '59',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_j,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_59_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_591 SET
    code = '591',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_59,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_591_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_5911 SET
    code = '5911',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_591,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_5911_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_5912 SET
    code = '5912',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_591,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_5912_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_5913 SET
    code = '5913',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_591,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_5913_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_5914 SET
    code = '5914',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_591,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_5914_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_592 SET
    code = '592',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_59,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_592_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_5920 SET
    code = '5920',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_592,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_5920_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_60 SET
    code = '60',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_j,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_60_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_601 SET
    code = '601',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_60,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_601_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_6010 SET
    code = '6010',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_601,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_6010_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_602 SET
    code = '602',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_60,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_602_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_6020 SET
    code = '6020',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_602,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_6020_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_61 SET
    code = '61',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_j,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_61_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_611 SET
    code = '611',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_61,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_611_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_6110 SET
    code = '6110',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_611,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_6110_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_612 SET
    code = '612',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_61,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_612_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_6120 SET
    code = '6120',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_612,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_6120_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_613 SET
    code = '613',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_61,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_613_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_6130 SET
    code = '6130',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_613,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_6130_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_619 SET
    code = '619',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_61,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_619_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_6190 SET
    code = '6190',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_619,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_6190_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_62 SET
    code = '62',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_j,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_62_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_620 SET
    code = '620',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_62,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_620_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_6201 SET
    code = '6201',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_620,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_6201_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_6202 SET
    code = '6202',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_620,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_6202_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_6209 SET
    code = '6209',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_620,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_6209_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_63 SET
    code = '63',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_j,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_63_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_631 SET
    code = '631',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_63,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_631_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_6311 SET
    code = '6311',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_631,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_6311_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_6312 SET
    code = '6312',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_631,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_6312_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_639 SET
    code = '639',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_63,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_639_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_6391 SET
    code = '6391',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_639,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_6391_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_6399 SET
    code = '6399',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_639,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_6399_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_k SET
    code = 'K',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:section,
    pays_reference = NONE,
    parent_code = NONE,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_k_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_64 SET
    code = '64',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_k,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_64_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_641 SET
    code = '641',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_64,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_641_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_6411 SET
    code = '6411',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_641,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_6411_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_6419 SET
    code = '6419',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_641,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_6419_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_642 SET
    code = '642',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_64,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_642_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_6420 SET
    code = '6420',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_642,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_6420_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_643 SET
    code = '643',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_64,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_643_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_6430 SET
    code = '6430',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_643,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_6430_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_649 SET
    code = '649',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_64,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_649_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_6491 SET
    code = '6491',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_649,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_6491_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_6492 SET
    code = '6492',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_649,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_6492_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_6499 SET
    code = '6499',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_649,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_6499_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_65 SET
    code = '65',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_k,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_65_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_651 SET
    code = '651',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_65,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_651_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_6511 SET
    code = '6511',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_651,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_6511_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_6512 SET
    code = '6512',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_651,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_6512_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_652 SET
    code = '652',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_65,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_652_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_6520 SET
    code = '6520',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_652,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_6520_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_653 SET
    code = '653',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_65,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_653_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_6530 SET
    code = '6530',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_653,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_6530_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_66 SET
    code = '66',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_k,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_66_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_661 SET
    code = '661',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_66,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_661_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_6611 SET
    code = '6611',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_661,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_6611_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_6612 SET
    code = '6612',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_661,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_6612_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_6619 SET
    code = '6619',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_661,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_6619_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_662 SET
    code = '662',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_66,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_662_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_6621 SET
    code = '6621',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_662,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_6621_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_6622 SET
    code = '6622',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_662,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_6622_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_6629 SET
    code = '6629',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_662,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_6629_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_663 SET
    code = '663',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_66,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_663_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_6630 SET
    code = '6630',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_663,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_6630_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_l SET
    code = 'L',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:section,
    pays_reference = NONE,
    parent_code = NONE,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_l_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_68 SET
    code = '68',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_l,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_68_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_681 SET
    code = '681',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_68,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_681_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_6810 SET
    code = '6810',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_681,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_6810_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_682 SET
    code = '682',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_68,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_682_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_6820 SET
    code = '6820',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_682,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_6820_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_m SET
    code = 'M',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:section,
    pays_reference = NONE,
    parent_code = NONE,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_m_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_69 SET
    code = '69',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_m,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_69_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_691 SET
    code = '691',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_69,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_691_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_6910 SET
    code = '6910',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_691,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_6910_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_692 SET
    code = '692',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_69,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_692_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_6920 SET
    code = '6920',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_692,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_6920_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_70 SET
    code = '70',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_m,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_70_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_701 SET
    code = '701',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_70,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_701_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_7010 SET
    code = '7010',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_701,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_7010_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_702 SET
    code = '702',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_70,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_702_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_7020 SET
    code = '7020',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_702,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_7020_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_71 SET
    code = '71',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_m,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_71_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_711 SET
    code = '711',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_71,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_711_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_7110 SET
    code = '7110',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_711,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_7110_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_712 SET
    code = '712',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_71,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_712_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_7120 SET
    code = '7120',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_712,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_7120_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_72 SET
    code = '72',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_m,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_72_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_721 SET
    code = '721',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_72,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_721_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_7210 SET
    code = '7210',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_721,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_7210_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_722 SET
    code = '722',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_72,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_722_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_7220 SET
    code = '7220',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_722,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_7220_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_73 SET
    code = '73',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_m,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_73_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_731 SET
    code = '731',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_73,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_731_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_7310 SET
    code = '7310',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_731,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_7310_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_732 SET
    code = '732',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_73,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_732_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_7320 SET
    code = '7320',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_732,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_7320_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_74 SET
    code = '74',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_m,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_74_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_741 SET
    code = '741',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_74,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_741_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_7410 SET
    code = '7410',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_741,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_7410_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_742 SET
    code = '742',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_74,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_742_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_7420 SET
    code = '7420',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_742,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_7420_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_749 SET
    code = '749',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_74,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_749_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_7490 SET
    code = '7490',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_749,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_7490_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_75 SET
    code = '75',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_m,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_75_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_750 SET
    code = '750',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_75,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_750_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_7500 SET
    code = '7500',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_750,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_7500_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_n SET
    code = 'N',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:section,
    pays_reference = NONE,
    parent_code = NONE,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_n_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_77 SET
    code = '77',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_n,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_77_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_771 SET
    code = '771',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_77,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_771_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_7710 SET
    code = '7710',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_771,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_7710_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_772 SET
    code = '772',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_77,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_772_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_7721 SET
    code = '7721',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_772,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_7721_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_7722 SET
    code = '7722',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_772,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_7722_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_7729 SET
    code = '7729',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_772,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_7729_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_773 SET
    code = '773',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_77,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_773_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_7730 SET
    code = '7730',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_773,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_7730_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_774 SET
    code = '774',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_77,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_774_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_7740 SET
    code = '7740',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_774,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_7740_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_78 SET
    code = '78',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_n,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_78_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_781 SET
    code = '781',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_78,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_781_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_7810 SET
    code = '7810',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_781,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_7810_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_782 SET
    code = '782',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_78,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_782_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_7820 SET
    code = '7820',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_782,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_7820_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_783 SET
    code = '783',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_78,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_783_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_7830 SET
    code = '7830',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_783,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_7830_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_79 SET
    code = '79',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_n,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_79_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_791 SET
    code = '791',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_79,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_791_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_7911 SET
    code = '7911',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_791,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_7911_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_7912 SET
    code = '7912',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_791,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_7912_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_799 SET
    code = '799',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_79,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_799_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_7990 SET
    code = '7990',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_799,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_7990_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_80 SET
    code = '80',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_n,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_80_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_801 SET
    code = '801',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_80,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_801_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_8010 SET
    code = '8010',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_801,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_8010_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_802 SET
    code = '802',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_80,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_802_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_8020 SET
    code = '8020',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_802,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_8020_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_803 SET
    code = '803',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_80,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_803_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_8030 SET
    code = '8030',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_803,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_8030_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_81 SET
    code = '81',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_n,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_81_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_811 SET
    code = '811',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_81,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_811_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_8110 SET
    code = '8110',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_811,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_8110_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_812 SET
    code = '812',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_81,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_812_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_8121 SET
    code = '8121',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_812,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_8121_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_8129 SET
    code = '8129',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_812,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_8129_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_813 SET
    code = '813',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_81,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_813_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_8130 SET
    code = '8130',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_813,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_8130_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_82 SET
    code = '82',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_n,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_82_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_821 SET
    code = '821',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_82,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_821_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_8211 SET
    code = '8211',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_821,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_8211_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_8219 SET
    code = '8219',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_821,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_8219_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_822 SET
    code = '822',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_82,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_822_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_8220 SET
    code = '8220',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_822,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_8220_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_823 SET
    code = '823',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_82,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_823_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_8230 SET
    code = '8230',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_823,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_8230_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_829 SET
    code = '829',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_82,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_829_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_8291 SET
    code = '8291',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_829,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_8291_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_8292 SET
    code = '8292',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_829,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_8292_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_8299 SET
    code = '8299',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_829,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_8299_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_o SET
    code = 'O',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:section,
    pays_reference = NONE,
    parent_code = NONE,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_o_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_84 SET
    code = '84',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_o,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_84_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_841 SET
    code = '841',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_84,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_841_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_8411 SET
    code = '8411',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_841,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_8411_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_8412 SET
    code = '8412',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_841,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_8412_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_8413 SET
    code = '8413',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_841,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_8413_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_842 SET
    code = '842',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_84,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_842_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_8421 SET
    code = '8421',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_842,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_8421_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_8422 SET
    code = '8422',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_842,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_8422_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_8423 SET
    code = '8423',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_842,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_8423_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_843 SET
    code = '843',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_84,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_843_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_8430 SET
    code = '8430',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_843,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_8430_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_p SET
    code = 'P',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:section,
    pays_reference = NONE,
    parent_code = NONE,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_p_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_85 SET
    code = '85',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_p,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_85_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_851 SET
    code = '851',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_85,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_851_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_8510 SET
    code = '8510',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_851,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_8510_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_852 SET
    code = '852',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_85,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_852_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_8521 SET
    code = '8521',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_852,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_8521_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_8522 SET
    code = '8522',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_852,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_8522_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_853 SET
    code = '853',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_85,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_853_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_8530 SET
    code = '8530',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_853,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_8530_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_854 SET
    code = '854',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_85,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_854_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_8541 SET
    code = '8541',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_854,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_8541_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_8542 SET
    code = '8542',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_854,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_8542_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_8549 SET
    code = '8549',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_854,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_8549_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_855 SET
    code = '855',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_85,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_855_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_8550 SET
    code = '8550',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_855,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_8550_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_q SET
    code = 'Q',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:section,
    pays_reference = NONE,
    parent_code = NONE,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_q_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_86 SET
    code = '86',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_q,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_86_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_861 SET
    code = '861',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_86,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_861_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_8610 SET
    code = '8610',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_861,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_8610_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_862 SET
    code = '862',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_86,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_862_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_8620 SET
    code = '8620',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_862,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_8620_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_869 SET
    code = '869',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_86,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_869_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_8690 SET
    code = '8690',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_869,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_8690_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_87 SET
    code = '87',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_q,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_87_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_871 SET
    code = '871',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_87,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_871_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_8710 SET
    code = '8710',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_871,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_8710_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_872 SET
    code = '872',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_87,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_872_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_8720 SET
    code = '8720',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_872,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_8720_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_873 SET
    code = '873',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_87,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_873_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_8730 SET
    code = '8730',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_873,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_8730_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_879 SET
    code = '879',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_87,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_879_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_8790 SET
    code = '8790',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_879,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_8790_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_88 SET
    code = '88',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_q,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_88_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_881 SET
    code = '881',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_88,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_881_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_8810 SET
    code = '8810',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_881,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_8810_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_889 SET
    code = '889',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_88,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_889_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_8890 SET
    code = '8890',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_889,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_8890_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_r SET
    code = 'R',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:section,
    pays_reference = NONE,
    parent_code = NONE,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_r_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_90 SET
    code = '90',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_r,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_90_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_900 SET
    code = '900',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_90,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_900_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_9000 SET
    code = '9000',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_900,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_9000_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_91 SET
    code = '91',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_r,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_91_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_910 SET
    code = '910',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_91,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_910_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_9101 SET
    code = '9101',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_910,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_9101_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_9102 SET
    code = '9102',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_910,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_9102_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_9103 SET
    code = '9103',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_910,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_9103_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_92 SET
    code = '92',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_r,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_92_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_920 SET
    code = '920',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_92,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_920_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_9200 SET
    code = '9200',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_920,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_9200_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_93 SET
    code = '93',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_r,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_93_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_931 SET
    code = '931',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_93,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_931_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_9311 SET
    code = '9311',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_931,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_9311_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_9312 SET
    code = '9312',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_931,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_9312_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_9319 SET
    code = '9319',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_931,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_9319_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_932 SET
    code = '932',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_93,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_932_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_9321 SET
    code = '9321',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_932,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_9321_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_9329 SET
    code = '9329',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_932,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_9329_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_s SET
    code = 'S',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:section,
    pays_reference = NONE,
    parent_code = NONE,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_s_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_94 SET
    code = '94',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_s,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_94_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_941 SET
    code = '941',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_94,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_941_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_9411 SET
    code = '9411',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_941,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_9411_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_9412 SET
    code = '9412',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_941,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_9412_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_942 SET
    code = '942',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_94,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_942_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_9420 SET
    code = '9420',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_942,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_9420_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_949 SET
    code = '949',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_94,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_949_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_9491 SET
    code = '9491',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_949,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_9491_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_9492 SET
    code = '9492',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_949,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_9492_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_9499 SET
    code = '9499',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_949,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_9499_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_95 SET
    code = '95',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_s,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_95_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_951 SET
    code = '951',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_95,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_951_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_9511 SET
    code = '9511',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_951,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_9511_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_9512 SET
    code = '9512',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_951,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_9512_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_952 SET
    code = '952',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_95,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_952_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_9521 SET
    code = '9521',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_952,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_9521_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_9522 SET
    code = '9522',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_952,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_9522_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_9523 SET
    code = '9523',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_952,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_9523_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_9524 SET
    code = '9524',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_952,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_9524_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_9529 SET
    code = '9529',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_952,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_9529_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_96 SET
    code = '96',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_s,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_96_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_960 SET
    code = '960',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_96,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_960_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_9601 SET
    code = '9601',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_960,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_9601_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_9602 SET
    code = '9602',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_960,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_9602_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_9603 SET
    code = '9603',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_960,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_9603_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_9609 SET
    code = '9609',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_960,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_9609_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_t SET
    code = 'T',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:section,
    pays_reference = NONE,
    parent_code = NONE,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_t_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_97 SET
    code = '97',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_t,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_97_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_970 SET
    code = '970',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_97,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_970_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_9700 SET
    code = '9700',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_970,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_9700_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_98 SET
    code = '98',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_t,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_98_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_981 SET
    code = '981',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_98,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_981_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_9810 SET
    code = '9810',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_981,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_9810_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_982 SET
    code = '982',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_98,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_982_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_9820 SET
    code = '9820',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_982,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_9820_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_u SET
    code = 'U',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:section,
    pays_reference = NONE,
    parent_code = NONE,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_u_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_99 SET
    code = '99',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_u,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_99_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_990 SET
    code = '990',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_99,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_990_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev4_9900 SET
    code = '9900',
    nomenclature_type = society_activity_nomenclature_type:isic_rev4,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev4_990,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev4_9900_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

-- -------------------------------------------------------------------------------------------------
-- ISIC_Rev3.1 (538 codes)
-- -------------------------------------------------------------------------------------------------

CREATE society_activity_code:isic_rev3_1_a SET
    code = 'A',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:section,
    pays_reference = NONE,
    parent_code = NONE,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_a_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_01 SET
    code = '01',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_a,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_01_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_011 SET
    code = '011',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_01,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_011_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_0111 SET
    code = '0111',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_011,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_0111_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_0112 SET
    code = '0112',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_011,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_0112_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_0113 SET
    code = '0113',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_011,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_0113_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_012 SET
    code = '012',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_01,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_012_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_0121 SET
    code = '0121',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_012,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_0121_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_0122 SET
    code = '0122',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_012,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_0122_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_013 SET
    code = '013',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_01,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_013_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_0130 SET
    code = '0130',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_013,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_0130_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_014 SET
    code = '014',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_01,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_014_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_0140 SET
    code = '0140',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_014,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_0140_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_015 SET
    code = '015',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_01,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_015_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_0150 SET
    code = '0150',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_015,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_0150_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_02 SET
    code = '02',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_a,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_02_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_020 SET
    code = '020',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_02,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_020_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_0200 SET
    code = '0200',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_020,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_0200_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_b SET
    code = 'B',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:section,
    pays_reference = NONE,
    parent_code = NONE,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_b_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_05 SET
    code = '05',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_b,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_05_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_050 SET
    code = '050',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_05,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_050_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_0501 SET
    code = '0501',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_050,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_0501_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_0502 SET
    code = '0502',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_050,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_0502_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_c SET
    code = 'C',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:section,
    pays_reference = NONE,
    parent_code = NONE,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_c_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_10 SET
    code = '10',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_c,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_10_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_101 SET
    code = '101',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_10,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_101_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_1010 SET
    code = '1010',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_101,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_1010_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_102 SET
    code = '102',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_10,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_102_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_1020 SET
    code = '1020',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_102,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_1020_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_103 SET
    code = '103',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_10,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_103_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_1030 SET
    code = '1030',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_103,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_1030_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_11 SET
    code = '11',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_c,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_11_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_111 SET
    code = '111',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_11,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_111_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_1110 SET
    code = '1110',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_111,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_1110_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_112 SET
    code = '112',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_11,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_112_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_1120 SET
    code = '1120',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_112,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_1120_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_12 SET
    code = '12',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_c,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_12_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_120 SET
    code = '120',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_12,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_120_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_1200 SET
    code = '1200',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_120,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_1200_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_13 SET
    code = '13',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_c,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_13_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_131 SET
    code = '131',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_13,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_131_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_1310 SET
    code = '1310',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_131,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_1310_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_132 SET
    code = '132',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_13,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_132_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_1320 SET
    code = '1320',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_132,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_1320_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_14 SET
    code = '14',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_c,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_14_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_141 SET
    code = '141',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_14,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_141_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_1410 SET
    code = '1410',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_141,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_1410_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_142 SET
    code = '142',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_14,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_142_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_1421 SET
    code = '1421',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_142,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_1421_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_1422 SET
    code = '1422',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_142,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_1422_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_1429 SET
    code = '1429',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_142,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_1429_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_d SET
    code = 'D',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:section,
    pays_reference = NONE,
    parent_code = NONE,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_d_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_15 SET
    code = '15',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_d,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_15_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_151 SET
    code = '151',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_15,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_151_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_1511 SET
    code = '1511',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_151,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_1511_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_1512 SET
    code = '1512',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_151,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_1512_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_1513 SET
    code = '1513',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_151,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_1513_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_1514 SET
    code = '1514',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_151,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_1514_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_152 SET
    code = '152',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_15,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_152_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_1520 SET
    code = '1520',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_152,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_1520_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_153 SET
    code = '153',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_15,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_153_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_1531 SET
    code = '1531',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_153,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_1531_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_1532 SET
    code = '1532',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_153,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_1532_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_1533 SET
    code = '1533',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_153,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_1533_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_154 SET
    code = '154',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_15,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_154_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_1541 SET
    code = '1541',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_154,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_1541_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_1542 SET
    code = '1542',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_154,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_1542_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_1543 SET
    code = '1543',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_154,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_1543_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_1544 SET
    code = '1544',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_154,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_1544_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_1549 SET
    code = '1549',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_154,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_1549_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_155 SET
    code = '155',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_15,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_155_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_1551 SET
    code = '1551',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_155,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_1551_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_1552 SET
    code = '1552',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_155,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_1552_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_1553 SET
    code = '1553',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_155,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_1553_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_1554 SET
    code = '1554',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_155,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_1554_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_16 SET
    code = '16',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_d,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_16_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_160 SET
    code = '160',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_16,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_160_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_1600 SET
    code = '1600',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_160,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_1600_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_17 SET
    code = '17',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_d,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_17_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_171 SET
    code = '171',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_17,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_171_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_1711 SET
    code = '1711',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_171,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_1711_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_1712 SET
    code = '1712',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_171,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_1712_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_172 SET
    code = '172',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_17,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_172_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_1721 SET
    code = '1721',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_172,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_1721_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_1722 SET
    code = '1722',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_172,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_1722_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_1723 SET
    code = '1723',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_172,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_1723_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_1729 SET
    code = '1729',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_172,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_1729_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_173 SET
    code = '173',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_17,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_173_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_1730 SET
    code = '1730',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_173,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_1730_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_18 SET
    code = '18',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_d,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_18_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_181 SET
    code = '181',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_18,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_181_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_1810 SET
    code = '1810',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_181,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_1810_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_182 SET
    code = '182',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_18,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_182_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_1820 SET
    code = '1820',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_182,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_1820_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_19 SET
    code = '19',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_d,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_19_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_191 SET
    code = '191',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_19,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_191_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_1911 SET
    code = '1911',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_191,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_1911_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_1912 SET
    code = '1912',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_191,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_1912_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_192 SET
    code = '192',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_19,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_192_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_1920 SET
    code = '1920',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_192,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_1920_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_20 SET
    code = '20',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_d,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_20_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_201 SET
    code = '201',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_20,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_201_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_2010 SET
    code = '2010',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_201,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_2010_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_202 SET
    code = '202',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_20,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_202_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_2021 SET
    code = '2021',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_202,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_2021_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_2022 SET
    code = '2022',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_202,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_2022_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_2023 SET
    code = '2023',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_202,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_2023_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_2029 SET
    code = '2029',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_202,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_2029_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_21 SET
    code = '21',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_d,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_21_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_210 SET
    code = '210',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_21,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_210_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_2101 SET
    code = '2101',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_210,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_2101_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_2102 SET
    code = '2102',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_210,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_2102_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_2109 SET
    code = '2109',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_210,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_2109_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_22 SET
    code = '22',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_d,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_22_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_221 SET
    code = '221',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_22,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_221_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_2211 SET
    code = '2211',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_221,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_2211_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_2212 SET
    code = '2212',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_221,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_2212_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_2213 SET
    code = '2213',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_221,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_2213_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_2219 SET
    code = '2219',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_221,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_2219_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_222 SET
    code = '222',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_22,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_222_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_2221 SET
    code = '2221',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_222,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_2221_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_2222 SET
    code = '2222',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_222,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_2222_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_223 SET
    code = '223',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_22,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_223_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_2230 SET
    code = '2230',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_223,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_2230_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_23 SET
    code = '23',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_d,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_23_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_231 SET
    code = '231',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_23,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_231_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_2310 SET
    code = '2310',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_231,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_2310_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_232 SET
    code = '232',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_23,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_232_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_2320 SET
    code = '2320',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_232,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_2320_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_233 SET
    code = '233',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_23,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_233_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_2330 SET
    code = '2330',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_233,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_2330_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_24 SET
    code = '24',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_d,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_24_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_241 SET
    code = '241',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_24,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_241_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_2411 SET
    code = '2411',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_241,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_2411_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_2412 SET
    code = '2412',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_241,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_2412_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_2413 SET
    code = '2413',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_241,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_2413_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_242 SET
    code = '242',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_24,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_242_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_2421 SET
    code = '2421',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_242,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_2421_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_2422 SET
    code = '2422',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_242,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_2422_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_2423 SET
    code = '2423',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_242,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_2423_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_2424 SET
    code = '2424',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_242,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_2424_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_2429 SET
    code = '2429',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_242,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_2429_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_243 SET
    code = '243',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_24,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_243_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_2430 SET
    code = '2430',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_243,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_2430_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_25 SET
    code = '25',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_d,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_25_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_251 SET
    code = '251',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_25,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_251_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_2511 SET
    code = '2511',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_251,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_2511_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_2519 SET
    code = '2519',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_251,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_2519_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_252 SET
    code = '252',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_25,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_252_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_2520 SET
    code = '2520',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_252,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_2520_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_26 SET
    code = '26',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_d,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_26_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_261 SET
    code = '261',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_26,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_261_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_2610 SET
    code = '2610',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_261,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_2610_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_269 SET
    code = '269',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_26,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_269_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_2691 SET
    code = '2691',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_269,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_2691_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_2692 SET
    code = '2692',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_269,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_2692_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_2693 SET
    code = '2693',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_269,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_2693_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_2694 SET
    code = '2694',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_269,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_2694_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_2695 SET
    code = '2695',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_269,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_2695_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_2696 SET
    code = '2696',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_269,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_2696_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_2699 SET
    code = '2699',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_269,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_2699_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_27 SET
    code = '27',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_d,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_27_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_271 SET
    code = '271',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_27,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_271_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_2710 SET
    code = '2710',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_271,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_2710_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_272 SET
    code = '272',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_27,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_272_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_2720 SET
    code = '2720',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_272,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_2720_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_273 SET
    code = '273',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_27,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_273_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_2731 SET
    code = '2731',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_273,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_2731_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_2732 SET
    code = '2732',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_273,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_2732_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_28 SET
    code = '28',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_d,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_28_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_281 SET
    code = '281',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_28,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_281_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_2811 SET
    code = '2811',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_281,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_2811_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_2812 SET
    code = '2812',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_281,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_2812_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_2813 SET
    code = '2813',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_281,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_2813_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_289 SET
    code = '289',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_28,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_289_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_2891 SET
    code = '2891',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_289,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_2891_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_2892 SET
    code = '2892',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_289,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_2892_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_2893 SET
    code = '2893',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_289,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_2893_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_2899 SET
    code = '2899',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_289,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_2899_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_29 SET
    code = '29',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_d,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_29_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_291 SET
    code = '291',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_29,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_291_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_2911 SET
    code = '2911',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_291,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_2911_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_2912 SET
    code = '2912',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_291,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_2912_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_2913 SET
    code = '2913',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_291,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_2913_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_2914 SET
    code = '2914',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_291,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_2914_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_2915 SET
    code = '2915',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_291,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_2915_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_2919 SET
    code = '2919',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_291,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_2919_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_292 SET
    code = '292',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_29,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_292_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_2921 SET
    code = '2921',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_292,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_2921_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_2922 SET
    code = '2922',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_292,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_2922_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_2923 SET
    code = '2923',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_292,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_2923_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_2924 SET
    code = '2924',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_292,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_2924_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_2925 SET
    code = '2925',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_292,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_2925_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_2926 SET
    code = '2926',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_292,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_2926_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_2927 SET
    code = '2927',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_292,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_2927_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_2929 SET
    code = '2929',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_292,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_2929_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_293 SET
    code = '293',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_29,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_293_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_2930 SET
    code = '2930',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_293,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_2930_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_30 SET
    code = '30',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_d,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_30_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_300 SET
    code = '300',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_30,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_300_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_3000 SET
    code = '3000',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_300,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_3000_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_31 SET
    code = '31',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_d,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_31_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_311 SET
    code = '311',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_31,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_311_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_3110 SET
    code = '3110',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_311,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_3110_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_312 SET
    code = '312',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_31,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_312_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_3120 SET
    code = '3120',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_312,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_3120_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_313 SET
    code = '313',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_31,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_313_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_3130 SET
    code = '3130',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_313,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_3130_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_314 SET
    code = '314',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_31,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_314_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_3140 SET
    code = '3140',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_314,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_3140_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_315 SET
    code = '315',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_31,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_315_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_3150 SET
    code = '3150',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_315,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_3150_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_319 SET
    code = '319',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_31,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_319_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_3190 SET
    code = '3190',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_319,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_3190_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_32 SET
    code = '32',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_d,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_32_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_321 SET
    code = '321',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_32,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_321_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_3210 SET
    code = '3210',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_321,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_3210_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_322 SET
    code = '322',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_32,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_322_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_3220 SET
    code = '3220',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_322,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_3220_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_323 SET
    code = '323',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_32,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_323_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_3230 SET
    code = '3230',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_323,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_3230_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_33 SET
    code = '33',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_d,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_33_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_331 SET
    code = '331',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_33,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_331_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_3311 SET
    code = '3311',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_331,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_3311_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_3312 SET
    code = '3312',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_331,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_3312_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_3313 SET
    code = '3313',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_331,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_3313_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_332 SET
    code = '332',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_33,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_332_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_3320 SET
    code = '3320',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_332,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_3320_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_333 SET
    code = '333',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_33,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_333_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_3330 SET
    code = '3330',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_333,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_3330_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_34 SET
    code = '34',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_d,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_34_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_341 SET
    code = '341',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_34,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_341_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_3410 SET
    code = '3410',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_341,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_3410_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_342 SET
    code = '342',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_34,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_342_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_3420 SET
    code = '3420',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_342,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_3420_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_343 SET
    code = '343',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_34,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_343_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_3430 SET
    code = '3430',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_343,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_3430_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_35 SET
    code = '35',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_d,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_35_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_351 SET
    code = '351',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_35,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_351_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_3511 SET
    code = '3511',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_351,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_3511_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_3512 SET
    code = '3512',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_351,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_3512_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_352 SET
    code = '352',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_35,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_352_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_3520 SET
    code = '3520',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_352,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_3520_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_353 SET
    code = '353',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_35,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_353_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_3530 SET
    code = '3530',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_353,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_3530_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_359 SET
    code = '359',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_35,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_359_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_3591 SET
    code = '3591',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_359,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_3591_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_3592 SET
    code = '3592',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_359,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_3592_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_3599 SET
    code = '3599',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_359,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_3599_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_36 SET
    code = '36',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_d,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_36_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_361 SET
    code = '361',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_36,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_361_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_3610 SET
    code = '3610',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_361,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_3610_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_369 SET
    code = '369',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_36,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_369_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_3691 SET
    code = '3691',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_369,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_3691_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_3692 SET
    code = '3692',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_369,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_3692_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_3693 SET
    code = '3693',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_369,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_3693_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_3694 SET
    code = '3694',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_369,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_3694_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_3699 SET
    code = '3699',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_369,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_3699_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_37 SET
    code = '37',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_d,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_37_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_371 SET
    code = '371',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_37,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_371_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_3710 SET
    code = '3710',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_371,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_3710_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_372 SET
    code = '372',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_37,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_372_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_3720 SET
    code = '3720',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_372,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_3720_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_e SET
    code = 'E',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:section,
    pays_reference = NONE,
    parent_code = NONE,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_e_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_40 SET
    code = '40',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_e,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_40_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_401 SET
    code = '401',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_40,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_401_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_4010 SET
    code = '4010',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_401,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_4010_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_402 SET
    code = '402',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_40,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_402_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_4020 SET
    code = '4020',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_402,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_4020_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_403 SET
    code = '403',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_40,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_403_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_4030 SET
    code = '4030',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_403,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_4030_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_41 SET
    code = '41',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_e,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_41_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_410 SET
    code = '410',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_41,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_410_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_4100 SET
    code = '4100',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_410,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_4100_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_f SET
    code = 'F',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:section,
    pays_reference = NONE,
    parent_code = NONE,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_f_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_45 SET
    code = '45',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_f,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_45_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_451 SET
    code = '451',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_45,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_451_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_4510 SET
    code = '4510',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_451,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_4510_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_452 SET
    code = '452',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_45,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_452_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_4520 SET
    code = '4520',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_452,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_4520_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_453 SET
    code = '453',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_45,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_453_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_4530 SET
    code = '4530',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_453,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_4530_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_454 SET
    code = '454',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_45,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_454_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_4540 SET
    code = '4540',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_454,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_4540_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_455 SET
    code = '455',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_45,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_455_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_4550 SET
    code = '4550',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_455,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_4550_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_g SET
    code = 'G',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:section,
    pays_reference = NONE,
    parent_code = NONE,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_g_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_50 SET
    code = '50',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_g,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_50_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_501 SET
    code = '501',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_50,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_501_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_5010 SET
    code = '5010',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_501,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_5010_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_502 SET
    code = '502',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_50,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_502_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_5020 SET
    code = '5020',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_502,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_5020_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_503 SET
    code = '503',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_50,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_503_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_5030 SET
    code = '5030',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_503,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_5030_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_504 SET
    code = '504',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_50,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_504_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_5040 SET
    code = '5040',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_504,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_5040_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_505 SET
    code = '505',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_50,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_505_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_5050 SET
    code = '5050',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_505,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_5050_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_51 SET
    code = '51',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_g,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_51_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_511 SET
    code = '511',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_51,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_511_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_5110 SET
    code = '5110',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_511,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_5110_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_512 SET
    code = '512',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_51,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_512_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_5121 SET
    code = '5121',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_512,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_5121_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_5122 SET
    code = '5122',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_512,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_5122_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_513 SET
    code = '513',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_51,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_513_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_5131 SET
    code = '5131',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_513,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_5131_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_5139 SET
    code = '5139',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_513,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_5139_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_514 SET
    code = '514',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_51,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_514_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_5141 SET
    code = '5141',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_514,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_5141_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_5142 SET
    code = '5142',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_514,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_5142_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_5143 SET
    code = '5143',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_514,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_5143_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_5149 SET
    code = '5149',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_514,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_5149_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_515 SET
    code = '515',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_51,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_515_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_5151 SET
    code = '5151',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_515,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_5151_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_5152 SET
    code = '5152',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_515,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_5152_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_5159 SET
    code = '5159',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_515,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_5159_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_519 SET
    code = '519',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_51,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_519_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_5190 SET
    code = '5190',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_519,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_5190_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_52 SET
    code = '52',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_g,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_52_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_521 SET
    code = '521',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_52,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_521_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_5211 SET
    code = '5211',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_521,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_5211_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_5219 SET
    code = '5219',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_521,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_5219_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_522 SET
    code = '522',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_52,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_522_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_5220 SET
    code = '5220',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_522,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_5220_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_523 SET
    code = '523',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_52,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_523_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_5231 SET
    code = '5231',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_523,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_5231_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_5232 SET
    code = '5232',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_523,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_5232_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_5233 SET
    code = '5233',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_523,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_5233_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_5234 SET
    code = '5234',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_523,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_5234_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_5239 SET
    code = '5239',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_523,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_5239_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_524 SET
    code = '524',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_52,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_524_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_5240 SET
    code = '5240',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_524,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_5240_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_525 SET
    code = '525',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_52,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_525_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_5251 SET
    code = '5251',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_525,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_5251_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_5252 SET
    code = '5252',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_525,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_5252_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_5259 SET
    code = '5259',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_525,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_5259_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_526 SET
    code = '526',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_52,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_526_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_5260 SET
    code = '5260',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_526,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_5260_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_h SET
    code = 'H',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:section,
    pays_reference = NONE,
    parent_code = NONE,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_h_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_55 SET
    code = '55',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_h,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_55_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_551 SET
    code = '551',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_55,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_551_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_5510 SET
    code = '5510',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_551,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_5510_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_552 SET
    code = '552',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_55,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_552_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_5520 SET
    code = '5520',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_552,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_5520_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_i SET
    code = 'I',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:section,
    pays_reference = NONE,
    parent_code = NONE,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_i_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_60 SET
    code = '60',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_i,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_60_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_601 SET
    code = '601',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_60,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_601_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_6010 SET
    code = '6010',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_601,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_6010_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_602 SET
    code = '602',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_60,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_602_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_6021 SET
    code = '6021',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_602,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_6021_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_6022 SET
    code = '6022',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_602,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_6022_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_6023 SET
    code = '6023',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_602,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_6023_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_603 SET
    code = '603',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_60,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_603_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_6030 SET
    code = '6030',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_603,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_6030_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_61 SET
    code = '61',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_i,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_61_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_611 SET
    code = '611',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_61,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_611_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_6110 SET
    code = '6110',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_611,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_6110_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_612 SET
    code = '612',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_61,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_612_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_6120 SET
    code = '6120',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_612,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_6120_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_62 SET
    code = '62',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_i,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_62_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_621 SET
    code = '621',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_62,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_621_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_6210 SET
    code = '6210',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_621,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_6210_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_622 SET
    code = '622',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_62,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_622_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_6220 SET
    code = '6220',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_622,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_6220_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_63 SET
    code = '63',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_i,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_63_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_630 SET
    code = '630',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_63,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_630_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_6301 SET
    code = '6301',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_630,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_6301_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_6302 SET
    code = '6302',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_630,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_6302_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_6303 SET
    code = '6303',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_630,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_6303_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_6304 SET
    code = '6304',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_630,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_6304_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_6309 SET
    code = '6309',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_630,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_6309_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_64 SET
    code = '64',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_i,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_64_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_641 SET
    code = '641',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_64,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_641_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_6411 SET
    code = '6411',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_641,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_6411_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_6412 SET
    code = '6412',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_641,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_6412_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_642 SET
    code = '642',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_64,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_642_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_6420 SET
    code = '6420',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_642,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_6420_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_j SET
    code = 'J',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:section,
    pays_reference = NONE,
    parent_code = NONE,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_j_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_65 SET
    code = '65',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_j,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_65_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_651 SET
    code = '651',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_65,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_651_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_6511 SET
    code = '6511',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_651,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_6511_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_6519 SET
    code = '6519',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_651,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_6519_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_659 SET
    code = '659',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_65,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_659_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_6591 SET
    code = '6591',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_659,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_6591_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_6592 SET
    code = '6592',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_659,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_6592_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_6599 SET
    code = '6599',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_659,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_6599_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_66 SET
    code = '66',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_j,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_66_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_660 SET
    code = '660',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_66,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_660_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_6601 SET
    code = '6601',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_660,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_6601_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_6602 SET
    code = '6602',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_660,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_6602_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_6603 SET
    code = '6603',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_660,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_6603_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_67 SET
    code = '67',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_j,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_67_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_671 SET
    code = '671',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_67,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_671_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_6711 SET
    code = '6711',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_671,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_6711_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_6712 SET
    code = '6712',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_671,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_6712_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_6719 SET
    code = '6719',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_671,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_6719_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_672 SET
    code = '672',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_67,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_672_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_6720 SET
    code = '6720',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_672,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_6720_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_k SET
    code = 'K',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:section,
    pays_reference = NONE,
    parent_code = NONE,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_k_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_70 SET
    code = '70',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_k,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_70_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_701 SET
    code = '701',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_70,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_701_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_7010 SET
    code = '7010',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_701,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_7010_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_702 SET
    code = '702',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_70,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_702_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_7020 SET
    code = '7020',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_702,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_7020_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_71 SET
    code = '71',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_k,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_71_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_711 SET
    code = '711',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_71,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_711_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_7111 SET
    code = '7111',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_711,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_7111_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_7112 SET
    code = '7112',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_711,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_7112_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_7113 SET
    code = '7113',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_711,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_7113_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_712 SET
    code = '712',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_71,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_712_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_7121 SET
    code = '7121',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_712,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_7121_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_7122 SET
    code = '7122',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_712,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_7122_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_7123 SET
    code = '7123',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_712,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_7123_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_7129 SET
    code = '7129',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_712,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_7129_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_713 SET
    code = '713',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_71,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_713_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_7130 SET
    code = '7130',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_713,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_7130_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_72 SET
    code = '72',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_k,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_72_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_721 SET
    code = '721',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_72,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_721_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_7210 SET
    code = '7210',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_721,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_7210_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_722 SET
    code = '722',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_72,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_722_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_7221 SET
    code = '7221',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_722,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_7221_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_7229 SET
    code = '7229',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_722,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_7229_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_723 SET
    code = '723',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_72,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_723_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_7230 SET
    code = '7230',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_723,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_7230_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_724 SET
    code = '724',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_72,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_724_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_7240 SET
    code = '7240',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_724,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_7240_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_725 SET
    code = '725',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_72,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_725_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_7250 SET
    code = '7250',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_725,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_7250_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_729 SET
    code = '729',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_72,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_729_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_7290 SET
    code = '7290',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_729,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_7290_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_73 SET
    code = '73',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_k,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_73_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_731 SET
    code = '731',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_73,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_731_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_7310 SET
    code = '7310',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_731,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_7310_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_732 SET
    code = '732',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_73,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_732_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_7320 SET
    code = '7320',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_732,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_7320_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_74 SET
    code = '74',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_k,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_74_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_741 SET
    code = '741',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_74,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_741_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_7411 SET
    code = '7411',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_741,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_7411_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_7412 SET
    code = '7412',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_741,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_7412_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_7413 SET
    code = '7413',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_741,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_7413_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_7414 SET
    code = '7414',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_741,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_7414_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_742 SET
    code = '742',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_74,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_742_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_7421 SET
    code = '7421',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_742,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_7421_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_7422 SET
    code = '7422',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_742,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_7422_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_743 SET
    code = '743',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_74,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_743_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_7430 SET
    code = '7430',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_743,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_7430_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_749 SET
    code = '749',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_74,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_749_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_7491 SET
    code = '7491',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_749,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_7491_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_7492 SET
    code = '7492',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_749,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_7492_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_7493 SET
    code = '7493',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_749,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_7493_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_7494 SET
    code = '7494',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_749,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_7494_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_7495 SET
    code = '7495',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_749,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_7495_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_7499 SET
    code = '7499',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_749,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_7499_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_l SET
    code = 'L',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:section,
    pays_reference = NONE,
    parent_code = NONE,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_l_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_75 SET
    code = '75',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_l,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_75_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_751 SET
    code = '751',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_75,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_751_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_7511 SET
    code = '7511',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_751,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_7511_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_7512 SET
    code = '7512',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_751,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_7512_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_7513 SET
    code = '7513',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_751,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_7513_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_7514 SET
    code = '7514',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_751,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_7514_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_752 SET
    code = '752',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_75,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_752_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_7521 SET
    code = '7521',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_752,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_7521_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_7522 SET
    code = '7522',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_752,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_7522_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_7523 SET
    code = '7523',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_752,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_7523_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_753 SET
    code = '753',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_75,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_753_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_7530 SET
    code = '7530',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_753,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_7530_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_m SET
    code = 'M',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:section,
    pays_reference = NONE,
    parent_code = NONE,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_m_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_80 SET
    code = '80',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_m,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_80_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_801 SET
    code = '801',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_80,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_801_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_8010 SET
    code = '8010',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_801,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_8010_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_802 SET
    code = '802',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_80,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_802_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_8021 SET
    code = '8021',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_802,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_8021_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_8022 SET
    code = '8022',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_802,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_8022_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_803 SET
    code = '803',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_80,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_803_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_8030 SET
    code = '8030',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_803,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_8030_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_809 SET
    code = '809',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_80,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_809_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_8090 SET
    code = '8090',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_809,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_8090_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_n SET
    code = 'N',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:section,
    pays_reference = NONE,
    parent_code = NONE,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_n_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_85 SET
    code = '85',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_n,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_85_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_851 SET
    code = '851',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_85,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_851_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_8511 SET
    code = '8511',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_851,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_8511_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_8512 SET
    code = '8512',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_851,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_8512_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_8519 SET
    code = '8519',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_851,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_8519_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_852 SET
    code = '852',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_85,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_852_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_8520 SET
    code = '8520',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_852,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_8520_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_853 SET
    code = '853',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_85,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_853_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_8531 SET
    code = '8531',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_853,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_8531_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_8532 SET
    code = '8532',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_853,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_8532_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_o SET
    code = 'O',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:section,
    pays_reference = NONE,
    parent_code = NONE,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_o_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_90 SET
    code = '90',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_o,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_90_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_900 SET
    code = '900',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_90,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_900_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_9000 SET
    code = '9000',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_900,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_9000_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_91 SET
    code = '91',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_o,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_91_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_911 SET
    code = '911',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_91,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_911_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_9111 SET
    code = '9111',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_911,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_9111_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_9112 SET
    code = '9112',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_911,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_9112_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_912 SET
    code = '912',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_91,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_912_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_9120 SET
    code = '9120',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_912,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_9120_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_919 SET
    code = '919',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_91,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_919_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_9191 SET
    code = '9191',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_919,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_9191_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_9192 SET
    code = '9192',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_919,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_9192_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_9199 SET
    code = '9199',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_919,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_9199_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_92 SET
    code = '92',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_o,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_92_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_921 SET
    code = '921',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_92,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_921_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_9211 SET
    code = '9211',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_921,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_9211_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_9212 SET
    code = '9212',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_921,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_9212_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_9213 SET
    code = '9213',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_921,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_9213_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_9214 SET
    code = '9214',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_921,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_9214_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_9219 SET
    code = '9219',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_921,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_9219_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_922 SET
    code = '922',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_92,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_922_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_9220 SET
    code = '9220',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_922,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_9220_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_923 SET
    code = '923',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_92,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_923_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_9231 SET
    code = '9231',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_923,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_9231_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_9232 SET
    code = '9232',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_923,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_9232_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_9233 SET
    code = '9233',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_923,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_9233_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_924 SET
    code = '924',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_92,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_924_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_9241 SET
    code = '9241',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_924,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_9241_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_9249 SET
    code = '9249',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_924,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_9249_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_93 SET
    code = '93',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_o,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_93_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_930 SET
    code = '930',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_93,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_930_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_9301 SET
    code = '9301',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_930,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_9301_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_9302 SET
    code = '9302',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_930,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_9302_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_9303 SET
    code = '9303',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_930,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_9303_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_9309 SET
    code = '9309',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_930,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_9309_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_p SET
    code = 'P',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:section,
    pays_reference = NONE,
    parent_code = NONE,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_p_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_95 SET
    code = '95',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_p,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_95_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_950 SET
    code = '950',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_95,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_950_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_9500 SET
    code = '9500',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_950,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_9500_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_96 SET
    code = '96',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_p,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_96_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_960 SET
    code = '960',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_96,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_960_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_9600 SET
    code = '9600',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_960,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_9600_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_97 SET
    code = '97',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_p,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_97_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_970 SET
    code = '970',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_97,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_970_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_9700 SET
    code = '9700',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_970,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_9700_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_q SET
    code = 'Q',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:section,
    pays_reference = NONE,
    parent_code = NONE,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_q_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_99 SET
    code = '99',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_q,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_99_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_990 SET
    code = '990',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_99,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_990_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1_9900 SET
    code = '9900',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_1_990,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1_9900_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

-- -------------------------------------------------------------------------------------------------
-- ISIC_Rev3 (528 codes)
-- -------------------------------------------------------------------------------------------------

CREATE society_activity_code:isic_rev3_a SET
    code = 'A',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:section,
    pays_reference = NONE,
    parent_code = NONE,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_a_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_01 SET
    code = '01',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_a,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_01_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_011 SET
    code = '011',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_01,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_011_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_0111 SET
    code = '0111',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_011,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_0111_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_0112 SET
    code = '0112',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_011,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_0112_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_0113 SET
    code = '0113',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_011,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_0113_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_012 SET
    code = '012',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_01,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_012_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_0121 SET
    code = '0121',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_012,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_0121_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_0122 SET
    code = '0122',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_012,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_0122_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_013 SET
    code = '013',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_01,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_013_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_0130 SET
    code = '0130',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_013,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_0130_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_014 SET
    code = '014',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_01,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_014_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_0140 SET
    code = '0140',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_014,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_0140_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_015 SET
    code = '015',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_01,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_015_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_0150 SET
    code = '0150',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_015,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_0150_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_02 SET
    code = '02',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_a,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_02_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_020 SET
    code = '020',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_02,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_020_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_0200 SET
    code = '0200',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_020,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_0200_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_b SET
    code = 'B',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:section,
    pays_reference = NONE,
    parent_code = NONE,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_b_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_05 SET
    code = '05',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_b,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_05_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_050 SET
    code = '050',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_05,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_050_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_0500 SET
    code = '0500',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_050,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_0500_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_c SET
    code = 'C',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:section,
    pays_reference = NONE,
    parent_code = NONE,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_c_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_10 SET
    code = '10',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_c,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_10_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_101 SET
    code = '101',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_10,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_101_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1010 SET
    code = '1010',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_101,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1010_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_102 SET
    code = '102',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_10,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_102_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1020 SET
    code = '1020',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_102,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1020_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_103 SET
    code = '103',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_10,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_103_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1030 SET
    code = '1030',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_103,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1030_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_11 SET
    code = '11',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_c,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_11_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_111 SET
    code = '111',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_11,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_111_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1110 SET
    code = '1110',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_111,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1110_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_112 SET
    code = '112',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_11,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_112_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1120 SET
    code = '1120',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_112,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1120_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_12 SET
    code = '12',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_c,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_12_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_120 SET
    code = '120',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_12,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_120_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1200 SET
    code = '1200',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_120,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1200_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_13 SET
    code = '13',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_c,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_13_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_131 SET
    code = '131',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_13,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_131_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1310 SET
    code = '1310',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_131,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1310_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_132 SET
    code = '132',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_13,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_132_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1320 SET
    code = '1320',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_132,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1320_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_14 SET
    code = '14',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_c,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_14_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_141 SET
    code = '141',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_14,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_141_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1410 SET
    code = '1410',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_141,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1410_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_142 SET
    code = '142',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_14,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_142_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1421 SET
    code = '1421',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_142,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1421_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1422 SET
    code = '1422',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_142,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1422_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1429 SET
    code = '1429',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_142,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1429_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_d SET
    code = 'D',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:section,
    pays_reference = NONE,
    parent_code = NONE,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_d_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_15 SET
    code = '15',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_d,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_15_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_151 SET
    code = '151',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_15,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_151_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1511 SET
    code = '1511',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_151,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1511_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1512 SET
    code = '1512',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_151,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1512_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1513 SET
    code = '1513',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_151,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1513_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1514 SET
    code = '1514',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_151,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1514_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_152 SET
    code = '152',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_15,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_152_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1520 SET
    code = '1520',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_152,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1520_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_153 SET
    code = '153',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_15,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_153_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1531 SET
    code = '1531',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_153,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1531_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1532 SET
    code = '1532',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_153,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1532_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1533 SET
    code = '1533',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_153,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1533_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_154 SET
    code = '154',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_15,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_154_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1541 SET
    code = '1541',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_154,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1541_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1542 SET
    code = '1542',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_154,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1542_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1543 SET
    code = '1543',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_154,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1543_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1544 SET
    code = '1544',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_154,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1544_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1549 SET
    code = '1549',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_154,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1549_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_155 SET
    code = '155',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_15,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_155_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1551 SET
    code = '1551',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_155,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1551_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1552 SET
    code = '1552',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_155,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1552_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1553 SET
    code = '1553',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_155,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1553_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1554 SET
    code = '1554',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_155,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1554_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_16 SET
    code = '16',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_d,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_16_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_160 SET
    code = '160',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_16,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_160_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1600 SET
    code = '1600',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_160,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1600_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_17 SET
    code = '17',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_d,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_17_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_171 SET
    code = '171',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_17,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_171_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1711 SET
    code = '1711',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_171,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1711_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1712 SET
    code = '1712',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_171,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1712_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_172 SET
    code = '172',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_17,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_172_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1721 SET
    code = '1721',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_172,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1721_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1722 SET
    code = '1722',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_172,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1722_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1723 SET
    code = '1723',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_172,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1723_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1729 SET
    code = '1729',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_172,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1729_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_173 SET
    code = '173',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_17,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_173_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1730 SET
    code = '1730',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_173,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1730_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_18 SET
    code = '18',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_d,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_18_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_181 SET
    code = '181',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_18,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_181_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1810 SET
    code = '1810',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_181,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1810_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_182 SET
    code = '182',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_18,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_182_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1820 SET
    code = '1820',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_182,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1820_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_19 SET
    code = '19',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_d,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_19_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_191 SET
    code = '191',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_19,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_191_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1911 SET
    code = '1911',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_191,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1911_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1912 SET
    code = '1912',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_191,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1912_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_192 SET
    code = '192',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_19,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_192_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_1920 SET
    code = '1920',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_192,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_1920_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_20 SET
    code = '20',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_d,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_20_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_201 SET
    code = '201',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_20,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_201_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_2010 SET
    code = '2010',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_201,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_2010_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_202 SET
    code = '202',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_20,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_202_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_2021 SET
    code = '2021',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_202,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_2021_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_2022 SET
    code = '2022',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_202,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_2022_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_2023 SET
    code = '2023',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_202,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_2023_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_2029 SET
    code = '2029',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_202,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_2029_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_21 SET
    code = '21',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_d,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_21_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_210 SET
    code = '210',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_21,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_210_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_2101 SET
    code = '2101',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_210,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_2101_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_2102 SET
    code = '2102',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_210,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_2102_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_2109 SET
    code = '2109',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_210,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_2109_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_22 SET
    code = '22',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_d,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_22_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_221 SET
    code = '221',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_22,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_221_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_2211 SET
    code = '2211',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_221,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_2211_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_2212 SET
    code = '2212',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_221,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_2212_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_2213 SET
    code = '2213',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_221,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_2213_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_2219 SET
    code = '2219',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_221,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_2219_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_222 SET
    code = '222',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_22,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_222_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_2221 SET
    code = '2221',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_222,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_2221_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_2222 SET
    code = '2222',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_222,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_2222_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_223 SET
    code = '223',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_22,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_223_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_2230 SET
    code = '2230',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_223,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_2230_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_23 SET
    code = '23',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_d,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_23_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_231 SET
    code = '231',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_23,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_231_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_2310 SET
    code = '2310',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_231,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_2310_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_232 SET
    code = '232',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_23,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_232_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_2320 SET
    code = '2320',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_232,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_2320_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_233 SET
    code = '233',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_23,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_233_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_2330 SET
    code = '2330',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_233,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_2330_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_24 SET
    code = '24',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_d,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_24_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_241 SET
    code = '241',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_24,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_241_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_2411 SET
    code = '2411',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_241,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_2411_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_2412 SET
    code = '2412',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_241,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_2412_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_2413 SET
    code = '2413',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_241,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_2413_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_242 SET
    code = '242',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_24,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_242_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_2421 SET
    code = '2421',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_242,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_2421_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_2422 SET
    code = '2422',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_242,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_2422_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_2423 SET
    code = '2423',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_242,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_2423_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_2424 SET
    code = '2424',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_242,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_2424_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_2429 SET
    code = '2429',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_242,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_2429_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_243 SET
    code = '243',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_24,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_243_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_2430 SET
    code = '2430',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_243,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_2430_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_25 SET
    code = '25',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_d,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_25_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_251 SET
    code = '251',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_25,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_251_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_2511 SET
    code = '2511',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_251,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_2511_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_2519 SET
    code = '2519',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_251,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_2519_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_252 SET
    code = '252',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_25,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_252_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_2520 SET
    code = '2520',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_252,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_2520_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_26 SET
    code = '26',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_d,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_26_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_261 SET
    code = '261',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_26,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_261_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_2610 SET
    code = '2610',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_261,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_2610_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_269 SET
    code = '269',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_26,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_269_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_2691 SET
    code = '2691',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_269,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_2691_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_2692 SET
    code = '2692',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_269,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_2692_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_2693 SET
    code = '2693',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_269,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_2693_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_2694 SET
    code = '2694',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_269,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_2694_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_2695 SET
    code = '2695',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_269,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_2695_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_2696 SET
    code = '2696',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_269,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_2696_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_2699 SET
    code = '2699',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_269,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_2699_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_27 SET
    code = '27',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_d,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_27_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_271 SET
    code = '271',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_27,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_271_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_2710 SET
    code = '2710',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_271,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_2710_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_272 SET
    code = '272',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_27,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_272_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_2720 SET
    code = '2720',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_272,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_2720_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_273 SET
    code = '273',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_27,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_273_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_2731 SET
    code = '2731',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_273,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_2731_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_2732 SET
    code = '2732',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_273,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_2732_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_28 SET
    code = '28',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_d,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_28_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_281 SET
    code = '281',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_28,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_281_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_2811 SET
    code = '2811',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_281,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_2811_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_2812 SET
    code = '2812',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_281,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_2812_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_2813 SET
    code = '2813',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_281,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_2813_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_289 SET
    code = '289',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_28,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_289_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_2891 SET
    code = '2891',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_289,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_2891_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_2892 SET
    code = '2892',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_289,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_2892_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_2893 SET
    code = '2893',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_289,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_2893_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_2899 SET
    code = '2899',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_289,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_2899_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_29 SET
    code = '29',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_d,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_29_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_291 SET
    code = '291',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_29,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_291_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_2911 SET
    code = '2911',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_291,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_2911_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_2912 SET
    code = '2912',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_291,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_2912_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_2913 SET
    code = '2913',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_291,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_2913_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_2914 SET
    code = '2914',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_291,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_2914_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_2915 SET
    code = '2915',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_291,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_2915_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_2919 SET
    code = '2919',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_291,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_2919_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_292 SET
    code = '292',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_29,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_292_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_2921 SET
    code = '2921',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_292,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_2921_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_2922 SET
    code = '2922',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_292,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_2922_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_2923 SET
    code = '2923',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_292,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_2923_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_2924 SET
    code = '2924',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_292,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_2924_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_2925 SET
    code = '2925',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_292,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_2925_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_2926 SET
    code = '2926',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_292,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_2926_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_2927 SET
    code = '2927',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_292,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_2927_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_2929 SET
    code = '2929',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_292,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_2929_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_293 SET
    code = '293',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_29,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_293_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_2930 SET
    code = '2930',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_293,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_2930_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_30 SET
    code = '30',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_d,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_30_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_300 SET
    code = '300',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_30,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_300_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_3000 SET
    code = '3000',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_300,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_3000_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_31 SET
    code = '31',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_d,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_31_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_311 SET
    code = '311',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_31,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_311_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_3110 SET
    code = '3110',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_311,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_3110_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_312 SET
    code = '312',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_31,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_312_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_3120 SET
    code = '3120',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_312,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_3120_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_313 SET
    code = '313',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_31,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_313_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_3130 SET
    code = '3130',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_313,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_3130_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_314 SET
    code = '314',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_31,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_314_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_3140 SET
    code = '3140',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_314,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_3140_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_315 SET
    code = '315',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_31,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_315_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_3150 SET
    code = '3150',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_315,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_3150_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_319 SET
    code = '319',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_31,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_319_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_3190 SET
    code = '3190',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_319,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_3190_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_32 SET
    code = '32',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_d,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_32_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_321 SET
    code = '321',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_32,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_321_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_3210 SET
    code = '3210',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_321,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_3210_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_322 SET
    code = '322',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_32,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_322_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_3220 SET
    code = '3220',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_322,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_3220_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_323 SET
    code = '323',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_32,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_323_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_3230 SET
    code = '3230',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_323,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_3230_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_33 SET
    code = '33',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_d,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_33_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_331 SET
    code = '331',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_33,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_331_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_3311 SET
    code = '3311',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_331,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_3311_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_3312 SET
    code = '3312',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_331,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_3312_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_3313 SET
    code = '3313',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_331,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_3313_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_332 SET
    code = '332',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_33,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_332_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_3320 SET
    code = '3320',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_332,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_3320_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_333 SET
    code = '333',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_33,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_333_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_3330 SET
    code = '3330',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_333,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_3330_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_34 SET
    code = '34',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_d,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_34_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_341 SET
    code = '341',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_34,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_341_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_3410 SET
    code = '3410',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_341,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_3410_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_342 SET
    code = '342',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_34,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_342_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_3420 SET
    code = '3420',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_342,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_3420_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_343 SET
    code = '343',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_34,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_343_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_3430 SET
    code = '3430',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_343,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_3430_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_35 SET
    code = '35',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_d,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_35_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_351 SET
    code = '351',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_35,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_351_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_3511 SET
    code = '3511',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_351,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_3511_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_3512 SET
    code = '3512',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_351,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_3512_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_352 SET
    code = '352',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_35,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_352_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_3520 SET
    code = '3520',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_352,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_3520_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_353 SET
    code = '353',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_35,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_353_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_3530 SET
    code = '3530',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_353,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_3530_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_359 SET
    code = '359',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_35,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_359_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_3591 SET
    code = '3591',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_359,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_3591_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_3592 SET
    code = '3592',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_359,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_3592_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_3599 SET
    code = '3599',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_359,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_3599_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_36 SET
    code = '36',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_d,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_36_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_361 SET
    code = '361',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_36,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_361_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_3610 SET
    code = '3610',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_361,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_3610_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_369 SET
    code = '369',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_36,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_369_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_3691 SET
    code = '3691',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_369,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_3691_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_3692 SET
    code = '3692',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_369,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_3692_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_3693 SET
    code = '3693',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_369,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_3693_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_3694 SET
    code = '3694',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_369,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_3694_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_3699 SET
    code = '3699',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_369,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_3699_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_37 SET
    code = '37',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_d,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_37_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_371 SET
    code = '371',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_37,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_371_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_3710 SET
    code = '3710',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_371,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_3710_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_372 SET
    code = '372',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_37,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_372_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_3720 SET
    code = '3720',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_372,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_3720_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_e SET
    code = 'E',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:section,
    pays_reference = NONE,
    parent_code = NONE,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_e_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_40 SET
    code = '40',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_e,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_40_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_401 SET
    code = '401',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_40,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_401_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_4010 SET
    code = '4010',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_401,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_4010_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_402 SET
    code = '402',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_40,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_402_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_4020 SET
    code = '4020',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_402,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_4020_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_403 SET
    code = '403',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_40,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_403_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_4030 SET
    code = '4030',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_403,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_4030_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_41 SET
    code = '41',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_e,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_41_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_410 SET
    code = '410',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_41,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_410_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_4100 SET
    code = '4100',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_410,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_4100_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_f SET
    code = 'F',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:section,
    pays_reference = NONE,
    parent_code = NONE,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_f_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_45 SET
    code = '45',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_f,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_45_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_451 SET
    code = '451',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_45,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_451_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_4510 SET
    code = '4510',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_451,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_4510_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_452 SET
    code = '452',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_45,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_452_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_4520 SET
    code = '4520',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_452,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_4520_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_453 SET
    code = '453',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_45,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_453_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_4530 SET
    code = '4530',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_453,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_4530_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_454 SET
    code = '454',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_45,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_454_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_4540 SET
    code = '4540',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_454,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_4540_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_455 SET
    code = '455',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_45,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_455_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_4550 SET
    code = '4550',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_455,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_4550_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_g SET
    code = 'G',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:section,
    pays_reference = NONE,
    parent_code = NONE,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_g_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_50 SET
    code = '50',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_g,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_50_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_501 SET
    code = '501',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_50,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_501_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_5010 SET
    code = '5010',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_501,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_5010_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_502 SET
    code = '502',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_50,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_502_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_5020 SET
    code = '5020',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_502,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_5020_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_503 SET
    code = '503',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_50,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_503_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_5030 SET
    code = '5030',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_503,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_5030_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_504 SET
    code = '504',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_50,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_504_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_5040 SET
    code = '5040',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_504,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_5040_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_505 SET
    code = '505',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_50,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_505_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_5050 SET
    code = '5050',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_505,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_5050_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_51 SET
    code = '51',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_g,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_51_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_511 SET
    code = '511',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_51,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_511_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_5110 SET
    code = '5110',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_511,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_5110_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_512 SET
    code = '512',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_51,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_512_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_5121 SET
    code = '5121',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_512,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_5121_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_5122 SET
    code = '5122',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_512,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_5122_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_513 SET
    code = '513',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_51,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_513_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_5131 SET
    code = '5131',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_513,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_5131_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_5139 SET
    code = '5139',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_513,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_5139_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_514 SET
    code = '514',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_51,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_514_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_5141 SET
    code = '5141',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_514,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_5141_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_5142 SET
    code = '5142',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_514,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_5142_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_5143 SET
    code = '5143',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_514,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_5143_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_5149 SET
    code = '5149',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_514,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_5149_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_515 SET
    code = '515',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_51,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_515_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_5150 SET
    code = '5150',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_515,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_5150_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_519 SET
    code = '519',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_51,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_519_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_5190 SET
    code = '5190',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_519,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_5190_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_52 SET
    code = '52',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_g,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_52_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_521 SET
    code = '521',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_52,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_521_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_5211 SET
    code = '5211',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_521,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_5211_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_5219 SET
    code = '5219',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_521,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_5219_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_522 SET
    code = '522',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_52,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_522_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_5220 SET
    code = '5220',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_522,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_5220_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_523 SET
    code = '523',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_52,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_523_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_5231 SET
    code = '5231',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_523,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_5231_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_5232 SET
    code = '5232',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_523,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_5232_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_5233 SET
    code = '5233',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_523,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_5233_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_5234 SET
    code = '5234',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_523,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_5234_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_5239 SET
    code = '5239',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_523,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_5239_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_524 SET
    code = '524',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_52,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_524_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_5240 SET
    code = '5240',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_524,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_5240_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_525 SET
    code = '525',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_52,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_525_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_5251 SET
    code = '5251',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_525,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_5251_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_5252 SET
    code = '5252',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_525,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_5252_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_5259 SET
    code = '5259',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_525,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_5259_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_526 SET
    code = '526',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_52,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_526_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_5260 SET
    code = '5260',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_526,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_5260_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_h SET
    code = 'H',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:section,
    pays_reference = NONE,
    parent_code = NONE,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_h_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_55 SET
    code = '55',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_h,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_55_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_551 SET
    code = '551',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_55,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_551_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_5510 SET
    code = '5510',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_551,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_5510_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_552 SET
    code = '552',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_55,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_552_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_5520 SET
    code = '5520',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_552,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_5520_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_i SET
    code = 'I',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:section,
    pays_reference = NONE,
    parent_code = NONE,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_i_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_60 SET
    code = '60',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_i,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_60_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_601 SET
    code = '601',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_60,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_601_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_6010 SET
    code = '6010',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_601,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_6010_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_602 SET
    code = '602',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_60,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_602_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_6021 SET
    code = '6021',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_602,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_6021_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_6022 SET
    code = '6022',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_602,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_6022_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_6023 SET
    code = '6023',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_602,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_6023_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_603 SET
    code = '603',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_60,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_603_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_6030 SET
    code = '6030',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_603,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_6030_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_61 SET
    code = '61',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_i,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_61_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_611 SET
    code = '611',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_61,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_611_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_6110 SET
    code = '6110',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_611,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_6110_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_612 SET
    code = '612',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_61,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_612_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_6120 SET
    code = '6120',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_612,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_6120_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_62 SET
    code = '62',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_i,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_62_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_621 SET
    code = '621',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_62,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_621_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_6210 SET
    code = '6210',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_621,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_6210_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_622 SET
    code = '622',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_62,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_622_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_6220 SET
    code = '6220',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_622,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_6220_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_63 SET
    code = '63',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_i,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_63_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_630 SET
    code = '630',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_63,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_630_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_6301 SET
    code = '6301',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_630,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_6301_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_6302 SET
    code = '6302',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_630,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_6302_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_6303 SET
    code = '6303',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_630,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_6303_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_6304 SET
    code = '6304',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_630,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_6304_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_6309 SET
    code = '6309',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_630,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_6309_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_64 SET
    code = '64',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_i,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_64_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_641 SET
    code = '641',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_64,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_641_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_6411 SET
    code = '6411',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_641,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_6411_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_6412 SET
    code = '6412',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_641,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_6412_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_642 SET
    code = '642',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_64,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_642_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_6420 SET
    code = '6420',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_642,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_6420_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_j SET
    code = 'J',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:section,
    pays_reference = NONE,
    parent_code = NONE,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_j_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_65 SET
    code = '65',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_j,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_65_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_651 SET
    code = '651',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_65,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_651_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_6511 SET
    code = '6511',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_651,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_6511_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_6519 SET
    code = '6519',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_651,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_6519_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_659 SET
    code = '659',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_65,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_659_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_6591 SET
    code = '6591',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_659,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_6591_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_6592 SET
    code = '6592',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_659,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_6592_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_6599 SET
    code = '6599',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_659,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_6599_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_66 SET
    code = '66',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_j,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_66_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_660 SET
    code = '660',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_66,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_660_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_6601 SET
    code = '6601',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_660,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_6601_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_6602 SET
    code = '6602',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_660,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_6602_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_6603 SET
    code = '6603',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_660,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_6603_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_67 SET
    code = '67',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_j,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_67_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_671 SET
    code = '671',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_67,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_671_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_6711 SET
    code = '6711',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_671,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_6711_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_6712 SET
    code = '6712',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_671,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_6712_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_6719 SET
    code = '6719',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_671,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_6719_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_672 SET
    code = '672',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_67,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_672_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_6720 SET
    code = '6720',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_672,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_6720_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_k SET
    code = 'K',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:section,
    pays_reference = NONE,
    parent_code = NONE,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_k_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_70 SET
    code = '70',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_k,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_70_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_701 SET
    code = '701',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_70,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_701_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_7010 SET
    code = '7010',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_701,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_7010_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_702 SET
    code = '702',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_70,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_702_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_7020 SET
    code = '7020',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_702,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_7020_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_71 SET
    code = '71',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_k,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_71_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_711 SET
    code = '711',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_71,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_711_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_7111 SET
    code = '7111',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_711,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_7111_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_7112 SET
    code = '7112',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_711,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_7112_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_7113 SET
    code = '7113',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_711,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_7113_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_712 SET
    code = '712',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_71,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_712_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_7121 SET
    code = '7121',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_712,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_7121_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_7122 SET
    code = '7122',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_712,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_7122_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_7123 SET
    code = '7123',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_712,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_7123_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_7129 SET
    code = '7129',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_712,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_7129_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_713 SET
    code = '713',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_71,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_713_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_7130 SET
    code = '7130',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_713,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_7130_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_72 SET
    code = '72',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_k,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_72_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_721 SET
    code = '721',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_72,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_721_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_7210 SET
    code = '7210',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_721,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_7210_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_722 SET
    code = '722',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_72,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_722_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_7220 SET
    code = '7220',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_722,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_7220_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_723 SET
    code = '723',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_72,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_723_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_7230 SET
    code = '7230',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_723,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_7230_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_724 SET
    code = '724',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_72,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_724_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_7240 SET
    code = '7240',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_724,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_7240_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_725 SET
    code = '725',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_72,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_725_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_7250 SET
    code = '7250',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_725,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_7250_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_729 SET
    code = '729',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_72,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_729_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_7290 SET
    code = '7290',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_729,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_7290_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_73 SET
    code = '73',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_k,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_73_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_731 SET
    code = '731',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_73,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_731_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_7310 SET
    code = '7310',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_731,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_7310_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_732 SET
    code = '732',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_73,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_732_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_7320 SET
    code = '7320',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_732,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_7320_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_74 SET
    code = '74',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_k,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_74_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_741 SET
    code = '741',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_74,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_741_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_7411 SET
    code = '7411',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_741,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_7411_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_7412 SET
    code = '7412',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_741,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_7412_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_7413 SET
    code = '7413',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_741,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_7413_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_7414 SET
    code = '7414',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_741,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_7414_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_742 SET
    code = '742',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_74,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_742_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_7421 SET
    code = '7421',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_742,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_7421_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_7422 SET
    code = '7422',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_742,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_7422_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_743 SET
    code = '743',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_74,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_743_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_7430 SET
    code = '7430',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_743,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_7430_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_749 SET
    code = '749',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_74,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_749_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_7491 SET
    code = '7491',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_749,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_7491_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_7492 SET
    code = '7492',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_749,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_7492_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_7493 SET
    code = '7493',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_749,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_7493_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_7494 SET
    code = '7494',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_749,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_7494_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_7495 SET
    code = '7495',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_749,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_7495_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_7499 SET
    code = '7499',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_749,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_7499_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_l SET
    code = 'L',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:section,
    pays_reference = NONE,
    parent_code = NONE,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_l_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_75 SET
    code = '75',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_l,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_75_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_751 SET
    code = '751',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_75,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_751_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_7511 SET
    code = '7511',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_751,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_7511_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_7512 SET
    code = '7512',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_751,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_7512_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_7513 SET
    code = '7513',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_751,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_7513_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_7514 SET
    code = '7514',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_751,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_7514_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_752 SET
    code = '752',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_75,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_752_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_7521 SET
    code = '7521',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_752,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_7521_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_7522 SET
    code = '7522',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_752,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_7522_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_7523 SET
    code = '7523',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_752,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_7523_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_753 SET
    code = '753',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_75,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_753_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_7530 SET
    code = '7530',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_753,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_7530_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_m SET
    code = 'M',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:section,
    pays_reference = NONE,
    parent_code = NONE,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_m_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_80 SET
    code = '80',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_m,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_80_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_801 SET
    code = '801',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_80,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_801_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_8010 SET
    code = '8010',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_801,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_8010_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_802 SET
    code = '802',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_80,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_802_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_8021 SET
    code = '8021',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_802,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_8021_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_8022 SET
    code = '8022',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_802,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_8022_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_803 SET
    code = '803',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_80,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_803_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_8030 SET
    code = '8030',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_803,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_8030_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_809 SET
    code = '809',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_80,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_809_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_8090 SET
    code = '8090',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_809,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_8090_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_n SET
    code = 'N',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:section,
    pays_reference = NONE,
    parent_code = NONE,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_n_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_85 SET
    code = '85',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_n,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_85_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_851 SET
    code = '851',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_85,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_851_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_8511 SET
    code = '8511',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_851,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_8511_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_8512 SET
    code = '8512',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_851,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_8512_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_8519 SET
    code = '8519',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_851,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_8519_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_852 SET
    code = '852',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_85,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_852_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_8520 SET
    code = '8520',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_852,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_8520_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_853 SET
    code = '853',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_85,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_853_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_8531 SET
    code = '8531',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_853,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_8531_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_8532 SET
    code = '8532',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_853,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_8532_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_o SET
    code = 'O',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:section,
    pays_reference = NONE,
    parent_code = NONE,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_o_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_90 SET
    code = '90',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_o,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_90_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_900 SET
    code = '900',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_90,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_900_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_9000 SET
    code = '9000',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_900,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_9000_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_91 SET
    code = '91',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_o,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_91_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_911 SET
    code = '911',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_91,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_911_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_9111 SET
    code = '9111',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_911,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_9111_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_9112 SET
    code = '9112',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_911,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_9112_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_912 SET
    code = '912',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_91,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_912_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_9120 SET
    code = '9120',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_912,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_9120_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_919 SET
    code = '919',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_91,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_919_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_9191 SET
    code = '9191',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_919,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_9191_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_9192 SET
    code = '9192',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_919,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_9192_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_9199 SET
    code = '9199',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_919,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_9199_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_92 SET
    code = '92',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_o,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_92_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_921 SET
    code = '921',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_92,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_921_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_9211 SET
    code = '9211',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_921,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_9211_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_9212 SET
    code = '9212',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_921,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_9212_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_9213 SET
    code = '9213',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_921,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_9213_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_9214 SET
    code = '9214',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_921,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_9214_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_9219 SET
    code = '9219',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_921,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_9219_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_922 SET
    code = '922',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_92,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_922_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_9220 SET
    code = '9220',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_922,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_9220_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_923 SET
    code = '923',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_92,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_923_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_9231 SET
    code = '9231',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_923,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_9231_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_9232 SET
    code = '9232',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_923,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_9232_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_9233 SET
    code = '9233',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_923,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_9233_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_924 SET
    code = '924',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_92,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_924_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_9241 SET
    code = '9241',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_924,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_9241_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_9249 SET
    code = '9249',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_924,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_9249_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_93 SET
    code = '93',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_o,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_93_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_930 SET
    code = '930',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_93,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_930_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_9301 SET
    code = '9301',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_930,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_9301_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_9302 SET
    code = '9302',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_930,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_9302_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_9303 SET
    code = '9303',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_930,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_9303_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_9309 SET
    code = '9309',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_930,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_9309_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_p SET
    code = 'P',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:section,
    pays_reference = NONE,
    parent_code = NONE,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_p_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_95 SET
    code = '95',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_p,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_95_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_950 SET
    code = '950',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_95,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_950_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_9500 SET
    code = '9500',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_950,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_9500_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_q SET
    code = 'Q',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:section,
    pays_reference = NONE,
    parent_code = NONE,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_q_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_99 SET
    code = '99',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_q,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_99_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_990 SET
    code = '990',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_99,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_990_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev3_9900 SET
    code = '9900',
    nomenclature_type = society_activity_nomenclature_type:isic_rev3,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev3_990,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev3_9900_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

-- -------------------------------------------------------------------------------------------------
-- ISIC_Rev2 (276 codes)
-- -------------------------------------------------------------------------------------------------

CREATE society_activity_code:isic_rev2_1 SET
    code = '1',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:section,
    pays_reference = NONE,
    parent_code = NONE,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_1_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_11 SET
    code = '11',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_11_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_111 SET
    code = '111',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_11,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_111_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_1110 SET
    code = '1110',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_111,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_1110_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_112 SET
    code = '112',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_11,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_112_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_1120 SET
    code = '1120',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_112,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_1120_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_113 SET
    code = '113',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_11,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_113_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_1130 SET
    code = '1130',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_113,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_1130_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_12 SET
    code = '12',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_12_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_121 SET
    code = '121',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_12,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_121_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_1210 SET
    code = '1210',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_121,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_1210_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_122 SET
    code = '122',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_12,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_122_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_1220 SET
    code = '1220',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_122,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_1220_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_13 SET
    code = '13',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_13_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_130 SET
    code = '130',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_13,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_130_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_1301 SET
    code = '1301',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_130,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_1301_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_1302 SET
    code = '1302',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_130,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_1302_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_2 SET
    code = '2',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:section,
    pays_reference = NONE,
    parent_code = NONE,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_2_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_21 SET
    code = '21',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_21_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_210 SET
    code = '210',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_21,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_210_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_2100 SET
    code = '2100',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_210,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_2100_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_22 SET
    code = '22',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_22_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_220 SET
    code = '220',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_22,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_220_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_2200 SET
    code = '2200',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_220,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_2200_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_23 SET
    code = '23',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_23_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_230 SET
    code = '230',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_23,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_230_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_2301 SET
    code = '2301',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_230,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_2301_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_2302 SET
    code = '2302',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_230,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_2302_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_29 SET
    code = '29',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_29_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_290 SET
    code = '290',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_29,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_290_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_2901 SET
    code = '2901',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_290,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_2901_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_2902 SET
    code = '2902',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_290,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_2902_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_2903 SET
    code = '2903',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_290,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_2903_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_2909 SET
    code = '2909',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_290,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_2909_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_3 SET
    code = '3',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:section,
    pays_reference = NONE,
    parent_code = NONE,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_3_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_31 SET
    code = '31',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_31_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_311_312 SET
    code = '311-312',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:unknown,
    pays_reference = NONE,
    parent_code = NONE,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_311_312_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_3111 SET
    code = '3111',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_311,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_3111_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_3112 SET
    code = '3112',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_311,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_3112_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_3113 SET
    code = '3113',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_311,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_3113_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_3114 SET
    code = '3114',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_311,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_3114_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_3115 SET
    code = '3115',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_311,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_3115_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_3116 SET
    code = '3116',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_311,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_3116_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_3117 SET
    code = '3117',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_311,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_3117_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_3118 SET
    code = '3118',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_311,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_3118_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_3119 SET
    code = '3119',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_311,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_3119_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_3121 SET
    code = '3121',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_312,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_3121_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_3122 SET
    code = '3122',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_312,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_3122_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_313 SET
    code = '313',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_31,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_313_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_3131 SET
    code = '3131',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_313,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_3131_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_3132 SET
    code = '3132',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_313,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_3132_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_3133 SET
    code = '3133',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_313,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_3133_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_3134 SET
    code = '3134',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_313,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_3134_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_314 SET
    code = '314',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_31,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_314_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_3140 SET
    code = '3140',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_314,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_3140_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_32 SET
    code = '32',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_32_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_321 SET
    code = '321',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_32,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_321_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_3211 SET
    code = '3211',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_321,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_3211_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_3212 SET
    code = '3212',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_321,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_3212_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_3213 SET
    code = '3213',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_321,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_3213_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_3214 SET
    code = '3214',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_321,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_3214_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_3215 SET
    code = '3215',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_321,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_3215_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_3219 SET
    code = '3219',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_321,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_3219_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_322 SET
    code = '322',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_32,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_322_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_3220 SET
    code = '3220',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_322,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_3220_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_323 SET
    code = '323',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_32,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_323_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_3231 SET
    code = '3231',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_323,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_3231_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_3232 SET
    code = '3232',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_323,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_3232_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_3233 SET
    code = '3233',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_323,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_3233_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_324 SET
    code = '324',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_32,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_324_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_3240 SET
    code = '3240',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_324,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_3240_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_33 SET
    code = '33',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_33_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_331 SET
    code = '331',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_33,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_331_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_3311 SET
    code = '3311',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_331,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_3311_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_3312 SET
    code = '3312',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_331,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_3312_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_3319 SET
    code = '3319',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_331,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_3319_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_332 SET
    code = '332',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_33,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_332_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_3320 SET
    code = '3320',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_332,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_3320_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_34 SET
    code = '34',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_34_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_341 SET
    code = '341',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_34,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_341_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_3411 SET
    code = '3411',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_341,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_3411_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_3412 SET
    code = '3412',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_341,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_3412_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_3419 SET
    code = '3419',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_341,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_3419_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_342 SET
    code = '342',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_34,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_342_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_3420 SET
    code = '3420',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_342,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_3420_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_35 SET
    code = '35',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_35_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_351 SET
    code = '351',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_35,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_351_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_3511 SET
    code = '3511',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_351,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_3511_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_3512 SET
    code = '3512',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_351,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_3512_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_3513 SET
    code = '3513',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_351,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_3513_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_352 SET
    code = '352',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_35,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_352_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_3521 SET
    code = '3521',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_352,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_3521_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_3522 SET
    code = '3522',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_352,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_3522_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_3523 SET
    code = '3523',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_352,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_3523_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_3529 SET
    code = '3529',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_352,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_3529_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_353 SET
    code = '353',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_35,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_353_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_3530 SET
    code = '3530',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_353,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_3530_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_354 SET
    code = '354',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_35,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_354_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_3540 SET
    code = '3540',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_354,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_3540_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_355 SET
    code = '355',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_35,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_355_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_3551 SET
    code = '3551',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_355,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_3551_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_3559 SET
    code = '3559',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_355,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_3559_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_356 SET
    code = '356',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_35,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_356_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_3560 SET
    code = '3560',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_356,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_3560_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_36 SET
    code = '36',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_36_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_361 SET
    code = '361',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_36,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_361_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_3610 SET
    code = '3610',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_361,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_3610_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_362 SET
    code = '362',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_36,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_362_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_3620 SET
    code = '3620',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_362,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_3620_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_369 SET
    code = '369',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_36,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_369_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_3691 SET
    code = '3691',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_369,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_3691_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_3692 SET
    code = '3692',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_369,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_3692_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_3699 SET
    code = '3699',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_369,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_3699_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_37 SET
    code = '37',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_37_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_371 SET
    code = '371',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_37,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_371_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_3710 SET
    code = '3710',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_371,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_3710_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_372 SET
    code = '372',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_37,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_372_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_3720 SET
    code = '3720',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_372,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_3720_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_38 SET
    code = '38',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_38_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_381 SET
    code = '381',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_38,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_381_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_3811 SET
    code = '3811',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_381,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_3811_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_3812 SET
    code = '3812',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_381,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_3812_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_3813 SET
    code = '3813',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_381,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_3813_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_3819 SET
    code = '3819',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_381,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_3819_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_382 SET
    code = '382',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_38,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_382_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_3821 SET
    code = '3821',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_382,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_3821_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_3822 SET
    code = '3822',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_382,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_3822_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_3823 SET
    code = '3823',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_382,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_3823_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_3824 SET
    code = '3824',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_382,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_3824_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_3825 SET
    code = '3825',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_382,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_3825_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_3829 SET
    code = '3829',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_382,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_3829_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_383 SET
    code = '383',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_38,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_383_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_3831 SET
    code = '3831',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_383,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_3831_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_3832 SET
    code = '3832',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_383,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_3832_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_3833 SET
    code = '3833',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_383,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_3833_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_3839 SET
    code = '3839',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_383,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_3839_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_384 SET
    code = '384',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_38,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_384_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_3841 SET
    code = '3841',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_384,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_3841_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_3842 SET
    code = '3842',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_384,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_3842_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_3843 SET
    code = '3843',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_384,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_3843_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_3844 SET
    code = '3844',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_384,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_3844_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_3845 SET
    code = '3845',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_384,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_3845_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_3849 SET
    code = '3849',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_384,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_3849_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_385 SET
    code = '385',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_38,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_385_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_3851 SET
    code = '3851',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_385,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_3851_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_3852 SET
    code = '3852',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_385,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_3852_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_3853 SET
    code = '3853',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_385,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_3853_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_39 SET
    code = '39',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_39_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_390 SET
    code = '390',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_39,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_390_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_3901 SET
    code = '3901',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_390,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_3901_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_3902 SET
    code = '3902',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_390,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_3902_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_3903 SET
    code = '3903',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_390,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_3903_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_3909 SET
    code = '3909',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_390,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_3909_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_4 SET
    code = '4',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:section,
    pays_reference = NONE,
    parent_code = NONE,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_4_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_41 SET
    code = '41',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_4,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_41_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_410 SET
    code = '410',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_41,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_410_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_4101 SET
    code = '4101',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_410,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_4101_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_4102 SET
    code = '4102',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_410,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_4102_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_4103 SET
    code = '4103',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_410,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_4103_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_42 SET
    code = '42',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_4,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_42_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_420 SET
    code = '420',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_42,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_420_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_4200 SET
    code = '4200',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_420,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_4200_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_5 SET
    code = '5',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:section,
    pays_reference = NONE,
    parent_code = NONE,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_5_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_50 SET
    code = '50',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_5,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_50_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_500 SET
    code = '500',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_50,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_500_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_5000 SET
    code = '5000',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_500,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_5000_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_6 SET
    code = '6',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:section,
    pays_reference = NONE,
    parent_code = NONE,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_6_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_61 SET
    code = '61',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_6,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_61_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_610 SET
    code = '610',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_61,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_610_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_6100 SET
    code = '6100',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_610,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_6100_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_62 SET
    code = '62',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_6,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_62_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_620 SET
    code = '620',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_62,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_620_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_6200 SET
    code = '6200',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_620,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_6200_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_63 SET
    code = '63',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_6,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_63_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_631 SET
    code = '631',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_63,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_631_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_6310 SET
    code = '6310',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_631,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_6310_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_632 SET
    code = '632',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_63,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_632_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_6320 SET
    code = '6320',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_632,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_6320_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_7 SET
    code = '7',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:section,
    pays_reference = NONE,
    parent_code = NONE,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_7_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_71 SET
    code = '71',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_7,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_71_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_711 SET
    code = '711',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_71,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_711_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_7111 SET
    code = '7111',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_711,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_7111_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_7112 SET
    code = '7112',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_711,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_7112_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_7113 SET
    code = '7113',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_711,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_7113_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_7114 SET
    code = '7114',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_711,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_7114_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_7115 SET
    code = '7115',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_711,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_7115_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_7116 SET
    code = '7116',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_711,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_7116_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_712 SET
    code = '712',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_71,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_712_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_7121 SET
    code = '7121',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_712,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_7121_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_7122 SET
    code = '7122',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_712,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_7122_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_7123 SET
    code = '7123',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_712,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_7123_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_713 SET
    code = '713',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_71,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_713_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_7131 SET
    code = '7131',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_713,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_7131_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_7132 SET
    code = '7132',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_713,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_7132_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_719 SET
    code = '719',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_71,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_719_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_7191 SET
    code = '7191',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_719,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_7191_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_7192 SET
    code = '7192',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_719,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_7192_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_72 SET
    code = '72',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_7,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_72_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_720 SET
    code = '720',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_72,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_720_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_7200 SET
    code = '7200',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_720,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_7200_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_8 SET
    code = '8',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:section,
    pays_reference = NONE,
    parent_code = NONE,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_8_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_81 SET
    code = '81',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_8,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_81_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_810 SET
    code = '810',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_81,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_810_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_8101 SET
    code = '8101',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_810,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_8101_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_8102 SET
    code = '8102',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_810,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_8102_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_8103 SET
    code = '8103',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_810,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_8103_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_82 SET
    code = '82',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_8,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_82_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_820 SET
    code = '820',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_82,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_820_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_8200 SET
    code = '8200',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_820,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_8200_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_83 SET
    code = '83',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_8,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_83_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_831 SET
    code = '831',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_83,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_831_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_8310 SET
    code = '8310',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_831,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_8310_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_832 SET
    code = '832',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_83,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_832_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_8321 SET
    code = '8321',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_832,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_8321_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_8322 SET
    code = '8322',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_832,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_8322_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_8323 SET
    code = '8323',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_832,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_8323_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_8324 SET
    code = '8324',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_832,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_8324_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_8325 SET
    code = '8325',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_832,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_8325_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_8329 SET
    code = '8329',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_832,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_8329_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_833 SET
    code = '833',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_83,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_833_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_8330 SET
    code = '8330',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_833,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_8330_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_9 SET
    code = '9',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:section,
    pays_reference = NONE,
    parent_code = NONE,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_9_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_91 SET
    code = '91',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_9,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_91_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_910 SET
    code = '910',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_91,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_910_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_9100 SET
    code = '9100',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_910,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_9100_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_92 SET
    code = '92',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_9,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_92_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_920 SET
    code = '920',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_92,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_920_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_9200 SET
    code = '9200',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_920,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_9200_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_93 SET
    code = '93',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_9,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_93_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_931 SET
    code = '931',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_93,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_931_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_9310 SET
    code = '9310',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_931,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_9310_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_932 SET
    code = '932',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_93,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_932_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_9320 SET
    code = '9320',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_932,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_9320_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_933 SET
    code = '933',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_93,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_933_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_9331 SET
    code = '9331',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_933,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_9331_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_9332 SET
    code = '9332',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_933,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_9332_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_934 SET
    code = '934',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_93,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_934_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_9340 SET
    code = '9340',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_934,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_9340_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_935 SET
    code = '935',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_93,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_935_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_9350 SET
    code = '9350',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_935,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_9350_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_939 SET
    code = '939',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_93,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_939_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_9391 SET
    code = '9391',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_939,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_9391_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_9399 SET
    code = '9399',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_939,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_9399_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_94 SET
    code = '94',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_9,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_94_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_941 SET
    code = '941',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_94,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_941_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_9411 SET
    code = '9411',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_941,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_9411_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_9412 SET
    code = '9412',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_941,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_9412_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_9413 SET
    code = '9413',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_941,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_9413_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_9414 SET
    code = '9414',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_941,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_9414_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_9415 SET
    code = '9415',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_941,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_9415_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_942 SET
    code = '942',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_94,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_942_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_9420 SET
    code = '9420',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_942,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_9420_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_949 SET
    code = '949',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_94,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_949_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_9490 SET
    code = '9490',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_949,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_9490_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_95 SET
    code = '95',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_9,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_95_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_951 SET
    code = '951',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_95,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_951_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_9511 SET
    code = '9511',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_951,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_9511_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_9512 SET
    code = '9512',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_951,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_9512_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_9513 SET
    code = '9513',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_951,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_9513_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_9514 SET
    code = '9514',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_951,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_9514_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_9519 SET
    code = '9519',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_951,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_9519_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_952 SET
    code = '952',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_95,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_952_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_9520 SET
    code = '9520',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_952,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_9520_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_953 SET
    code = '953',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_95,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_953_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_9530 SET
    code = '9530',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_953,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_9530_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_959 SET
    code = '959',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_95,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_959_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_9591 SET
    code = '9591',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_959,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_9591_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_9592 SET
    code = '9592',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_959,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_9592_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_9599 SET
    code = '9599',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_959,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_9599_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_96 SET
    code = '96',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_9,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_96_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_960 SET
    code = '960',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_96,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_960_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_9600 SET
    code = '9600',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_960,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_9600_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_0 SET
    code = '0',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:section,
    pays_reference = NONE,
    parent_code = NONE,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_0_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_00 SET
    code = '00',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_0,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_00_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_000 SET
    code = '000',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_00,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_000_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:isic_rev2_0000 SET
    code = '0000',
    nomenclature_type = society_activity_nomenclature_type:isic_rev2,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:isic_rev2_000,
    libelle_long_i18n_key = i18n_key:society_activity_code_isic_rev2_0000_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;


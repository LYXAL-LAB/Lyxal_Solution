-- =================================================================================================
-- SEEDS: society_activity_code (EUROPE - NACE Rev 2.1)
-- Total: 1,047 codes
-- Source: Eurostat
-- =================================================================================================

CREATE society_activity_code:nace_rev2_a SET
    code = 'A',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:section,
    pays_reference = NONE,
    parent_code = NONE,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_a_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_01 SET
    code = '01',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_a,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_01_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_01_1 SET
    code = '01.1',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_01,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_01_1_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_01_11 SET
    code = '01.11',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_01_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_01_11_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_01_12 SET
    code = '01.12',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_01_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_01_12_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_01_13 SET
    code = '01.13',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_01_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_01_13_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_01_14 SET
    code = '01.14',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_01_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_01_14_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_01_15 SET
    code = '01.15',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_01_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_01_15_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_01_16 SET
    code = '01.16',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_01_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_01_16_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_01_19 SET
    code = '01.19',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_01_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_01_19_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_01_2 SET
    code = '01.2',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_01,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_01_2_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_01_21 SET
    code = '01.21',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_01_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_01_21_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_01_22 SET
    code = '01.22',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_01_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_01_22_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_01_23 SET
    code = '01.23',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_01_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_01_23_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_01_24 SET
    code = '01.24',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_01_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_01_24_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_01_25 SET
    code = '01.25',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_01_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_01_25_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_01_26 SET
    code = '01.26',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_01_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_01_26_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_01_27 SET
    code = '01.27',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_01_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_01_27_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_01_28 SET
    code = '01.28',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_01_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_01_28_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_01_29 SET
    code = '01.29',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_01_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_01_29_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_01_3 SET
    code = '01.3',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_01,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_01_3_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_01_30 SET
    code = '01.30',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_01_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_01_30_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_01_4 SET
    code = '01.4',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_01,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_01_4_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_01_41 SET
    code = '01.41',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_01_4,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_01_41_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_01_42 SET
    code = '01.42',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_01_4,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_01_42_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_01_43 SET
    code = '01.43',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_01_4,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_01_43_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_01_44 SET
    code = '01.44',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_01_4,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_01_44_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_01_45 SET
    code = '01.45',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_01_4,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_01_45_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_01_46 SET
    code = '01.46',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_01_4,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_01_46_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_01_47 SET
    code = '01.47',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_01_4,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_01_47_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_01_48 SET
    code = '01.48',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_01_4,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_01_48_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_01_5 SET
    code = '01.5',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_01,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_01_5_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_01_50 SET
    code = '01.50',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_01_5,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_01_50_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_01_6 SET
    code = '01.6',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_01,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_01_6_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_01_61 SET
    code = '01.61',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_01_6,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_01_61_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_01_62 SET
    code = '01.62',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_01_6,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_01_62_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_01_63 SET
    code = '01.63',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_01_6,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_01_63_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_01_7 SET
    code = '01.7',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_01,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_01_7_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_01_70 SET
    code = '01.70',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_01_7,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_01_70_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_02 SET
    code = '02',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_a,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_02_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_02_1 SET
    code = '02.1',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_02,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_02_1_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_02_10 SET
    code = '02.10',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_02_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_02_10_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_02_2 SET
    code = '02.2',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_02,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_02_2_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_02_20 SET
    code = '02.20',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_02_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_02_20_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_02_3 SET
    code = '02.3',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_02,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_02_3_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_02_30 SET
    code = '02.30',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_02_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_02_30_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_02_4 SET
    code = '02.4',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_02,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_02_4_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_02_40 SET
    code = '02.40',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_02_4,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_02_40_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_03 SET
    code = '03',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_a,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_03_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_03_1 SET
    code = '03.1',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_03,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_03_1_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_03_11 SET
    code = '03.11',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_03_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_03_11_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_03_12 SET
    code = '03.12',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_03_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_03_12_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_03_2 SET
    code = '03.2',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_03,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_03_2_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_03_21 SET
    code = '03.21',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_03_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_03_21_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_03_22 SET
    code = '03.22',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_03_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_03_22_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_03_3 SET
    code = '03.3',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_03,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_03_3_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_03_30 SET
    code = '03.30',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_03_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_03_30_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_b SET
    code = 'B',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:section,
    pays_reference = NONE,
    parent_code = NONE,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_b_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_05 SET
    code = '05',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_b,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_05_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_05_1 SET
    code = '05.1',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_05,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_05_1_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_05_10 SET
    code = '05.10',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_05_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_05_10_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_05_2 SET
    code = '05.2',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_05,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_05_2_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_05_20 SET
    code = '05.20',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_05_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_05_20_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_06 SET
    code = '06',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_b,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_06_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_06_1 SET
    code = '06.1',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_06,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_06_1_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_06_10 SET
    code = '06.10',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_06_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_06_10_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_06_2 SET
    code = '06.2',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_06,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_06_2_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_06_20 SET
    code = '06.20',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_06_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_06_20_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_07 SET
    code = '07',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_b,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_07_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_07_1 SET
    code = '07.1',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_07,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_07_1_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_07_10 SET
    code = '07.10',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_07_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_07_10_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_07_2 SET
    code = '07.2',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_07,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_07_2_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_07_21 SET
    code = '07.21',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_07_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_07_21_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_07_29 SET
    code = '07.29',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_07_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_07_29_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_08 SET
    code = '08',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_b,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_08_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_08_1 SET
    code = '08.1',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_08,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_08_1_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_08_11 SET
    code = '08.11',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_08_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_08_11_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_08_12 SET
    code = '08.12',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_08_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_08_12_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_08_9 SET
    code = '08.9',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_08,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_08_9_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_08_91 SET
    code = '08.91',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_08_9,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_08_91_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_08_92 SET
    code = '08.92',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_08_9,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_08_92_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_08_93 SET
    code = '08.93',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_08_9,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_08_93_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_08_99 SET
    code = '08.99',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_08_9,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_08_99_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_09 SET
    code = '09',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_b,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_09_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_09_1 SET
    code = '09.1',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_09,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_09_1_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_09_10 SET
    code = '09.10',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_09_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_09_10_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_09_9 SET
    code = '09.9',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_09,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_09_9_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_09_90 SET
    code = '09.90',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_09_9,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_09_90_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_c SET
    code = 'C',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:section,
    pays_reference = NONE,
    parent_code = NONE,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_c_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_10 SET
    code = '10',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_c,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_10_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_10_1 SET
    code = '10.1',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_10,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_10_1_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_10_11 SET
    code = '10.11',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_10_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_10_11_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_10_12 SET
    code = '10.12',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_10_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_10_12_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_10_13 SET
    code = '10.13',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_10_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_10_13_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_10_2 SET
    code = '10.2',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_10,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_10_2_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_10_20 SET
    code = '10.20',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_10_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_10_20_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_10_3 SET
    code = '10.3',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_10,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_10_3_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_10_31 SET
    code = '10.31',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_10_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_10_31_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_10_32 SET
    code = '10.32',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_10_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_10_32_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_10_39 SET
    code = '10.39',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_10_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_10_39_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_10_4 SET
    code = '10.4',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_10,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_10_4_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_10_41 SET
    code = '10.41',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_10_4,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_10_41_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_10_42 SET
    code = '10.42',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_10_4,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_10_42_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_10_5 SET
    code = '10.5',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_10,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_10_5_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_10_51 SET
    code = '10.51',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_10_5,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_10_51_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_10_52 SET
    code = '10.52',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_10_5,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_10_52_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_10_6 SET
    code = '10.6',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_10,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_10_6_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_10_61 SET
    code = '10.61',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_10_6,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_10_61_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_10_62 SET
    code = '10.62',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_10_6,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_10_62_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_10_7 SET
    code = '10.7',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_10,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_10_7_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_10_71 SET
    code = '10.71',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_10_7,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_10_71_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_10_72 SET
    code = '10.72',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_10_7,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_10_72_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_10_73 SET
    code = '10.73',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_10_7,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_10_73_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_10_8 SET
    code = '10.8',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_10,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_10_8_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_10_81 SET
    code = '10.81',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_10_8,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_10_81_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_10_82 SET
    code = '10.82',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_10_8,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_10_82_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_10_83 SET
    code = '10.83',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_10_8,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_10_83_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_10_84 SET
    code = '10.84',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_10_8,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_10_84_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_10_85 SET
    code = '10.85',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_10_8,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_10_85_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_10_86 SET
    code = '10.86',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_10_8,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_10_86_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_10_89 SET
    code = '10.89',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_10_8,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_10_89_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_10_9 SET
    code = '10.9',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_10,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_10_9_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_10_91 SET
    code = '10.91',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_10_9,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_10_91_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_10_92 SET
    code = '10.92',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_10_9,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_10_92_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_11 SET
    code = '11',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_c,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_11_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_11_0 SET
    code = '11.0',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_11,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_11_0_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_11_01 SET
    code = '11.01',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_11_0,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_11_01_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_11_02 SET
    code = '11.02',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_11_0,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_11_02_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_11_03 SET
    code = '11.03',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_11_0,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_11_03_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_11_04 SET
    code = '11.04',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_11_0,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_11_04_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_11_05 SET
    code = '11.05',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_11_0,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_11_05_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_11_06 SET
    code = '11.06',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_11_0,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_11_06_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_11_07 SET
    code = '11.07',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_11_0,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_11_07_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_12 SET
    code = '12',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_c,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_12_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_12_0 SET
    code = '12.0',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_12,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_12_0_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_12_00 SET
    code = '12.00',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_12_0,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_12_00_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_13 SET
    code = '13',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_c,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_13_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_13_1 SET
    code = '13.1',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_13,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_13_1_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_13_10 SET
    code = '13.10',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_13_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_13_10_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_13_2 SET
    code = '13.2',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_13,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_13_2_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_13_20 SET
    code = '13.20',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_13_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_13_20_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_13_3 SET
    code = '13.3',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_13,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_13_3_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_13_30 SET
    code = '13.30',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_13_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_13_30_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_13_9 SET
    code = '13.9',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_13,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_13_9_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_13_91 SET
    code = '13.91',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_13_9,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_13_91_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_13_92 SET
    code = '13.92',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_13_9,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_13_92_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_13_93 SET
    code = '13.93',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_13_9,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_13_93_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_13_94 SET
    code = '13.94',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_13_9,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_13_94_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_13_95 SET
    code = '13.95',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_13_9,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_13_95_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_13_96 SET
    code = '13.96',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_13_9,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_13_96_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_13_99 SET
    code = '13.99',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_13_9,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_13_99_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_14 SET
    code = '14',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_c,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_14_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_14_1 SET
    code = '14.1',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_14,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_14_1_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_14_10 SET
    code = '14.10',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_14_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_14_10_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_14_2 SET
    code = '14.2',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_14,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_14_2_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_14_21 SET
    code = '14.21',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_14_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_14_21_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_14_22 SET
    code = '14.22',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_14_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_14_22_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_14_23 SET
    code = '14.23',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_14_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_14_23_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_14_24 SET
    code = '14.24',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_14_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_14_24_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_14_29 SET
    code = '14.29',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_14_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_14_29_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_15 SET
    code = '15',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_c,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_15_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_15_1 SET
    code = '15.1',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_15,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_15_1_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_15_11 SET
    code = '15.11',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_15_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_15_11_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_15_12 SET
    code = '15.12',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_15_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_15_12_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_15_2 SET
    code = '15.2',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_15,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_15_2_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_15_20 SET
    code = '15.20',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_15_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_15_20_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_16 SET
    code = '16',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_c,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_16_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_16_1 SET
    code = '16.1',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_16,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_16_1_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_16_11 SET
    code = '16.11',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_16_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_16_11_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_16_12 SET
    code = '16.12',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_16_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_16_12_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_16_2 SET
    code = '16.2',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_16,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_16_2_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_16_21 SET
    code = '16.21',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_16_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_16_21_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_16_22 SET
    code = '16.22',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_16_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_16_22_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_16_23 SET
    code = '16.23',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_16_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_16_23_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_16_24 SET
    code = '16.24',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_16_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_16_24_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_16_25 SET
    code = '16.25',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_16_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_16_25_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_16_26 SET
    code = '16.26',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_16_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_16_26_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_16_27 SET
    code = '16.27',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_16_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_16_27_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_16_28 SET
    code = '16.28',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_16_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_16_28_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_17 SET
    code = '17',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_c,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_17_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_17_1 SET
    code = '17.1',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_17,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_17_1_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_17_11 SET
    code = '17.11',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_17_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_17_11_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_17_12 SET
    code = '17.12',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_17_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_17_12_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_17_2 SET
    code = '17.2',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_17,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_17_2_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_17_21 SET
    code = '17.21',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_17_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_17_21_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_17_22 SET
    code = '17.22',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_17_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_17_22_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_17_23 SET
    code = '17.23',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_17_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_17_23_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_17_24 SET
    code = '17.24',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_17_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_17_24_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_17_25 SET
    code = '17.25',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_17_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_17_25_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_18 SET
    code = '18',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_c,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_18_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_18_1 SET
    code = '18.1',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_18,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_18_1_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_18_11 SET
    code = '18.11',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_18_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_18_11_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_18_12 SET
    code = '18.12',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_18_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_18_12_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_18_13 SET
    code = '18.13',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_18_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_18_13_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_18_14 SET
    code = '18.14',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_18_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_18_14_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_18_2 SET
    code = '18.2',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_18,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_18_2_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_18_20 SET
    code = '18.20',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_18_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_18_20_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_19 SET
    code = '19',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_c,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_19_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_19_1 SET
    code = '19.1',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_19,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_19_1_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_19_10 SET
    code = '19.10',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_19_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_19_10_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_19_2 SET
    code = '19.2',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_19,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_19_2_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_19_20 SET
    code = '19.20',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_19_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_19_20_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_20 SET
    code = '20',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_c,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_20_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_20_1 SET
    code = '20.1',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_20,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_20_1_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_20_11 SET
    code = '20.11',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_20_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_20_11_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_20_12 SET
    code = '20.12',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_20_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_20_12_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_20_13 SET
    code = '20.13',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_20_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_20_13_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_20_14 SET
    code = '20.14',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_20_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_20_14_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_20_15 SET
    code = '20.15',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_20_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_20_15_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_20_16 SET
    code = '20.16',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_20_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_20_16_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_20_17 SET
    code = '20.17',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_20_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_20_17_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_20_2 SET
    code = '20.2',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_20,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_20_2_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_20_20 SET
    code = '20.20',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_20_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_20_20_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_20_3 SET
    code = '20.3',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_20,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_20_3_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_20_30 SET
    code = '20.30',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_20_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_20_30_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_20_4 SET
    code = '20.4',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_20,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_20_4_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_20_41 SET
    code = '20.41',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_20_4,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_20_41_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_20_42 SET
    code = '20.42',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_20_4,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_20_42_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_20_5 SET
    code = '20.5',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_20,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_20_5_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_20_51 SET
    code = '20.51',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_20_5,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_20_51_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_20_59 SET
    code = '20.59',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_20_5,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_20_59_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_20_6 SET
    code = '20.6',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_20,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_20_6_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_20_60 SET
    code = '20.60',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_20_6,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_20_60_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_21 SET
    code = '21',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_c,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_21_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_21_1 SET
    code = '21.1',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_21,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_21_1_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_21_10 SET
    code = '21.10',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_21_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_21_10_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_21_2 SET
    code = '21.2',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_21,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_21_2_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_21_20 SET
    code = '21.20',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_21_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_21_20_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_22 SET
    code = '22',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_c,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_22_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_22_1 SET
    code = '22.1',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_22,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_22_1_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_22_11 SET
    code = '22.11',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_22_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_22_11_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_22_12 SET
    code = '22.12',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_22_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_22_12_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_22_2 SET
    code = '22.2',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_22,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_22_2_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_22_21 SET
    code = '22.21',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_22_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_22_21_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_22_22 SET
    code = '22.22',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_22_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_22_22_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_22_23 SET
    code = '22.23',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_22_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_22_23_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_22_24 SET
    code = '22.24',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_22_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_22_24_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_22_25 SET
    code = '22.25',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_22_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_22_25_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_22_26 SET
    code = '22.26',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_22_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_22_26_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_23 SET
    code = '23',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_c,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_23_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_23_1 SET
    code = '23.1',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_23,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_23_1_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_23_11 SET
    code = '23.11',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_23_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_23_11_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_23_12 SET
    code = '23.12',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_23_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_23_12_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_23_13 SET
    code = '23.13',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_23_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_23_13_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_23_14 SET
    code = '23.14',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_23_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_23_14_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_23_15 SET
    code = '23.15',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_23_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_23_15_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_23_2 SET
    code = '23.2',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_23,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_23_2_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_23_20 SET
    code = '23.20',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_23_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_23_20_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_23_3 SET
    code = '23.3',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_23,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_23_3_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_23_31 SET
    code = '23.31',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_23_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_23_31_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_23_32 SET
    code = '23.32',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_23_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_23_32_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_23_4 SET
    code = '23.4',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_23,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_23_4_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_23_41 SET
    code = '23.41',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_23_4,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_23_41_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_23_42 SET
    code = '23.42',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_23_4,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_23_42_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_23_43 SET
    code = '23.43',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_23_4,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_23_43_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_23_44 SET
    code = '23.44',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_23_4,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_23_44_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_23_45 SET
    code = '23.45',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_23_4,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_23_45_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_23_5 SET
    code = '23.5',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_23,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_23_5_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_23_51 SET
    code = '23.51',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_23_5,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_23_51_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_23_52 SET
    code = '23.52',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_23_5,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_23_52_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_23_6 SET
    code = '23.6',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_23,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_23_6_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_23_61 SET
    code = '23.61',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_23_6,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_23_61_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_23_62 SET
    code = '23.62',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_23_6,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_23_62_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_23_63 SET
    code = '23.63',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_23_6,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_23_63_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_23_64 SET
    code = '23.64',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_23_6,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_23_64_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_23_65 SET
    code = '23.65',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_23_6,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_23_65_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_23_66 SET
    code = '23.66',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_23_6,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_23_66_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_23_7 SET
    code = '23.7',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_23,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_23_7_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_23_70 SET
    code = '23.70',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_23_7,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_23_70_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_23_9 SET
    code = '23.9',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_23,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_23_9_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_23_91 SET
    code = '23.91',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_23_9,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_23_91_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_23_99 SET
    code = '23.99',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_23_9,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_23_99_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_24 SET
    code = '24',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_c,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_24_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_24_1 SET
    code = '24.1',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_24,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_24_1_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_24_10 SET
    code = '24.10',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_24_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_24_10_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_24_2 SET
    code = '24.2',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_24,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_24_2_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_24_20 SET
    code = '24.20',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_24_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_24_20_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_24_3 SET
    code = '24.3',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_24,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_24_3_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_24_31 SET
    code = '24.31',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_24_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_24_31_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_24_32 SET
    code = '24.32',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_24_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_24_32_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_24_33 SET
    code = '24.33',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_24_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_24_33_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_24_34 SET
    code = '24.34',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_24_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_24_34_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_24_4 SET
    code = '24.4',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_24,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_24_4_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_24_41 SET
    code = '24.41',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_24_4,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_24_41_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_24_42 SET
    code = '24.42',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_24_4,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_24_42_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_24_43 SET
    code = '24.43',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_24_4,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_24_43_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_24_44 SET
    code = '24.44',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_24_4,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_24_44_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_24_45 SET
    code = '24.45',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_24_4,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_24_45_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_24_46 SET
    code = '24.46',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_24_4,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_24_46_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_24_5 SET
    code = '24.5',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_24,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_24_5_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_24_51 SET
    code = '24.51',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_24_5,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_24_51_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_24_52 SET
    code = '24.52',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_24_5,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_24_52_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_24_53 SET
    code = '24.53',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_24_5,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_24_53_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_24_54 SET
    code = '24.54',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_24_5,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_24_54_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_25 SET
    code = '25',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_c,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_25_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_25_1 SET
    code = '25.1',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_25,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_25_1_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_25_11 SET
    code = '25.11',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_25_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_25_11_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_25_12 SET
    code = '25.12',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_25_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_25_12_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_25_2 SET
    code = '25.2',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_25,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_25_2_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_25_21 SET
    code = '25.21',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_25_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_25_21_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_25_22 SET
    code = '25.22',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_25_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_25_22_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_25_3 SET
    code = '25.3',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_25,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_25_3_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_25_30 SET
    code = '25.30',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_25_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_25_30_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_25_4 SET
    code = '25.4',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_25,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_25_4_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_25_40 SET
    code = '25.40',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_25_4,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_25_40_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_25_5 SET
    code = '25.5',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_25,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_25_5_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_25_51 SET
    code = '25.51',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_25_5,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_25_51_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_25_52 SET
    code = '25.52',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_25_5,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_25_52_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_25_53 SET
    code = '25.53',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_25_5,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_25_53_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_25_6 SET
    code = '25.6',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_25,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_25_6_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_25_61 SET
    code = '25.61',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_25_6,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_25_61_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_25_62 SET
    code = '25.62',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_25_6,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_25_62_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_25_63 SET
    code = '25.63',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_25_6,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_25_63_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_25_9 SET
    code = '25.9',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_25,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_25_9_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_25_91 SET
    code = '25.91',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_25_9,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_25_91_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_25_92 SET
    code = '25.92',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_25_9,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_25_92_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_25_93 SET
    code = '25.93',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_25_9,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_25_93_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_25_94 SET
    code = '25.94',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_25_9,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_25_94_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_25_99 SET
    code = '25.99',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_25_9,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_25_99_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_26 SET
    code = '26',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_c,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_26_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_26_1 SET
    code = '26.1',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_26,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_26_1_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_26_11 SET
    code = '26.11',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_26_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_26_11_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_26_12 SET
    code = '26.12',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_26_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_26_12_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_26_2 SET
    code = '26.2',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_26,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_26_2_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_26_20 SET
    code = '26.20',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_26_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_26_20_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_26_3 SET
    code = '26.3',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_26,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_26_3_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_26_30 SET
    code = '26.30',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_26_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_26_30_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_26_4 SET
    code = '26.4',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_26,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_26_4_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_26_40 SET
    code = '26.40',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_26_4,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_26_40_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_26_5 SET
    code = '26.5',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_26,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_26_5_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_26_51 SET
    code = '26.51',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_26_5,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_26_51_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_26_52 SET
    code = '26.52',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_26_5,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_26_52_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_26_6 SET
    code = '26.6',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_26,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_26_6_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_26_60 SET
    code = '26.60',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_26_6,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_26_60_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_26_7 SET
    code = '26.7',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_26,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_26_7_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_26_70 SET
    code = '26.70',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_26_7,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_26_70_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_27 SET
    code = '27',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_c,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_27_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_27_1 SET
    code = '27.1',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_27,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_27_1_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_27_11 SET
    code = '27.11',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_27_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_27_11_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_27_12 SET
    code = '27.12',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_27_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_27_12_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_27_2 SET
    code = '27.2',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_27,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_27_2_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_27_20 SET
    code = '27.20',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_27_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_27_20_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_27_3 SET
    code = '27.3',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_27,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_27_3_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_27_31 SET
    code = '27.31',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_27_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_27_31_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_27_32 SET
    code = '27.32',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_27_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_27_32_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_27_33 SET
    code = '27.33',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_27_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_27_33_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_27_4 SET
    code = '27.4',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_27,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_27_4_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_27_40 SET
    code = '27.40',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_27_4,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_27_40_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_27_5 SET
    code = '27.5',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_27,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_27_5_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_27_51 SET
    code = '27.51',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_27_5,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_27_51_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_27_52 SET
    code = '27.52',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_27_5,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_27_52_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_27_9 SET
    code = '27.9',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_27,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_27_9_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_27_90 SET
    code = '27.90',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_27_9,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_27_90_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_28 SET
    code = '28',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_c,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_28_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_28_1 SET
    code = '28.1',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_28,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_28_1_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_28_11 SET
    code = '28.11',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_28_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_28_11_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_28_12 SET
    code = '28.12',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_28_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_28_12_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_28_13 SET
    code = '28.13',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_28_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_28_13_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_28_14 SET
    code = '28.14',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_28_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_28_14_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_28_15 SET
    code = '28.15',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_28_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_28_15_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_28_2 SET
    code = '28.2',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_28,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_28_2_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_28_21 SET
    code = '28.21',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_28_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_28_21_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_28_22 SET
    code = '28.22',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_28_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_28_22_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_28_23 SET
    code = '28.23',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_28_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_28_23_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_28_24 SET
    code = '28.24',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_28_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_28_24_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_28_25 SET
    code = '28.25',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_28_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_28_25_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_28_29 SET
    code = '28.29',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_28_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_28_29_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_28_3 SET
    code = '28.3',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_28,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_28_3_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_28_30 SET
    code = '28.30',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_28_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_28_30_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_28_4 SET
    code = '28.4',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_28,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_28_4_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_28_41 SET
    code = '28.41',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_28_4,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_28_41_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_28_42 SET
    code = '28.42',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_28_4,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_28_42_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_28_9 SET
    code = '28.9',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_28,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_28_9_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_28_91 SET
    code = '28.91',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_28_9,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_28_91_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_28_92 SET
    code = '28.92',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_28_9,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_28_92_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_28_93 SET
    code = '28.93',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_28_9,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_28_93_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_28_94 SET
    code = '28.94',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_28_9,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_28_94_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_28_95 SET
    code = '28.95',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_28_9,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_28_95_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_28_96 SET
    code = '28.96',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_28_9,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_28_96_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_28_97 SET
    code = '28.97',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_28_9,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_28_97_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_28_99 SET
    code = '28.99',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_28_9,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_28_99_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_29 SET
    code = '29',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_c,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_29_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_29_1 SET
    code = '29.1',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_29,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_29_1_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_29_10 SET
    code = '29.10',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_29_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_29_10_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_29_2 SET
    code = '29.2',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_29,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_29_2_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_29_20 SET
    code = '29.20',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_29_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_29_20_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_29_3 SET
    code = '29.3',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_29,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_29_3_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_29_31 SET
    code = '29.31',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_29_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_29_31_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_29_32 SET
    code = '29.32',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_29_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_29_32_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_30 SET
    code = '30',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_c,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_30_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_30_1 SET
    code = '30.1',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_30,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_30_1_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_30_11 SET
    code = '30.11',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_30_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_30_11_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_30_12 SET
    code = '30.12',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_30_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_30_12_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_30_13 SET
    code = '30.13',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_30_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_30_13_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_30_2 SET
    code = '30.2',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_30,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_30_2_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_30_20 SET
    code = '30.20',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_30_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_30_20_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_30_3 SET
    code = '30.3',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_30,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_30_3_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_30_31 SET
    code = '30.31',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_30_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_30_31_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_30_32 SET
    code = '30.32',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_30_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_30_32_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_30_4 SET
    code = '30.4',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_30,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_30_4_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_30_40 SET
    code = '30.40',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_30_4,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_30_40_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_30_9 SET
    code = '30.9',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_30,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_30_9_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_30_91 SET
    code = '30.91',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_30_9,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_30_91_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_30_92 SET
    code = '30.92',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_30_9,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_30_92_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_30_99 SET
    code = '30.99',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_30_9,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_30_99_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_31 SET
    code = '31',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_c,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_31_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_31_0 SET
    code = '31.0',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_31,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_31_0_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_31_00 SET
    code = '31.00',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_31_0,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_31_00_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_32 SET
    code = '32',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_c,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_32_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_32_1 SET
    code = '32.1',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_32,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_32_1_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_32_11 SET
    code = '32.11',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_32_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_32_11_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_32_12 SET
    code = '32.12',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_32_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_32_12_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_32_13 SET
    code = '32.13',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_32_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_32_13_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_32_2 SET
    code = '32.2',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_32,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_32_2_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_32_20 SET
    code = '32.20',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_32_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_32_20_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_32_3 SET
    code = '32.3',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_32,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_32_3_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_32_30 SET
    code = '32.30',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_32_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_32_30_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_32_4 SET
    code = '32.4',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_32,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_32_4_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_32_40 SET
    code = '32.40',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_32_4,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_32_40_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_32_5 SET
    code = '32.5',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_32,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_32_5_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_32_50 SET
    code = '32.50',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_32_5,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_32_50_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_32_9 SET
    code = '32.9',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_32,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_32_9_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_32_91 SET
    code = '32.91',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_32_9,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_32_91_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_32_99 SET
    code = '32.99',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_32_9,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_32_99_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_33 SET
    code = '33',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_c,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_33_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_33_1 SET
    code = '33.1',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_33,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_33_1_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_33_11 SET
    code = '33.11',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_33_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_33_11_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_33_12 SET
    code = '33.12',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_33_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_33_12_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_33_13 SET
    code = '33.13',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_33_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_33_13_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_33_14 SET
    code = '33.14',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_33_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_33_14_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_33_15 SET
    code = '33.15',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_33_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_33_15_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_33_16 SET
    code = '33.16',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_33_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_33_16_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_33_17 SET
    code = '33.17',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_33_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_33_17_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_33_18 SET
    code = '33.18',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_33_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_33_18_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_33_19 SET
    code = '33.19',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_33_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_33_19_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_33_2 SET
    code = '33.2',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_33,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_33_2_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_33_20 SET
    code = '33.20',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_33_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_33_20_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_d SET
    code = 'D',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:section,
    pays_reference = NONE,
    parent_code = NONE,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_d_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_35 SET
    code = '35',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_d,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_35_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_35_1 SET
    code = '35.1',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_35,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_35_1_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_35_11 SET
    code = '35.11',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_35_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_35_11_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_35_12 SET
    code = '35.12',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_35_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_35_12_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_35_13 SET
    code = '35.13',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_35_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_35_13_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_35_14 SET
    code = '35.14',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_35_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_35_14_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_35_15 SET
    code = '35.15',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_35_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_35_15_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_35_16 SET
    code = '35.16',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_35_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_35_16_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_35_2 SET
    code = '35.2',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_35,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_35_2_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_35_21 SET
    code = '35.21',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_35_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_35_21_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_35_22 SET
    code = '35.22',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_35_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_35_22_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_35_23 SET
    code = '35.23',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_35_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_35_23_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_35_24 SET
    code = '35.24',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_35_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_35_24_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_35_3 SET
    code = '35.3',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_35,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_35_3_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_35_30 SET
    code = '35.30',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_35_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_35_30_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_35_4 SET
    code = '35.4',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_35,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_35_4_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_35_40 SET
    code = '35.40',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_35_4,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_35_40_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_e SET
    code = 'E',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:section,
    pays_reference = NONE,
    parent_code = NONE,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_e_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_36 SET
    code = '36',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_e,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_36_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_36_0 SET
    code = '36.0',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_36,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_36_0_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_36_00 SET
    code = '36.00',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_36_0,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_36_00_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_37 SET
    code = '37',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_e,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_37_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_37_0 SET
    code = '37.0',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_37,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_37_0_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_37_00 SET
    code = '37.00',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_37_0,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_37_00_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_38 SET
    code = '38',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_e,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_38_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_38_1 SET
    code = '38.1',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_38,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_38_1_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_38_11 SET
    code = '38.11',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_38_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_38_11_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_38_12 SET
    code = '38.12',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_38_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_38_12_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_38_2 SET
    code = '38.2',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_38,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_38_2_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_38_21 SET
    code = '38.21',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_38_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_38_21_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_38_22 SET
    code = '38.22',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_38_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_38_22_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_38_23 SET
    code = '38.23',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_38_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_38_23_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_38_3 SET
    code = '38.3',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_38,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_38_3_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_38_31 SET
    code = '38.31',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_38_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_38_31_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_38_32 SET
    code = '38.32',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_38_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_38_32_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_38_33 SET
    code = '38.33',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_38_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_38_33_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_39 SET
    code = '39',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_e,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_39_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_39_0 SET
    code = '39.0',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_39,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_39_0_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_39_00 SET
    code = '39.00',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_39_0,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_39_00_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_f SET
    code = 'F',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:section,
    pays_reference = NONE,
    parent_code = NONE,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_f_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_41 SET
    code = '41',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_f,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_41_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_41_0 SET
    code = '41.0',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_41,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_41_0_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_41_00 SET
    code = '41.00',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_41_0,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_41_00_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_42 SET
    code = '42',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_f,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_42_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_42_1 SET
    code = '42.1',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_42,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_42_1_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_42_11 SET
    code = '42.11',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_42_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_42_11_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_42_12 SET
    code = '42.12',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_42_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_42_12_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_42_13 SET
    code = '42.13',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_42_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_42_13_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_42_2 SET
    code = '42.2',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_42,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_42_2_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_42_21 SET
    code = '42.21',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_42_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_42_21_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_42_22 SET
    code = '42.22',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_42_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_42_22_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_42_9 SET
    code = '42.9',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_42,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_42_9_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_42_91 SET
    code = '42.91',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_42_9,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_42_91_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_42_99 SET
    code = '42.99',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_42_9,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_42_99_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_43 SET
    code = '43',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_f,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_43_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_43_1 SET
    code = '43.1',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_43,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_43_1_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_43_11 SET
    code = '43.11',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_43_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_43_11_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_43_12 SET
    code = '43.12',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_43_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_43_12_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_43_13 SET
    code = '43.13',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_43_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_43_13_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_43_2 SET
    code = '43.2',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_43,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_43_2_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_43_21 SET
    code = '43.21',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_43_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_43_21_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_43_22 SET
    code = '43.22',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_43_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_43_22_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_43_23 SET
    code = '43.23',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_43_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_43_23_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_43_24 SET
    code = '43.24',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_43_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_43_24_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_43_3 SET
    code = '43.3',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_43,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_43_3_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_43_31 SET
    code = '43.31',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_43_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_43_31_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_43_32 SET
    code = '43.32',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_43_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_43_32_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_43_33 SET
    code = '43.33',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_43_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_43_33_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_43_34 SET
    code = '43.34',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_43_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_43_34_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_43_35 SET
    code = '43.35',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_43_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_43_35_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_43_4 SET
    code = '43.4',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_43,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_43_4_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_43_41 SET
    code = '43.41',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_43_4,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_43_41_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_43_42 SET
    code = '43.42',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_43_4,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_43_42_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_43_5 SET
    code = '43.5',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_43,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_43_5_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_43_50 SET
    code = '43.50',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_43_5,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_43_50_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_43_6 SET
    code = '43.6',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_43,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_43_6_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_43_60 SET
    code = '43.60',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_43_6,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_43_60_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_43_9 SET
    code = '43.9',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_43,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_43_9_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_43_91 SET
    code = '43.91',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_43_9,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_43_91_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_43_99 SET
    code = '43.99',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_43_9,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_43_99_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_g SET
    code = 'G',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:section,
    pays_reference = NONE,
    parent_code = NONE,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_g_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_46 SET
    code = '46',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_g,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_46_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_46_1 SET
    code = '46.1',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_46,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_46_1_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_46_11 SET
    code = '46.11',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_46_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_46_11_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_46_12 SET
    code = '46.12',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_46_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_46_12_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_46_13 SET
    code = '46.13',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_46_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_46_13_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_46_14 SET
    code = '46.14',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_46_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_46_14_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_46_15 SET
    code = '46.15',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_46_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_46_15_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_46_16 SET
    code = '46.16',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_46_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_46_16_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_46_17 SET
    code = '46.17',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_46_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_46_17_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_46_18 SET
    code = '46.18',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_46_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_46_18_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_46_19 SET
    code = '46.19',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_46_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_46_19_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_46_2 SET
    code = '46.2',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_46,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_46_2_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_46_21 SET
    code = '46.21',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_46_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_46_21_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_46_22 SET
    code = '46.22',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_46_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_46_22_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_46_23 SET
    code = '46.23',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_46_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_46_23_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_46_24 SET
    code = '46.24',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_46_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_46_24_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_46_3 SET
    code = '46.3',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_46,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_46_3_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_46_31 SET
    code = '46.31',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_46_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_46_31_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_46_32 SET
    code = '46.32',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_46_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_46_32_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_46_33 SET
    code = '46.33',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_46_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_46_33_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_46_34 SET
    code = '46.34',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_46_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_46_34_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_46_35 SET
    code = '46.35',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_46_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_46_35_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_46_36 SET
    code = '46.36',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_46_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_46_36_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_46_37 SET
    code = '46.37',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_46_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_46_37_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_46_38 SET
    code = '46.38',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_46_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_46_38_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_46_39 SET
    code = '46.39',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_46_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_46_39_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_46_4 SET
    code = '46.4',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_46,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_46_4_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_46_41 SET
    code = '46.41',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_46_4,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_46_41_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_46_42 SET
    code = '46.42',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_46_4,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_46_42_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_46_43 SET
    code = '46.43',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_46_4,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_46_43_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_46_44 SET
    code = '46.44',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_46_4,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_46_44_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_46_45 SET
    code = '46.45',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_46_4,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_46_45_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_46_46 SET
    code = '46.46',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_46_4,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_46_46_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_46_47 SET
    code = '46.47',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_46_4,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_46_47_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_46_48 SET
    code = '46.48',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_46_4,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_46_48_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_46_49 SET
    code = '46.49',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_46_4,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_46_49_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_46_5 SET
    code = '46.5',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_46,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_46_5_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_46_50 SET
    code = '46.50',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_46_5,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_46_50_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_46_6 SET
    code = '46.6',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_46,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_46_6_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_46_61 SET
    code = '46.61',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_46_6,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_46_61_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_46_62 SET
    code = '46.62',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_46_6,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_46_62_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_46_63 SET
    code = '46.63',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_46_6,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_46_63_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_46_64 SET
    code = '46.64',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_46_6,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_46_64_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_46_7 SET
    code = '46.7',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_46,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_46_7_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_46_71 SET
    code = '46.71',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_46_7,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_46_71_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_46_72 SET
    code = '46.72',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_46_7,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_46_72_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_46_73 SET
    code = '46.73',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_46_7,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_46_73_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_46_8 SET
    code = '46.8',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_46,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_46_8_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_46_81 SET
    code = '46.81',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_46_8,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_46_81_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_46_82 SET
    code = '46.82',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_46_8,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_46_82_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_46_83 SET
    code = '46.83',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_46_8,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_46_83_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_46_84 SET
    code = '46.84',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_46_8,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_46_84_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_46_85 SET
    code = '46.85',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_46_8,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_46_85_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_46_86 SET
    code = '46.86',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_46_8,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_46_86_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_46_87 SET
    code = '46.87',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_46_8,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_46_87_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_46_89 SET
    code = '46.89',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_46_8,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_46_89_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_46_9 SET
    code = '46.9',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_46,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_46_9_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_46_90 SET
    code = '46.90',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_46_9,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_46_90_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_47 SET
    code = '47',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_g,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_47_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_47_1 SET
    code = '47.1',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_47,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_47_1_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_47_11 SET
    code = '47.11',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_47_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_47_11_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_47_12 SET
    code = '47.12',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_47_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_47_12_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_47_2 SET
    code = '47.2',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_47,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_47_2_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_47_21 SET
    code = '47.21',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_47_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_47_21_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_47_22 SET
    code = '47.22',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_47_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_47_22_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_47_23 SET
    code = '47.23',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_47_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_47_23_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_47_24 SET
    code = '47.24',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_47_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_47_24_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_47_25 SET
    code = '47.25',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_47_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_47_25_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_47_26 SET
    code = '47.26',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_47_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_47_26_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_47_27 SET
    code = '47.27',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_47_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_47_27_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_47_3 SET
    code = '47.3',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_47,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_47_3_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_47_30 SET
    code = '47.30',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_47_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_47_30_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_47_4 SET
    code = '47.4',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_47,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_47_4_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_47_40 SET
    code = '47.40',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_47_4,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_47_40_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_47_5 SET
    code = '47.5',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_47,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_47_5_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_47_51 SET
    code = '47.51',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_47_5,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_47_51_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_47_52 SET
    code = '47.52',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_47_5,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_47_52_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_47_53 SET
    code = '47.53',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_47_5,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_47_53_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_47_54 SET
    code = '47.54',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_47_5,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_47_54_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_47_55 SET
    code = '47.55',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_47_5,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_47_55_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_47_6 SET
    code = '47.6',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_47,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_47_6_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_47_61 SET
    code = '47.61',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_47_6,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_47_61_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_47_62 SET
    code = '47.62',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_47_6,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_47_62_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_47_63 SET
    code = '47.63',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_47_6,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_47_63_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_47_64 SET
    code = '47.64',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_47_6,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_47_64_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_47_69 SET
    code = '47.69',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_47_6,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_47_69_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_47_7 SET
    code = '47.7',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_47,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_47_7_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_47_71 SET
    code = '47.71',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_47_7,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_47_71_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_47_72 SET
    code = '47.72',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_47_7,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_47_72_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_47_73 SET
    code = '47.73',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_47_7,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_47_73_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_47_74 SET
    code = '47.74',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_47_7,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_47_74_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_47_75 SET
    code = '47.75',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_47_7,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_47_75_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_47_76 SET
    code = '47.76',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_47_7,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_47_76_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_47_77 SET
    code = '47.77',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_47_7,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_47_77_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_47_78 SET
    code = '47.78',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_47_7,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_47_78_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_47_79 SET
    code = '47.79',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_47_7,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_47_79_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_47_8 SET
    code = '47.8',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_47,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_47_8_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_47_81 SET
    code = '47.81',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_47_8,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_47_81_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_47_82 SET
    code = '47.82',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_47_8,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_47_82_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_47_83 SET
    code = '47.83',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_47_8,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_47_83_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_47_9 SET
    code = '47.9',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_47,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_47_9_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_47_91 SET
    code = '47.91',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_47_9,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_47_91_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_47_92 SET
    code = '47.92',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_47_9,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_47_92_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_h SET
    code = 'H',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:section,
    pays_reference = NONE,
    parent_code = NONE,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_h_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_49 SET
    code = '49',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_h,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_49_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_49_1 SET
    code = '49.1',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_49,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_49_1_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_49_11 SET
    code = '49.11',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_49_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_49_11_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_49_12 SET
    code = '49.12',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_49_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_49_12_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_49_2 SET
    code = '49.2',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_49,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_49_2_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_49_20 SET
    code = '49.20',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_49_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_49_20_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_49_3 SET
    code = '49.3',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_49,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_49_3_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_49_31 SET
    code = '49.31',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_49_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_49_31_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_49_32 SET
    code = '49.32',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_49_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_49_32_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_49_33 SET
    code = '49.33',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_49_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_49_33_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_49_34 SET
    code = '49.34',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_49_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_49_34_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_49_39 SET
    code = '49.39',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_49_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_49_39_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_49_4 SET
    code = '49.4',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_49,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_49_4_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_49_41 SET
    code = '49.41',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_49_4,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_49_41_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_49_42 SET
    code = '49.42',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_49_4,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_49_42_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_49_5 SET
    code = '49.5',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_49,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_49_5_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_49_50 SET
    code = '49.50',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_49_5,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_49_50_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_50 SET
    code = '50',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_h,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_50_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_50_1 SET
    code = '50.1',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_50,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_50_1_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_50_10 SET
    code = '50.10',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_50_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_50_10_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_50_2 SET
    code = '50.2',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_50,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_50_2_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_50_20 SET
    code = '50.20',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_50_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_50_20_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_50_3 SET
    code = '50.3',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_50,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_50_3_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_50_30 SET
    code = '50.30',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_50_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_50_30_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_50_4 SET
    code = '50.4',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_50,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_50_4_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_50_40 SET
    code = '50.40',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_50_4,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_50_40_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_51 SET
    code = '51',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_h,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_51_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_51_1 SET
    code = '51.1',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_51,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_51_1_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_51_10 SET
    code = '51.10',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_51_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_51_10_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_51_2 SET
    code = '51.2',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_51,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_51_2_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_51_21 SET
    code = '51.21',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_51_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_51_21_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_51_22 SET
    code = '51.22',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_51_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_51_22_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_52 SET
    code = '52',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_h,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_52_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_52_1 SET
    code = '52.1',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_52,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_52_1_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_52_10 SET
    code = '52.10',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_52_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_52_10_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_52_2 SET
    code = '52.2',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_52,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_52_2_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_52_21 SET
    code = '52.21',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_52_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_52_21_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_52_22 SET
    code = '52.22',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_52_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_52_22_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_52_23 SET
    code = '52.23',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_52_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_52_23_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_52_24 SET
    code = '52.24',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_52_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_52_24_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_52_25 SET
    code = '52.25',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_52_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_52_25_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_52_26 SET
    code = '52.26',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_52_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_52_26_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_52_3 SET
    code = '52.3',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_52,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_52_3_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_52_31 SET
    code = '52.31',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_52_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_52_31_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_52_32 SET
    code = '52.32',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_52_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_52_32_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_53 SET
    code = '53',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_h,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_53_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_53_1 SET
    code = '53.1',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_53,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_53_1_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_53_10 SET
    code = '53.10',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_53_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_53_10_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_53_2 SET
    code = '53.2',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_53,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_53_2_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_53_20 SET
    code = '53.20',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_53_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_53_20_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_53_3 SET
    code = '53.3',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_53,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_53_3_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_53_30 SET
    code = '53.30',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_53_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_53_30_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_i SET
    code = 'I',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:section,
    pays_reference = NONE,
    parent_code = NONE,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_i_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_55 SET
    code = '55',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_i,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_55_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_55_1 SET
    code = '55.1',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_55,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_55_1_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_55_10 SET
    code = '55.10',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_55_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_55_10_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_55_2 SET
    code = '55.2',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_55,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_55_2_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_55_20 SET
    code = '55.20',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_55_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_55_20_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_55_3 SET
    code = '55.3',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_55,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_55_3_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_55_30 SET
    code = '55.30',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_55_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_55_30_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_55_4 SET
    code = '55.4',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_55,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_55_4_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_55_40 SET
    code = '55.40',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_55_4,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_55_40_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_55_9 SET
    code = '55.9',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_55,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_55_9_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_55_90 SET
    code = '55.90',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_55_9,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_55_90_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_56 SET
    code = '56',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_i,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_56_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_56_1 SET
    code = '56.1',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_56,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_56_1_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_56_11 SET
    code = '56.11',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_56_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_56_11_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_56_12 SET
    code = '56.12',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_56_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_56_12_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_56_2 SET
    code = '56.2',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_56,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_56_2_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_56_21 SET
    code = '56.21',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_56_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_56_21_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_56_22 SET
    code = '56.22',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_56_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_56_22_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_56_3 SET
    code = '56.3',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_56,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_56_3_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_56_30 SET
    code = '56.30',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_56_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_56_30_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_56_4 SET
    code = '56.4',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_56,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_56_4_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_56_40 SET
    code = '56.40',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_56_4,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_56_40_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_j SET
    code = 'J',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:section,
    pays_reference = NONE,
    parent_code = NONE,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_j_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_58 SET
    code = '58',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_j,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_58_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_58_1 SET
    code = '58.1',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_58,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_58_1_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_58_11 SET
    code = '58.11',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_58_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_58_11_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_58_12 SET
    code = '58.12',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_58_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_58_12_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_58_13 SET
    code = '58.13',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_58_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_58_13_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_58_19 SET
    code = '58.19',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_58_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_58_19_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_58_2 SET
    code = '58.2',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_58,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_58_2_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_58_21 SET
    code = '58.21',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_58_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_58_21_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_58_29 SET
    code = '58.29',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_58_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_58_29_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_59 SET
    code = '59',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_j,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_59_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_59_1 SET
    code = '59.1',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_59,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_59_1_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_59_11 SET
    code = '59.11',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_59_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_59_11_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_59_12 SET
    code = '59.12',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_59_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_59_12_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_59_13 SET
    code = '59.13',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_59_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_59_13_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_59_14 SET
    code = '59.14',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_59_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_59_14_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_59_2 SET
    code = '59.2',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_59,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_59_2_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_59_20 SET
    code = '59.20',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_59_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_59_20_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_60 SET
    code = '60',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_j,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_60_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_60_1 SET
    code = '60.1',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_60,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_60_1_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_60_10 SET
    code = '60.10',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_60_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_60_10_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_60_2 SET
    code = '60.2',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_60,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_60_2_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_60_20 SET
    code = '60.20',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_60_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_60_20_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_60_3 SET
    code = '60.3',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_60,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_60_3_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_60_31 SET
    code = '60.31',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_60_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_60_31_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_60_39 SET
    code = '60.39',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_60_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_60_39_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_k SET
    code = 'K',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:section,
    pays_reference = NONE,
    parent_code = NONE,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_k_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_61 SET
    code = '61',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_j,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_61_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_61_1 SET
    code = '61.1',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_61,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_61_1_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_61_10 SET
    code = '61.10',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_61_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_61_10_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_61_2 SET
    code = '61.2',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_61,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_61_2_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_61_20 SET
    code = '61.20',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_61_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_61_20_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_61_9 SET
    code = '61.9',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_61,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_61_9_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_61_90 SET
    code = '61.90',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_61_9,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_61_90_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_62 SET
    code = '62',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_j,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_62_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_62_1 SET
    code = '62.1',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_62,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_62_1_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_62_10 SET
    code = '62.10',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_62_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_62_10_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_62_2 SET
    code = '62.2',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_62,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_62_2_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_62_20 SET
    code = '62.20',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_62_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_62_20_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_62_9 SET
    code = '62.9',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_62,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_62_9_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_62_90 SET
    code = '62.90',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_62_9,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_62_90_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_63 SET
    code = '63',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_j,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_63_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_63_1 SET
    code = '63.1',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_63,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_63_1_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_63_10 SET
    code = '63.10',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_63_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_63_10_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_63_9 SET
    code = '63.9',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_63,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_63_9_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_63_91 SET
    code = '63.91',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_63_9,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_63_91_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_63_92 SET
    code = '63.92',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_63_9,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_63_92_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_l SET
    code = 'L',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:section,
    pays_reference = NONE,
    parent_code = NONE,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_l_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_64 SET
    code = '64',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_k,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_64_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_64_1 SET
    code = '64.1',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_64,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_64_1_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_64_11 SET
    code = '64.11',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_64_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_64_11_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_64_19 SET
    code = '64.19',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_64_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_64_19_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_64_2 SET
    code = '64.2',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_64,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_64_2_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_64_21 SET
    code = '64.21',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_64_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_64_21_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_64_22 SET
    code = '64.22',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_64_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_64_22_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_64_3 SET
    code = '64.3',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_64,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_64_3_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_64_31 SET
    code = '64.31',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_64_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_64_31_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_64_32 SET
    code = '64.32',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_64_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_64_32_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_64_9 SET
    code = '64.9',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_64,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_64_9_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_64_91 SET
    code = '64.91',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_64_9,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_64_91_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_64_92 SET
    code = '64.92',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_64_9,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_64_92_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_64_99 SET
    code = '64.99',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_64_9,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_64_99_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_65 SET
    code = '65',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_k,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_65_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_65_1 SET
    code = '65.1',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_65,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_65_1_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_65_11 SET
    code = '65.11',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_65_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_65_11_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_65_12 SET
    code = '65.12',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_65_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_65_12_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_65_2 SET
    code = '65.2',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_65,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_65_2_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_65_20 SET
    code = '65.20',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_65_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_65_20_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_65_3 SET
    code = '65.3',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_65,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_65_3_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_65_30 SET
    code = '65.30',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_65_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_65_30_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_66 SET
    code = '66',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_k,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_66_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_66_1 SET
    code = '66.1',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_66,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_66_1_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_66_11 SET
    code = '66.11',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_66_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_66_11_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_66_12 SET
    code = '66.12',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_66_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_66_12_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_66_19 SET
    code = '66.19',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_66_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_66_19_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_66_2 SET
    code = '66.2',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_66,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_66_2_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_66_21 SET
    code = '66.21',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_66_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_66_21_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_66_22 SET
    code = '66.22',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_66_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_66_22_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_66_29 SET
    code = '66.29',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_66_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_66_29_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_66_3 SET
    code = '66.3',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_66,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_66_3_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_66_30 SET
    code = '66.30',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_66_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_66_30_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_m SET
    code = 'M',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:section,
    pays_reference = NONE,
    parent_code = NONE,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_m_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_68 SET
    code = '68',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_l,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_68_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_68_1 SET
    code = '68.1',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_68,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_68_1_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_68_11 SET
    code = '68.11',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_68_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_68_11_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_68_12 SET
    code = '68.12',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_68_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_68_12_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_68_2 SET
    code = '68.2',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_68,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_68_2_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_68_20 SET
    code = '68.20',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_68_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_68_20_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_68_3 SET
    code = '68.3',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_68,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_68_3_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_68_31 SET
    code = '68.31',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_68_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_68_31_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_68_32 SET
    code = '68.32',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_68_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_68_32_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_n SET
    code = 'N',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:section,
    pays_reference = NONE,
    parent_code = NONE,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_n_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_69 SET
    code = '69',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_m,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_69_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_69_1 SET
    code = '69.1',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_69,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_69_1_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_69_10 SET
    code = '69.10',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_69_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_69_10_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_69_2 SET
    code = '69.2',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_69,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_69_2_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_69_20 SET
    code = '69.20',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_69_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_69_20_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_70 SET
    code = '70',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_m,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_70_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_70_1 SET
    code = '70.1',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_70,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_70_1_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_70_10 SET
    code = '70.10',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_70_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_70_10_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_70_2 SET
    code = '70.2',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_70,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_70_2_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_70_20 SET
    code = '70.20',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_70_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_70_20_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_71 SET
    code = '71',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_m,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_71_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_71_1 SET
    code = '71.1',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_71,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_71_1_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_71_11 SET
    code = '71.11',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_71_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_71_11_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_71_12 SET
    code = '71.12',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_71_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_71_12_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_71_2 SET
    code = '71.2',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_71,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_71_2_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_71_20 SET
    code = '71.20',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_71_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_71_20_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_72 SET
    code = '72',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_m,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_72_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_72_1 SET
    code = '72.1',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_72,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_72_1_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_72_10 SET
    code = '72.10',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_72_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_72_10_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_72_2 SET
    code = '72.2',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_72,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_72_2_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_72_20 SET
    code = '72.20',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_72_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_72_20_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_73 SET
    code = '73',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_m,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_73_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_73_1 SET
    code = '73.1',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_73,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_73_1_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_73_11 SET
    code = '73.11',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_73_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_73_11_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_73_12 SET
    code = '73.12',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_73_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_73_12_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_73_2 SET
    code = '73.2',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_73,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_73_2_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_73_20 SET
    code = '73.20',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_73_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_73_20_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_73_3 SET
    code = '73.3',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_73,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_73_3_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_73_30 SET
    code = '73.30',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_73_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_73_30_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_74 SET
    code = '74',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_m,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_74_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_74_1 SET
    code = '74.1',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_74,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_74_1_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_74_11 SET
    code = '74.11',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_74_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_74_11_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_74_12 SET
    code = '74.12',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_74_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_74_12_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_74_13 SET
    code = '74.13',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_74_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_74_13_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_74_14 SET
    code = '74.14',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_74_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_74_14_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_74_2 SET
    code = '74.2',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_74,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_74_2_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_74_20 SET
    code = '74.20',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_74_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_74_20_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_74_3 SET
    code = '74.3',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_74,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_74_3_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_74_30 SET
    code = '74.30',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_74_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_74_30_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_74_9 SET
    code = '74.9',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_74,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_74_9_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_74_91 SET
    code = '74.91',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_74_9,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_74_91_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_74_99 SET
    code = '74.99',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_74_9,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_74_99_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_75 SET
    code = '75',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_m,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_75_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_75_0 SET
    code = '75.0',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_75,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_75_0_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_75_00 SET
    code = '75.00',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_75_0,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_75_00_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_o SET
    code = 'O',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:section,
    pays_reference = NONE,
    parent_code = NONE,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_o_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_77 SET
    code = '77',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_n,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_77_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_77_1 SET
    code = '77.1',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_77,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_77_1_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_77_11 SET
    code = '77.11',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_77_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_77_11_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_77_12 SET
    code = '77.12',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_77_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_77_12_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_77_2 SET
    code = '77.2',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_77,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_77_2_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_77_21 SET
    code = '77.21',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_77_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_77_21_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_77_22 SET
    code = '77.22',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_77_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_77_22_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_77_3 SET
    code = '77.3',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_77,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_77_3_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_77_31 SET
    code = '77.31',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_77_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_77_31_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_77_32 SET
    code = '77.32',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_77_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_77_32_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_77_33 SET
    code = '77.33',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_77_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_77_33_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_77_34 SET
    code = '77.34',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_77_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_77_34_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_77_35 SET
    code = '77.35',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_77_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_77_35_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_77_39 SET
    code = '77.39',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_77_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_77_39_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_77_4 SET
    code = '77.4',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_77,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_77_4_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_77_40 SET
    code = '77.40',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_77_4,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_77_40_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_77_5 SET
    code = '77.5',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_77,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_77_5_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_77_51 SET
    code = '77.51',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_77_5,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_77_51_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_77_52 SET
    code = '77.52',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_77_5,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_77_52_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_78 SET
    code = '78',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_n,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_78_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_78_1 SET
    code = '78.1',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_78,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_78_1_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_78_10 SET
    code = '78.10',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_78_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_78_10_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_78_2 SET
    code = '78.2',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_78,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_78_2_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_78_20 SET
    code = '78.20',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_78_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_78_20_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_79 SET
    code = '79',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_n,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_79_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_79_1 SET
    code = '79.1',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_79,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_79_1_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_79_11 SET
    code = '79.11',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_79_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_79_11_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_79_12 SET
    code = '79.12',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_79_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_79_12_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_79_9 SET
    code = '79.9',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_79,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_79_9_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_79_90 SET
    code = '79.90',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_79_9,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_79_90_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_80 SET
    code = '80',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_n,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_80_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_80_0 SET
    code = '80.0',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_80,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_80_0_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_80_01 SET
    code = '80.01',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_80_0,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_80_01_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_80_09 SET
    code = '80.09',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_80_0,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_80_09_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_81 SET
    code = '81',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_n,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_81_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_81_1 SET
    code = '81.1',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_81,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_81_1_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_81_10 SET
    code = '81.10',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_81_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_81_10_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_81_2 SET
    code = '81.2',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_81,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_81_2_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_81_21 SET
    code = '81.21',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_81_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_81_21_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_81_22 SET
    code = '81.22',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_81_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_81_22_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_81_23 SET
    code = '81.23',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_81_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_81_23_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_81_3 SET
    code = '81.3',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_81,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_81_3_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_81_30 SET
    code = '81.30',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_81_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_81_30_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_82 SET
    code = '82',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_n,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_82_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_82_1 SET
    code = '82.1',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_82,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_82_1_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_82_10 SET
    code = '82.10',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_82_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_82_10_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_82_2 SET
    code = '82.2',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_82,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_82_2_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_82_20 SET
    code = '82.20',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_82_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_82_20_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_82_3 SET
    code = '82.3',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_82,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_82_3_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_82_30 SET
    code = '82.30',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_82_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_82_30_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_82_4 SET
    code = '82.4',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_82,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_82_4_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_82_40 SET
    code = '82.40',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_82_4,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_82_40_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_82_9 SET
    code = '82.9',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_82,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_82_9_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_82_91 SET
    code = '82.91',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_82_9,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_82_91_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_82_92 SET
    code = '82.92',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_82_9,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_82_92_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_82_99 SET
    code = '82.99',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_82_9,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_82_99_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_p SET
    code = 'P',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:section,
    pays_reference = NONE,
    parent_code = NONE,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_p_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_84 SET
    code = '84',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_o,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_84_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_84_1 SET
    code = '84.1',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_84,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_84_1_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_84_11 SET
    code = '84.11',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_84_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_84_11_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_84_12 SET
    code = '84.12',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_84_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_84_12_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_84_13 SET
    code = '84.13',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_84_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_84_13_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_84_2 SET
    code = '84.2',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_84,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_84_2_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_84_21 SET
    code = '84.21',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_84_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_84_21_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_84_22 SET
    code = '84.22',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_84_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_84_22_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_84_23 SET
    code = '84.23',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_84_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_84_23_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_84_24 SET
    code = '84.24',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_84_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_84_24_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_84_25 SET
    code = '84.25',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_84_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_84_25_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_84_3 SET
    code = '84.3',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_84,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_84_3_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_84_30 SET
    code = '84.30',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_84_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_84_30_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_q SET
    code = 'Q',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:section,
    pays_reference = NONE,
    parent_code = NONE,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_q_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_85 SET
    code = '85',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_p,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_85_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_85_1 SET
    code = '85.1',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_85,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_85_1_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_85_10 SET
    code = '85.10',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_85_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_85_10_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_85_2 SET
    code = '85.2',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_85,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_85_2_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_85_20 SET
    code = '85.20',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_85_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_85_20_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_85_3 SET
    code = '85.3',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_85,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_85_3_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_85_31 SET
    code = '85.31',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_85_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_85_31_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_85_32 SET
    code = '85.32',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_85_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_85_32_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_85_33 SET
    code = '85.33',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_85_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_85_33_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_85_4 SET
    code = '85.4',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_85,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_85_4_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_85_40 SET
    code = '85.40',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_85_4,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_85_40_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_85_5 SET
    code = '85.5',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_85,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_85_5_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_85_51 SET
    code = '85.51',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_85_5,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_85_51_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_85_52 SET
    code = '85.52',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_85_5,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_85_52_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_85_53 SET
    code = '85.53',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_85_5,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_85_53_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_85_59 SET
    code = '85.59',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_85_5,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_85_59_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_85_6 SET
    code = '85.6',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_85,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_85_6_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_85_61 SET
    code = '85.61',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_85_6,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_85_61_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_85_69 SET
    code = '85.69',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_85_6,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_85_69_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_r SET
    code = 'R',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:section,
    pays_reference = NONE,
    parent_code = NONE,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_r_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_86 SET
    code = '86',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_q,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_86_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_86_1 SET
    code = '86.1',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_86,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_86_1_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_86_10 SET
    code = '86.10',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_86_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_86_10_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_86_2 SET
    code = '86.2',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_86,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_86_2_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_86_21 SET
    code = '86.21',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_86_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_86_21_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_86_22 SET
    code = '86.22',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_86_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_86_22_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_86_23 SET
    code = '86.23',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_86_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_86_23_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_86_9 SET
    code = '86.9',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_86,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_86_9_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_86_91 SET
    code = '86.91',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_86_9,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_86_91_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_86_92 SET
    code = '86.92',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_86_9,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_86_92_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_86_93 SET
    code = '86.93',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_86_9,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_86_93_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_86_94 SET
    code = '86.94',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_86_9,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_86_94_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_86_95 SET
    code = '86.95',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_86_9,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_86_95_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_86_96 SET
    code = '86.96',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_86_9,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_86_96_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_86_97 SET
    code = '86.97',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_86_9,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_86_97_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_86_99 SET
    code = '86.99',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_86_9,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_86_99_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_87 SET
    code = '87',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_q,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_87_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_87_1 SET
    code = '87.1',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_87,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_87_1_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_87_10 SET
    code = '87.10',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_87_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_87_10_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_87_2 SET
    code = '87.2',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_87,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_87_2_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_87_20 SET
    code = '87.20',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_87_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_87_20_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_87_3 SET
    code = '87.3',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_87,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_87_3_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_87_30 SET
    code = '87.30',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_87_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_87_30_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_87_9 SET
    code = '87.9',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_87,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_87_9_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_87_91 SET
    code = '87.91',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_87_9,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_87_91_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_87_99 SET
    code = '87.99',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_87_9,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_87_99_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_88 SET
    code = '88',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_q,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_88_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_88_1 SET
    code = '88.1',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_88,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_88_1_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_88_10 SET
    code = '88.10',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_88_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_88_10_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_88_9 SET
    code = '88.9',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_88,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_88_9_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_88_91 SET
    code = '88.91',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_88_9,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_88_91_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_88_99 SET
    code = '88.99',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_88_9,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_88_99_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_s SET
    code = 'S',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:section,
    pays_reference = NONE,
    parent_code = NONE,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_s_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_90 SET
    code = '90',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_r,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_90_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_90_1 SET
    code = '90.1',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_90,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_90_1_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_90_11 SET
    code = '90.11',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_90_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_90_11_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_90_12 SET
    code = '90.12',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_90_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_90_12_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_90_13 SET
    code = '90.13',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_90_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_90_13_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_90_2 SET
    code = '90.2',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_90,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_90_2_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_90_20 SET
    code = '90.20',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_90_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_90_20_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_90_3 SET
    code = '90.3',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_90,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_90_3_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_90_31 SET
    code = '90.31',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_90_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_90_31_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_90_39 SET
    code = '90.39',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_90_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_90_39_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_91 SET
    code = '91',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_r,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_91_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_91_1 SET
    code = '91.1',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_91,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_91_1_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_91_11 SET
    code = '91.11',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_91_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_91_11_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_91_12 SET
    code = '91.12',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_91_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_91_12_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_91_2 SET
    code = '91.2',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_91,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_91_2_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_91_21 SET
    code = '91.21',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_91_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_91_21_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_91_22 SET
    code = '91.22',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_91_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_91_22_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_91_3 SET
    code = '91.3',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_91,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_91_3_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_91_30 SET
    code = '91.30',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_91_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_91_30_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_91_4 SET
    code = '91.4',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_91,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_91_4_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_91_41 SET
    code = '91.41',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_91_4,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_91_41_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_91_42 SET
    code = '91.42',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_91_4,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_91_42_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_92 SET
    code = '92',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_r,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_92_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_92_0 SET
    code = '92.0',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_92,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_92_0_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_92_00 SET
    code = '92.00',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_92_0,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_92_00_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_93 SET
    code = '93',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_r,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_93_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_93_1 SET
    code = '93.1',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_93,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_93_1_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_93_11 SET
    code = '93.11',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_93_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_93_11_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_93_12 SET
    code = '93.12',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_93_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_93_12_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_93_13 SET
    code = '93.13',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_93_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_93_13_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_93_19 SET
    code = '93.19',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_93_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_93_19_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_93_2 SET
    code = '93.2',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_93,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_93_2_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_93_21 SET
    code = '93.21',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_93_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_93_21_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_93_29 SET
    code = '93.29',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_93_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_93_29_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_t SET
    code = 'T',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:section,
    pays_reference = NONE,
    parent_code = NONE,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_t_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_94 SET
    code = '94',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_s,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_94_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_94_1 SET
    code = '94.1',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_94,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_94_1_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_94_11 SET
    code = '94.11',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_94_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_94_11_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_94_12 SET
    code = '94.12',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_94_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_94_12_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_94_2 SET
    code = '94.2',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_94,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_94_2_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_94_20 SET
    code = '94.20',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_94_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_94_20_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_94_9 SET
    code = '94.9',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_94,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_94_9_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_94_91 SET
    code = '94.91',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_94_9,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_94_91_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_94_92 SET
    code = '94.92',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_94_9,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_94_92_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_94_99 SET
    code = '94.99',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_94_9,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_94_99_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_95 SET
    code = '95',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_s,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_95_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_95_1 SET
    code = '95.1',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_95,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_95_1_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_95_10 SET
    code = '95.10',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_95_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_95_10_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_95_2 SET
    code = '95.2',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_95,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_95_2_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_95_21 SET
    code = '95.21',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_95_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_95_21_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_95_22 SET
    code = '95.22',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_95_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_95_22_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_95_23 SET
    code = '95.23',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_95_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_95_23_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_95_24 SET
    code = '95.24',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_95_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_95_24_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_95_25 SET
    code = '95.25',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_95_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_95_25_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_95_29 SET
    code = '95.29',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_95_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_95_29_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_95_3 SET
    code = '95.3',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_95,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_95_3_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_95_31 SET
    code = '95.31',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_95_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_95_31_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_95_32 SET
    code = '95.32',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_95_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_95_32_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_95_4 SET
    code = '95.4',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_95,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_95_4_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_95_40 SET
    code = '95.40',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_95_4,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_95_40_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_96 SET
    code = '96',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_s,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_96_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_96_1 SET
    code = '96.1',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_96,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_96_1_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_96_10 SET
    code = '96.10',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_96_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_96_10_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_96_2 SET
    code = '96.2',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_96,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_96_2_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_96_21 SET
    code = '96.21',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_96_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_96_21_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_96_22 SET
    code = '96.22',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_96_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_96_22_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_96_23 SET
    code = '96.23',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_96_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_96_23_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_96_3 SET
    code = '96.3',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_96,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_96_3_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_96_30 SET
    code = '96.30',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_96_3,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_96_30_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_96_4 SET
    code = '96.4',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_96,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_96_4_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_96_40 SET
    code = '96.40',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_96_4,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_96_40_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_96_9 SET
    code = '96.9',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_96,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_96_9_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_96_91 SET
    code = '96.91',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_96_9,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_96_91_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_96_99 SET
    code = '96.99',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_96_9,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_96_99_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_u SET
    code = 'U',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:section,
    pays_reference = NONE,
    parent_code = NONE,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_u_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_97 SET
    code = '97',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_t,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_97_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_97_0 SET
    code = '97.0',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_97,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_97_0_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_97_00 SET
    code = '97.00',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_97_0,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_97_00_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_98 SET
    code = '98',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_t,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_98_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_98_1 SET
    code = '98.1',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_98,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_98_1_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_98_10 SET
    code = '98.10',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_98_1,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_98_10_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_98_2 SET
    code = '98.2',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_98,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_98_2_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_98_20 SET
    code = '98.20',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_98_2,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_98_20_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_v SET
    code = 'V',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:section,
    pays_reference = NONE,
    parent_code = NONE,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_v_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_99 SET
    code = '99',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:division,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_u,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_99_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_99_0 SET
    code = '99.0',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:groupe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_99,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_99_0_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;

CREATE society_activity_code:nace_rev2_99_00 SET
    code = '99.00',
    nomenclature_type = society_activity_nomenclature_type:nace_rev2_1,
    hierarchical_level = society_activity_hierarchical_level:classe,
    pays_reference = NONE,
    parent_code = society_activity_code:nace_rev2_99_0,
    libelle_long_i18n_key = i18n_key:society_activity_code_nace_rev2_99_00_long,
    libelle_moyen_i18n_key = NONE,
    libelle_court_i18n_key = NONE;


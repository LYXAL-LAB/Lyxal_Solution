-- =================================================================================================
-- SEEDS: business_legal_form
-- Total: 307 formes juridiques
-- =================================================================================================

-- Niveau 1 (10 formes)
-- -------------------------------------------------------------------------------------------------

CREATE business_legal_form:cj_0 SET
    code = '0',
    level = business_legal_form_level:level_1,
    parent_code = NONE,
    name_i18n_key = i18n_key:i18n_legal_form_0_name;

CREATE business_legal_form:cj_1 SET
    code = '1',
    level = business_legal_form_level:level_1,
    parent_code = NONE,
    name_i18n_key = i18n_key:i18n_legal_form_1_name;

CREATE business_legal_form:cj_2 SET
    code = '2',
    level = business_legal_form_level:level_1,
    parent_code = NONE,
    name_i18n_key = i18n_key:i18n_legal_form_2_name;

CREATE business_legal_form:cj_3 SET
    code = '3',
    level = business_legal_form_level:level_1,
    parent_code = NONE,
    name_i18n_key = i18n_key:i18n_legal_form_3_name;

CREATE business_legal_form:cj_4 SET
    code = '4',
    level = business_legal_form_level:level_1,
    parent_code = NONE,
    name_i18n_key = i18n_key:i18n_legal_form_4_name;

CREATE business_legal_form:cj_5 SET
    code = '5',
    level = business_legal_form_level:level_1,
    parent_code = NONE,
    name_i18n_key = i18n_key:i18n_legal_form_5_name;

CREATE business_legal_form:cj_6 SET
    code = '6',
    level = business_legal_form_level:level_1,
    parent_code = NONE,
    name_i18n_key = i18n_key:i18n_legal_form_6_name;

CREATE business_legal_form:cj_7 SET
    code = '7',
    level = business_legal_form_level:level_1,
    parent_code = NONE,
    name_i18n_key = i18n_key:i18n_legal_form_7_name;

CREATE business_legal_form:cj_8 SET
    code = '8',
    level = business_legal_form_level:level_1,
    parent_code = NONE,
    name_i18n_key = i18n_key:i18n_legal_form_8_name;

CREATE business_legal_form:cj_9 SET
    code = '9',
    level = business_legal_form_level:level_1,
    parent_code = NONE,
    name_i18n_key = i18n_key:i18n_legal_form_9_name;

-- Niveau 2 (38 formes)
-- -------------------------------------------------------------------------------------------------

CREATE business_legal_form:cj_10 SET
    code = '10',
    level = business_legal_form_level:level_2,
    parent_code = business_legal_form:cj_1,
    name_i18n_key = i18n_key:i18n_legal_form_10_name;

CREATE business_legal_form:cj_21 SET
    code = '21',
    level = business_legal_form_level:level_2,
    parent_code = business_legal_form:cj_2,
    name_i18n_key = i18n_key:i18n_legal_form_21_name;

CREATE business_legal_form:cj_22 SET
    code = '22',
    level = business_legal_form_level:level_2,
    parent_code = business_legal_form:cj_2,
    name_i18n_key = i18n_key:i18n_legal_form_22_name;

CREATE business_legal_form:cj_23 SET
    code = '23',
    level = business_legal_form_level:level_2,
    parent_code = business_legal_form:cj_2,
    name_i18n_key = i18n_key:i18n_legal_form_23_name;

CREATE business_legal_form:cj_24 SET
    code = '24',
    level = business_legal_form_level:level_2,
    parent_code = business_legal_form:cj_2,
    name_i18n_key = i18n_key:i18n_legal_form_24_name;

CREATE business_legal_form:cj_27 SET
    code = '27',
    level = business_legal_form_level:level_2,
    parent_code = business_legal_form:cj_2,
    name_i18n_key = i18n_key:i18n_legal_form_27_name;

CREATE business_legal_form:cj_28 SET
    code = '28',
    level = business_legal_form_level:level_2,
    parent_code = business_legal_form:cj_2,
    name_i18n_key = i18n_key:i18n_legal_form_28_name;

CREATE business_legal_form:cj_29 SET
    code = '29',
    level = business_legal_form_level:level_2,
    parent_code = business_legal_form:cj_2,
    name_i18n_key = i18n_key:i18n_legal_form_29_name;

CREATE business_legal_form:cj_31 SET
    code = '31',
    level = business_legal_form_level:level_2,
    parent_code = business_legal_form:cj_3,
    name_i18n_key = i18n_key:i18n_legal_form_31_name;

CREATE business_legal_form:cj_32 SET
    code = '32',
    level = business_legal_form_level:level_2,
    parent_code = business_legal_form:cj_3,
    name_i18n_key = i18n_key:i18n_legal_form_32_name;

CREATE business_legal_form:cj_41 SET
    code = '41',
    level = business_legal_form_level:level_2,
    parent_code = business_legal_form:cj_4,
    name_i18n_key = i18n_key:i18n_legal_form_41_name;

CREATE business_legal_form:cj_51 SET
    code = '51',
    level = business_legal_form_level:level_2,
    parent_code = business_legal_form:cj_5,
    name_i18n_key = i18n_key:i18n_legal_form_51_name;

CREATE business_legal_form:cj_52 SET
    code = '52',
    level = business_legal_form_level:level_2,
    parent_code = business_legal_form:cj_5,
    name_i18n_key = i18n_key:i18n_legal_form_52_name;

CREATE business_legal_form:cj_53 SET
    code = '53',
    level = business_legal_form_level:level_2,
    parent_code = business_legal_form:cj_5,
    name_i18n_key = i18n_key:i18n_legal_form_53_name;

CREATE business_legal_form:cj_54 SET
    code = '54',
    level = business_legal_form_level:level_2,
    parent_code = business_legal_form:cj_5,
    name_i18n_key = i18n_key:i18n_legal_form_54_name;

CREATE business_legal_form:cj_55 SET
    code = '55',
    level = business_legal_form_level:level_2,
    parent_code = business_legal_form:cj_5,
    name_i18n_key = i18n_key:i18n_legal_form_55_name;

CREATE business_legal_form:cj_56 SET
    code = '56',
    level = business_legal_form_level:level_2,
    parent_code = business_legal_form:cj_5,
    name_i18n_key = i18n_key:i18n_legal_form_56_name;

CREATE business_legal_form:cj_57 SET
    code = '57',
    level = business_legal_form_level:level_2,
    parent_code = business_legal_form:cj_5,
    name_i18n_key = i18n_key:i18n_legal_form_57_name;

CREATE business_legal_form:cj_58 SET
    code = '58',
    level = business_legal_form_level:level_2,
    parent_code = business_legal_form:cj_5,
    name_i18n_key = i18n_key:i18n_legal_form_58_name;

CREATE business_legal_form:cj_61 SET
    code = '61',
    level = business_legal_form_level:level_2,
    parent_code = business_legal_form:cj_6,
    name_i18n_key = i18n_key:i18n_legal_form_61_name;

CREATE business_legal_form:cj_62 SET
    code = '62',
    level = business_legal_form_level:level_2,
    parent_code = business_legal_form:cj_6,
    name_i18n_key = i18n_key:i18n_legal_form_62_name;

CREATE business_legal_form:cj_63 SET
    code = '63',
    level = business_legal_form_level:level_2,
    parent_code = business_legal_form:cj_6,
    name_i18n_key = i18n_key:i18n_legal_form_63_name;

CREATE business_legal_form:cj_64 SET
    code = '64',
    level = business_legal_form_level:level_2,
    parent_code = business_legal_form:cj_6,
    name_i18n_key = i18n_key:i18n_legal_form_64_name;

CREATE business_legal_form:cj_65 SET
    code = '65',
    level = business_legal_form_level:level_2,
    parent_code = business_legal_form:cj_6,
    name_i18n_key = i18n_key:i18n_legal_form_65_name;

CREATE business_legal_form:cj_69 SET
    code = '69',
    level = business_legal_form_level:level_2,
    parent_code = business_legal_form:cj_6,
    name_i18n_key = i18n_key:i18n_legal_form_69_name;

CREATE business_legal_form:cj_71 SET
    code = '71',
    level = business_legal_form_level:level_2,
    parent_code = business_legal_form:cj_7,
    name_i18n_key = i18n_key:i18n_legal_form_71_name;

CREATE business_legal_form:cj_72 SET
    code = '72',
    level = business_legal_form_level:level_2,
    parent_code = business_legal_form:cj_7,
    name_i18n_key = i18n_key:i18n_legal_form_72_name;

CREATE business_legal_form:cj_73 SET
    code = '73',
    level = business_legal_form_level:level_2,
    parent_code = business_legal_form:cj_7,
    name_i18n_key = i18n_key:i18n_legal_form_73_name;

CREATE business_legal_form:cj_74 SET
    code = '74',
    level = business_legal_form_level:level_2,
    parent_code = business_legal_form:cj_7,
    name_i18n_key = i18n_key:i18n_legal_form_74_name;

CREATE business_legal_form:cj_81 SET
    code = '81',
    level = business_legal_form_level:level_2,
    parent_code = business_legal_form:cj_8,
    name_i18n_key = i18n_key:i18n_legal_form_81_name;

CREATE business_legal_form:cj_82 SET
    code = '82',
    level = business_legal_form_level:level_2,
    parent_code = business_legal_form:cj_8,
    name_i18n_key = i18n_key:i18n_legal_form_82_name;

CREATE business_legal_form:cj_83 SET
    code = '83',
    level = business_legal_form_level:level_2,
    parent_code = business_legal_form:cj_8,
    name_i18n_key = i18n_key:i18n_legal_form_83_name;

CREATE business_legal_form:cj_84 SET
    code = '84',
    level = business_legal_form_level:level_2,
    parent_code = business_legal_form:cj_8,
    name_i18n_key = i18n_key:i18n_legal_form_84_name;

CREATE business_legal_form:cj_85 SET
    code = '85',
    level = business_legal_form_level:level_2,
    parent_code = business_legal_form:cj_8,
    name_i18n_key = i18n_key:i18n_legal_form_85_name;

CREATE business_legal_form:cj_91 SET
    code = '91',
    level = business_legal_form_level:level_2,
    parent_code = business_legal_form:cj_9,
    name_i18n_key = i18n_key:i18n_legal_form_91_name;

CREATE business_legal_form:cj_92 SET
    code = '92',
    level = business_legal_form_level:level_2,
    parent_code = business_legal_form:cj_9,
    name_i18n_key = i18n_key:i18n_legal_form_92_name;

CREATE business_legal_form:cj_93 SET
    code = '93',
    level = business_legal_form_level:level_2,
    parent_code = business_legal_form:cj_9,
    name_i18n_key = i18n_key:i18n_legal_form_93_name;

CREATE business_legal_form:cj_99 SET
    code = '99',
    level = business_legal_form_level:level_2,
    parent_code = business_legal_form:cj_9,
    name_i18n_key = i18n_key:i18n_legal_form_99_name;

-- Niveau 3 (259 formes)
-- -------------------------------------------------------------------------------------------------

CREATE business_legal_form:cj_1000 SET
    code = '1000',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_10,
    name_i18n_key = i18n_key:i18n_legal_form_1000_name;

CREATE business_legal_form:cj_2110 SET
    code = '2110',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_21,
    name_i18n_key = i18n_key:i18n_legal_form_2110_name;

CREATE business_legal_form:cj_2120 SET
    code = '2120',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_21,
    name_i18n_key = i18n_key:i18n_legal_form_2120_name;

CREATE business_legal_form:cj_2210 SET
    code = '2210',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_22,
    name_i18n_key = i18n_key:i18n_legal_form_2210_name;

CREATE business_legal_form:cj_2220 SET
    code = '2220',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_22,
    name_i18n_key = i18n_key:i18n_legal_form_2220_name;

CREATE business_legal_form:cj_2310 SET
    code = '2310',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_23,
    name_i18n_key = i18n_key:i18n_legal_form_2310_name;

CREATE business_legal_form:cj_2320 SET
    code = '2320',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_23,
    name_i18n_key = i18n_key:i18n_legal_form_2320_name;

CREATE business_legal_form:cj_2385 SET
    code = '2385',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_23,
    name_i18n_key = i18n_key:i18n_legal_form_2385_name;

CREATE business_legal_form:cj_2400 SET
    code = '2400',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_24,
    name_i18n_key = i18n_key:i18n_legal_form_2400_name;

CREATE business_legal_form:cj_2700 SET
    code = '2700',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_27,
    name_i18n_key = i18n_key:i18n_legal_form_2700_name;

CREATE business_legal_form:cj_2800 SET
    code = '2800',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_28,
    name_i18n_key = i18n_key:i18n_legal_form_2800_name;

CREATE business_legal_form:cj_2900 SET
    code = '2900',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_29,
    name_i18n_key = i18n_key:i18n_legal_form_2900_name;

CREATE business_legal_form:cj_3110 SET
    code = '3110',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_31,
    name_i18n_key = i18n_key:i18n_legal_form_3110_name;

CREATE business_legal_form:cj_3120 SET
    code = '3120',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_31,
    name_i18n_key = i18n_key:i18n_legal_form_3120_name;

CREATE business_legal_form:cj_3205 SET
    code = '3205',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_32,
    name_i18n_key = i18n_key:i18n_legal_form_3205_name;

CREATE business_legal_form:cj_3210 SET
    code = '3210',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_32,
    name_i18n_key = i18n_key:i18n_legal_form_3210_name;

CREATE business_legal_form:cj_3220 SET
    code = '3220',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_32,
    name_i18n_key = i18n_key:i18n_legal_form_3220_name;

CREATE business_legal_form:cj_3290 SET
    code = '3290',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_32,
    name_i18n_key = i18n_key:i18n_legal_form_3290_name;

CREATE business_legal_form:cj_4110 SET
    code = '4110',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_41,
    name_i18n_key = i18n_key:i18n_legal_form_4110_name;

CREATE business_legal_form:cj_4120 SET
    code = '4120',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_41,
    name_i18n_key = i18n_key:i18n_legal_form_4120_name;

CREATE business_legal_form:cj_4130 SET
    code = '4130',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_41,
    name_i18n_key = i18n_key:i18n_legal_form_4130_name;

CREATE business_legal_form:cj_4140 SET
    code = '4140',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_41,
    name_i18n_key = i18n_key:i18n_legal_form_4140_name;

CREATE business_legal_form:cj_4150 SET
    code = '4150',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_41,
    name_i18n_key = i18n_key:i18n_legal_form_4150_name;

CREATE business_legal_form:cj_4160 SET
    code = '4160',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_41,
    name_i18n_key = i18n_key:i18n_legal_form_4160_name;

CREATE business_legal_form:cj_5191 SET
    code = '5191',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_51,
    name_i18n_key = i18n_key:i18n_legal_form_5191_name;

CREATE business_legal_form:cj_5192 SET
    code = '5192',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_51,
    name_i18n_key = i18n_key:i18n_legal_form_5192_name;

CREATE business_legal_form:cj_5193 SET
    code = '5193',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_51,
    name_i18n_key = i18n_key:i18n_legal_form_5193_name;

CREATE business_legal_form:cj_5194 SET
    code = '5194',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_51,
    name_i18n_key = i18n_key:i18n_legal_form_5194_name;

CREATE business_legal_form:cj_5195 SET
    code = '5195',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_51,
    name_i18n_key = i18n_key:i18n_legal_form_5195_name;

CREATE business_legal_form:cj_5196 SET
    code = '5196',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_51,
    name_i18n_key = i18n_key:i18n_legal_form_5196_name;

CREATE business_legal_form:cj_5202 SET
    code = '5202',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_52,
    name_i18n_key = i18n_key:i18n_legal_form_5202_name;

CREATE business_legal_form:cj_5203 SET
    code = '5203',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_52,
    name_i18n_key = i18n_key:i18n_legal_form_5203_name;

CREATE business_legal_form:cj_5306 SET
    code = '5306',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_53,
    name_i18n_key = i18n_key:i18n_legal_form_5306_name;

CREATE business_legal_form:cj_5307 SET
    code = '5307',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_53,
    name_i18n_key = i18n_key:i18n_legal_form_5307_name;

CREATE business_legal_form:cj_5308 SET
    code = '5308',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_53,
    name_i18n_key = i18n_key:i18n_legal_form_5308_name;

CREATE business_legal_form:cj_5309 SET
    code = '5309',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_53,
    name_i18n_key = i18n_key:i18n_legal_form_5309_name;

CREATE business_legal_form:cj_5310 SET
    code = '5310',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_53,
    name_i18n_key = i18n_key:i18n_legal_form_5310_name;

CREATE business_legal_form:cj_5370 SET
    code = '5370',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_53,
    name_i18n_key = i18n_key:i18n_legal_form_5370_name;

CREATE business_legal_form:cj_5385 SET
    code = '5385',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_53,
    name_i18n_key = i18n_key:i18n_legal_form_5385_name;

CREATE business_legal_form:cj_5410 SET
    code = '5410',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_54,
    name_i18n_key = i18n_key:i18n_legal_form_5410_name;

CREATE business_legal_form:cj_5415 SET
    code = '5415',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_54,
    name_i18n_key = i18n_key:i18n_legal_form_5415_name;

CREATE business_legal_form:cj_5422 SET
    code = '5422',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_54,
    name_i18n_key = i18n_key:i18n_legal_form_5422_name;

CREATE business_legal_form:cj_5426 SET
    code = '5426',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_54,
    name_i18n_key = i18n_key:i18n_legal_form_5426_name;

CREATE business_legal_form:cj_5430 SET
    code = '5430',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_54,
    name_i18n_key = i18n_key:i18n_legal_form_5430_name;

CREATE business_legal_form:cj_5431 SET
    code = '5431',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_54,
    name_i18n_key = i18n_key:i18n_legal_form_5431_name;

CREATE business_legal_form:cj_5432 SET
    code = '5432',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_54,
    name_i18n_key = i18n_key:i18n_legal_form_5432_name;

CREATE business_legal_form:cj_5442 SET
    code = '5442',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_54,
    name_i18n_key = i18n_key:i18n_legal_form_5442_name;

CREATE business_legal_form:cj_5443 SET
    code = '5443',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_54,
    name_i18n_key = i18n_key:i18n_legal_form_5443_name;

CREATE business_legal_form:cj_5451 SET
    code = '5451',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_54,
    name_i18n_key = i18n_key:i18n_legal_form_5451_name;

CREATE business_legal_form:cj_5453 SET
    code = '5453',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_54,
    name_i18n_key = i18n_key:i18n_legal_form_5453_name;

CREATE business_legal_form:cj_5454 SET
    code = '5454',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_54,
    name_i18n_key = i18n_key:i18n_legal_form_5454_name;

CREATE business_legal_form:cj_5455 SET
    code = '5455',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_54,
    name_i18n_key = i18n_key:i18n_legal_form_5455_name;

CREATE business_legal_form:cj_5458 SET
    code = '5458',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_54,
    name_i18n_key = i18n_key:i18n_legal_form_5458_name;

CREATE business_legal_form:cj_5459 SET
    code = '5459',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_54,
    name_i18n_key = i18n_key:i18n_legal_form_5459_name;

CREATE business_legal_form:cj_5460 SET
    code = '5460',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_54,
    name_i18n_key = i18n_key:i18n_legal_form_5460_name;

CREATE business_legal_form:cj_5470 SET
    code = '5470',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_54,
    name_i18n_key = i18n_key:i18n_legal_form_5470_name;

CREATE business_legal_form:cj_5485 SET
    code = '5485',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_54,
    name_i18n_key = i18n_key:i18n_legal_form_5485_name;

CREATE business_legal_form:cj_5499 SET
    code = '5499',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_54,
    name_i18n_key = i18n_key:i18n_legal_form_5499_name;

CREATE business_legal_form:cj_5505 SET
    code = '5505',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_55,
    name_i18n_key = i18n_key:i18n_legal_form_5505_name;

CREATE business_legal_form:cj_5510 SET
    code = '5510',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_55,
    name_i18n_key = i18n_key:i18n_legal_form_5510_name;

CREATE business_legal_form:cj_5515 SET
    code = '5515',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_55,
    name_i18n_key = i18n_key:i18n_legal_form_5515_name;

CREATE business_legal_form:cj_5520 SET
    code = '5520',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_55,
    name_i18n_key = i18n_key:i18n_legal_form_5520_name;

CREATE business_legal_form:cj_5522 SET
    code = '5522',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_55,
    name_i18n_key = i18n_key:i18n_legal_form_5522_name;

CREATE business_legal_form:cj_5525 SET
    code = '5525',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_55,
    name_i18n_key = i18n_key:i18n_legal_form_5525_name;

CREATE business_legal_form:cj_5530 SET
    code = '5530',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_55,
    name_i18n_key = i18n_key:i18n_legal_form_5530_name;

CREATE business_legal_form:cj_5531 SET
    code = '5531',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_55,
    name_i18n_key = i18n_key:i18n_legal_form_5531_name;

CREATE business_legal_form:cj_5532 SET
    code = '5532',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_55,
    name_i18n_key = i18n_key:i18n_legal_form_5532_name;

CREATE business_legal_form:cj_5542 SET
    code = '5542',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_55,
    name_i18n_key = i18n_key:i18n_legal_form_5542_name;

CREATE business_legal_form:cj_5543 SET
    code = '5543',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_55,
    name_i18n_key = i18n_key:i18n_legal_form_5543_name;

CREATE business_legal_form:cj_5546 SET
    code = '5546',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_55,
    name_i18n_key = i18n_key:i18n_legal_form_5546_name;

CREATE business_legal_form:cj_5547 SET
    code = '5547',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_55,
    name_i18n_key = i18n_key:i18n_legal_form_5547_name;

CREATE business_legal_form:cj_5548 SET
    code = '5548',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_55,
    name_i18n_key = i18n_key:i18n_legal_form_5548_name;

CREATE business_legal_form:cj_5551 SET
    code = '5551',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_55,
    name_i18n_key = i18n_key:i18n_legal_form_5551_name;

CREATE business_legal_form:cj_5552 SET
    code = '5552',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_55,
    name_i18n_key = i18n_key:i18n_legal_form_5552_name;

CREATE business_legal_form:cj_5553 SET
    code = '5553',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_55,
    name_i18n_key = i18n_key:i18n_legal_form_5553_name;

CREATE business_legal_form:cj_5554 SET
    code = '5554',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_55,
    name_i18n_key = i18n_key:i18n_legal_form_5554_name;

CREATE business_legal_form:cj_5555 SET
    code = '5555',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_55,
    name_i18n_key = i18n_key:i18n_legal_form_5555_name;

CREATE business_legal_form:cj_5558 SET
    code = '5558',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_55,
    name_i18n_key = i18n_key:i18n_legal_form_5558_name;

CREATE business_legal_form:cj_5559 SET
    code = '5559',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_55,
    name_i18n_key = i18n_key:i18n_legal_form_5559_name;

CREATE business_legal_form:cj_5560 SET
    code = '5560',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_55,
    name_i18n_key = i18n_key:i18n_legal_form_5560_name;

CREATE business_legal_form:cj_5570 SET
    code = '5570',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_55,
    name_i18n_key = i18n_key:i18n_legal_form_5570_name;

CREATE business_legal_form:cj_5585 SET
    code = '5585',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_55,
    name_i18n_key = i18n_key:i18n_legal_form_5585_name;

CREATE business_legal_form:cj_5599 SET
    code = '5599',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_55,
    name_i18n_key = i18n_key:i18n_legal_form_5599_name;

CREATE business_legal_form:cj_5605 SET
    code = '5605',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_56,
    name_i18n_key = i18n_key:i18n_legal_form_5605_name;

CREATE business_legal_form:cj_5610 SET
    code = '5610',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_56,
    name_i18n_key = i18n_key:i18n_legal_form_5610_name;

CREATE business_legal_form:cj_5615 SET
    code = '5615',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_56,
    name_i18n_key = i18n_key:i18n_legal_form_5615_name;

CREATE business_legal_form:cj_5620 SET
    code = '5620',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_56,
    name_i18n_key = i18n_key:i18n_legal_form_5620_name;

CREATE business_legal_form:cj_5622 SET
    code = '5622',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_56,
    name_i18n_key = i18n_key:i18n_legal_form_5622_name;

CREATE business_legal_form:cj_5625 SET
    code = '5625',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_56,
    name_i18n_key = i18n_key:i18n_legal_form_5625_name;

CREATE business_legal_form:cj_5630 SET
    code = '5630',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_56,
    name_i18n_key = i18n_key:i18n_legal_form_5630_name;

CREATE business_legal_form:cj_5631 SET
    code = '5631',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_56,
    name_i18n_key = i18n_key:i18n_legal_form_5631_name;

CREATE business_legal_form:cj_5632 SET
    code = '5632',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_56,
    name_i18n_key = i18n_key:i18n_legal_form_5632_name;

CREATE business_legal_form:cj_5642 SET
    code = '5642',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_56,
    name_i18n_key = i18n_key:i18n_legal_form_5642_name;

CREATE business_legal_form:cj_5643 SET
    code = '5643',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_56,
    name_i18n_key = i18n_key:i18n_legal_form_5643_name;

CREATE business_legal_form:cj_5646 SET
    code = '5646',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_56,
    name_i18n_key = i18n_key:i18n_legal_form_5646_name;

CREATE business_legal_form:cj_5647 SET
    code = '5647',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_56,
    name_i18n_key = i18n_key:i18n_legal_form_5647_name;

CREATE business_legal_form:cj_5648 SET
    code = '5648',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_56,
    name_i18n_key = i18n_key:i18n_legal_form_5648_name;

CREATE business_legal_form:cj_5651 SET
    code = '5651',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_56,
    name_i18n_key = i18n_key:i18n_legal_form_5651_name;

CREATE business_legal_form:cj_5652 SET
    code = '5652',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_56,
    name_i18n_key = i18n_key:i18n_legal_form_5652_name;

CREATE business_legal_form:cj_5653 SET
    code = '5653',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_56,
    name_i18n_key = i18n_key:i18n_legal_form_5653_name;

CREATE business_legal_form:cj_5654 SET
    code = '5654',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_56,
    name_i18n_key = i18n_key:i18n_legal_form_5654_name;

CREATE business_legal_form:cj_5655 SET
    code = '5655',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_56,
    name_i18n_key = i18n_key:i18n_legal_form_5655_name;

CREATE business_legal_form:cj_5658 SET
    code = '5658',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_56,
    name_i18n_key = i18n_key:i18n_legal_form_5658_name;

CREATE business_legal_form:cj_5659 SET
    code = '5659',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_56,
    name_i18n_key = i18n_key:i18n_legal_form_5659_name;

CREATE business_legal_form:cj_5660 SET
    code = '5660',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_56,
    name_i18n_key = i18n_key:i18n_legal_form_5660_name;

CREATE business_legal_form:cj_5670 SET
    code = '5670',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_56,
    name_i18n_key = i18n_key:i18n_legal_form_5670_name;

CREATE business_legal_form:cj_5685 SET
    code = '5685',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_56,
    name_i18n_key = i18n_key:i18n_legal_form_5685_name;

CREATE business_legal_form:cj_5699 SET
    code = '5699',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_56,
    name_i18n_key = i18n_key:i18n_legal_form_5699_name;

CREATE business_legal_form:cj_5710 SET
    code = '5710',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_57,
    name_i18n_key = i18n_key:i18n_legal_form_5710_name;

CREATE business_legal_form:cj_5770 SET
    code = '5770',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_57,
    name_i18n_key = i18n_key:i18n_legal_form_5770_name;

CREATE business_legal_form:cj_5785 SET
    code = '5785',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_57,
    name_i18n_key = i18n_key:i18n_legal_form_5785_name;

CREATE business_legal_form:cj_5800 SET
    code = '5800',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_58,
    name_i18n_key = i18n_key:i18n_legal_form_5800_name;

CREATE business_legal_form:cj_6100 SET
    code = '6100',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_61,
    name_i18n_key = i18n_key:i18n_legal_form_6100_name;

CREATE business_legal_form:cj_6210 SET
    code = '6210',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_62,
    name_i18n_key = i18n_key:i18n_legal_form_6210_name;

CREATE business_legal_form:cj_6220 SET
    code = '6220',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_62,
    name_i18n_key = i18n_key:i18n_legal_form_6220_name;

CREATE business_legal_form:cj_6316 SET
    code = '6316',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_63,
    name_i18n_key = i18n_key:i18n_legal_form_6316_name;

CREATE business_legal_form:cj_6317 SET
    code = '6317',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_63,
    name_i18n_key = i18n_key:i18n_legal_form_6317_name;

CREATE business_legal_form:cj_6318 SET
    code = '6318',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_63,
    name_i18n_key = i18n_key:i18n_legal_form_6318_name;

CREATE business_legal_form:cj_6411 SET
    code = '6411',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_64,
    name_i18n_key = i18n_key:i18n_legal_form_6411_name;

CREATE business_legal_form:cj_6511 SET
    code = '6511',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_65,
    name_i18n_key = i18n_key:i18n_legal_form_6511_name;

CREATE business_legal_form:cj_6521 SET
    code = '6521',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_65,
    name_i18n_key = i18n_key:i18n_legal_form_6521_name;

CREATE business_legal_form:cj_6532 SET
    code = '6532',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_65,
    name_i18n_key = i18n_key:i18n_legal_form_6532_name;

CREATE business_legal_form:cj_6533 SET
    code = '6533',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_65,
    name_i18n_key = i18n_key:i18n_legal_form_6533_name;

CREATE business_legal_form:cj_6534 SET
    code = '6534',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_65,
    name_i18n_key = i18n_key:i18n_legal_form_6534_name;

CREATE business_legal_form:cj_6535 SET
    code = '6535',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_65,
    name_i18n_key = i18n_key:i18n_legal_form_6535_name;

CREATE business_legal_form:cj_6536 SET
    code = '6536',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_65,
    name_i18n_key = i18n_key:i18n_legal_form_6536_name;

CREATE business_legal_form:cj_6537 SET
    code = '6537',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_65,
    name_i18n_key = i18n_key:i18n_legal_form_6537_name;

CREATE business_legal_form:cj_6538 SET
    code = '6538',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_65,
    name_i18n_key = i18n_key:i18n_legal_form_6538_name;

CREATE business_legal_form:cj_6539 SET
    code = '6539',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_65,
    name_i18n_key = i18n_key:i18n_legal_form_6539_name;

CREATE business_legal_form:cj_6540 SET
    code = '6540',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_65,
    name_i18n_key = i18n_key:i18n_legal_form_6540_name;

CREATE business_legal_form:cj_6541 SET
    code = '6541',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_65,
    name_i18n_key = i18n_key:i18n_legal_form_6541_name;

CREATE business_legal_form:cj_6542 SET
    code = '6542',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_65,
    name_i18n_key = i18n_key:i18n_legal_form_6542_name;

CREATE business_legal_form:cj_6543 SET
    code = '6543',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_65,
    name_i18n_key = i18n_key:i18n_legal_form_6543_name;

CREATE business_legal_form:cj_6544 SET
    code = '6544',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_65,
    name_i18n_key = i18n_key:i18n_legal_form_6544_name;

CREATE business_legal_form:cj_6551 SET
    code = '6551',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_65,
    name_i18n_key = i18n_key:i18n_legal_form_6551_name;

CREATE business_legal_form:cj_6554 SET
    code = '6554',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_65,
    name_i18n_key = i18n_key:i18n_legal_form_6554_name;

CREATE business_legal_form:cj_6558 SET
    code = '6558',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_65,
    name_i18n_key = i18n_key:i18n_legal_form_6558_name;

CREATE business_legal_form:cj_6560 SET
    code = '6560',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_65,
    name_i18n_key = i18n_key:i18n_legal_form_6560_name;

CREATE business_legal_form:cj_6561 SET
    code = '6561',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_65,
    name_i18n_key = i18n_key:i18n_legal_form_6561_name;

CREATE business_legal_form:cj_6562 SET
    code = '6562',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_65,
    name_i18n_key = i18n_key:i18n_legal_form_6562_name;

CREATE business_legal_form:cj_6563 SET
    code = '6563',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_65,
    name_i18n_key = i18n_key:i18n_legal_form_6563_name;

CREATE business_legal_form:cj_6564 SET
    code = '6564',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_65,
    name_i18n_key = i18n_key:i18n_legal_form_6564_name;

CREATE business_legal_form:cj_6565 SET
    code = '6565',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_65,
    name_i18n_key = i18n_key:i18n_legal_form_6565_name;

CREATE business_legal_form:cj_6566 SET
    code = '6566',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_65,
    name_i18n_key = i18n_key:i18n_legal_form_6566_name;

CREATE business_legal_form:cj_6567 SET
    code = '6567',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_65,
    name_i18n_key = i18n_key:i18n_legal_form_6567_name;

CREATE business_legal_form:cj_6568 SET
    code = '6568',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_65,
    name_i18n_key = i18n_key:i18n_legal_form_6568_name;

CREATE business_legal_form:cj_6569 SET
    code = '6569',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_65,
    name_i18n_key = i18n_key:i18n_legal_form_6569_name;

CREATE business_legal_form:cj_6571 SET
    code = '6571',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_65,
    name_i18n_key = i18n_key:i18n_legal_form_6571_name;

CREATE business_legal_form:cj_6572 SET
    code = '6572',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_65,
    name_i18n_key = i18n_key:i18n_legal_form_6572_name;

CREATE business_legal_form:cj_6573 SET
    code = '6573',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_65,
    name_i18n_key = i18n_key:i18n_legal_form_6573_name;

CREATE business_legal_form:cj_6574 SET
    code = '6574',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_65,
    name_i18n_key = i18n_key:i18n_legal_form_6574_name;

CREATE business_legal_form:cj_6575 SET
    code = '6575',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_65,
    name_i18n_key = i18n_key:i18n_legal_form_6575_name;

CREATE business_legal_form:cj_6576 SET
    code = '6576',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_65,
    name_i18n_key = i18n_key:i18n_legal_form_6576_name;

CREATE business_legal_form:cj_6577 SET
    code = '6577',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_65,
    name_i18n_key = i18n_key:i18n_legal_form_6577_name;

CREATE business_legal_form:cj_6578 SET
    code = '6578',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_65,
    name_i18n_key = i18n_key:i18n_legal_form_6578_name;

CREATE business_legal_form:cj_6585 SET
    code = '6585',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_65,
    name_i18n_key = i18n_key:i18n_legal_form_6585_name;

CREATE business_legal_form:cj_6589 SET
    code = '6589',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_65,
    name_i18n_key = i18n_key:i18n_legal_form_6589_name;

CREATE business_legal_form:cj_6595 SET
    code = '6595',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_65,
    name_i18n_key = i18n_key:i18n_legal_form_6595_name;

CREATE business_legal_form:cj_6596 SET
    code = '6596',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_65,
    name_i18n_key = i18n_key:i18n_legal_form_6596_name;

CREATE business_legal_form:cj_6597 SET
    code = '6597',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_65,
    name_i18n_key = i18n_key:i18n_legal_form_6597_name;

CREATE business_legal_form:cj_6598 SET
    code = '6598',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_65,
    name_i18n_key = i18n_key:i18n_legal_form_6598_name;

CREATE business_legal_form:cj_6599 SET
    code = '6599',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_65,
    name_i18n_key = i18n_key:i18n_legal_form_6599_name;

CREATE business_legal_form:cj_6901 SET
    code = '6901',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_69,
    name_i18n_key = i18n_key:i18n_legal_form_6901_name;

CREATE business_legal_form:cj_7111 SET
    code = '7111',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_71,
    name_i18n_key = i18n_key:i18n_legal_form_7111_name;

CREATE business_legal_form:cj_7112 SET
    code = '7112',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_71,
    name_i18n_key = i18n_key:i18n_legal_form_7112_name;

CREATE business_legal_form:cj_7113 SET
    code = '7113',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_71,
    name_i18n_key = i18n_key:i18n_legal_form_7113_name;

CREATE business_legal_form:cj_7120 SET
    code = '7120',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_71,
    name_i18n_key = i18n_key:i18n_legal_form_7120_name;

CREATE business_legal_form:cj_7150 SET
    code = '7150',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_71,
    name_i18n_key = i18n_key:i18n_legal_form_7150_name;

CREATE business_legal_form:cj_7160 SET
    code = '7160',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_71,
    name_i18n_key = i18n_key:i18n_legal_form_7160_name;

CREATE business_legal_form:cj_7171 SET
    code = '7171',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_71,
    name_i18n_key = i18n_key:i18n_legal_form_7171_name;

CREATE business_legal_form:cj_7172 SET
    code = '7172',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_71,
    name_i18n_key = i18n_key:i18n_legal_form_7172_name;

CREATE business_legal_form:cj_7179 SET
    code = '7179',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_71,
    name_i18n_key = i18n_key:i18n_legal_form_7179_name;

CREATE business_legal_form:cj_7190 SET
    code = '7190',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_71,
    name_i18n_key = i18n_key:i18n_legal_form_7190_name;

CREATE business_legal_form:cj_7210 SET
    code = '7210',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_72,
    name_i18n_key = i18n_key:i18n_legal_form_7210_name;

CREATE business_legal_form:cj_7220 SET
    code = '7220',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_72,
    name_i18n_key = i18n_key:i18n_legal_form_7220_name;

CREATE business_legal_form:cj_7225 SET
    code = '7225',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_72,
    name_i18n_key = i18n_key:i18n_legal_form_7225_name;

CREATE business_legal_form:cj_7229 SET
    code = '7229',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_72,
    name_i18n_key = i18n_key:i18n_legal_form_7229_name;

CREATE business_legal_form:cj_7230 SET
    code = '7230',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_72,
    name_i18n_key = i18n_key:i18n_legal_form_7230_name;

CREATE business_legal_form:cj_7312 SET
    code = '7312',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_73,
    name_i18n_key = i18n_key:i18n_legal_form_7312_name;

CREATE business_legal_form:cj_7313 SET
    code = '7313',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_73,
    name_i18n_key = i18n_key:i18n_legal_form_7313_name;

CREATE business_legal_form:cj_7314 SET
    code = '7314',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_73,
    name_i18n_key = i18n_key:i18n_legal_form_7314_name;

CREATE business_legal_form:cj_7321 SET
    code = '7321',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_73,
    name_i18n_key = i18n_key:i18n_legal_form_7321_name;

CREATE business_legal_form:cj_7322 SET
    code = '7322',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_73,
    name_i18n_key = i18n_key:i18n_legal_form_7322_name;

CREATE business_legal_form:cj_7323 SET
    code = '7323',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_73,
    name_i18n_key = i18n_key:i18n_legal_form_7323_name;

CREATE business_legal_form:cj_7331 SET
    code = '7331',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_73,
    name_i18n_key = i18n_key:i18n_legal_form_7331_name;

CREATE business_legal_form:cj_7340 SET
    code = '7340',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_73,
    name_i18n_key = i18n_key:i18n_legal_form_7340_name;

CREATE business_legal_form:cj_7341 SET
    code = '7341',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_73,
    name_i18n_key = i18n_key:i18n_legal_form_7341_name;

CREATE business_legal_form:cj_7342 SET
    code = '7342',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_73,
    name_i18n_key = i18n_key:i18n_legal_form_7342_name;

CREATE business_legal_form:cj_7343 SET
    code = '7343',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_73,
    name_i18n_key = i18n_key:i18n_legal_form_7343_name;

CREATE business_legal_form:cj_7344 SET
    code = '7344',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_73,
    name_i18n_key = i18n_key:i18n_legal_form_7344_name;

CREATE business_legal_form:cj_7345 SET
    code = '7345',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_73,
    name_i18n_key = i18n_key:i18n_legal_form_7345_name;

CREATE business_legal_form:cj_7346 SET
    code = '7346',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_73,
    name_i18n_key = i18n_key:i18n_legal_form_7346_name;

CREATE business_legal_form:cj_7347 SET
    code = '7347',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_73,
    name_i18n_key = i18n_key:i18n_legal_form_7347_name;

CREATE business_legal_form:cj_7348 SET
    code = '7348',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_73,
    name_i18n_key = i18n_key:i18n_legal_form_7348_name;

CREATE business_legal_form:cj_7349 SET
    code = '7349',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_73,
    name_i18n_key = i18n_key:i18n_legal_form_7349_name;

CREATE business_legal_form:cj_7351 SET
    code = '7351',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_73,
    name_i18n_key = i18n_key:i18n_legal_form_7351_name;

CREATE business_legal_form:cj_7352 SET
    code = '7352',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_73,
    name_i18n_key = i18n_key:i18n_legal_form_7352_name;

CREATE business_legal_form:cj_7353 SET
    code = '7353',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_73,
    name_i18n_key = i18n_key:i18n_legal_form_7353_name;

CREATE business_legal_form:cj_7354 SET
    code = '7354',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_73,
    name_i18n_key = i18n_key:i18n_legal_form_7354_name;

CREATE business_legal_form:cj_7355 SET
    code = '7355',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_73,
    name_i18n_key = i18n_key:i18n_legal_form_7355_name;

CREATE business_legal_form:cj_7356 SET
    code = '7356',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_73,
    name_i18n_key = i18n_key:i18n_legal_form_7356_name;

CREATE business_legal_form:cj_7357 SET
    code = '7357',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_73,
    name_i18n_key = i18n_key:i18n_legal_form_7357_name;

CREATE business_legal_form:cj_7361 SET
    code = '7361',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_73,
    name_i18n_key = i18n_key:i18n_legal_form_7361_name;

CREATE business_legal_form:cj_7362 SET
    code = '7362',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_73,
    name_i18n_key = i18n_key:i18n_legal_form_7362_name;

CREATE business_legal_form:cj_7363 SET
    code = '7363',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_73,
    name_i18n_key = i18n_key:i18n_legal_form_7363_name;

CREATE business_legal_form:cj_7364 SET
    code = '7364',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_73,
    name_i18n_key = i18n_key:i18n_legal_form_7364_name;

CREATE business_legal_form:cj_7365 SET
    code = '7365',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_73,
    name_i18n_key = i18n_key:i18n_legal_form_7365_name;

CREATE business_legal_form:cj_7366 SET
    code = '7366',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_73,
    name_i18n_key = i18n_key:i18n_legal_form_7366_name;

CREATE business_legal_form:cj_7367 SET
    code = '7367',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_73,
    name_i18n_key = i18n_key:i18n_legal_form_7367_name;

CREATE business_legal_form:cj_7371 SET
    code = '7371',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_73,
    name_i18n_key = i18n_key:i18n_legal_form_7371_name;

CREATE business_legal_form:cj_7372 SET
    code = '7372',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_73,
    name_i18n_key = i18n_key:i18n_legal_form_7372_name;

CREATE business_legal_form:cj_7373 SET
    code = '7373',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_73,
    name_i18n_key = i18n_key:i18n_legal_form_7373_name;

CREATE business_legal_form:cj_7378 SET
    code = '7378',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_73,
    name_i18n_key = i18n_key:i18n_legal_form_7378_name;

CREATE business_legal_form:cj_7379 SET
    code = '7379',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_73,
    name_i18n_key = i18n_key:i18n_legal_form_7379_name;

CREATE business_legal_form:cj_7381 SET
    code = '7381',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_73,
    name_i18n_key = i18n_key:i18n_legal_form_7381_name;

CREATE business_legal_form:cj_7382 SET
    code = '7382',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_73,
    name_i18n_key = i18n_key:i18n_legal_form_7382_name;

CREATE business_legal_form:cj_7383 SET
    code = '7383',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_73,
    name_i18n_key = i18n_key:i18n_legal_form_7383_name;

CREATE business_legal_form:cj_7384 SET
    code = '7384',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_73,
    name_i18n_key = i18n_key:i18n_legal_form_7384_name;

CREATE business_legal_form:cj_7385 SET
    code = '7385',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_73,
    name_i18n_key = i18n_key:i18n_legal_form_7385_name;

CREATE business_legal_form:cj_7389 SET
    code = '7389',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_73,
    name_i18n_key = i18n_key:i18n_legal_form_7389_name;

CREATE business_legal_form:cj_7410 SET
    code = '7410',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_74,
    name_i18n_key = i18n_key:i18n_legal_form_7410_name;

CREATE business_legal_form:cj_7430 SET
    code = '7430',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_74,
    name_i18n_key = i18n_key:i18n_legal_form_7430_name;

CREATE business_legal_form:cj_7450 SET
    code = '7450',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_74,
    name_i18n_key = i18n_key:i18n_legal_form_7450_name;

CREATE business_legal_form:cj_7470 SET
    code = '7470',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_74,
    name_i18n_key = i18n_key:i18n_legal_form_7470_name;

CREATE business_legal_form:cj_7490 SET
    code = '7490',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_74,
    name_i18n_key = i18n_key:i18n_legal_form_7490_name;

CREATE business_legal_form:cj_8110 SET
    code = '8110',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_81,
    name_i18n_key = i18n_key:i18n_legal_form_8110_name;

CREATE business_legal_form:cj_8120 SET
    code = '8120',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_81,
    name_i18n_key = i18n_key:i18n_legal_form_8120_name;

CREATE business_legal_form:cj_8130 SET
    code = '8130',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_81,
    name_i18n_key = i18n_key:i18n_legal_form_8130_name;

CREATE business_legal_form:cj_8140 SET
    code = '8140',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_81,
    name_i18n_key = i18n_key:i18n_legal_form_8140_name;

CREATE business_legal_form:cj_8150 SET
    code = '8150',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_81,
    name_i18n_key = i18n_key:i18n_legal_form_8150_name;

CREATE business_legal_form:cj_8160 SET
    code = '8160',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_81,
    name_i18n_key = i18n_key:i18n_legal_form_8160_name;

CREATE business_legal_form:cj_8170 SET
    code = '8170',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_81,
    name_i18n_key = i18n_key:i18n_legal_form_8170_name;

CREATE business_legal_form:cj_8190 SET
    code = '8190',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_81,
    name_i18n_key = i18n_key:i18n_legal_form_8190_name;

CREATE business_legal_form:cj_8210 SET
    code = '8210',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_82,
    name_i18n_key = i18n_key:i18n_legal_form_8210_name;

CREATE business_legal_form:cj_8250 SET
    code = '8250',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_82,
    name_i18n_key = i18n_key:i18n_legal_form_8250_name;

CREATE business_legal_form:cj_8290 SET
    code = '8290',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_82,
    name_i18n_key = i18n_key:i18n_legal_form_8290_name;

CREATE business_legal_form:cj_8310 SET
    code = '8310',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_83,
    name_i18n_key = i18n_key:i18n_legal_form_8310_name;

CREATE business_legal_form:cj_8311 SET
    code = '8311',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_83,
    name_i18n_key = i18n_key:i18n_legal_form_8311_name;

CREATE business_legal_form:cj_8410 SET
    code = '8410',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_84,
    name_i18n_key = i18n_key:i18n_legal_form_8410_name;

CREATE business_legal_form:cj_8420 SET
    code = '8420',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_84,
    name_i18n_key = i18n_key:i18n_legal_form_8420_name;

CREATE business_legal_form:cj_8450 SET
    code = '8450',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_84,
    name_i18n_key = i18n_key:i18n_legal_form_8450_name;

CREATE business_legal_form:cj_8470 SET
    code = '8470',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_84,
    name_i18n_key = i18n_key:i18n_legal_form_8470_name;

CREATE business_legal_form:cj_8490 SET
    code = '8490',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_84,
    name_i18n_key = i18n_key:i18n_legal_form_8490_name;

CREATE business_legal_form:cj_8510 SET
    code = '8510',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_85,
    name_i18n_key = i18n_key:i18n_legal_form_8510_name;

CREATE business_legal_form:cj_8520 SET
    code = '8520',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_85,
    name_i18n_key = i18n_key:i18n_legal_form_8520_name;

CREATE business_legal_form:cj_9110 SET
    code = '9110',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_91,
    name_i18n_key = i18n_key:i18n_legal_form_9110_name;

CREATE business_legal_form:cj_9150 SET
    code = '9150',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_91,
    name_i18n_key = i18n_key:i18n_legal_form_9150_name;

CREATE business_legal_form:cj_9210 SET
    code = '9210',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_92,
    name_i18n_key = i18n_key:i18n_legal_form_9210_name;

CREATE business_legal_form:cj_9220 SET
    code = '9220',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_92,
    name_i18n_key = i18n_key:i18n_legal_form_9220_name;

CREATE business_legal_form:cj_9221 SET
    code = '9221',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_92,
    name_i18n_key = i18n_key:i18n_legal_form_9221_name;

CREATE business_legal_form:cj_9222 SET
    code = '9222',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_92,
    name_i18n_key = i18n_key:i18n_legal_form_9222_name;

CREATE business_legal_form:cj_9223 SET
    code = '9223',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_92,
    name_i18n_key = i18n_key:i18n_legal_form_9223_name;

CREATE business_legal_form:cj_9224 SET
    code = '9224',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_92,
    name_i18n_key = i18n_key:i18n_legal_form_9224_name;

CREATE business_legal_form:cj_9230 SET
    code = '9230',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_92,
    name_i18n_key = i18n_key:i18n_legal_form_9230_name;

CREATE business_legal_form:cj_9240 SET
    code = '9240',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_92,
    name_i18n_key = i18n_key:i18n_legal_form_9240_name;

CREATE business_legal_form:cj_9260 SET
    code = '9260',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_92,
    name_i18n_key = i18n_key:i18n_legal_form_9260_name;

CREATE business_legal_form:cj_9300 SET
    code = '9300',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_93,
    name_i18n_key = i18n_key:i18n_legal_form_9300_name;

CREATE business_legal_form:cj_9900 SET
    code = '9900',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_99,
    name_i18n_key = i18n_key:i18n_legal_form_9900_name;

CREATE business_legal_form:cj_9970 SET
    code = '9970',
    level = business_legal_form_level:level_3,
    parent_code = business_legal_form:cj_99,
    name_i18n_key = i18n_key:i18n_legal_form_9970_name;


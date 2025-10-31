-- =================================================================================================
-- SEEDS: business_company_category
-- Total: 4 catégories d'entreprises
-- Source: Article 51 de la loi de modernisation de l'économie
-- =================================================================================================

CREATE business_company_category:cat_mic SET
    code = 'MIC',
    name_i18n_key = i18n_key:i18n_company_category_mic_name,
    description_i18n_key = i18n_key:i18n_company_category_mic_description,
    min_employees = 0,
    max_employees = 9,
    max_revenue_millions = 2,
    max_balance_millions = 2,
    sort_order = 1;

CREATE business_company_category:cat_pme SET
    code = 'PME',
    name_i18n_key = i18n_key:i18n_company_category_pme_name,
    description_i18n_key = i18n_key:i18n_company_category_pme_description,
    min_employees = 0,
    max_employees = 249,
    max_revenue_millions = 50,
    max_balance_millions = 43,
    sort_order = 2;

CREATE business_company_category:cat_eti SET
    code = 'ETI',
    name_i18n_key = i18n_key:i18n_company_category_eti_name,
    description_i18n_key = i18n_key:i18n_company_category_eti_description,
    min_employees = 250,
    max_employees = 4999,
    max_revenue_millions = 1500,
    max_balance_millions = 2000,
    sort_order = 3;

CREATE business_company_category:cat_ge SET
    code = 'GE',
    name_i18n_key = i18n_key:i18n_company_category_ge_name,
    description_i18n_key = i18n_key:i18n_company_category_ge_description,
    min_employees = 5000,
    max_employees = NONE,
    max_revenue_millions = NONE,
    max_balance_millions = NONE,
    sort_order = 4;


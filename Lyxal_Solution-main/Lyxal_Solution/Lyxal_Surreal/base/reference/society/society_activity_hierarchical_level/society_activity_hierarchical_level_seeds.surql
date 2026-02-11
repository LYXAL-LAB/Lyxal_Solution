-- =================================================================================================
-- SEEDS: society_activity_hierarchical_level
-- =================================================================================================

CREATE society_activity_hierarchical_level:section SET
    code = 'section',
    name_i18n_key = i18n_key:society_activity_hierarchical_level_section_name,
    description_i18n_key = i18n_key:society_activity_hierarchical_level_section_description,
    level_number = 1,
    is_terminal = false,
    sort_order = 1;

CREATE society_activity_hierarchical_level:division SET
    code = 'division',
    name_i18n_key = i18n_key:society_activity_hierarchical_level_division_name,
    description_i18n_key = i18n_key:society_activity_hierarchical_level_division_description,
    level_number = 2,
    is_terminal = false,
    sort_order = 2;

CREATE society_activity_hierarchical_level:groupe SET
    code = 'groupe',
    name_i18n_key = i18n_key:society_activity_hierarchical_level_groupe_name,
    description_i18n_key = i18n_key:society_activity_hierarchical_level_groupe_description,
    level_number = 3,
    is_terminal = false,
    sort_order = 3;

CREATE society_activity_hierarchical_level:classe SET
    code = 'classe',
    name_i18n_key = i18n_key:society_activity_hierarchical_level_classe_name,
    description_i18n_key = i18n_key:society_activity_hierarchical_level_classe_description,
    level_number = 4,
    is_terminal = false,
    sort_order = 4;

CREATE society_activity_hierarchical_level:sous_classe SET
    code = 'sous_classe',
    name_i18n_key = i18n_key:society_activity_hierarchical_level_sous_classe_name,
    description_i18n_key = i18n_key:society_activity_hierarchical_level_sous_classe_description,
    level_number = 5,
    is_terminal = true,
    sort_order = 5;


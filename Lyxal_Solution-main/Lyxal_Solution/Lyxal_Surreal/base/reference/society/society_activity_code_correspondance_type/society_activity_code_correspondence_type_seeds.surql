-- =================================================================================================
-- SEEDS: society_activity_code_correspondence_type
-- =================================================================================================

CREATE society_activity_code_correspondence_type:exact SET
    code = 'exact',
    name_i18n_key = i18n_key:society_activity_correspondence_type_exact_name,
    description_i18n_key = i18n_key:society_activity_correspondence_type_exact_description,
    sort_order = 1;

CREATE society_activity_code_correspondence_type:partial SET
    code = 'partial',
    name_i18n_key = i18n_key:society_activity_correspondence_type_partial_name,
    description_i18n_key = i18n_key:society_activity_correspondence_type_partial_description,
    sort_order = 2;

CREATE society_activity_code_correspondence_type:aggregate SET
    code = 'aggregate',
    name_i18n_key = i18n_key:society_activity_correspondence_type_aggregate_name,
    description_i18n_key = i18n_key:society_activity_correspondence_type_aggregate_description,
    sort_order = 3;

CREATE society_activity_code_correspondence_type:split SET
    code = 'split',
    name_i18n_key = i18n_key:society_activity_correspondence_type_split_name,
    description_i18n_key = i18n_key:society_activity_correspondence_type_split_description,
    sort_order = 4;

CREATE society_activity_code_correspondence_type:approximate SET
    code = 'approximate',
    name_i18n_key = i18n_key:society_activity_correspondence_type_approximate_name,
    description_i18n_key = i18n_key:society_activity_correspondence_type_approximate_description,
    sort_order = 5;


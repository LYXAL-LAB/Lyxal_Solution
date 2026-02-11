-- =============================================================================================
-- |
-- | Fichier : uses_credential_batch1_seeds.surql
-- | Module : integrations > reference > credentials > uses_credential
-- | Description : Relations service → credential_type pour Batch 1.
-- |
-- | Batch 1 : Services de productivité (30 relations)
-- | • Airtable (3), Asana (2), ClickUp (2), Monday (2), Notion (2), Todoist (2)
-- | • Trello (1), Drift (2), Freshdesk (1), HelpScout (1), Intercom (1)
-- | • Segment (1), Zendesk (2), Mailgun (1), Postmark (1), Sendgrid (1)
-- | • Typeform (2), SurveyMonkey (2), Jotform (1)
-- |
-- =============================================================================================

-- =====================================================
-- AIRTABLE (3 credentials)
-- =====================================================

RELATE service:airtable->uses_credential->credential_type:airtable_api SET
    is_required = false,
    presentation = {
        display_order: 2,
        is_recommended: false,
        badge_color_type: theme_color_type:warning,
        custom_label_i18n: i18n_key:uses_cred_airtable_api_label
    },
    config = {
        custom_description_i18n: i18n_key:uses_cred_airtable_api_desc,
        setup_complexity: "medium",
        estimated_setup_time: 5,
        use_case: "development"
    }, documentation = {};

RELATE service:airtable->uses_credential->credential_type:airtable_oauth2_api SET
    is_required = true,
    presentation = {
        display_order: 1,
        is_recommended: true,
        badge_color_type: theme_color_type:primary
    },
    config = {
        custom_description_i18n: i18n_key:uses_cred_airtable_oauth2_desc,
        scopes_required: ["data.records:read", "data.records:write"],
        setup_complexity: "easy",
        estimated_setup_time: 5,
        use_case: "standard"
    }, documentation = {};

RELATE service:airtable->uses_credential->credential_type:airtable_token_api SET
    is_required = false,
    presentation = {
        display_order: 3,
        is_recommended: false,
        badge_color_type: theme_color_type:neutral
    },
    config = {
        setup_complexity: "easy",
        estimated_setup_time: 2,
        use_case: "development"
    }, documentation = {};

-- =====================================================
-- ASANA (2 credentials)
-- =====================================================

RELATE service:asana->uses_credential->credential_type:asana_oauth2_api SET
    is_required = true,
    presentation = {
        display_order: 1,
        is_recommended: true,
        badge_color_type: theme_color_type:primary
    },
    config = {
        custom_description_i18n: i18n_key:uses_cred_asana_oauth2_desc,
        setup_complexity: "easy",
        estimated_setup_time: 5,
        use_case: "standard"
    }, documentation = {};

RELATE service:asana->uses_credential->credential_type:asana_api SET
    is_required = false,
    presentation = {
        display_order: 2,
        is_recommended: false,
        badge_color_type: theme_color_type:warning,
        custom_label_i18n: i18n_key:uses_cred_asana_token_label
    },
    config = {
        custom_description_i18n: i18n_key:uses_cred_asana_token_desc,
        setup_complexity: "medium",
        estimated_setup_time: 3,
        use_case: "development"
    }, documentation = {};

-- =====================================================
-- CLICKUP (2 credentials)
-- =====================================================

RELATE service:clickup->uses_credential->credential_type:clickup_oauth2_api SET
    is_required = true,
    presentation = {
        display_order: 1,
        is_recommended: true,
        badge_color_type: theme_color_type:primary
    },
    config = {
        setup_complexity: "easy",
        estimated_setup_time: 5,
        use_case: "standard"
    }, documentation = {};

RELATE service:clickup->uses_credential->credential_type:clickup_api SET
    is_required = false,
    presentation = {
        display_order: 2,
        is_recommended: false,
        badge_color_type: theme_color_type:neutral
    },
    config = {
        setup_complexity: "easy",
        estimated_setup_time: 3,
        use_case: "development"
    }, documentation = {};

-- =====================================================
-- MONDAY.COM (2 credentials)
-- =====================================================

RELATE service:monday_com->uses_credential->credential_type:monday_com_oauth2_api SET
    is_required = true,
    presentation = {
        display_order: 1,
        is_recommended: true,
        badge_color_type: theme_color_type:primary
    },
    config = {
        setup_complexity: "easy",
        estimated_setup_time: 5,
        use_case: "standard"
    }, documentation = {};

RELATE service:monday_com->uses_credential->credential_type:monday_com_api SET
    is_required = false,
    presentation = {
        display_order: 2,
        is_recommended: false,
        badge_color_type: theme_color_type:neutral
    },
    config = {
        setup_complexity: "easy",
        estimated_setup_time: 2,
        use_case: "automation"
    }, documentation = {};

-- =====================================================
-- NOTION (2 credentials)
-- =====================================================

RELATE service:notion->uses_credential->credential_type:notion_oauth2_api SET
    is_required = true,
    presentation = {
        display_order: 1,
        is_recommended: true,
        badge_color_type: theme_color_type:primary
    },
    config = {
        setup_complexity: "easy",
        estimated_setup_time: 5,
        use_case: "standard"
    }, documentation = {};

RELATE service:notion->uses_credential->credential_type:notion_api SET
    is_required = false,
    presentation = {
        display_order: 2,
        is_recommended: false,
        badge_color_type: theme_color_type:neutral
    },
    config = {
        setup_complexity: "easy",
        estimated_setup_time: 3,
        use_case: "development"
    }, documentation = {};

-- =====================================================
-- TODOIST (2 credentials)
-- =====================================================

RELATE service:todoist->uses_credential->credential_type:todoist_oauth2_api SET
    is_required = true,
    presentation = {
        display_order: 1,
        is_recommended: true,
        badge_color_type: theme_color_type:primary
    },
    config = {
        setup_complexity: "easy",
        estimated_setup_time: 5,
        use_case: "standard"
    }, documentation = {};

RELATE service:todoist->uses_credential->credential_type:todoist_api SET
    is_required = false,
    presentation = {
        display_order: 2,
        is_recommended: false,
        badge_color_type: theme_color_type:neutral
    },
    config = {
        setup_complexity: "easy",
        estimated_setup_time: 2,
        use_case: "automation"
    }, documentation = {};

-- =====================================================
-- TRELLO (1 credential)
-- =====================================================

RELATE service:trello->uses_credential->credential_type:trello_api SET
    is_required = true,
    presentation = {
        display_order: 1,
        is_recommended: true,
        badge_color_type: theme_color_type:primary
    },
    config = {
        setup_complexity: "easy",
        estimated_setup_time: 3,
        use_case: "standard"
    }, documentation = {};

-- =====================================================
-- DRIFT (2 credentials)
-- =====================================================

RELATE service:drift->uses_credential->credential_type:drift_oauth2_api SET
    is_required = true,
    presentation = {
        display_order: 1,
        is_recommended: true,
        badge_color_type: theme_color_type:primary
    },
    config = {
        setup_complexity: "easy",
        estimated_setup_time: 5,
        use_case: "standard"
    }, documentation = {};

RELATE service:drift->uses_credential->credential_type:drift_api SET
    is_required = false,
    presentation = {
        display_order: 2,
        is_recommended: false,
        badge_color_type: theme_color_type:neutral
    },
    config = {
        setup_complexity: "easy",
        estimated_setup_time: 3,
        use_case: "development"
    }, documentation = {};

-- =====================================================
-- FRESHDESK (1 credential)
-- =====================================================

RELATE service:freshdesk->uses_credential->credential_type:freshdesk_api SET
    is_required = true,
    presentation = {
        display_order: 1,
        is_recommended: true,
        badge_color_type: theme_color_type:primary
    },
    config = {
        setup_complexity: "easy",
        estimated_setup_time: 3,
        use_case: "standard"
    }, documentation = {};

-- =====================================================
-- HELPSCOUT (1 credential)
-- =====================================================

RELATE service:helpscout->uses_credential->credential_type:helpscout_oauth2_api SET
    is_required = true,
    presentation = {
        display_order: 1,
        is_recommended: true,
        badge_color_type: theme_color_type:primary
    },
    config = {
        setup_complexity: "easy",
        estimated_setup_time: 5,
        use_case: "standard"
    }, documentation = {};

-- =====================================================
-- INTERCOM (1 credential)
-- =====================================================

RELATE service:intercom->uses_credential->credential_type:intercom_api SET
    is_required = true,
    presentation = {
        display_order: 1,
        is_recommended: true,
        badge_color_type: theme_color_type:primary
    },
    config = {
        setup_complexity: "easy",
        estimated_setup_time: 3,
        use_case: "standard"
    }, documentation = {};

-- =====================================================
-- SEGMENT (1 credential)
-- =====================================================

RELATE service:segment->uses_credential->credential_type:segment_api SET
    is_required = true,
    presentation = {
        display_order: 1,
        is_recommended: true,
        badge_color_type: theme_color_type:primary
    },
    config = {
        setup_complexity: "easy",
        estimated_setup_time: 3,
        use_case: "standard"
    }, documentation = {};

-- =====================================================
-- ZENDESK (2 credentials)
-- =====================================================

RELATE service:zendesk->uses_credential->credential_type:zendesk_oauth2_api SET
    is_required = true,
    presentation = {
        display_order: 1,
        is_recommended: true,
        badge_color_type: theme_color_type:primary
    },
    config = {
        setup_complexity: "easy",
        estimated_setup_time: 5,
        use_case: "standard"
    }, documentation = {};

RELATE service:zendesk->uses_credential->credential_type:zendesk_api SET
    is_required = false,
    presentation = {
        display_order: 2,
        is_recommended: false,
        badge_color_type: theme_color_type:neutral
    },
    config = {
        setup_complexity: "easy",
        estimated_setup_time: 3,
        use_case: "automation"
    }, documentation = {};

-- =====================================================
-- MAILGUN (1 credential)
-- =====================================================

RELATE service:mailgun->uses_credential->credential_type:mailgun_api SET
    is_required = true,
    presentation = {
        display_order: 1,
        is_recommended: true,
        badge_color_type: theme_color_type:primary
    },
    config = {
        setup_complexity: "easy",
        estimated_setup_time: 2,
        use_case: "standard"
    }, documentation = {};

-- =====================================================
-- POSTMARK (1 credential)
-- =====================================================

RELATE service:postmark->uses_credential->credential_type:postmark_api SET
    is_required = true,
    presentation = {
        display_order: 1,
        is_recommended: true,
        badge_color_type: theme_color_type:primary
    },
    config = {
        setup_complexity: "easy",
        estimated_setup_time: 2,
        use_case: "standard"
    }, documentation = {};

-- =====================================================
-- SENDGRID (1 credential)
-- =====================================================

RELATE service:sendgrid->uses_credential->credential_type:sendgrid_api SET
    is_required = true,
    presentation = {
        display_order: 1,
        is_recommended: true,
        badge_color_type: theme_color_type:primary
    },
    config = {
        setup_complexity: "easy",
        estimated_setup_time: 2,
        use_case: "standard"
    }, documentation = {};

-- =====================================================
-- TYPEFORM (2 credentials)
-- =====================================================

RELATE service:typeform->uses_credential->credential_type:typeform_oauth2_api SET
    is_required = true,
    presentation = {
        display_order: 1,
        is_recommended: true,
        badge_color_type: theme_color_type:primary
    },
    config = {
        setup_complexity: "easy",
        estimated_setup_time: 5,
        use_case: "standard"
    }, documentation = {};

RELATE service:typeform->uses_credential->credential_type:typeform_api SET
    is_required = false,
    presentation = {
        display_order: 2,
        is_recommended: false,
        badge_color_type: theme_color_type:neutral
    },
    config = {
        setup_complexity: "easy",
        estimated_setup_time: 3,
        use_case: "development"
    }, documentation = {};

-- =====================================================
-- SURVEYMONKEY (2 credentials)
-- =====================================================

RELATE service:surveymonkey->uses_credential->credential_type:surveymonkey_oauth2_api SET
    is_required = true,
    presentation = {
        display_order: 1,
        is_recommended: true,
        badge_color_type: theme_color_type:primary
    },
    config = {
        setup_complexity: "easy",
        estimated_setup_time: 5,
        use_case: "standard"
    }, documentation = {};

RELATE service:surveymonkey->uses_credential->credential_type:surveymonkey_api SET
    is_required = false,
    presentation = {
        display_order: 2,
        is_recommended: false,
        badge_color_type: theme_color_type:neutral
    },
    config = {
        setup_complexity: "easy",
        estimated_setup_time: 3,
        use_case: "development"
    }, documentation = {};

-- =====================================================
-- JOTFORM (1 credential)
-- =====================================================

RELATE service:jotform->uses_credential->credential_type:jotform_api SET
    is_required = true,
    presentation = {
        display_order: 1,
        is_recommended: true,
        badge_color_type: theme_color_type:primary
    },
    config = {
        setup_complexity: "easy",
        estimated_setup_time: 3,
        use_case: "standard"
    }, documentation = {};


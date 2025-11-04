-- =============================================================================================
-- |
-- | Fichier : uses_credential_batch2_seeds.surql
-- | Module : integrations > reference > credentials > uses_credential
-- | Description : Relations service → credential_type pour Batch 2.
-- |
-- | Batch 2 : Services formulaires, scheduling & AI (30 relations)
-- | • Formstack (2), Calendly (2), Acuity Scheduling (2)
-- | • OpenAI (1), Perplexity (1), DeepL (1), Datadog (1)
-- | • Linear (2), Figma (1), Miro (1), N8N (1)
-- | • Ghost (2), Baserow (1), NocoDB (2), Grafana (1), Metabase (1), PostHog (1)
-- | • Coda (1), Gong (2), Okta (1), Auth0 (1), Contentful (1), Strapi (1)
-- |
-- =============================================================================================

RELATE service:formstack->uses_credential->credential_type:formstack_oauth2_api SET is_required=true, presentation={display_order:1, is_recommended:true, badge_color_type: theme_color_type:primary}, config={setup_complexity:"easy", estimated_setup_time:5, use_case:"standard"};
RELATE service:formstack->uses_credential->credential_type:formstack_api SET is_required=false, presentation={display_order:2, is_recommended:false, badge_color_type: theme_color_type:neutral}, config={setup_complexity:"easy", estimated_setup_time:3, use_case:"development"};

RELATE service:calendly->uses_credential->credential_type:calendly_oauth2_api SET is_required=true, presentation={display_order:1, is_recommended:true, badge_color_type: theme_color_type:primary}, config={setup_complexity:"easy", estimated_setup_time:5, use_case:"standard"};
RELATE service:calendly->uses_credential->credential_type:calendly_api SET is_required=false, presentation={display_order:2, is_recommended:false, badge_color_type: theme_color_type:neutral}, config={setup_complexity:"easy", estimated_setup_time:3, use_case:"automation"};

RELATE service:acuity_scheduling->uses_credential->credential_type:acuity_scheduling_oauth2_api SET is_required=true, presentation={display_order:1, is_recommended:true, badge_color_type: theme_color_type:primary}, config={setup_complexity:"easy", estimated_setup_time:5, use_case:"standard"};
RELATE service:acuity_scheduling->uses_credential->credential_type:acuity_scheduling_api SET is_required=false, presentation={display_order:2, is_recommended:false, badge_color_type: theme_color_type:neutral}, config={setup_complexity:"easy", estimated_setup_time:3, use_case:"automation"};

RELATE service:openai->uses_credential->credential_type:openai_api SET is_required=true, presentation={display_order:1, is_recommended:true, badge_color_type: theme_color_type:primary}, config={setup_complexity:"easy", estimated_setup_time:2, use_case:"standard"};

RELATE service:perplexity->uses_credential->credential_type:perplexity_api SET is_required=true, presentation={display_order:1, is_recommended:true, badge_color_type: theme_color_type:primary}, config={setup_complexity:"easy", estimated_setup_time:2, use_case:"standard"};

RELATE service:deepl->uses_credential->credential_type:deepl_api SET is_required=true, presentation={display_order:1, is_recommended:true, badge_color_type: theme_color_type:primary}, config={setup_complexity:"easy", estimated_setup_time:2, use_case:"standard"};

RELATE service:datadog->uses_credential->credential_type:datadog_api SET is_required=true, presentation={display_order:1, is_recommended:true, badge_color_type: theme_color_type:primary}, config={setup_complexity:"medium", estimated_setup_time:5, use_case:"standard"};

RELATE service:linear->uses_credential->credential_type:linear_oauth2_api SET is_required=true, presentation={display_order:1, is_recommended:true, badge_color_type: theme_color_type:primary}, config={setup_complexity:"easy", estimated_setup_time:5, use_case:"standard"};
RELATE service:linear->uses_credential->credential_type:linear_api SET is_required=false, presentation={display_order:2, is_recommended:false, badge_color_type: theme_color_type:neutral}, config={setup_complexity:"easy", estimated_setup_time:3, use_case:"development"};

RELATE service:figma->uses_credential->credential_type:figma_api SET is_required=true, presentation={display_order:1, is_recommended:true, badge_color_type: theme_color_type:primary}, config={setup_complexity:"easy", estimated_setup_time:3, use_case:"standard"};

RELATE service:miro->uses_credential->credential_type:miro_oauth2_api SET is_required=true, presentation={display_order:1, is_recommended:true, badge_color_type: theme_color_type:primary}, config={setup_complexity:"easy", estimated_setup_time:5, use_case:"standard"};

RELATE service:n8n->uses_credential->credential_type:n8n_api SET is_required=true, presentation={display_order:1, is_recommended:true, badge_color_type: theme_color_type:primary}, config={setup_complexity:"medium", estimated_setup_time:5, use_case:"automation"};

RELATE service:ghost->uses_credential->credential_type:ghost_admin_api SET is_required=true, presentation={display_order:1, is_recommended:true, badge_color_type: theme_color_type:primary}, config={setup_complexity:"medium", estimated_setup_time:5, use_case:"standard"};
RELATE service:ghost->uses_credential->credential_type:ghost_content_api SET is_required=false, presentation={display_order:2, is_recommended:false, badge_color_type: theme_color_type:neutral}, config={setup_complexity:"easy", estimated_setup_time:3, use_case:"development"};

RELATE service:baserow->uses_credential->credential_type:baserow_api SET is_required=true, presentation={display_order:1, is_recommended:true, badge_color_type: theme_color_type:primary}, config={setup_complexity:"easy", estimated_setup_time:3, use_case:"standard"};

RELATE service:nocodb->uses_credential->credential_type:nocodb SET is_required=true, presentation={display_order:1, is_recommended:true, badge_color_type: theme_color_type:primary}, config={setup_complexity:"easy", estimated_setup_time:3, use_case:"standard"};
RELATE service:nocodb->uses_credential->credential_type:nocodb_api_token SET is_required=false, presentation={display_order:2, is_recommended:false, badge_color_type: theme_color_type:neutral}, config={setup_complexity:"easy", estimated_setup_time:2, use_case:"automation"};

RELATE service:grafana->uses_credential->credential_type:grafana_api SET is_required=true, presentation={display_order:1, is_recommended:true, badge_color_type: theme_color_type:primary}, config={setup_complexity:"medium", estimated_setup_time:5, use_case:"standard"};

RELATE service:metabase->uses_credential->credential_type:metabase_api SET is_required=true, presentation={display_order:1, is_recommended:true, badge_color_type: theme_color_type:primary}, config={setup_complexity:"medium", estimated_setup_time:5, use_case:"standard"};

RELATE service:posthog->uses_credential->credential_type:posthog_api SET is_required=true, presentation={display_order:1, is_recommended:true, badge_color_type: theme_color_type:primary}, config={setup_complexity:"easy", estimated_setup_time:3, use_case:"standard"};

RELATE service:coda->uses_credential->credential_type:coda_api SET is_required=true, presentation={display_order:1, is_recommended:true, badge_color_type: theme_color_type:primary}, config={setup_complexity:"easy", estimated_setup_time:3, use_case:"standard"};

RELATE service:gong->uses_credential->credential_type:gong_oauth2_api SET is_required=true, presentation={display_order:1, is_recommended:true, badge_color_type: theme_color_type:primary}, config={setup_complexity:"easy", estimated_setup_time:5, use_case:"standard"};
RELATE service:gong->uses_credential->credential_type:gong_api SET is_required=false, presentation={display_order:2, is_recommended:false, badge_color_type: theme_color_type:neutral}, config={setup_complexity:"medium", estimated_setup_time:5, use_case:"automation"};

RELATE service:okta->uses_credential->credential_type:okta_api SET is_required=true, presentation={display_order:1, is_recommended:true, badge_color_type: theme_color_type:primary}, config={setup_complexity:"hard", estimated_setup_time:10, use_case:"production"};

RELATE service:auth0->uses_credential->credential_type:auth0_management_api SET is_required=true, presentation={display_order:1, is_recommended:true, badge_color_type: theme_color_type:primary}, config={setup_complexity:"hard", estimated_setup_time:10, use_case:"production"};

RELATE service:contentful->uses_credential->credential_type:contentful_api SET is_required=true, presentation={display_order:1, is_recommended:true, badge_color_type: theme_color_type:primary}, config={setup_complexity:"easy", estimated_setup_time:3, use_case:"standard"};

RELATE service:strapi->uses_credential->credential_type:strapi_api SET is_required=true, presentation={display_order:1, is_recommended:true, badge_color_type: theme_color_type:primary}, config={setup_complexity:"easy", estimated_setup_time:3, use_case:"standard"};


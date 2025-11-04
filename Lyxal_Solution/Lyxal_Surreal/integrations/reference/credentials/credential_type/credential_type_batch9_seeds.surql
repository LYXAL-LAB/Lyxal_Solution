-- =============================================================================================
-- |
-- | Fichier : credential_type_batch9_seeds.surql (SEED DATA)
-- | Module : integrations > reference > credentials > credential_type
-- | Description : Seeds pour le Batch 9 des credential types (14 credentials Social Media & Content Platforms).
-- |
-- | Batch 9 : Social Media & Content Platforms (14 credentials)
-- | Providers : Twitter, LinkedIn, Facebook, Reddit, YouTube, Discourse, Disqus, Medium, Spotify
-- |
-- =============================================================================================

-- =====================================================
-- 1. TWITTER OAUTH1 API (display_order: 720) ✨ POPULAIRE
-- =====================================================

CREATE credential_type:twitter_oauth1_api SET
    name = "twitterOAuth1Api",
    slug = "twitter-oauth1-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_twitter_oauth1_api_name,
        description_i18n: i18n_key:credential_type_twitter_oauth1_api_description
    },
    
    presentation = {
        icon: icon:twitter,
        color_type: theme_color_type:neutral,
        tooltip_i18n: i18n_key:credential_type_twitter_oauth1_api_tooltip,
        display_order: 720
    },
    
    auth_type = auth_type:oauth1,
    provider = provider:twitter,
    
    config = {
        oauth2: NONE,
        oauth1: {
            request_token_url: "https://api.twitter.com/oauth/request_token",
            authorization_url: "https://api.twitter.com/oauth/authorize",
            access_token_url: "https://api.twitter.com/oauth/access_token",
            signature_method: "HMAC-SHA1"
        },
        required_fields: [],
        metadata: {
            api_version: "v1.1",
            deprecated_soon: true
        }
    },
    
    documentation = {
        url: url:twitter_oauth1_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 2. TWITTER OAUTH2 API (display_order: 721) ✨ POPULAIRE
-- =====================================================

CREATE credential_type:twitter_oauth2_api SET
    name = "twitterOAuth2Api",
    slug = "twitter-oauth2-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_twitter_oauth2_api_name,
        description_i18n: i18n_key:credential_type_twitter_oauth2_api_description
    },
    
    presentation = {
        icon: icon:twitter,
        color_type: theme_color_type:primary,
        tooltip_i18n: i18n_key:credential_type_twitter_oauth2_api_tooltip,
        display_order: 721
    },
    
    auth_type = auth_type:oauth2,
    provider = provider:twitter,
    
    config = {
        oauth2: {
            grant_type: "authorization_code",
            access_token_url: "https://api.twitter.com/2/oauth2/token",
            authorization_url: "https://twitter.com/i/oauth2/authorize",
            authentication_method: "body",
            scope: "tweet.read users.read"
        },
        oauth1: NONE,
        required_fields: [],
        metadata: {
            api_version: "v2",
            recommended: true
        }
    },
    
    documentation = {
        url: url:twitter_oauth2_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 3. LINKEDIN OAUTH2 API (display_order: 730) ✨ TRÈS POPULAIRE
-- =====================================================

CREATE credential_type:linkedin_oauth2_api SET
    name = "linkedInOAuth2Api",
    slug = "linkedin-oauth2-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_linkedin_oauth2_api_name,
        description_i18n: i18n_key:credential_type_linkedin_oauth2_api_description
    },
    
    presentation = {
        icon: icon:linkedin,
        color_type: theme_color_type:info,
        tooltip_i18n: i18n_key:credential_type_linkedin_oauth2_api_tooltip,
        display_order: 730
    },
    
    auth_type = auth_type:oauth2,
    provider = provider:linkedin,
    
    config = {
        oauth2: {
            grant_type: "authorization_code",
            access_token_url: "https://www.linkedin.com/oauth/v2/accessToken",
            authorization_url: "https://www.linkedin.com/oauth/v2/authorization",
            authentication_method: "body",
            scope: "r_liteprofile r_emailaddress w_member_social"
        },
        oauth1: NONE,
        required_fields: [],
        metadata: {
            professional_network: true
        }
    },
    
    documentation = {
        url: url:linkedin_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 4. LINKEDIN COMMUNITY MANAGEMENT OAUTH2 API (display_order: 731)
-- =====================================================

CREATE credential_type:linkedin_community_management_oauth2_api SET
    name = "linkedInCommunityManagementOAuth2Api",
    slug = "linkedin-community-management-oauth2-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_linkedin_community_management_oauth2_api_name,
        description_i18n: i18n_key:credential_type_linkedin_community_management_oauth2_api_description
    },
    
    presentation = {
        icon: icon:linkedin,
        color: "#0A66C2",
        color_daisy: "accent",
        tooltip_i18n: i18n_key:credential_type_linkedin_community_management_oauth2_api_tooltip,
        display_order: 731
    },
    
    auth_type = auth_type:oauth2,
    provider = provider:linkedin,
    
    config = {
        oauth2: {
            grant_type: "authorization_code",
            access_token_url: "https://www.linkedin.com/oauth/v2/accessToken",
            authorization_url: "https://www.linkedin.com/oauth/v2/authorization",
            authentication_method: "body",
            scope: "w_organization_social r_organization_social rw_organization_admin"
        },
        oauth1: NONE,
        required_fields: [],
        metadata: {
            for_organizations: true
        }
    },
    
    documentation = {
        url: url:linkedin_community_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 5. FACEBOOK GRAPH API (display_order: 740) ✨ TRÈS POPULAIRE
-- =====================================================

CREATE credential_type:facebook_graph_api SET
    name = "facebookGraphApi",
    slug = "facebook-graph-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_facebook_graph_api_name,
        description_i18n: i18n_key:credential_type_facebook_graph_api_description
    },
    
    presentation = {
        icon: icon:facebook,
        color_type: theme_color_type:info,
        tooltip_i18n: i18n_key:credential_type_facebook_graph_api_tooltip,
        display_order: 740
    },
    
    auth_type = auth_type:oauth2,
    provider = provider:facebook,
    
    config = {
        oauth2: {
            grant_type: "authorization_code",
            access_token_url: "https://graph.facebook.com/v18.0/oauth/access_token",
            authorization_url: "https://www.facebook.com/v18.0/dialog/oauth",
            authentication_method: "query",
            scope: "public_profile email"
        },
        oauth1: NONE,
        required_fields: [],
        metadata: {
            meta_platform: true,
            api_version: "v18.0"
        }
    },
    
    documentation = {
        url: url:facebook_graph_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 6. FACEBOOK GRAPH APP API (display_order: 741)
-- =====================================================

CREATE credential_type:facebook_graph_app_api SET
    name = "facebookGraphAppApi",
    slug = "facebook-graph-app-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_facebook_graph_app_api_name,
        description_i18n: i18n_key:credential_type_facebook_graph_app_api_description
    },
    
    presentation = {
        icon: icon:facebook,
        color: "#1877F2",
        color_daisy: "secondary",
        tooltip_i18n: i18n_key:credential_type_facebook_graph_app_api_tooltip,
        display_order: 741
    },
    
    auth_type = auth_type:bearer_token,
    provider = provider:facebook,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "appId",
                display_name: "App ID",
                type: "string",
                is_secret: false,
                required: true,
                description: "Facebook App ID"
            },
            {
                name: "appSecret",
                display_name: "App Secret",
                type: "string",
                is_secret: true,
                required: true,
                description: "Facebook App Secret"
            }
        ],
        metadata: {
            server_to_server: true
        }
    },
    
    documentation = {
        url: url:facebook_app_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 7. FACEBOOK LEAD ADS OAUTH2 API (display_order: 742)
-- =====================================================

CREATE credential_type:facebook_lead_ads_oauth2_api SET
    name = "facebookLeadAdsOAuth2Api",
    slug = "facebook-lead-ads-oauth2-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_facebook_lead_ads_oauth2_api_name,
        description_i18n: i18n_key:credential_type_facebook_lead_ads_oauth2_api_description
    },
    
    presentation = {
        icon: icon:facebook,
        color: "#1877F2",
        color_daisy: "accent",
        tooltip_i18n: i18n_key:credential_type_facebook_lead_ads_oauth2_api_tooltip,
        display_order: 742
    },
    
    auth_type = auth_type:oauth2,
    provider = provider:facebook,
    
    config = {
        oauth2: {
            grant_type: "authorization_code",
            access_token_url: "https://graph.facebook.com/v18.0/oauth/access_token",
            authorization_url: "https://www.facebook.com/v18.0/dialog/oauth",
            authentication_method: "query",
            scope: "leads_retrieval pages_read_engagement pages_manage_ads"
        },
        oauth1: NONE,
        required_fields: [],
        metadata: {
            use_case: "lead_generation"
        }
    },
    
    documentation = {
        url: url:facebook_lead_ads_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 8. REDDIT OAUTH2 API (display_order: 750)
-- =====================================================

CREATE credential_type:reddit_oauth2_api SET
    name = "redditOAuth2Api",
    slug = "reddit-oauth2-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_reddit_oauth2_api_name,
        description_i18n: i18n_key:credential_type_reddit_oauth2_api_description
    },
    
    presentation = {
        icon: icon:reddit,
        color_type: theme_color_type:warning,
        tooltip_i18n: i18n_key:credential_type_reddit_oauth2_api_tooltip,
        display_order: 750
    },
    
    auth_type = auth_type:oauth2,
    provider = provider:reddit,
    
    config = {
        oauth2: {
            grant_type: "authorization_code",
            access_token_url: "https://www.reddit.com/api/v1/access_token",
            authorization_url: "https://www.reddit.com/api/v1/authorize",
            authentication_method: "body",
            scope: "identity read submit"
        },
        oauth1: NONE,
        required_fields: [],
        metadata: {
            community_platform: true
        }
    },
    
    documentation = {
        url: url:reddit_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 9. YOUTUBE OAUTH2 API (display_order: 760) ✨ TRÈS POPULAIRE
-- =====================================================

CREATE credential_type:youtube_oauth2_api SET
    name = "youTubeOAuth2Api",
    slug = "youtube-oauth2-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_youtube_oauth2_api_name,
        description_i18n: i18n_key:credential_type_youtube_oauth2_api_description
    },
    
    presentation = {
        icon: icon:youtube,
        color_type: theme_color_type:error,
        tooltip_i18n: i18n_key:credential_type_youtube_oauth2_api_tooltip,
        display_order: 760
    },
    
    auth_type = auth_type:oauth2,
    provider = provider:google,
    
    config = {
        oauth2: {
            grant_type: "authorization_code",
            access_token_url: "https://oauth2.googleapis.com/token",
            authorization_url: "https://accounts.google.com/o/oauth2/v2/auth",
            authentication_method: "body",
            scope: "https://www.googleapis.com/auth/youtube https://www.googleapis.com/auth/youtube.upload"
        },
        oauth1: NONE,
        required_fields: [],
        metadata: {
            google_service: true,
            video_platform: true
        }
    },
    
    documentation = {
        url: url:youtube_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 10. DISCOURSE API (display_order: 770)
-- =====================================================

CREATE credential_type:discourse_api SET
    name = "discourseApi",
    slug = "discourse-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_discourse_api_name,
        description_i18n: i18n_key:credential_type_discourse_api_description
    },
    
    presentation = {
        icon: icon:discourse,
        color_type: theme_color_type:neutral,
        tooltip_i18n: i18n_key:credential_type_discourse_api_tooltip,
        display_order: 770
    },
    
    auth_type = auth_type:api_key,
    provider = provider:discourse,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "url",
                display_name: "Discourse URL",
                type: "string",
                is_secret: false,
                required: true,
                description: "Discourse forum URL",
                placeholder: "https://forum.example.com"
            },
            {
                name: "apiKey",
                display_name: "API Key",
                type: "string",
                is_secret: true,
                required: true,
                description: "Discourse API key"
            },
            {
                name: "username",
                display_name: "API Username",
                type: "string",
                is_secret: false,
                required: true,
                description: "Discourse API username"
            }
        ],
        metadata: {
            forum_platform: true,
            open_source: true
        }
    },
    
    documentation = {
        url: url:discourse_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 11. DISQUS API (display_order: 771)
-- =====================================================

CREATE credential_type:disqus_api SET
    name = "disqusApi",
    slug = "disqus-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_disqus_api_name,
        description_i18n: i18n_key:credential_type_disqus_api_description
    },
    
    presentation = {
        icon: icon:disqus,
        color_type: theme_color_type:info,
        tooltip_i18n: i18n_key:credential_type_disqus_api_tooltip,
        display_order: 771
    },
    
    auth_type = auth_type:api_key,
    provider = provider:disqus,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "accessToken",
                display_name: "Access Token",
                type: "string",
                is_secret: true,
                required: true,
                description: "Disqus access token"
            }
        ],
        metadata: {
            comment_system: true,
            embedded_service: true
        }
    },
    
    documentation = {
        url: url:disqus_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 12. MEDIUM API (display_order: 780)
-- =====================================================

CREATE credential_type:medium_api SET
    name = "mediumApi",
    slug = "medium-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_medium_api_name,
        description_i18n: i18n_key:credential_type_medium_api_description
    },
    
    presentation = {
        icon: icon:medium,
        color_type: theme_color_type:neutral,
        tooltip_i18n: i18n_key:credential_type_medium_api_tooltip,
        display_order: 780
    },
    
    auth_type = auth_type:bearer_token,
    provider = provider:medium,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "accessToken",
                display_name: "Integration Token",
                type: "string",
                is_secret: true,
                required: true,
                description: "Medium integration token"
            }
        ],
        metadata: {
            blogging_platform: true,
            long_form: true
        }
    },
    
    documentation = {
        url: url:medium_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 13. MEDIUM OAUTH2 API (display_order: 781)
-- =====================================================

CREATE credential_type:medium_oauth2_api SET
    name = "mediumOAuth2Api",
    slug = "medium-oauth2-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_medium_oauth2_api_name,
        description_i18n: i18n_key:credential_type_medium_oauth2_api_description
    },
    
    presentation = {
        icon: icon:medium,
        color_type: theme_color_type:primary,
        tooltip_i18n: i18n_key:credential_type_medium_oauth2_api_tooltip,
        display_order: 781
    },
    
    auth_type = auth_type:oauth2,
    provider = provider:medium,
    
    config = {
        oauth2: {
            grant_type: "authorization_code",
            access_token_url: "https://api.medium.com/v1/tokens",
            authorization_url: "https://medium.com/m/oauth/authorize",
            authentication_method: "body",
            scope: "basicProfile publishPost"
        },
        oauth1: NONE,
        required_fields: [],
        metadata: {
            recommended_for_apps: true
        }
    },
    
    documentation = {
        url: url:medium_oauth2_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 14. SPOTIFY OAUTH2 API (display_order: 790) ✨ TRÈS POPULAIRE
-- =====================================================

CREATE credential_type:spotify_oauth2_api SET
    name = "spotifyOAuth2Api",
    slug = "spotify-oauth2-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_spotify_oauth2_api_name,
        description_i18n: i18n_key:credential_type_spotify_oauth2_api_description
    },
    
    presentation = {
        icon: icon:spotify,
        color_type: theme_color_type:success,
        tooltip_i18n: i18n_key:credential_type_spotify_oauth2_api_tooltip,
        display_order: 790
    },
    
    auth_type = auth_type:oauth2,
    provider = provider:spotify,
    
    config = {
        oauth2: {
            grant_type: "authorization_code",
            access_token_url: "https://accounts.spotify.com/api/token",
            authorization_url: "https://accounts.spotify.com/authorize",
            authentication_method: "body",
            scope: "user-read-playback-state user-modify-playback-state user-read-currently-playing playlist-read-private playlist-modify-public playlist-modify-private"
        },
        oauth1: NONE,
        required_fields: [],
        metadata: {
            music_streaming: true
        }
    },
    
    documentation = {
        url: url:spotify_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- VÉRIFICATION
-- =====================================================

/*
SELECT 
    id,
    name,
    slug,
    identity.display_name_i18n AS display_name,
    presentation.color_daisy AS color,
    presentation.display_order AS order,
    auth_type.name AS auth_type_name,
    provider.name AS provider_name
FROM credential_type
WHERE presentation.display_order >= 720 AND presentation.display_order < 800
ORDER BY presentation.display_order ASC;
*/

-- =====================================================
-- RÉSUMÉ BATCH 9
-- =====================================================
--
-- ✅ 14 credentials Social Media & Content Platforms créés :
--
-- Twitter/X (2) - display_order: 720-721 ✨ POPULAIRE
--  1. twitter_oauth1_api (720) - Deprecated soon
--  2. twitter_oauth2_api (721) ✨ RECOMMANDÉ - API v2
--
-- LinkedIn (2) - display_order: 730-731 ✨ TRÈS POPULAIRE
--  3. linkedin_oauth2_api (730) ✨ TRÈS POPULAIRE - Personal
--  4. linkedin_community_management_oauth2_api (731) - Organizations
--
-- Facebook/Meta (3) - display_order: 740-742 ✨ TRÈS POPULAIRE
--  5. facebook_graph_api (740) ✨ TRÈS POPULAIRE
--  6. facebook_graph_app_api (741) - Server-to-Server
--  7. facebook_lead_ads_oauth2_api (742) - Lead Generation
--
-- Reddit (1) - display_order: 750
--  8. reddit_oauth2_api (750)
--
-- YouTube (1) - display_order: 760 ✨ TRÈS POPULAIRE
--  9. youtube_oauth2_api (760) ✨ TRÈS POPULAIRE
--
-- Forum & Comments (2) - display_order: 770-771
-- 10. discourse_api (770) - Forum Platform
-- 11. disqus_api (771) - Comment System
--
-- Blogging (2) - display_order: 780-781
-- 12. medium_api (780)
-- 13. medium_oauth2_api (781) - Recommandé
--
-- Music Streaming (1) - display_order: 790 ✨ TRÈS POPULAIRE
-- 14. spotify_oauth2_api (790) ✨ TRÈS POPULAIRE
--
-- Structure complète : identity, presentation, config, documentation
--
-- =============================================================================================


-- =============================================================================================
-- |
-- | Fichier : credential_type_batch5_seeds.surql (SEED DATA)
-- | Module : integrations > reference > credentials > credential_type
-- | Description : Seeds pour le Batch 5 des credential types (12 credentials Development).
-- |
-- | Batch 5 : Top Development (12 credentials)
-- | Providers : GitHub, GitLab, Jira, Bitbucket, Jenkins, CircleCI, Travis CI
-- |
-- =============================================================================================

-- =====================================================
-- 1. GITHUB API (display_order: 400) ✨ TRÈS POPULAIRE
-- =====================================================

CREATE credential_type:github_api SET
    name = "githubApi",
    slug = "github-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_github_api_name,
        description_i18n: i18n_key:credential_type_github_api_description
    },
    
    presentation = {
        icon: icon:github,
        color: "#181717",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:credential_type_github_api_tooltip,
        display_order: 400
    },
    
    auth_type = auth_type:bearer_token,
    provider = provider:github,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "accessToken",
                display_name: "Personal Access Token",
                type: "string",
                is_secret: true,
                required: true,
                description: "GitHub Personal Access Token (classic or fine-grained)"
            }
        ],
        metadata: {
            auth_method: "personal_access_token",
            token_types: ["classic", "fine_grained"]
        }
    },
    
    documentation = {
        url: url:github_api_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 2. GITHUB OAUTH2 API (display_order: 401) ✨ TRÈS POPULAIRE
-- =====================================================

CREATE credential_type:github_oauth2_api SET
    name = "githubOAuth2Api",
    slug = "github-oauth2-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_github_oauth2_api_name,
        description_i18n: i18n_key:credential_type_github_oauth2_api_description
    },
    
    presentation = {
        icon: icon:github,
        color: "#181717",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:credential_type_github_oauth2_api_tooltip,
        display_order: 401
    },
    
    auth_type = auth_type:oauth2,
    provider = provider:github,
    
    config = {
        oauth2: {
            grant_type: "authorization_code",
            access_token_url: "https://github.com/login/oauth/access_token",
            authorization_url: "https://github.com/login/oauth/authorize",
            authentication_method: "body",
            scope: "repo user"
        },
        oauth1: NONE,
        required_fields: [],
        metadata: {
            github_apps: true
        }
    },
    
    documentation = {
        url: url:github_oauth2_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 3. GITLAB API (display_order: 402) ✨ POPULAIRE
-- =====================================================

CREATE credential_type:gitlab_api SET
    name = "gitlabApi",
    slug = "gitlab-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_gitlab_api_name,
        description_i18n: i18n_key:credential_type_gitlab_api_description
    },
    
    presentation = {
        icon: icon:gitlab,
        color: "#FC6D26",
        color_daisy: "warning",
        tooltip_i18n: i18n_key:credential_type_gitlab_api_tooltip,
        display_order: 402
    },
    
    auth_type = auth_type:bearer_token,
    provider = provider:gitlab,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "server",
                display_name: "GitLab Server URL",
                type: "string",
                is_secret: false,
                required: false,
                description: "GitLab server URL (leave empty for gitlab.com)",
                placeholder: "https://gitlab.com",
                default: "https://gitlab.com"
            },
            {
                name: "accessToken",
                display_name: "Access Token",
                type: "string",
                is_secret: true,
                required: true,
                description: "GitLab Personal Access Token"
            }
        ],
        metadata: {
            supports_self_hosted: true,
            auth_method: "personal_access_token"
        }
    },
    
    documentation = {
        url: url:gitlab_api_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 4. GITLAB OAUTH2 API (display_order: 403)
-- =====================================================

CREATE credential_type:gitlab_oauth2_api SET
    name = "gitlabOAuth2Api",
    slug = "gitlab-oauth2-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_gitlab_oauth2_api_name,
        description_i18n: i18n_key:credential_type_gitlab_oauth2_api_description
    },
    
    presentation = {
        icon: icon:gitlab,
        color: "#FC6D26",
        color_daisy: "warning",
        tooltip_i18n: i18n_key:credential_type_gitlab_oauth2_api_tooltip,
        display_order: 403
    },
    
    auth_type = auth_type:oauth2,
    provider = provider:gitlab,
    
    config = {
        oauth2: {
            grant_type: "authorization_code",
            access_token_url: "={{$parameter.server}}/oauth/token",
            authorization_url: "={{$parameter.server}}/oauth/authorize",
            authentication_method: "body",
            scope: "api read_user"
        },
        oauth1: NONE,
        required_fields: [
            {
                name: "server",
                display_name: "GitLab Server URL",
                type: "string",
                is_secret: false,
                required: false,
                description: "GitLab server URL",
                placeholder: "https://gitlab.com",
                default: "https://gitlab.com"
            }
        ],
        metadata: {
            supports_self_hosted: true
        }
    },
    
    documentation = {
        url: url:gitlab_oauth2_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 5. JIRA SOFTWARE CLOUD API (display_order: 410) ✨ TRÈS POPULAIRE
-- =====================================================

CREATE credential_type:jira_software_cloud_api SET
    name = "jiraSoftwareCloudApi",
    slug = "jira-software-cloud-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_jira_software_cloud_api_name,
        description_i18n: i18n_key:credential_type_jira_software_cloud_api_description
    },
    
    presentation = {
        icon: icon:jira,
        color: "#0052CC",
        color_daisy: "info",
        tooltip_i18n: i18n_key:credential_type_jira_software_cloud_api_tooltip,
        display_order: 410
    },
    
    auth_type = auth_type:basic_auth,
    provider = provider:jira,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "email",
                display_name: "Email",
                type: "string",
                is_secret: false,
                required: true,
                description: "Atlassian account email"
            },
            {
                name: "apiToken",
                display_name: "API Token",
                type: "string",
                is_secret: true,
                required: true,
                description: "Jira API token from Atlassian account"
            },
            {
                name: "domain",
                display_name: "Jira Domain",
                type: "string",
                is_secret: false,
                required: true,
                description: "Jira domain (e.g., yourcompany.atlassian.net)",
                placeholder: "yourcompany.atlassian.net"
            }
        ],
        metadata: {
            cloud_only: true,
            auth_method: "api_token"
        }
    },
    
    documentation = {
        url: url:jira_cloud_api_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 6. JIRA SOFTWARE SERVER API (display_order: 411)
-- =====================================================

CREATE credential_type:jira_software_server_api SET
    name = "jiraSoftwareServerApi",
    slug = "jira-software-server-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_jira_software_server_api_name,
        description_i18n: i18n_key:credential_type_jira_software_server_api_description
    },
    
    presentation = {
        icon: icon:jira,
        color: "#0052CC",
        color_daisy: "info",
        tooltip_i18n: i18n_key:credential_type_jira_software_server_api_tooltip,
        display_order: 411
    },
    
    auth_type = auth_type:basic_auth,
    provider = provider:jira,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "domain",
                display_name: "Domain",
                type: "string",
                is_secret: false,
                required: true,
                description: "Jira Server domain",
                placeholder: "jira.yourcompany.com"
            },
            {
                name: "email",
                display_name: "Email",
                type: "string",
                is_secret: false,
                required: true,
                description: "Jira username or email"
            },
            {
                name: "password",
                display_name: "Password",
                type: "string",
                is_secret: true,
                required: true,
                description: "Jira password"
            }
        ],
        metadata: {
            self_hosted: true,
            auth_method: "basic_auth"
        }
    },
    
    documentation = {
        url: url:jira_server_api_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 7. JIRA SOFTWARE SERVER PAT API (display_order: 412)
-- =====================================================

CREATE credential_type:jira_software_server_pat_api SET
    name = "jiraSoftwareServerPatApi",
    slug = "jira-software-server-pat-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_jira_software_server_pat_api_name,
        description_i18n: i18n_key:credential_type_jira_software_server_pat_api_description
    },
    
    presentation = {
        icon: icon:jira,
        color: "#0052CC",
        color_daisy: "success",
        tooltip_i18n: i18n_key:credential_type_jira_software_server_pat_api_tooltip,
        display_order: 412
    },
    
    auth_type = auth_type:bearer_token,
    provider = provider:jira,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "domain",
                display_name: "Domain",
                type: "string",
                is_secret: false,
                required: true,
                description: "Jira Server domain",
                placeholder: "jira.yourcompany.com"
            },
            {
                name: "personalAccessToken",
                display_name: "Personal Access Token",
                type: "string",
                is_secret: true,
                required: true,
                description: "Jira Server Personal Access Token (PAT)"
            }
        ],
        metadata: {
            self_hosted: true,
            auth_method: "personal_access_token",
            more_secure: true
        }
    },
    
    documentation = {
        url: url:jira_server_pat_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 8. BITBUCKET API (display_order: 420)
-- =====================================================

CREATE credential_type:bitbucket_api SET
    name = "bitbucketApi",
    slug = "bitbucket-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_bitbucket_api_name,
        description_i18n: i18n_key:credential_type_bitbucket_api_description
    },
    
    presentation = {
        icon: icon:bitbucket,
        color: "#0052CC",
        color_daisy: "info",
        tooltip_i18n: i18n_key:credential_type_bitbucket_api_tooltip,
        display_order: 420
    },
    
    auth_type = auth_type:basic_auth,
    provider = provider:bitbucket,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "username",
                display_name: "Username",
                type: "string",
                is_secret: false,
                required: true,
                description: "Bitbucket username"
            },
            {
                name: "appPassword",
                display_name: "App Password",
                type: "string",
                is_secret: true,
                required: true,
                description: "Bitbucket app password"
            }
        ],
        metadata: {
            auth_method: "app_password"
        }
    },
    
    documentation = {
        url: url:bitbucket_api_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 9. BITBUCKET ACCESS TOKEN API (display_order: 421)
-- =====================================================

CREATE credential_type:bitbucket_access_token_api SET
    name = "bitbucketAccessTokenApi",
    slug = "bitbucket-access-token-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_bitbucket_access_token_api_name,
        description_i18n: i18n_key:credential_type_bitbucket_access_token_api_description
    },
    
    presentation = {
        icon: icon:bitbucket,
        color: "#0052CC",
        color_daisy: "success",
        tooltip_i18n: i18n_key:credential_type_bitbucket_access_token_api_tooltip,
        display_order: 421
    },
    
    auth_type = auth_type:bearer_token,
    provider = provider:bitbucket,
    
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
                description: "Bitbucket access token"
            }
        ],
        metadata: {
            auth_method: "access_token"
        }
    },
    
    documentation = {
        url: url:bitbucket_access_token_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 10. JENKINS API (display_order: 430)
-- =====================================================

CREATE credential_type:jenkins_api SET
    name = "jenkinsApi",
    slug = "jenkins-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_jenkins_api_name,
        description_i18n: i18n_key:credential_type_jenkins_api_description
    },
    
    presentation = {
        icon: icon:jenkins,
        color: "#D24939",
        color_daisy: "error",
        tooltip_i18n: i18n_key:credential_type_jenkins_api_tooltip,
        display_order: 430
    },
    
    auth_type = auth_type:basic_auth,
    provider = provider:jenkins,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "baseUrl",
                display_name: "Jenkins Base URL",
                type: "string",
                is_secret: false,
                required: true,
                description: "Jenkins server URL",
                placeholder: "https://jenkins.yourcompany.com"
            },
            {
                name: "username",
                display_name: "Username",
                type: "string",
                is_secret: false,
                required: true,
                description: "Jenkins username"
            },
            {
                name: "apiToken",
                display_name: "API Token",
                type: "string",
                is_secret: true,
                required: true,
                description: "Jenkins API token"
            }
        ],
        metadata: {
            self_hosted: true,
            open_source: true
        }
    },
    
    documentation = {
        url: url:jenkins_api_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 11. CIRCLECI API (display_order: 431)
-- =====================================================

CREATE credential_type:circleci_api SET
    name = "circleCiApi",
    slug = "circleci-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_circleci_api_name,
        description_i18n: i18n_key:credential_type_circleci_api_description
    },
    
    presentation = {
        icon: icon:circleci,
        color: "#343434",
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:credential_type_circleci_api_tooltip,
        display_order: 431
    },
    
    auth_type = auth_type:bearer_token,
    provider = provider:circleci,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "apiToken",
                display_name: "API Token",
                type: "string",
                is_secret: true,
                required: true,
                description: "CircleCI personal API token"
            }
        ],
        metadata: {
            cloud_service: true
        }
    },
    
    documentation = {
        url: url:circleci_api_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 12. TRAVIS CI API (display_order: 432)
-- =====================================================

CREATE credential_type:travis_ci_api SET
    name = "travisCiApi",
    slug = "travis-ci-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_travis_ci_api_name,
        description_i18n: i18n_key:credential_type_travis_ci_api_description
    },
    
    presentation = {
        icon: icon:travis_ci,
        color: "#3EAAAF",
        color_daisy: "info",
        tooltip_i18n: i18n_key:credential_type_travis_ci_api_tooltip,
        display_order: 432
    },
    
    auth_type = auth_type:bearer_token,
    provider = provider:travis_ci,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "apiToken",
                display_name: "API Token",
                type: "string",
                is_secret: true,
                required: true,
                description: "Travis CI API token"
            }
        ],
        metadata: {
            cloud_service: true,
            open_source_friendly: true
        }
    },
    
    documentation = {
        url: url:travis_ci_api_docs,
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
WHERE presentation.display_order >= 400 AND presentation.display_order < 500
ORDER BY presentation.display_order ASC;
*/

-- =====================================================
-- RÉSUMÉ BATCH 5
-- =====================================================
--
-- ✅ 12 credentials Development créés :
--
-- Version Control (4) - display_order: 400-403 ✨ TRÈS POPULAIRES
--  1. github_api (400) ✨ TRÈS POPULAIRE
--  2. github_oauth2_api (401) ✨ TRÈS POPULAIRE
--  3. gitlab_api (402) ✨ POPULAIRE
--  4. gitlab_oauth2_api (403)
--
-- Project Management (3) - display_order: 410-412 ✨ TRÈS POPULAIRES
--  5. jira_software_cloud_api (410) ✨ TRÈS POPULAIRE
--  6. jira_software_server_api (411)
--  7. jira_software_server_pat_api (412)
--
-- Git Hosting (2) - display_order: 420-421
--  8. bitbucket_api (420)
--  9. bitbucket_access_token_api (421)
--
-- CI/CD Platforms (3) - display_order: 430-432
-- 10. jenkins_api (430) - Open-source automation server
-- 11. circleci_api (431) - Cloud CI/CD
-- 12. travis_ci_api (432) - CI/CD for open-source
--
-- Structure complète : identity, presentation, config, documentation
--
-- =============================================================================================


-- =============================================================================================
-- |
-- | Fichier : credential_type_batch8_seeds.surql (SEED DATA)
-- | Module : integrations > reference > credentials > credential_type
-- | Description : Seeds pour le Batch 8 des credential types (17 credentials Cloud, Storage & Infrastructure).
-- |
-- | Batch 8 : Cloud, Storage & Infrastructure (17 credentials)
-- | Providers : AWS, S3, Cloudflare, Netlify, Supabase, Dropbox, Box, FTP, SSH, Webflow, WooCommerce, WordPress
-- |
-- =============================================================================================

-- =====================================================
-- 1. AWS (display_order: 650) ✨ TRÈS POPULAIRE
-- =====================================================

CREATE credential_type:aws SET
    name = "aws",
    slug = "aws",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_aws_name,
        description_i18n: i18n_key:credential_type_aws_description
    },
    
    presentation = {
        icon: icon:aws,
        color_type: theme_color_type:warning,
        tooltip_i18n: i18n_key:credential_type_aws_tooltip,
        display_order: 650
    },
    
    auth_type = auth_type:api_key,
    provider = provider:aws,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "accessKeyId",
                display_name: "Access Key ID",
                type: "string",
                is_secret: false,
                required: true,
                description: "AWS IAM Access Key ID"
            },
            {
                name: "secretAccessKey",
                display_name: "Secret Access Key",
                type: "string",
                is_secret: true,
                required: true,
                description: "AWS IAM Secret Access Key"
            },
            {
                name: "region",
                display_name: "Region",
                type: "string",
                is_secret: false,
                required: true,
                description: "AWS region",
                default: "us-east-1",
                placeholder: "us-east-1"
            }
        ],
        metadata: {
            supports_iam: true,
            global_service: true
        }
    },
    
    documentation = {
        url: url:aws_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 2. S3 (display_order: 651) ✨ TRÈS POPULAIRE
-- =====================================================

CREATE credential_type:s3 SET
    name = "s3",
    slug = "s3",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_s3_name,
        description_i18n: i18n_key:credential_type_s3_description
    },
    
    presentation = {
        icon: icon:s3,
        color_type: theme_color_type:success,
        tooltip_i18n: i18n_key:credential_type_s3_tooltip,
        display_order: 651
    },
    
    auth_type = auth_type:api_key,
    provider = provider:aws,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "accessKeyId",
                display_name: "Access Key ID",
                type: "string",
                is_secret: false,
                required: true,
                description: "AWS S3 Access Key ID"
            },
            {
                name: "secretAccessKey",
                display_name: "Secret Access Key",
                type: "string",
                is_secret: true,
                required: true,
                description: "AWS S3 Secret Access Key"
            },
            {
                name: "region",
                display_name: "Region",
                type: "string",
                is_secret: false,
                required: true,
                description: "S3 bucket region",
                default: "us-east-1"
            }
        ],
        metadata: {
            storage_type: "object",
            compatible_with: ["AWS S3", "MinIO", "DigitalOcean Spaces", "Wasabi"]
        }
    },
    
    documentation = {
        url: url:s3_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 3. CLOUDFLARE API (display_order: 660)
-- =====================================================

CREATE credential_type:cloudflare_api SET
    name = "cloudflareApi",
    slug = "cloudflare-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_cloudflare_api_name,
        description_i18n: i18n_key:credential_type_cloudflare_api_description
    },
    
    presentation = {
        icon: icon:cloudflare,
        color_type: theme_color_type:warning,
        tooltip_i18n: i18n_key:credential_type_cloudflare_api_tooltip,
        display_order: 660
    },
    
    auth_type = auth_type:bearer_token,
    provider = provider:cloudflare,
    
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
                description: "Cloudflare API Token"
            }
        ],
        metadata: {
            cdn_provider: true,
            supports_workers: true
        }
    },
    
    documentation = {
        url: url:cloudflare_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 4. NETLIFY API (display_order: 661)
-- =====================================================

CREATE credential_type:netlify_api SET
    name = "netlifyApi",
    slug = "netlify-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_netlify_api_name,
        description_i18n: i18n_key:credential_type_netlify_api_description
    }, presentation = { icon: icon:netlify_api, color_type: theme_color_type:neutral, tooltip_i18n: i18n_key:credential_type_netlify_api_tooltip,
        display_order: 661
    },
    
    auth_type = auth_type:bearer_token,
    provider = provider:netlify,
    
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
                description: "Netlify Personal Access Token"
            }
        ],
        metadata: {
            hosting_type: "jamstack",
            supports_serverless: true
        }
    },
    
    documentation = {
        url: url:netlify_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 5. SUPABASE API (display_order: 662)
-- =====================================================

CREATE credential_type:supabase_api SET
    name = "supabaseApi",
    slug = "supabase-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_supabase_api_name,
        description_i18n: i18n_key:credential_type_supabase_api_description
    },
    
    presentation = {
        icon: icon:supabase,
        color_type: theme_color_type:success,
        tooltip_i18n: i18n_key:credential_type_supabase_api_tooltip,
        display_order: 662
    },
    
    auth_type = auth_type:api_key,
    provider = provider:supabase,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "host",
                display_name: "Host",
                type: "string",
                is_secret: false,
                required: true,
                description: "Supabase project URL",
                placeholder: "https://yourproject.supabase.co"
            },
            {
                name: "serviceRole",
                display_name: "Service Role Secret",
                type: "string",
                is_secret: true,
                required: true,
                description: "Supabase service_role key"
            }
        ],
        metadata: {
            backend_type: "baas",
            database: "postgresql"
        }
    },
    
    documentation = {
        url: url:supabase_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 6. DROPBOX API (display_order: 670)
-- =====================================================

CREATE credential_type:dropbox_api SET
    name = "dropboxApi",
    slug = "dropbox-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_dropbox_api_name,
        description_i18n: i18n_key:credential_type_dropbox_api_description
    },
    
    presentation = {
        icon: icon:dropbox,
        color_type: theme_color_type:info,
        tooltip_i18n: i18n_key:credential_type_dropbox_api_tooltip,
        display_order: 670
    },
    
    auth_type = auth_type:bearer_token,
    provider = provider:dropbox,
    
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
                description: "Dropbox access token"
            }
        ],
        metadata: {
            storage_type: "cloud",
            deprecated: true,
            prefer: "dropboxOAuth2Api"
        }
    },
    
    documentation = {
        url: url:dropbox_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 7. DROPBOX OAUTH2 API (display_order: 671)
-- =====================================================

CREATE credential_type:dropbox_oauth2_api SET
    name = "dropboxOAuth2Api",
    slug = "dropbox-oauth2-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_dropbox_oauth2_api_name,
        description_i18n: i18n_key:credential_type_dropbox_oauth2_api_description
    },
    
    presentation = {
        icon: icon:dropbox,
        color_type: theme_color_type:primary,
        tooltip_i18n: i18n_key:credential_type_dropbox_oauth2_api_tooltip,
        display_order: 671
    },
    
    auth_type = auth_type:oauth2,
    provider = provider:dropbox,
    
    config = {
        oauth2: {
            grant_type: "authorization_code",
            access_token_url: "https://api.dropboxapi.com/oauth2/token",
            authorization_url: "https://www.dropbox.com/oauth2/authorize",
            authentication_method: "body",
            scope: ""
        },
        oauth1: NONE,
        required_fields: [],
        metadata: {
            recommended: true
        }
    },
    
    documentation = {
        url: url:dropbox_oauth2_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 8. BOX OAUTH2 API (display_order: 672)
-- =====================================================

CREATE credential_type:box_oauth2_api SET
    name = "boxOAuth2Api",
    slug = "box-oauth2-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_box_oauth2_api_name,
        description_i18n: i18n_key:credential_type_box_oauth2_api_description
    },
    
    presentation = {
        icon: icon:box,
        color_type: theme_color_type:primary,
        tooltip_i18n: i18n_key:credential_type_box_oauth2_api_tooltip,
        display_order: 672
    },
    
    auth_type = auth_type:oauth2,
    provider = provider:box,
    
    config = {
        oauth2: {
            grant_type: "authorization_code",
            access_token_url: "https://api.box.com/oauth2/token",
            authorization_url: "https://account.box.com/api/oauth2/authorize",
            authentication_method: "body",
            scope: "root_readwrite"
        },
        oauth1: NONE,
        required_fields: [],
        metadata: {
            enterprise: true
        }
    },
    
    documentation = {
        url: url:box_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 9. FTP (display_order: 680)
-- =====================================================

CREATE credential_type:ftp SET
    name = "ftp",
    slug = "ftp",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_ftp_name,
        description_i18n: i18n_key:credential_type_ftp_description
    },
    
    presentation = {
        icon: icon:ftp,
        color_type: theme_color_type:info,
        tooltip_i18n: i18n_key:credential_type_ftp_tooltip,
        display_order: 680
    },
    
    auth_type = auth_type:basic_auth,
    provider = provider:generic,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "host",
                display_name: "Host",
                type: "string",
                is_secret: false,
                required: true,
                description: "FTP server host"
            },
            {
                name: "port",
                display_name: "Port",
                type: "number",
                is_secret: false,
                required: true,
                description: "FTP server port",
                default: 21
            },
            {
                name: "username",
                display_name: "Username",
                type: "string",
                is_secret: false,
                required: true,
                description: "FTP username"
            },
            {
                name: "password",
                display_name: "Password",
                type: "string",
                is_secret: true,
                required: true,
                description: "FTP password"
            }
        ],
        metadata: {
            protocol: "ftp",
            secure: false,
            deprecated_for_security: true
        }
    },
    
    documentation = {
        url: url:ftp_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 10. SFTP (display_order: 681)
-- =====================================================

CREATE credential_type:sftp SET
    name = "sftp",
    slug = "sftp",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_sftp_name,
        description_i18n: i18n_key:credential_type_sftp_description
    },
    
    presentation = {
        icon: icon:sftp,
        color_type: theme_color_type:success,
        tooltip_i18n: i18n_key:credential_type_sftp_tooltip,
        display_order: 681
    },
    
    auth_type = auth_type:basic_auth,
    provider = provider:generic,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "host",
                display_name: "Host",
                type: "string",
                is_secret: false,
                required: true,
                description: "SFTP server host"
            },
            {
                name: "port",
                display_name: "Port",
                type: "number",
                is_secret: false,
                required: true,
                description: "SFTP server port",
                default: 22
            },
            {
                name: "username",
                display_name: "Username",
                type: "string",
                is_secret: false,
                required: true,
                description: "SFTP username"
            },
            {
                name: "password",
                display_name: "Password",
                type: "string",
                is_secret: true,
                required: false,
                description: "SFTP password (if not using private key)"
            },
            {
                name: "privateKey",
                display_name: "Private Key",
                type: "string",
                is_secret: true,
                required: false,
                description: "SSH private key (if not using password)"
            }
        ],
        metadata: {
            protocol: "sftp",
            secure: true,
            recommended: true
        }
    },
    
    documentation = {
        url: url:sftp_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 11. SSH PASSWORD (display_order: 682)
-- =====================================================

CREATE credential_type:ssh_password SET
    name = "sshPassword",
    slug = "ssh-password",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_ssh_password_name,
        description_i18n: i18n_key:credential_type_ssh_password_description
    },
    
    presentation = {
        icon: icon:ssh,
        color_type: theme_color_type:neutral,
        tooltip_i18n: i18n_key:credential_type_ssh_password_tooltip,
        display_order: 682
    },
    
    auth_type = auth_type:basic_auth,
    provider = provider:generic,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "host",
                display_name: "Host",
                type: "string",
                is_secret: false,
                required: true,
                description: "SSH server host"
            },
            {
                name: "port",
                display_name: "Port",
                type: "number",
                is_secret: false,
                required: true,
                description: "SSH server port",
                default: 22
            },
            {
                name: "username",
                display_name: "Username",
                type: "string",
                is_secret: false,
                required: true,
                description: "SSH username"
            },
            {
                name: "password",
                display_name: "Password",
                type: "string",
                is_secret: true,
                required: true,
                description: "SSH password"
            }
        ],
        metadata: {
            protocol: "ssh",
            auth_method: "password",
            less_secure: true
        }
    },
    
    documentation = {
        url: url:ssh_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 12. SSH PRIVATE KEY (display_order: 683)
-- =====================================================

CREATE credential_type:ssh_private_key SET
    name = "sshPrivateKey",
    slug = "ssh-private-key",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_ssh_private_key_name,
        description_i18n: i18n_key:credential_type_ssh_private_key_description
    },
    
    presentation = {
        icon: icon:ssh,
        color_type: theme_color_type:success,
        tooltip_i18n: i18n_key:credential_type_ssh_private_key_tooltip,
        display_order: 683
    },
    
    auth_type = auth_type:bearer_token,
    provider = provider:generic,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "host",
                display_name: "Host",
                type: "string",
                is_secret: false,
                required: true,
                description: "SSH server host"
            },
            {
                name: "port",
                display_name: "Port",
                type: "number",
                is_secret: false,
                required: true,
                description: "SSH server port",
                default: 22
            },
            {
                name: "username",
                display_name: "Username",
                type: "string",
                is_secret: false,
                required: true,
                description: "SSH username"
            },
            {
                name: "privateKey",
                display_name: "Private Key",
                type: "string",
                is_secret: true,
                required: true,
                description: "SSH private key (RSA, Ed25519, etc.)"
            },
            {
                name: "passphrase",
                display_name: "Passphrase",
                type: "string",
                is_secret: true,
                required: false,
                description: "Private key passphrase (if encrypted)"
            }
        ],
        metadata: {
            protocol: "ssh",
            auth_method: "public_key",
            recommended: true,
            secure: true
        }
    },
    
    documentation = {
        url: url:ssh_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 13. WEBFLOW API (display_order: 690)
-- =====================================================

CREATE credential_type:webflow_api SET
    name = "webflowApi",
    slug = "webflow-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_webflow_api_name,
        description_i18n: i18n_key:credential_type_webflow_api_description
    },
    
    presentation = {
        icon: icon:webflow,
        color_type: theme_color_type:primary,
        tooltip_i18n: i18n_key:credential_type_webflow_api_tooltip,
        display_order: 690
    },
    
    auth_type = auth_type:bearer_token,
    provider = provider:webflow,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "accessToken",
                display_name: "API Token",
                type: "string",
                is_secret: true,
                required: true,
                description: "Webflow site API token"
            }
        ],
        metadata: {
            platform_type: "no_code"
        }
    },
    
    documentation = {
        url: url:webflow_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 14. WEBFLOW OAUTH2 API (display_order: 691)
-- =====================================================

CREATE credential_type:webflow_oauth2_api SET
    name = "webflowOAuth2Api",
    slug = "webflow-oauth2-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_webflow_oauth2_api_name,
        description_i18n: i18n_key:credential_type_webflow_oauth2_api_description
    }, presentation = { icon: icon:webflow_oauth2_api, color_type: theme_color_type:neutral, tooltip_i18n: i18n_key:credential_type_webflow_oauth2_api_tooltip,
        display_order: 691
    },
    
    auth_type = auth_type:oauth2,
    provider = provider:webflow,
    
    config = {
        oauth2: {
            grant_type: "authorization_code",
            access_token_url: "https://api.webflow.com/oauth/access_token",
            authorization_url: "https://webflow.com/oauth/authorize",
            authentication_method: "body",
            scope: "sites:read sites:write"
        },
        oauth1: NONE,
        required_fields: [],
        metadata: {}
    },
    
    documentation = {
        url: url:webflow_oauth2_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 15. WOOCOMMERCE API (display_order: 700) ✨ POPULAIRE
-- =====================================================

CREATE credential_type:woocommerce_api SET
    name = "wooCommerceApi",
    slug = "woocommerce-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_woocommerce_api_name,
        description_i18n: i18n_key:credential_type_woocommerce_api_description
    }, presentation = { icon: icon:woocommerce_api, color_type: theme_color_type:neutral, tooltip_i18n: i18n_key:credential_type_woocommerce_api_tooltip,
        display_order: 700
    },
    
    auth_type = auth_type:basic_auth,
    provider = provider:woocommerce,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "url",
                display_name: "WooCommerce URL",
                type: "string",
                is_secret: false,
                required: true,
                description: "WooCommerce store URL",
                placeholder: "https://yourstore.com"
            },
            {
                name: "consumerKey",
                display_name: "Consumer Key",
                type: "string",
                is_secret: false,
                required: true,
                description: "WooCommerce REST API consumer key"
            },
            {
                name: "consumerSecret",
                display_name: "Consumer Secret",
                type: "string",
                is_secret: true,
                required: true,
                description: "WooCommerce REST API consumer secret"
            }
        ],
        metadata: {
            platform: "wordpress",
            ecommerce: true
        }
    },
    
    documentation = {
        url: url:woocommerce_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 16. WORDPRESS API (display_order: 701) ✨ TRÈS POPULAIRE
-- =====================================================

CREATE credential_type:wordpress_api SET
    name = "wordPressApi",
    slug = "wordpress-api",
    is_active = true,
    
    identity = {
        display_name_i18n: i18n_key:credential_type_wordpress_api_name,
        description_i18n: i18n_key:credential_type_wordpress_api_description
    },
    
    presentation = {
        icon: icon:wordpress,
        color_type: theme_color_type:info,
        tooltip_i18n: i18n_key:credential_type_wordpress_api_tooltip,
        display_order: 701
    },
    
    auth_type = auth_type:basic_auth,
    provider = provider:wordpress,
    
    config = {
        oauth2: NONE,
        oauth1: NONE,
        required_fields: [
            {
                name: "url",
                display_name: "WordPress URL",
                type: "string",
                is_secret: false,
                required: true,
                description: "WordPress site URL",
                placeholder: "https://yoursite.com"
            },
            {
                name: "username",
                display_name: "Username",
                type: "string",
                is_secret: false,
                required: true,
                description: "WordPress username"
            },
            {
                name: "password",
                display_name: "Application Password",
                type: "string",
                is_secret: true,
                required: true,
                description: "WordPress application password"
            }
        ],
        metadata: {
            cms: true,
            rest_api: true
        }
    },
    
    documentation = {
        url: url:wordpress_docs,
        use_cases_i18n: NONE
    };

-- =====================================================
-- 17. KOBOTOOLBOX API - DOUBLON SUPPRIMÉ (déjà défini dans batch26 avec name = "koBoToolboxApi")
-- =====================================================

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
WHERE presentation.display_order >= 650 AND presentation.display_order < 720
ORDER BY presentation.display_order ASC;
*/

-- =====================================================
-- RÉSUMÉ BATCH 8
-- =====================================================
--
-- ✅ 17 credentials Cloud, Storage & Infrastructure créés :
--
-- Cloud Platform (2) - display_order: 650-651 ✨ TRÈS POPULAIRE
--  1. aws (650) ✨ TRÈS POPULAIRE - Amazon Web Services
--  2. s3 (651) ✨ TRÈS POPULAIRE - Amazon S3 Storage
--
-- CDN & Hosting (3) - display_order: 660-662
--  3. cloudflare_api (660) - CDN & Security
--  4. netlify_api (661) - JAMstack Hosting
--  5. supabase_api (662) - Firebase Alternative
--
-- Cloud Storage (3) - display_order: 670-672
--  6. dropbox_api (670) - Deprecated
--  7. dropbox_oauth2_api (671) - Recommandé
--  8. box_oauth2_api (672) - Enterprise Storage
--
-- File Transfer (4) - display_order: 680-683
--  9. ftp (680) - Deprecated
-- 10. sftp (681) - Recommandé
-- 11. ssh_password (682) - SSH Password Auth
-- 12. ssh_private_key (683) - SSH Key Auth (Recommandé)
--
-- CMS & No-Code (4) - display_order: 690-701 ✨ POPULAIRE
-- 13. webflow_api (690)
-- 14. webflow_oauth2_api (691)
-- 15. woocommerce_api (700) ✨ POPULAIRE - E-Commerce
-- 16. wordpress_api (701) ✨ TRÈS POPULAIRE - CMS
--
-- Data Collection (1) - display_order: 710
-- 17. kobotoolbox_api (710) - Humanitarian Surveys
--
-- Structure complète : identity, presentation, config, documentation
--
-- =============================================================================================


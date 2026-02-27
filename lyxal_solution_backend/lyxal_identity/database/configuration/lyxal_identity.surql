DEFINE TABLE IF NOT EXISTS lyxal_identity
    SCHEMAFULL
    TYPE NORMAL
    COMMENT "Liste des tenants lyxal_identity"


DEFINE FIELD IF NOT EXISTS account_centers ON TABLE lyxal_identity
    TYPE object FLEXIBLE
    DEFAULT {}
    COMMENT "Account center configuration";

    DEFINE FIELD account_centers.enabled ON TABLE lyxal_identity 
        TYPE bool 
        DEFAULT true
        COMMENT "Account center activé/désactivé";

    DEFINE FIELD account_centers.fields ON TABLE lyxal_identity 
        TYPE object 
        DEFAULT {}
        COMMENT "Account center fields";

    DEFINE FIELD account_centers.webauthn_related_origins ON TABLE lyxal_identity 
        TYPE array 
        DEFAULT []
        COMMENT "Account center webauthn related origins";

DEFINE FIELD IF NOT EXISTS sign_in_experiences ON TABLE lyxal_identity
    TYPE object FLEXIBLE
    DEFAULT {}
    COMMENT "Sign in experiences configuration";

    DEFINE FIELD IF NOT EXISTS sign_in_experiences.branding ON TABLE lyxal_identity 
        TYPE object FLEXIBLE
        DEFAULT {}
        COMMENT "Configuration du branding de la page de connexion";

        DEFINE FIELD IF NOT EXISTS sign_in_experiences.branding.primaryColor ON TABLE lyxal_identity 
            TYPE string 
            ASSERT $value.is_hexadecimal()
            COMMENT "Couleur de la marque";

        DEFINE FIELD IF NOT EXISTS sign_in_experiences.branding.isDarkModeEnabled ON TABLE lyxal_identity 
            TYPE bool 
            DEFAULT false
            COMMENT "Mode sombre activé/désactivé";

        DEFINE FIELD IF NOT EXISTS sign_in_experiences.branding.darkPrimaryColor ON TABLE lyxal_identity 
            TYPE string 
            ASSERT $value.is_hexadecimal()
            COMMENT "Couleur de la marque en mode sombre";

        DEFINE FIELD IF NOT EXISTS sign_in_experiences.branding.logo ON TABLE lyxal_identity 
            TYPE option<string>
            ASSERT $value.is_url()
            DEFAULT none
            COMMENT "url du logo de la page de connexion en mode clair";

        DEFINE FIELD IF NOT EXISTS sign_in_experiences.branding.darkLogo ON TABLE lyxal_identity 
            TYPE option<string> 
            ASSERT $value.is_url()
            DEFAULT none
            COMMENT "url du logo de la page de connexion en mode sombre";

        DEFINE FIELD IF NOT EXISTS sign_in_experiences.branding.favicon ON TABLE lyxal_identity 
            TYPE option<string> 
            ASSERT $value.is_url()
            DEFAULT none
            COMMENT "url du favicon de la page de connexion";

        DEFINE FIELD IF NOT EXISTS sign_in_experiences.branding.darkFavicon ON TABLE lyxal_identity 
            TYPE option<string> 
            ASSERT $value.is_url()
            DEFAULT none
            COMMENT "url du favicon de la page de connexion en mode sombre";

        DEFINE FIELD IF NOT EXISTS sign_in_experiences.branding.hide_lyxal_branding ON TABLE lyxal_identity 
            TYPE bool 
            DEFAULT false
            COMMENT "Masquer la marque Lyxal";

    DEFINE FIELD IF NOT EXISTS sign_in_experiences.sign_in_sign_up ON TABLE lyxal_identity 
        TYPE object FLEXIBLE
        DEFAULT {}
        COMMENT "Configuration de l'inscription et de la connexion";  

        DEFINE FIELD IF NOT EXISTS sign_in_experiences.sign_in_sign_up.sign_in ON TABLE lyxal_identity 
            TYPE object FLEXIBLE 
            DEFAULT {}
            COMMENT "Configuration de la connexion";

            DEFINE FIELD IF NOT EXISTS sign_in_experiences.sign_in_sign_up.sign_in.methods ON TABLE lyxal_identity
                TYPE array<object> DEFAULT ALWAYS []
                COMMENT "méthodes de connexion";

                DEFINE FIELD IF NOT EXISTS sign_in_experiences.sign_in_sign_up.sign_in.methods.*.identifier ON TABLE lyxal_identity
                    TYPE record(sign_in_sign_up_identifier)
                    COMMENT "identifiant utilisé";

                DEFINE FIELD IF NOT EXISTS sign_in_experiences.sign_in_sign_up.sign_in.methods.*.password ON TABLE lyxal_identity
                    TYPE bool
                    COMMENT "autoriser le mot de passe";

                DEFINE FIELD IF NOT EXISTS sign_in_experiences.sign_in_sign_up.sign_in.methods.*.verification_code ON TABLE lyxal_identity
                    TYPE bool
                    COMMENT "autoriser le code de verification";

                DEFINE FIELD IF NOT EXISTS sign_in_experiences.sign_in_sign_up.sign_in.methods.*.is_password_primary ON TABLE lyxal_identity
                    TYPE bool
                    COMMENT "mot de passe en priorité";

        DEFINE FIELD IF NOT EXISTS sign_in_experiences.sign_in_sign_up.sign_up ON TABLE lyxal_identity 
            TYPE object FLEXIBLE 
            DEFAULT {}
            COMMENT "Configuration de l'inscription";

            -- Identifiants primaires requis (Email, Username, Phone)
            DEFINE FIELD IF NOT EXISTS sign_in_experiences.sign_in_sign_up.sign_up.identifiers ON TABLE lyxal_identity
                TYPE array<record(sign_in_sign_up_identifier)> 
                DEFAULT ALWAYS []
                COMMENT "Identifiants primaires requis pour créer un compte";

            -- Configuration du mot de passe à l'inscription
            DEFINE FIELD IF NOT EXISTS sign_in_experiences.sign_in_sign_up.sign_up.password ON TABLE lyxal_identity
                TYPE bool
                DEFAULT true
                COMMENT "L'utilisateur doit-il définir un mot de passe à l'inscription ?";

            -- Vérification immédiate
            DEFINE FIELD IF NOT EXISTS sign_in_experiences.sign_in_sign_up.sign_up.verify ON TABLE lyxal_identity
                TYPE bool
                DEFAULT false
                COMMENT "L\'utilisateur doit-il vérifier son identifiant immédiatement ?";

            -- Identifiants secondaires (ex: demander le username en plus de l'email)
            DEFINE FIELD IF NOT EXISTS sign_in_experiences.sign_in_sign_up.sign_up.secondary_identifiers ON TABLE lyxal_identity
                TYPE array<object> 
                DEFAULT ALWAYS []
                COMMENT "Identifiants secondaires demandés durant l'inscription";

            DEFINE FIELD IF NOT EXISTS sign_in_experiences.sign_in_sign_up.sign_up.secondary_identifiers.*.identifier ON TABLE lyxal_identity
                TYPE record(sign_in_sign_up_identifier)
                COMMENT "Type d'identifiant secondaire";

            DEFINE FIELD IF NOT EXISTS sign_in_experiences.sign_in_sign_up.sign_up.secondary_identifiers.*.verify ON TABLE lyxal_identity
                TYPE bool
                DEFAULT false
                COMMENT "Cet identifiant secondaire doit-il être vérifié ?";

        DEFINE FIELD IF NOT EXISTS sign_in_experiences.sign_in_sign_up.forgot_password_methods ON TABLE lyxal_identity 
            TYPE array<record(forgot_password_method)> 
            DEFAULT ALWAYS []
            COMMENT "Configuration de l\'oubli du mot de passe";

        DEFINE FIELD IF NOT EXISTS sign_in_experiences.sign_in_sign_up.social_sign_in ON TABLE lyxal_identity 
            TYPE object FLEXIBLE 
            DEFAULT {}
            COMMENT "Configuration de l\'inscription via les réseaux sociaux";

            DEFINE FIELD IF NOT EXISTS sign_in_experiences.sign_in_sign_up.social_sign_in.connectors ON TABLE lyxal_identity 
                TYPE array<record(connector)> 
                DEFAULT ALWAYS []
                COMMENT "Configuration des connecteurs";

            DEFINE FIELD IF NOT EXISTS sign_in_experiences.sign_in_sign_up.social_sign_in.automatic_account_linking ON TABLE lyxal_identity 
                TYPE bool 
                DEFAULT false
                COMMENT "L\'utilisateur doit-il lier son compte automatiquement ?";

            DEFINE FIELD IF NOT EXISTS sign_in_experiences.sign_in_sign_up.social_sign_in.skip_required_identifiers ON TABLE lyxal_identity 
                TYPE bool 
                DEFAULT false
                COMMENT "L\'utilisateur doit-il fournir les identifiants requis ?";

        DEFINE FIELD IF NOT EXISTS sign_in_experiences.sign_in_sign_up.advanced ON TABLE lyxal_identity 
            TYPE object FLEXIBLE 
            DEFAULT {}
            COMMENT "Configuration avancée de sign_in sign_up";

            DEFINE FIELD IF NOT EXISTS sign_in_experiences.sign_in_sign_up.advanced.sso_enabled ON TABLE lyxal_identity 
                TYPE bool 
                DEFAULT false
                COMMENT "Activer le SSO";


    DEFINE FIELD sign_in_experiences.content ON TABLE lyxal_identity 
        TYPE object FLEXIBLE
        DEFAULT {}
        COMMENT "Configuration du contenu de la page de connexion";   

        DEFINE FIELD sign_in_experiences.content.language_info ON TABLE lyxal_identity 
            TYPE object FLEXIBLE 
            DEFAULT {}
            COMMENT "Configuration des langues de la page de connexion";

            DEFINE FIELD sign_in_experiences.content.language_info.auto_detect ON TABLE lyxal_identity 
                TYPE bool 
                DEFAULT true
                COMMENT "Détection automatique de la langue";

            DEFINE FIELD sign_in_experiences.content.language_info.default_language ON TABLE lyxal_identity 
                TYPE string 
                DEFAULT 'fr'
                COMMENT "Langue par défaut";

        DEFINE FIELD sign_in_experiences.content.terms ON TABLE lyxal_identity 
            TYPE object FLEXIBLE 
            DEFAULT {}
            COMMENT "Configuration des termes de la page de connexion";

            DEFINE FIELD sign_in_experiences.content.terms.terms_of_use_url ON TABLE lyxal_identity 
                TYPE option<string>
                ASSERT $value.is_url()
                DEFAULT none
                COMMENT "url des conditions d\'utilisation";

            DEFINE FIELD sign_in_experiences.content.terms.privacy_policy_url ON TABLE lyxal_identity 
                TYPE option<string>
                ASSERT $value.is_url() 
                DEFAULT none
                COMMENT "url de la politique de confidentialité";

            DEFINE FIELD sign_in_experiences.content.terms.agree_to_terms_policy ON TABLE lyxal_identity 
                TYPE record(agree_to_terms_policy)
                DEFAULT 'Automatic'
                COMMENT "Type d'accord aux conditions d'utilisation et à la politique de confidentialité";

        DEFINE FIELD sign_in_experiences.content.support ON TABLE lyxal_identity 
            TYPE object FLEXIBLE 
            DEFAULT {}
            COMMENT "Configuration du support de la page de connexion";

            DEFINE FIELD sign_in_experiences.content.support.email ON TABLE lyxal_identity 
                TYPE option<string>
                ASSERT $value.is_email()
                DEFAULT none
                COMMENT "Adresse email du support de la page de connexion";

            DEFINE FIELD sign_in_experiences.content.support.website_url ON TABLE lyxal_identity 
                TYPE option<string>
                ASSERT $value.is_url() 
                DEFAULT none
                COMMENT "Url du site web du support de la page de connexion";




    DEFINE FIELD sign_in_experiences.sign_in_mode ON TABLE lyxal_identity 
        TYPE string 
        DEFAULT 'SignInAndRegister'
        COMMENT "Sign in experiences sign in mode";

    DEFINE FIELD sign_in_experiences.custom_css ON TABLE lyxal_identity 
        TYPE string 
        DEFAULT ''
        COMMENT "Sign in experiences custom css";

    DEFINE FIELD sign_in_experiences.custom_content ON TABLE lyxal_identity 
        TYPE jsonb 
        DEFAULT '{}'::jsonb
        COMMENT "Sign in experiences custom content";

    DEFINE FIELD sign_in_experiences.custom_ui_assets ON TABLE lyxal_identity 
        TYPE jsonb 
        DEFAULT '{}'::jsonb
        COMMENT "Sign in experiences custom ui assets";

    DEFINE FIELD sign_in_experiences.password_policy ON TABLE lyxal_identity 
        TYPE jsonb 
        DEFAULT '{}'::jsonb
        COMMENT "Sign in experiences password policy";

    DEFINE FIELD sign_in_experiences.mfa ON TABLE lyxal_identity 
        TYPE jsonb 
        DEFAULT '{}'::jsonb
        COMMENT "Sign in experiences mfa";

    DEFINE FIELD sign_in_experiences.adaptive_mfa ON TABLE lyxal_identity 
        TYPE jsonb 
        DEFAULT '{}'::jsonb
        COMMENT "Sign in experiences adaptive mfa";

    DEFINE FIELD sign_in_experiences.single_sign_on_enabled ON TABLE lyxal_identity 
        TYPE bool 
        DEFAULT false
        COMMENT "Sign in experiences single sign on enabled";

    DEFINE FIELD sign_in_experiences.support_email ON TABLE lyxal_identity 
        TYPE string 
        DEFAULT ''
        COMMENT "Sign in experiences support email";

    DEFINE FIELD sign_in_experiences.support_website_url ON TABLE lyxal_identity 
        TYPE string 
        DEFAULT ''
        COMMENT "Sign in experiences support website url";

    DEFINE FIELD sign_in_experiences.unknown_session_redirect_url ON TABLE lyxal_identity 
        TYPE string 
        DEFAULT ''
        COMMENT "Sign in experiences unknown session redirect url";

    DEFINE FIELD sign_in_experiences.captcha_policy ON TABLE lyxal_identity 
        TYPE jsonb 
        DEFAULT '{}'::jsonb
        COMMENT "Sign in experiences captcha policy";

    DEFINE FIELD sign_in_experiences.sentinel_policy ON TABLE lyxal_identity 
        TYPE jsonb 
        DEFAULT '{}'::jsonb
        COMMENT "Sign in experiences sentinel policy";

    DEFINE FIELD sign_in_experiences.email_blocklist_policy ON TABLE lyxal_identity 
        TYPE jsonb 
        DEFAULT '{}'::jsonb
        COMMENT "Sign in experiences email blocklist policy";

    DEFINE FIELD sign_in_experiences.forgot_password_methods ON TABLE lyxal_identity 
        TYPE array 
        DEFAULT []
        COMMENT "Sign in experiences forgot password methods";

    DEFINE FIELD sign_in_experiences.passkey_sign_in ON TABLE lyxal_identity 
        TYPE jsonb 
        DEFAULT '{}'::jsonb
        COMMENT "Sign in experiences passkey sign in";


 

 sign_in_mode sign_in_mode not null default 'SignInAndRegister',
  custom_css text,
  custom_content jsonb /* @use CustomContent */ not null default '{}'::jsonb,
  custom_ui_assets jsonb /* @use CustomUiAssets */,
  password_policy jsonb /* @use PartialPasswordPolicy */ not null default '{}'::jsonb,
  mfa jsonb /* @use Mfa */ not null default '{}'::jsonb,
  adaptive_mfa jsonb /* @use AdaptiveMfa */ not null default '{}'::jsonb,
  unknown_session_redirect_url text,
  captcha_policy jsonb /* @use CaptchaPolicy */ not null default '{}'::jsonb,
  sentinel_policy jsonb /* @use SentinelPolicy */ not null default '{}'::jsonb,
  email_blocklist_policy jsonb /* @use EmailBlocklistPolicy */ not null default '{}'::jsonb,
  
  passkey_sign_in jsonb /* @use PasskeySignIn */ not null default '{}'::jsonb,

DEFINE TABLE IF NOT EXISTS lyxal_identity
    SCHEMAFULL
    TYPE NORMAL
    COMMENT "Liste des tenants lyxal_identity"



---- Branding ----

DEFINE FIELD IF NOT EXISTS branding ON TABLE lyxal_identity 
    TYPE object FLEXIBLE
    DEFAULT {}
    COMMENT "Configuration du branding de la page de connexion";

    DEFINE FIELD IF NOT EXISTS branding.primaryColor ON TABLE lyxal_identity 
        TYPE string 
        ASSERT $value.is_hexadecimal()
        COMMENT "Couleur de la marque";

    DEFINE FIELD IF NOT EXISTS branding.isDarkModeEnabled ON TABLE lyxal_identity 
        TYPE bool 
        DEFAULT false
        COMMENT "Mode sombre activé/désactivé";

    DEFINE FIELD IF NOT EXISTS branding.darkPrimaryColor ON TABLE lyxal_identity 
        TYPE string 
        ASSERT $value.is_hexadecimal()
        COMMENT "Couleur de la marque en mode sombre";

    DEFINE FIELD IF NOT EXISTS branding.logo ON TABLE lyxal_identity 
        TYPE option<string>
        ASSERT $value.is_url()
        DEFAULT none
        COMMENT "url du logo de la page de connexion en mode clair";

    DEFINE FIELD IF NOT EXISTS branding.darkLogo ON TABLE lyxal_identity 
        TYPE option<string> 
        ASSERT $value.is_url()
        DEFAULT none
        COMMENT "url du logo de la page de connexion en mode sombre";

    DEFINE FIELD IF NOT EXISTS branding.favicon ON TABLE lyxal_identity 
        TYPE option<string> 
        ASSERT $value.is_url()
        DEFAULT none
        COMMENT "url du favicon de la page de connexion";

    DEFINE FIELD IF NOT EXISTS branding.darkFavicon ON TABLE lyxal_identity 
        TYPE option<string> 
        ASSERT $value.is_url()
        DEFAULT none
        COMMENT "url du favicon de la page de connexion en mode sombre";

    DEFINE FIELD IF NOT EXISTS branding.hide_lyxal_branding ON TABLE lyxal_identity 
        TYPE bool 
        DEFAULT false
        COMMENT "Masquer la marque Lyxal";

    -- Assets pour l'interface 'Bring your UI' (Remplacement total de l'UI)
    DEFINE FIELD IF NOT EXISTS branding.custom_ui_assets ON TABLE lyxal_identity 
        TYPE object 
        DEFAULT {}
        COMMENT "Référence au pack d'interface personnalisée (ZIP)";

        DEFINE FIELD IF NOT EXISTS branding.custom_ui_assets.id ON TABLE lyxal_identity 
            TYPE option<string> 
            ASSERT $value.is_url()
            DEFAULT none
            COMMENT "url du pack d'interface personnalisée";

        DEFINE FIELD IF NOT EXISTS branding.custom_ui_assets.created_at ON TABLE lyxal_identity 
            TYPE datetime
            DEFAULT 
            COMMENT "Date d'upload du pack d'interface";

    -- Contenu HTML dynamique injecté par URL
    DEFINE FIELD IF NOT EXISTS branding.custom_content ON TABLE lyxal_identity 
        TYPE object FLEXIBLE 
        DEFAULT {}
        COMMENT "Clés = Pathname de l'URL (ex: /v1/signin), Valeurs = HTML à injecter";

    -- Code CSS personnalisé pour surcharger le style par défaut
    DEFINE FIELD IF NOT EXISTS sign_in_experiences.branding.custom_css ON TABLE lyxal_identity 
        TYPE string 
        DEFAULT ""
        COMMENT "Bloc de code CSS brut injecté dans les pages du SaaS";

---- Sign In Sign Up ----

DEFINE FIELD IF NOT EXISTS sign_in_sign_up ON TABLE lyxal_identity 
    TYPE object FLEXIBLE
    DEFAULT {}
    COMMENT "Configuration de l'inscription et de la connexion";  
    
    ---- Sign In ----

    DEFINE FIELD IF NOT EXISTS sign_in_sign_up.sign_in ON TABLE lyxal_identity 
        TYPE object FLEXIBLE 
        DEFAULT {}
        COMMENT "Configuration de la connexion";

        DEFINE FIELD IF NOT EXISTS sign_in_sign_up.sign_in.methods ON TABLE lyxal_identity
            TYPE array<object> DEFAULT ALWAYS []
            COMMENT "méthodes de connexion";

            DEFINE FIELD IF NOT EXISTS sign_in_sign_up.sign_in.methods.*.identifier ON TABLE lyxal_identity
                TYPE record(sign_in_sign_up_identifier)
                COMMENT "identifiant utilisé";

            DEFINE FIELD IF NOT EXISTS sign_in_sign_up.sign_in.methods.*.password ON TABLE lyxal_identity
                TYPE bool
                COMMENT "autoriser le mot de passe";

            DEFINE FIELD IF NOT EXISTS sign_in_sign_up.sign_in.methods.*.verification_code ON TABLE lyxal_identity
                TYPE bool
                COMMENT "autoriser le code de verification";

            DEFINE FIELD IF NOT EXISTS sign_in_sign_up.sign_in.methods.*.is_password_primary ON TABLE lyxal_identity
                TYPE bool
                COMMENT "mot de passe en priorité";

    ---- Sign Up ----

    DEFINE FIELD IF NOT EXISTS sign_in_sign_up.sign_up ON TABLE lyxal_identity 
        TYPE object FLEXIBLE 
        DEFAULT {}
        COMMENT "Configuration de l'inscription";

        -- Identifiants primaires requis (Email, Username, Phone)
        DEFINE FIELD IF NOT EXISTS sign_in_sign_up.sign_up.identifiers ON TABLE lyxal_identity
            TYPE array<record(sign_in_sign_up_identifier)> 
            DEFAULT ALWAYS []
            COMMENT "Identifiants primaires requis pour créer un compte";

        -- Configuration du mot de passe à l'inscription
        DEFINE FIELD IF NOT EXISTS sign_in_sign_up.sign_up.password ON TABLE lyxal_identity
            TYPE bool
            DEFAULT true
            COMMENT "L'utilisateur doit-il définir un mot de passe à l'inscription ?";

        -- Vérification immédiate
        DEFINE FIELD IF NOT EXISTS sign_in_sign_up.sign_up.verify ON TABLE lyxal_identity
            TYPE bool
            DEFAULT false
            COMMENT "L\'utilisateur doit-il vérifier son identifiant immédiatement ?";

        -- Identifiants secondaires (ex: demander le username en plus de l'email)
        DEFINE FIELD IF NOT EXISTS sign_in_sign_up.sign_up.secondary_identifiers ON TABLE lyxal_identity
            TYPE array<object> 
            DEFAULT ALWAYS []
            COMMENT "Identifiants secondaires demandés durant l'inscription";

            DEFINE FIELD IF NOT EXISTS sign_in_sign_up.sign_up.secondary_identifiers.*.identifier ON TABLE lyxal_identity
                TYPE record(sign_in_sign_up_identifier)
                COMMENT "Type d'identifiant secondaire";

            DEFINE FIELD IF NOT EXISTS sign_in_sign_up.sign_up.secondary_identifiers.*.verify ON TABLE lyxal_identity
                TYPE bool
                DEFAULT false
                COMMENT "Cet identifiant secondaire doit-il être vérifié ?";

    ---- Forgot Paassword ----

    DEFINE FIELD IF NOT EXISTS sign_in_sign_up.forgot_password_methods ON TABLE lyxal_identity 
        TYPE array<record(forgot_password_method)> 
        DEFAULT ALWAYS []
        COMMENT "Configuration de l\'oubli du mot de passe";

    ---- Social Sign In ----

    DEFINE FIELD IF NOT EXISTS sign_in_sign_up.social_sign_in ON TABLE lyxal_identity 
        TYPE object FLEXIBLE 
        DEFAULT {}
        COMMENT "Configuration de l\'inscription via les réseaux sociaux";

        DEFINE FIELD IF NOT EXISTS sign_in_sign_up.social_sign_in.connectors ON TABLE lyxal_identity 
            TYPE array<record(connector)> 
            DEFAULT ALWAYS []
            COMMENT "Configuration des connecteurs";

        DEFINE FIELD IF NOT EXISTS sign_in_sign_up.social_sign_in.automatic_account_linking ON TABLE lyxal_identity 
            TYPE bool 
            DEFAULT false
            COMMENT "L\'utilisateur doit-il lier son compte automatiquement ?";

        DEFINE FIELD IF NOT EXISTS sign_in_sign_up.social_sign_in.skip_required_identifiers ON TABLE lyxal_identity 
            TYPE bool 
            DEFAULT false
            COMMENT "L\'utilisateur doit-il fournir les identifiants requis ?";

    ---- Options Avancées ----

    DEFINE FIELD IF NOT EXISTS sign_in_sign_up.advanced ON TABLE lyxal_identity 
        TYPE object FLEXIBLE 
        DEFAULT {}
        COMMENT "Configuration avancée de sign_in sign_up";

        DEFINE FIELD IF NOT EXISTS sign_in_sign_up.advanced.sso_enabled ON TABLE lyxal_identity 
            TYPE bool 
            DEFAULT false
            COMMENT "Activer le SSO";

        DEFINE FIELD IF NOT EXISTS sign_in_sign_up.advanced.sign_in_mode_register ON TABLE lyxal_identity 
            TYPE bool 
            DEFAULT false
            COMMENT "Active la creation de compte";

---- Account Centers -----

DEFINE FIELD IF NOT EXISTS account_centers ON TABLE lyxal_identity
    TYPE object FLEXIBLE
    DEFAULT {}
    COMMENT "Account center configuration";

    DEFINE FIELD IF NOT EXISTS account_centers.enabled ON TABLE lyxal_identity 
        TYPE bool 
        DEFAULT true
        COMMENT "Account center activé/désactivé";

    DEFINE FIELD IF NOT EXISTS account_centers.field_control ON TABLE lyxal_identity 
        TYPE object 
        DEFAULT {}
        COMMENT "Account center fields";

        --Identifiers--

        DEFINE FIELD IF NOT EXISTS account_centers.field_control.username ON TABLE lyxal_identity 
            TYPE record(account_center_control_value)
            COMMENT "Statut information username";

        DEFINE FIELD IF NOT EXISTS account_centers.field_control.email ON TABLE lyxal_identity 
            TYPE record(account_center_control_value)
            COMMENT "Statut information email";

        DEFINE FIELD IF NOT EXISTS account_centers.field_control.phone ON TABLE lyxal_identity 
            TYPE record(account_center_control_value)
            COMMENT "Statut information phone";

        DEFINE FIELD IF NOT EXISTS account_centers.field_control.social_identities ON TABLE lyxal_identity 
            TYPE record(account_center_control_value)
            COMMENT "Statut information social identities";                        

        --Authentication factors--

        DEFINE FIELD IF NOT EXISTS account_centers.field_control.password ON TABLE lyxal_identity 
            TYPE record(account_center_control_value)
            COMMENT "Statut information password";

        DEFINE FIELD IF NOT EXISTS account_centers.field_control.mfa ON TABLE lyxal_identity 
            TYPE record(account_center_control_value)
            COMMENT "Statut information mfa";

        --User profile--

        DEFINE FIELD IF NOT EXISTS account_centers.field_control.name ON TABLE lyxal_identity 
            TYPE record(account_center_control_value)
            COMMENT "Statut information name";

        DEFINE FIELD IF NOT EXISTS account_centers.field_control.avatar ON TABLE lyxal_identity 
            TYPE record(account_center_control_value)
            COMMENT "Statut information avatar";

        DEFINE FIELD IF NOT EXISTS account_centers.field_control.profile ON TABLE lyxal_identity 
            TYPE record(account_center_control_value)
            COMMENT "Statut information profile";

        DEFINE FIELD IF NOT EXISTS account_centers.field_control.custom_data ON TABLE lyxal_identity 
            TYPE record(account_center_control_value)
            COMMENT "Statut information custom data";                        

    ---- Webauthn ----
    DEFINE FIELD IF NOT EXISTS account_centers.webauthn_related_origins ON TABLE lyxal_identity
        TYPE array<string>
        DEFAULT []
        ASSERT $value.all(|$origin| string::is_url($origin))
        COMMENT "Account center webauthn relater origin";

---- Content ----

DEFINE FIELD IF NOT EXISTS content ON TABLE lyxal_identity 
    TYPE object FLEXIBLE    
    DEFAULT {}
    COMMENT "Configuration du contenu de la page de connexion";   

    ---- Language Info ----
    DEFINE FIELD IF NOT EXISTS content.language_info ON TABLE lyxal_identity 
        TYPE object FLEXIBLE 
        DEFAULT {}
        COMMENT "Configuration des langues de la page de connexion";

        DEFINE FIELD IF NOT EXISTS content.language_info.auto_detect ON TABLE lyxal_identity 
            TYPE bool 
            DEFAULT true
            COMMENT "Détection automatique de la langue";

        DEFINE FIELD IF NOT EXISTS content.language_info.default_language ON TABLE lyxal_identity 
            TYPE string 
            DEFAULT 'fr'
            COMMENT "Langue par défaut";


    DEFINE FIELD IF NOT EXISTS content.terms ON TABLE lyxal_identity 
        TYPE object FLEXIBLE 
        DEFAULT {}
        COMMENT "Configuration des termes de la page de connexion";

        DEFINE FIELD IF NOT EXISTS content.terms.terms_of_use_url ON TABLE lyxal_identity 
            TYPE option<string>
            ASSERT $value.is_url()
            DEFAULT none
            COMMENT "url des conditions d\'utilisation";

        DEFINE FIELD IF NOT EXISTS content.terms.privacy_policy_url ON TABLE lyxal_identity 
            TYPE option<string>
            ASSERT $value.is_url() 
            DEFAULT none
            COMMENT "url de la politique de confidentialité";

        DEFINE FIELD IF NOT EXISTS content.terms.agree_to_terms_policy ON TABLE lyxal_identity 
            TYPE record(agree_to_terms_policy)
            DEFAULT 'Automatic'
            COMMENT "Type d'accord aux conditions d'utilisation et à la politique de confidentialité";

    ---- Support ----
    DEFINE FIELD IF NOT EXISTS content.support ON TABLE lyxal_identity 
        TYPE object FLEXIBLE 
        DEFAULT {}
        COMMENT "Configuration du support de la page de connexion";

        DEFINE FIELD IF NOT EXISTS content.support.email ON TABLE lyxal_identity 
            TYPE option<string>
            ASSERT $value.is_email()
            DEFAULT none
            COMMENT "Adresse email du support de la page de connexion";

        DEFINE FIELD IF NOT EXISTS content.support.website_url ON TABLE lyxal_identity 
            TYPE option<string>
            ASSERT $value.is_url() 
            DEFAULT none
            COMMENT "Url du site web du support de la page de connexion";

---- Multi factor auth ----

DEFINE FIELD IF NOT EXISTS multi_factor_auth ON TABLE lyxal_identity 
    TYPE object FLEXIBLE    
    DEFAULT {}
    COMMENT "Configuration de la sécurité de la page de connexion";

    DEFINE FIELD IF NOT EXISTS multi_factor_auth.factors ON TABLE lyxal_identity
        TYPE array<record<mfa_factors>> 
        DEFAULT []
        COMMENT "Méthodes disponibles pour les utilisateurs (TOTP, SMS, etc.)";

    DEFINE FIELD IF NOT EXISTS multi_factor_auth.mfa_required ON TABLE lyxal_identity
        TYPE bool 
        DEFAULT false
        COMMENT "Exiger l'authentification multi-facteurs"; 

    -- La politique globale (ex: Obligatoire ou non)
    DEFINE FIELD IF NOT EXISTS multi_factor_auth.mfa_policy ON TABLE lyxal_identity
        TYPE record<mfa_policy>
        DEFAULT mfa_policy:NoPrompt
        COMMENT "Définit si le MFA est forcé ou optionnel pour tous";  

    DEFINE FIELD IF NOT EXISTS multi_factor_auth.adaptive_mfa_enabled ON TABLE lyxal_identity
        TYPE bool 
        DEFAULT false
        COMMENT "Activer l'authentification multi-facteurs adaptative";

---- Passkey ----

DEFINE FIELD IF NOT EXISTS passkey_sign_in ON TABLE lyxal_identity 
    TYPE object FLEXIBLE 
    DEFAULT {}
    COMMENT "Configuration de l'accès sans mot de passe via WebAuthn";

    DEFINE FIELD IF NOT EXISTS passkey_sign_in.enabled ON TABLE lyxal_identity
        TYPE bool 
        DEFAULT false;

    DEFINE FIELD IF NOT EXISTS passkey_sign_in.show_passkey_button ON TABLE lyxal_identity
        TYPE bool 
        DEFAULT false
        COMMENT "Afficher le bouton Passkey sur le formulaire";

    DEFINE FIELD IF NOT EXISTS passkey_sign_in.allow_autofill ON TABLE lyxal_identity
        TYPE bool 
        DEFAULT false
        COMMENT "Activer la détection automatique des clés par le navigateur";

---- Security ----

DEFINE FIELD IF NOT EXISTS security ON TABLE lyxal_identity 
    TYPE object FLEXIBLE    
    DEFAULT {}
    COMMENT "Configuration de la sécurité de la page de connexion"; 

    ---- Password ----

    DEFINE FIELD IF NOT EXISTS security.password_policy ON TABLE lyxal_identity 
        TYPE object FLEXIBLE    
        DEFAULT {}
        COMMENT "Configuration du password policy de la page de connexion"; 

        DEFINE FIELD IF NOT EXISTS security.password_policy.min_length ON TABLE lyxal_identity
            TYPE numbers 
            DEFAULT 8
            ASSERT $value >= 1 AND $value <= 128
            COMMENT "Longueur minimale (ex: 8, 12)";

        DEFINE FIELD IF NOT EXISTS security.password_policy.min_character_types ON TABLE lyxal_identity
            TYPE numbers 
            DEFAULT 1
            ASSERT $value >= 1 AND $value <= 4
            COMMENT "Nombre de types de caractères requis (1 à 4)";

        DEFINE FIELD IF NOT EXISTS security.password_policy.requireUppercase ON TABLE lyxal_identity
            TYPE boolean
            DEFAULT true
            COMMENT "Exiger des majuscules (A-Z)";

        DEFINE FIELD IF NOT EXISTS security.password_policy.requireLowercase ON TABLE lyxal_identity
            TYPE boolean
            DEFAULT true
            COMMENT "Exiger des minuscules (a-z)";

         DEFINE FIELD IF NOT EXISTS security.password_policy.requireNumbers ON TABLE lyxal_identity
            TYPE boolean
            DEFAULT true
            COMMENT "Exiger des chiffres (0-9)";

        DEFINE FIELD IF NOT EXISTS security.password_policy.requireSpecialCharacters ON TABLE lyxal_identity
            TYPE boolean
            DEFAULT true
            COMMENT "Exiger des caractères spéciaux (!@#$%...)";

        DEFINE FIELD IF NOT EXISTS security.password_policy.rejectBreachHistory ON TABLE lyxal_identity
            TYPE boolean
            DEFAULT true
            COMMENT "Vérifier si le mot de passe est dans une base de données piratée";

         DEFINE FIELD IF NOT EXISTS security.password_policy.rejectRepetition ON TABLE lyxal_identity
            TYPE boolean
            DEFAULT true
            COMMENT "Interdire les répétitions (ex: 'aaaaa', '123123')";

        DEFINE FIELD IF NOT EXISTS security.password_policy.rejectUserInfo ON TABLE lyxal_identity
            TYPE boolean
            DEFAULT true
            COMMENT "Interdire l'utilisation du username/email/phone dans le mdp"; 

        DEFINE FIELD IF NOT EXISTS security.password_policy.customWords ON TABLE lyxal_identity
            TYPE array<string>
            DEFAULT []
            COMMENT "Liste de mots interdits (ex: [lyxal, password, 123456])";                     

     ---- Captcha ----

    DEFINE FIELD IF NOT EXISTS security.captcha_policy ON TABLE lyxal_identity 
        TYPE object FLEXIBLE    
        DEFAULT {}
        COMMENT "Configuration du captcha policy de la page de connexion";    

        DEFINE FIELD IF NOT EXISTS security.captcha_policy.enabled ON TABLE lyxal_identity
            TYPE boolean
            DEFAULT false
            COMMENT "Activer ou désactiver globalement le captcha";

    ---- Blocklist ----

    DEFINE FIELD IF NOT EXISTS security.blocklist_policy ON TABLE lyxal_identity 
        TYPE object FLEXIBLE    
        DEFAULT {}
        COMMENT "Configuration du blocklist policy de la page de connexion"; 

        DEFINE FIELD IF NOT EXISTS security.blocklist_policy.blockDisposableAddresses ON TABLE lyxal_identity
            TYPE boolean
            DEFAULT true
            COMMENT "Bloquer les services d'emails jetables (ex: mailinator.com)";

        DEFINE FIELD IF NOT EXISTS security.blocklist_policy.blockSubaddressing ON TABLE lyxal_identity
            TYPE boolean
            DEFAULT true
            COMMENT "Bloquer l'utilisation du signe + dans les emails (ex: user+test@gmail.com)"; 

        DEFINE FIELD IF NOT EXISTS security.blocklist_policy.customBlocklist ON TABLE lyxal_identity
            TYPE array<string>
            DEFAULT []
            COMMENT "Liste personnalisée d'emails ou de domaines bloqués (ex: ["@spam.com", "bad@user.io"])";        

    ---- Sentinel ----

    DEFINE FIELD IF NOT EXISTS security.sentinel_policy ON TABLE lyxal_identity 
        TYPE object FLEXIBLE    
        DEFAULT {}
        COMMENT "Configuration du sentinel policy de la page de connexion"; 

        DEFINE FIELD IF NOT EXISTS security.sentinel_policy.identifier_lockout_enabled ON TABLE lyxal_identity
            TYPE boolean
            DEFAULT true
            COMMENT "Bloquer un identifiant";

        DEFINE FIELD IF NOT EXISTS security.sentinel_policy.maxAttempts ON TABLE lyxal_identity
            TYPE numbers
            DEFAULT 100
            COMMENT "Nombre maximum de tentatives échouées autorisées en une heure avant de bloquer l'identifiant"; 

        DEFINE FIELD IF NOT EXISTS security.sentinel_policy.lockoutDuration ON TABLE lyxal_identity
            TYPE numbers
            DEFAULT 60
            COMMENT "Durée du blocage en minutes après avoir dépassé le maximum d'échecs";


---- Metadonnées diverses ----

-- Table sign_in_experiences (Structure complète Logto)
DEFINE TABLE sign_in_experiences SCHEMAFULL;

-- Relations
DEFINE FIELD application ON TABLE sign_in_experiences TYPE record<applications>;

-- Visuel & Branding
DEFINE FIELD branding ON TABLE sign_in_experiences TYPE object 
    ASSERT $value.logoUrl == NONE OR string::is_url($value.logoUrl)
    AND $value.darkLogoUrl == NONE OR string::is_url($value.darkLogoUrl)
    AND $value.favicon == NONE OR string::is_url($value.favicon)
    AND $value.darkFavicon == NONE OR string::is_url($value.darkFavicon);

DEFINE FIELD color ON TABLE sign_in_experiences TYPE object
    ASSERT $value.primaryColor =~ /^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$/
    AND $value.darkPrimaryColor =~ /^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$/;

DEFINE FIELD hide_logto_branding ON TABLE sign_in_experiences TYPE bool DEFAULT false;
DEFINE FIELD language_info ON TABLE sign_in_experiences TYPE object
    ASSERT $value.autoDetect != NONE AND $value.fallbackLanguage != NONE;

-- Légal & Support
DEFINE FIELD terms_of_use_url ON TABLE sign_in_experiences TYPE option<string> 
    ASSERT $value == NONE OR string::is_url($value);
DEFINE FIELD privacy_policy_url ON TABLE sign_in_experiences TYPE option<string> 
    ASSERT $value == NONE OR string::is_url($value);
DEFINE FIELD support_email ON TABLE sign_in_experiences TYPE option<string>;
DEFINE FIELD support_website_url ON TABLE sign_in_experiences TYPE option<string> 
    ASSERT $value == NONE OR string::is_url($value);
DEFINE FIELD agree_to_terms_policy ON TABLE sign_in_experiences TYPE string DEFAULT 'Automatic' 
    ASSERT $value IN ['Automatic', 'ManualRegistrationOnly', 'Manual'];

-- Structure SIGN_IN (Moteur de connexion)
-- Correspond à l'interface TypeScript SignIn { methods: [...] }
DEFINE FIELD sign_in ON TABLE sign_in_experiences TYPE object
    ASSERT $value.methods != NONE AND type::is::array($value.methods)
    -- Chaque méthode doit avoir un identifiant, password, verificationCode, etc.
    ASSERT ALL($m IN $value.methods, 
        $m.identifier IN ['username', 'email', 'phone'] 
        AND type::is::bool($m.password) 
        AND type::is::bool($m.verificationCode)
    );

-- Structure SIGN_UP (Moteur d'inscription)
-- Correspond à l'interface TypeScript SignUp { identifiers: [...], password, verify, etc. }
DEFINE FIELD sign_up ON TABLE sign_in_experiences TYPE object
    ASSERT type::is::array($value.identifiers)
    AND type::is::bool($value.password)
    AND type::is::bool($value.verify);

-- Autres configurations
DEFINE FIELD social_sign_in ON TABLE sign_in_experiences TYPE object DEFAULT {};
DEFINE FIELD social_sign_in_connector_targets ON TABLE sign_in_experiences TYPE array DEFAULT [];
DEFINE FIELD sign_in_mode ON TABLE sign_in_experiences TYPE string DEFAULT 'SignInAndRegister' 
    ASSERT $value IN ['SignIn', 'Register', 'SignInAndRegister'];

-- Sécurité & MFA
DEFINE FIELD password_policy ON TABLE sign_in_experiences TYPE object DEFAULT {};
DEFINE FIELD mfa ON TABLE sign_in_experiences TYPE object DEFAULT {
    factors: [],
    policy: 'NoPrompt'
};
DEFINE FIELD adaptive_mfa ON TABLE sign_in_experiences TYPE object DEFAULT { enabled: false };
DEFINE FIELD captcha_policy ON TABLE sign_in_experiences TYPE object DEFAULT { enabled: false };
DEFINE FIELD passkey_sign_in ON TABLE sign_in_experiences TYPE object DEFAULT { enabled: false };

-- Redirections & Customization
DEFINE FIELD unknown_session_redirect_url ON TABLE sign_in_experiences TYPE option<string> 
    ASSERT $value == NONE OR string::is_url($value);
DEFINE FIELD custom_css ON TABLE sign_in_experiences TYPE option<string>;
DEFINE FIELD custom_content ON TABLE sign_in_experiences TYPE object DEFAULT {};

-- Timestamps
DEFINE FIELD created_at ON TABLE sign_in_experiences TYPE datetime DEFAULT time::now();
DEFINE FIELD updated_at ON TABLE sign_in_experiences TYPE datetime DEFAULT time::now();

DEFINE INDEX idx_exp_app ON TABLE sign_in_experiences COLUMNS application UNIQUE;

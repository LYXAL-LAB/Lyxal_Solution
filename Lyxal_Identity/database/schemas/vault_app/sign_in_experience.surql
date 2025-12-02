-- ============================================================
-- TABLE: sign_in_experience (PERSONNALISATION LOGIN)
-- Namespace: NS_APP_{UUID} (Vault App)
-- ============================================================

DEFINE IF NOT EXISTS TABLE sign_in_experience TYPE NORMAL SCHEMAFULL
COMMENT "Configuration de l'expérience de connexion (Branding, CSS, CGU)"
PERMISSIONS 
FOR SELECT, CREATE, UPDATE, DELETE NONE;

-- CHAMPS

DEFINE FIELD IF NOT EXISTS color ON TABLE sign_in_experience 
    TYPE object
    DEFAULT {}
    COMMENT "Palette de couleurs (PartialColor)";

DEFINE FIELD IF NOT EXISTS branding ON TABLE sign_in_experience 
    TYPE object
    DEFAULT {}
    COMMENT "Configuration Branding (Logo, Dark Mode...)";

DEFINE FIELD IF NOT EXISTS custom_css ON TABLE sign_in_experience 
    TYPE option<string>
    COMMENT "CSS personnalisé injecté dans la page de login";

DEFINE FIELD IF NOT EXISTS terms_of_use_url ON TABLE sign_in_experience 
    TYPE option<string>
    COMMENT "URL des Conditions Générales d'Utilisation";

DEFINE FIELD IF NOT EXISTS privacy_policy_url ON TABLE sign_in_experience 
    TYPE option<string>
    COMMENT "URL de la Politique de Confidentialité";

DEFINE FIELD IF NOT EXISTS display_name ON TABLE sign_in_experience 
    TYPE option<string>
    COMMENT "Nom affiché sur la page de login (si différent du nom de l'app)";

DEFINE FIELD IF NOT EXISTS updated_at ON TABLE sign_in_experience 
    TYPE datetime 
    DEFAULT ALWAYS time::now()
    READONLY;

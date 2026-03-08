---- Table des valeur mfa policy ----

DEFINE TABLE IF NOT EXISTS mfa_policy
    SCHEMAFULL
    TYPE NORMAL
    PERMISSIONS NONE
    COMMENT "MFA policy";

---- Fields de la table ----

DEFINE FIELD IF NOT EXISTS name ON TABLE mfa_policy 
    TYPE string 
    COMMENT "Nom de valeur";

DEFINE FIELD IF NOT EXISTS description ON TABLE mfa_policy 
    TYPE string 
    COMMENT "Description de valeur";

DEFINE FIELD IF NOT EXISTS is_enabled ON TABLE mfa_policy 
    TYPE bool 
    DEFAULT true
    COMMENT "Indique si le facteur MFA est activé";

---- Index de la table ----

DEFINE INDEX idx_name ON TABLE mfa_policy 
    FIELDS name 
    UNIQUE
    COMMENT "Index unique sur le nom";

---- Valeurs des seeds ----
CREATE mfa_policy:UserControlled CONTENT {
	name: 'User Controlled',
    description: 'User controlled',
    is_enabled: true,
};

CREATE mfa_policy:Mandatory CONTENT {
	name: 'Mandatory',
    description: 'Mandatory',
    is_enabled: true,
};

CREATE mfa_policy:PromptOnlyAtSignIn CONTENT {
	name: 'Prompt Only At SignIn',
    description: 'Prompt only at sign in',
    is_enabled: true,
};

CREATE mfa_policy:PromptAtSignInAndSignUp CONTENT {
	name: 'Prompt At SignIn And SignUp',
    description: 'Prompt at sign in and sign up',
    is_enabled: true,
};

CREATE mfa_policy:NoPrompt CONTENT {
	name: 'No Prompt',
    description: 'No prompt',
    is_enabled: true,
};
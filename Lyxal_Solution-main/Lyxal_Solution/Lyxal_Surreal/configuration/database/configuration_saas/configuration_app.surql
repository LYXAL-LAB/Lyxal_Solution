DEFINE TABLE IF NOT EXISTS app_configuration SCHEMAFULL
TYPE NORMAL
COMMENT "Configuration de l'application"
PERMISSIONS
    FOR SELECT WHERE $auth.role CONTAINS 'admin',
    FOR CREATE, UPDATE WHERE $auth.role CONTAINS 'admin',
    FOR DELETE WHERE $auth.role CONTAINS 'admin';

DEFINE FIELD langue_default ON configuration_app 
TYPE record<i18n_language>
REFERENCE ON DELETE REJECT
DEFAULT i18n_language:FR
COMMENT "Langue par défaut de l'application";
-- ============================================================================
-- Lyxal Bridge — Airtable Provider
-- Fichier : datafunction/fn_bridge_airtable_auth.surql
-- 
-- Helper Auth (réutilisé par chaque opération)
-- ============================================================================

DEFINE FUNCTION fn::bridge::airtable::auth() {

    -- 1. Récupérer les credentials
    LET $creds = (SELECT * FROM bridge_user_credentials 
                  WHERE provider = bridge_providers:airtable)[0];
    IF $creds == NONE { 
        THROW "Aucun credential configuré pour Airtable. Créez un record dans bridge_user_credentials." 
    };
    RETURN $creds.encrypted_data;
};

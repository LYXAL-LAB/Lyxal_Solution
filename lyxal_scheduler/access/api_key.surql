-- Access pour les clés API (PAT - Personal Access Tokens)
DEFINE ACCESS IF NOT EXISTS api_key ON DATABASE TYPE BEARER FOR RECORD
    AUTHENTICATE {
        LET $key = SELECT * FROM scheduler_api_key WHERE token_hash = crypto::sha256($auth) AND is_active = true;
        IF array::len($key) > 0 AND ($key[0].expires_at == NONE OR $key[0].expires_at > time::now()) {
            RETURN true;
        } ELSE {
            RETURN false;
        };
    }
    COMMENT "Accès sécurisé pour les applications clientes via Clés API / Personal Access Tokens";

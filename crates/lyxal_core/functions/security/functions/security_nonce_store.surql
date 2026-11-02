-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/security/functions/security_nonce_store.surql
-- Fonction : fn::security_nonce_store
--
-- Construit une entrée de stockage de nonce sans conserver le nonce brut.
--
-- Paramètres
--   $nonce     : string
--   $subject   : string
--   $issued_at : datetime
--   $ttl       : duration
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions security)
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : string::len(string::trim($nonce)) < 16
--   CORE_INVALID_ARGUMENT : $ttl <= 0s
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::security_nonce_store(
    $nonce: string,
    $subject: string,
    $issued_at: datetime,
    $ttl: duration
) -> object {
    IF string::len(string::trim($nonce)) < 16 {
        THROW "CORE_INVALID_ARGUMENT";
    };

    IF $ttl <= 0s {
        THROW "CORE_INVALID_ARGUMENT";
    };

    RETURN {
        nonce_hash:crypto::sha256(string::trim($nonce)),
        subject:string::trim($subject),
        issued_at:$issued_at,
        expires_at:$issued_at+$ttl,
        consumed:false
    };
}
COMMENT "Construit une entrée de stockage de nonce sans conserver le nonce brut."
PERMISSIONS FULL;

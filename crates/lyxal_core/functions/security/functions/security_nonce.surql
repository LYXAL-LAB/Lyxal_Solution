-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/security/functions/security_nonce.surql
-- Fonction : fn::security_nonce
--
-- Génère un nonce aléatoire alphanumérique de 16 à 128 caractères (rand::id
-- ; sûr sauf si le serveur est démarré avec SURREAL_RAND_SEED). Pour du
-- matériel cryptographique, utiliser lyxal_crypto.
--
-- Paramètres
--   $length : int
--
-- Valeur renvoyée : string (contrat : crates/lyxal_core/Readme.md, fonctions security)
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : $length < 16 OR $length > 128
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::security_nonce(
    $length: int
) -> string {
    IF $length < 16 OR $length > 128 { THROW "CORE_INVALID_ARGUMENT"; };
    RETURN rand::id($length);
}
COMMENT "Génère un nonce aléatoire alphanumérique de 16 à 128 caractères (rand::id ; sûr sauf si le serveur est démarré avec SURREAL_RAND_SEED). Pour du matériel cryptographique, utiliser lyxal_crypto."
PERMISSIONS FULL;

-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/security/functions/secret_generate.surql
-- Fonction : fn::security_secret_generate
--
-- Génère un secret alphanumérique à partir de rand::id. En SurrealDB 3.3,
-- rand::id tire ses caractères de rand::rng() (ChaCha12 réensemencé par le
-- système) : générateur cryptographiquement sûr, SAUF si le serveur est
-- démarré avec SURREAL_RAND_SEED (mode déterministe réservé aux tests et
-- benchmarks), qui rend les secrets prévisibles. Pour des clés binaires ou
-- du matériel cryptographique, utiliser lyxal_crypto (Rust, OsRng).
--
-- Paramètres
--   $length : int
--   $prefix : option<string>
--
-- Valeur renvoyée : string (contrat : crates/lyxal_core/Readme.md, fonctions security)
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : $length < 24 OR $length > 256
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::security_secret_generate(
    $length: int,
    $prefix: option<string>
) -> string {
    IF $length < 24 OR $length > 256 {
        THROW "CORE_INVALID_ARGUMENT";
    };

    LET $secret = rand::id($length);

    RETURN IF $prefix IS NONE OR string::trim($prefix) = "" {
        $secret
    } ELSE {
        string::concat(string::trim($prefix), "_", $secret)
    };
}
COMMENT "Génère un secret alphanumérique à partir de rand::id. En SurrealDB 3.3, rand::id tire ses caractères de rand::rng() (ChaCha12 réensemencé par le système) : générateur cryptographiquement sûr, SAUF si le serveur est démarré avec SURREAL_RAND_SEED (mode déterministe réservé aux tests et benchmarks), qui rend les secrets prévisibles. Pour des clés binaires ou du matériel cryptographique, utiliser lyxal_crypto (Rust, OsRng)."
PERMISSIONS FULL;

-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/security/functions/hash_fingerprint.surql
-- Fonction : fn::security_hash_fingerprint
--
-- Formate une empreinte en groupes lisibles.
--
-- Paramètres
--   $hash       : string
--   $group_size : int
--   $separator  : string
--
-- Valeur renvoyée : string (contrat : crates/lyxal_core/Readme.md, fonctions security)
--
-- Erreurs de programmation (THROW)
--   CORE_INVALID_ARGUMENT : $group_size < 1
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::security_hash_fingerprint(
    $hash: string,
    $group_size: int,
    $separator: string
) -> string {
    IF $group_size < 1 {
        THROW "CORE_INVALID_ARGUMENT";
    };

    LET $groups = array::map(
        array::range(0, (string::len($hash) + $group_size - 1) / $group_size),
        |$index| string::slice(
            $hash,
            $index * $group_size,
            ($index + 1) * $group_size
        )
    );

    RETURN array::join($groups, $separator);
}
COMMENT "Formate une empreinte en groupes lisibles."
PERMISSIONS FULL;

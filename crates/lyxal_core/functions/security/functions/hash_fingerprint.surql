-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fonction : fn::security_hash_fingerprint
-- Version  : 1.0.0
-- Statut   : Stable
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::security_hash_fingerprint(
    $hash: string,
    $group_size: int,
    $separator: string
) -> string {
    IF $group_size < 1 {
        THROW "SECURITY_INVALID_FINGERPRINT_GROUP_SIZE";
    };

    LET $groups = array::map(
        array::range(0, math::ceil(string::len($hash) / $group_size)),
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

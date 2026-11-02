-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/security/functions/audit_verify.surql
-- Fonction : fn::security_audit_verify
--
-- Vérifie une chaîne d'entrées d'audit : pour chaque entrée, lien vers
-- l'empreinte précédente et empreinte recalculée (même représentation que
-- fn::security_audit_entry). valid = toutes les entrées sont intactes.
--
-- Paramètres
--   $entries : array<object>
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions security)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::security_audit_verify(
    $entries: array<object>
) -> object {
    LET $results = array::map(
        $entries,
        |$entry,$index| {
            LET $expected_previous = IF $index=0 {
                NONE
            } ELSE {
                $entries[$index-1].entry_hash
            };

            LET $payload = <string> $entry.event;
            LET $expected_hash = crypto::sha256(
                string::concat(
                    IF $expected_previous IS NONE{""}ELSE{$expected_previous},
                    ":",
                    $payload
                )
            );

            {
                index:$index,
                valid_previous:$entry.previous_hash=$expected_previous,
                valid_hash:$entry.entry_hash=$expected_hash
            }
        }
    );

    RETURN {
        valid:array::all(
            $results,
            |$result|$result.valid_previous AND $result.valid_hash
        ),
        results:$results
    };
}
COMMENT "Vérifie une chaîne d'entrées d'audit : pour chaque entrée, lien vers l'empreinte précédente et empreinte recalculée (même représentation que fn::security_audit_entry). valid = toutes les entrées sont intactes."
PERMISSIONS FULL;

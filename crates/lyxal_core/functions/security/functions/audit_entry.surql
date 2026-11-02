-- ============================================================================
-- LYXAL OS — CORE SECURITY
-- ============================================================================
-- Fichier  : crates/lyxal_core/functions/security/functions/audit_entry.surql
-- Fonction : fn::security_audit_entry
--
-- Construit une entrée du journal d'audit chaînée : empreinte SHA-256 de «
-- <empreinte précédente>:<événement> », l'événement étant pris dans sa
-- représentation SurrealQL (types conservés). created_at = heure courante,
-- hors empreinte.
--
-- Paramètres
--   $event         : object
--   $previous_hash : option<string>
--
-- Valeur renvoyée : object (contrat : crates/lyxal_core/Readme.md, fonctions security)
-- ============================================================================
DEFINE FUNCTION OVERWRITE fn::security_audit_entry(
    $event: object,
    $previous_hash: option<string>
) -> object {
    LET $payload = <string> $event;
    LET $chain_input = string::concat(
        IF $previous_hash IS NONE{""}ELSE{$previous_hash},
        ":",
        $payload
    );

    RETURN {
        event:$event,
        previous_hash:$previous_hash,
        entry_hash:crypto::sha256($chain_input),
        created_at:time::now()
    };
}
COMMENT "Construit une entrée du journal d'audit chaînée : empreinte SHA-256 de « <empreinte précédente>:<événement> », l'événement étant pris dans sa représentation SurrealQL (types conservés). created_at = heure courante, hors empreinte."
PERMISSIONS FULL;

-- ============================================================================
-- EVENTS : lyxal_infra
-- MODULE : lyxal_infra
-- RÔLE   : Publication des événements infra.* (fn::event_publish vérifié)
-- ============================================================================
-- Publiés par la base dans la transaction de la mutation (.agents/AGENTS.md §5.6.1) ; une
-- publication refusée fait échouer la mutation. Charges sans nom de domaine, sans adresse, sans
-- valeur : identifiants opaques et codes seulement (décision I12). lyxal_infra ne connaît aucun
-- consommateur.

-- ----------------------------------------------------------------------------
-- infra.record.published, infra.record.conflict, infra.record.failed
-- ----------------------------------------------------------------------------

DEFINE EVENT OVERWRITE infra_record_state_event ON TABLE infra_record
WHEN $event = "UPDATE" AND $before.state != $after.state AND $after.state IN ["published", "conflict", "failed"]
THEN {
    LET $published = fn::event_publish({
        event_id: rand::uuid::v7(),
        event_type: "infra.record." + $after.state,
        producer: "lyxal_infra",
        source: $after.id,
        payload: {
            record: <string> $after.id,
            owner: $after.owner,
            subject: $after.subject,
            zone: IF $after.zone IS NONE { NONE } ELSE { <string> $after.zone },
            reason: $after.conflict.reason,
            code: $after.error.code
        },
        metadata: {}
    });
    IF !$published.ok { THROW $published.error.code; };
};

-- ----------------------------------------------------------------------------
-- infra.zone.blocked (zone bloquée, non rattachée ou en échec)
-- ----------------------------------------------------------------------------

DEFINE EVENT OVERWRITE infra_zone_state_event ON TABLE infra_zone
WHEN $event = "UPDATE" AND $before.state != $after.state AND $after.state IN ["blocked", "not_delegated", "failing"]
THEN {
    LET $published = fn::event_publish({
        event_id: rand::uuid::v7(),
        event_type: "infra.zone.blocked",
        producer: "lyxal_infra",
        source: $after.id,
        payload: {
            zone: <string> $after.id,
            state: $after.state,
            code: $after.last_error.code,
            deletions: $after.last_plan.deletions
        },
        metadata: {}
    });
    IF !$published.ok { THROW $published.error.code; };
};

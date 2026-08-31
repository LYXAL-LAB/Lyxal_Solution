-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::scheduler::alert_override_delete_expired                           │
-- │  Purge les surcharges de règles d'alerte dont la date expires_at        │
-- │  est dépassée (balayage par le Watchdog).                               │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION IF NOT EXISTS fn::scheduler::alert_override_delete_expired(
    $now: datetime
) {
    LET $deleted = (
        DELETE scheduler_alert_override
        WHERE expires_at != NONE AND expires_at <= $now
        RETURN BEFORE
    );

    -- Renvoie la liste des noms de règles dont les surcharges ont été purgées
    RETURN SELECT VALUE id FROM $deleted;
};

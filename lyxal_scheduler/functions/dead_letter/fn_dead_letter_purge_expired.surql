-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::scheduler::dead_letter_purge_expired                               │
-- │  Purge automatique des dead letters expirées par le Watchdog.          │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION IF NOT EXISTS fn::scheduler::dead_letter_purge_expired(
    $now: datetime
) {
    LET $deleted = (
        DELETE scheduler_dead_letter
        WHERE expires_at != NONE AND expires_at <= $now
    );

    RETURN array::len($deleted);
};

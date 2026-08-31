-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::scheduler::log_read                                                │
-- │  Lit les logs d'une exécution triés par horodatage et séquence.         │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION IF NOT EXISTS fn::scheduler::log_read(
    $execution_id: string,
    $limit: int
) {
    LET $e_id = type::record('scheduler_execution', $execution_id);

    RETURN SELECT * FROM scheduler_execution_log
        WHERE execution_id = $e_id
        ORDER BY timestamp ASC, seq ASC
        LIMIT $limit;
};

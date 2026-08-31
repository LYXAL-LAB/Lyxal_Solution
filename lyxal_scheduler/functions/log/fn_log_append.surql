-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::scheduler::log_append                                              │
-- │  Ajoute une ligne de log d'exécution.                                   │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION IF NOT EXISTS fn::scheduler::log_append(
    $id: string,
    $execution_id: string,
    $timestamp: datetime,
    $level: string,
    $message: string,
    $fields: object,
    $seq: int
) {
    LET $l_id = type::record('scheduler_execution_log', $id);
    LET $e_id = type::record('scheduler_execution', $execution_id);

    RETURN (
        CREATE $l_id SET
            execution_id = $e_id,
            timestamp    = $timestamp,
            level        = $level,
            message      = $message,
            fields       = $fields,
            seq          = $seq
    )[0];
};

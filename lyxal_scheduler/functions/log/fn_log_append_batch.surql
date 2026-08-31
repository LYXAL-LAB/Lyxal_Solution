-- fn::scheduler::log_append_batch
-- Transaction atomique : insère un lot complet de logs avec séquence monotone

DEFINE FUNCTION IF NOT EXISTS fn::scheduler::log_append_batch(
    $execution_id: string,
    $entries: array<object>
) {
    LET $e_id = type::record('scheduler_execution', $execution_id);

    LET $max_seq_res = (
        SELECT seq FROM scheduler_execution_log
        WHERE execution_id = $e_id
        ORDER BY seq DESC
        LIMIT 1
    );

    LET $current_seq = IF array::len($max_seq_res) > 0 THEN $max_seq_res[0].seq ELSE 0 END;

    LET $next_seq = $current_seq;

    FOR $entry IN $entries {
        LET $next_seq = $next_seq + 1;
        LET $l_id = type::record('scheduler_execution_log', $entry.id);

        CREATE $l_id SET
            execution_id = $e_id,
            timestamp    = IF $entry.timestamp != NONE THEN $entry.timestamp ELSE time::now() END,
            level        = IF $entry.level != NONE THEN $entry.level ELSE 'info' END,
            message      = $entry.message,
            fields       = IF $entry.fields != NONE THEN $entry.fields ELSE {} END,
            seq          = $next_seq;
    };

    RETURN $next_seq;
};

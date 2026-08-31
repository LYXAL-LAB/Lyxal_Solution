-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::scheduler::job_def_create                                          │
-- │  Crée ou met à jour la définition de configuration d'un job.           │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION IF NOT EXISTS fn::scheduler::job_def_create(
    $job_key: string,
    $description: option<string>,
    $assigned_runner_id: option<string>,
    $is_active: bool,
    $metadata: object,
    $tags: array<string>,
    $timeout: option<string>,
    $max_retries: option<int>,
    $dead_letter_enabled: option<bool>,
    $dead_letter_retention: option<string>,
    $dead_letter_operator_hint: option<string>,
    $dead_letter_replay_max_age: option<string>
) {
    LET $id = type::record('scheduler_job_definition', $job_key);
    LET $runner = IF $assigned_runner_id != NONE THEN type::record('scheduler_runner', $assigned_runner_id) ELSE NONE END;

    RETURN (
        UPSERT $id SET
            description                = $description,
            assigned_runner_id         = $runner,
            is_active                  = $is_active,
            metadata                   = $metadata,
            tags                       = $tags,
            timeout                    = $timeout,
            max_retries                = $max_retries,
            dead_letter_enabled        = $dead_letter_enabled,
            dead_letter_retention      = $dead_letter_retention,
            dead_letter_operator_hint  = $dead_letter_operator_hint,
            dead_letter_replay_max_age = $dead_letter_replay_max_age,
            updated_at                 = time::now()
    )[0];
};

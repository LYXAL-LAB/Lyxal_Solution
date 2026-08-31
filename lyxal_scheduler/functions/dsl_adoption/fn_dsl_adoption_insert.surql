-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::scheduler::dsl_adoption_insert                                     │
-- │  Insère un enregistrement d'adoption DSL.                              │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION IF NOT EXISTS fn::scheduler::dsl_adoption_insert(
    $resource_type: string,
    $resource_key: string,
    $adopted_by: option<string>
) {
    RETURN (
        UPSERT scheduler_dsl_adoption SET
            resource_type = $resource_type,
            resource_key  = $resource_key,
            adopted_at    = time::now(),
            adopted_by    = $adopted_by
        WHERE resource_type = $resource_type
          AND resource_key  = $resource_key
    )[0];
};

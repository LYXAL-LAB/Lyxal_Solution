-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::scheduler::dsl_adoption_delete                                     │
-- │  Supprime un enregistrement d'adoption DSL.                            │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION IF NOT EXISTS fn::scheduler::dsl_adoption_delete(
    $resource_type: string,
    $resource_key: string
) {
    LET $deleted = (
        DELETE scheduler_dsl_adoption
        WHERE resource_type = $resource_type
          AND resource_key  = $resource_key
    );

    RETURN array::len($deleted) > 0;
};

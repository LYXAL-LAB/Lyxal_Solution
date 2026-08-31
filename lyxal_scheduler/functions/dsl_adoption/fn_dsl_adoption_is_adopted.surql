-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::scheduler::dsl_adoption_is_adopted                                 │
-- │  Vérifie si une ressource DSL a été adoptée par l'API.                  │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION IF NOT EXISTS fn::scheduler::dsl_adoption_is_adopted(
    $resource_type: string,
    $resource_key: string
) {
    LET $found = (
        SELECT count() AS total FROM scheduler_dsl_adoption
        WHERE resource_type = $resource_type
          AND resource_key  = $resource_key
        GROUP ALL
    );

    RETURN IF array::len($found) > 0 THEN $found[0].total > 0 ELSE false END;
};

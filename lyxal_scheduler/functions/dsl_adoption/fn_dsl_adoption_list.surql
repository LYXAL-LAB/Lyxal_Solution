-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::scheduler::dsl_adoption_list                                       │
-- │  Liste les adoptions DSL pour un type de ressource donné.              │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION IF NOT EXISTS fn::scheduler::dsl_adoption_list(
    $resource_type: string
) {
    RETURN SELECT * FROM scheduler_dsl_adoption
        WHERE resource_type = $resource_type
        ORDER BY adopted_at DESC;
};

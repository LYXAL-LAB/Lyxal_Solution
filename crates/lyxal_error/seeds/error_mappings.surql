-- ============================================================================
-- SEEDS : Mappings externes initiaux de démonstration
-- MODULE : lyxal_error
-- CONFORMITÉ : .agents/AGENTS.md & SurrealDB 3.2.0 (Idempotent)
-- ============================================================================

LET $existing_400 = (SELECT VALUE id FROM error_external_mapping 
    WHERE provider = "http" AND service = "gateway" AND external_code = "400" AND matcher = "exact" LIMIT 1);

IF array::len($existing_400) == 0 THEN (
    CREATE error_external_mapping:http_gateway_400_exact CONTENT {
        provider: "http",
        service: "gateway",
        external_code: "400",
        matcher: "exact",
        definition: (SELECT VALUE id FROM error_definition WHERE code = "ERROR_PARAM_REQUIRED")[0],
        priority: 100,
        enabled: true,
        description: "Mapping HTTP 400 Bad Request vers ERROR_PARAM_REQUIRED"
    }
) END;

LET $existing_404 = (SELECT VALUE id FROM error_external_mapping 
    WHERE provider = "http" AND service = "gateway" AND external_code = "404" AND matcher = "exact" LIMIT 1);

IF array::len($existing_404) == 0 THEN (
    CREATE error_external_mapping:http_gateway_404_exact CONTENT {
        provider: "http",
        service: "gateway",
        external_code: "404",
        matcher: "exact",
        definition: (SELECT VALUE id FROM error_definition WHERE code = "ERROR_DEFINITION_NOT_FOUND")[0],
        priority: 100,
        enabled: true,
        description: "Mapping HTTP 404 Not Found vers ERROR_DEFINITION_NOT_FOUND"
    }
) END;

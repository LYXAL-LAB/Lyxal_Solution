-- ============================================================================
-- SEEDS : Mappings externes initiaux de démonstration
-- MODULE : lyxal_error
-- ============================================================================

CREATE error_external_mapping CONTENT {
    provider: "http",
    service: "gateway",
    external_code: "400",
    matcher: "exact",
    definition: (SELECT VALUE id FROM error_definition WHERE code = "ERROR_PARAM_REQUIRED")[0],
    priority: 100,
    enabled: true,
    description: "Mapping HTTP 400 Bad Request vers ERROR_PARAM_REQUIRED"
};

CREATE error_external_mapping CONTENT {
    provider: "http",
    service: "gateway",
    external_code: "404",
    matcher: "exact",
    definition: (SELECT VALUE id FROM error_definition WHERE code = "ERROR_DEFINITION_NOT_FOUND")[0],
    priority: 100,
    enabled: true,
    description: "Mapping HTTP 404 Not Found vers ERROR_DEFINITION_NOT_FOUND"
};

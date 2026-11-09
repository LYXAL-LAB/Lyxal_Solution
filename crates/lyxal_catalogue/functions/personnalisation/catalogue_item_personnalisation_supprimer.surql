-- ============================================================================
-- FONCTION : fn::catalogue_item_personnalisation_supprimer
-- MODULE   : lyxal_catalogue
-- RÔLE     : Suppression de la personnalisation d'un article maître par le locataire de la
--            session : l'article revient au libellé et à la disponibilité du référentiel
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::catalogue_item_personnalisation_supprimer($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            item_id: { pipeline: [{ rule: "record", options: { expected_table: "catalogue_item" } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 10);
    IF !$report.valid {
        RETURN fn::error_result("CATALOGUE_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $caller_tenant = fn::catalogue_caller({}).tenant;

    -- Seule la personnalisation du locataire de la session est visible (permissions de la table)
    LET $existing = (SELECT VALUE id FROM ONLY catalogue_item_personnalisation WHERE item = $p.item_id AND tenant = $caller_tenant LIMIT 1);
    IF $existing == NONE {
        RETURN fn::error_result("CATALOGUE_PERSONNALISATION_NOT_FOUND", $p.language, { item_id: <string> $p.item_id });
    };
    LET $deleted = (DELETE ONLY $existing RETURN BEFORE);
    IF $deleted == NONE {
        RETURN fn::error_result("CATALOGUE_WRITE_FORBIDDEN", $p.language, { table: "catalogue_item_personnalisation" });
    };
    RETURN fn::result_ok(true);
} COMMENT "Supprime la personnalisation d'un article maître du locataire de la session (retour au référentiel) ; CATALOGUE_PERSONNALISATION_NOT_FOUND s'il n'en a pas";

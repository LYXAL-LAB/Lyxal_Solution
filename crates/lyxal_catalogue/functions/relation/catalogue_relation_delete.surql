-- ============================================================================
-- FONCTION : fn::catalogue_relation_delete
-- MODULE   : lyxal_catalogue
-- RÔLE     : Suppression d'une relation transversale
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::catalogue_relation_delete($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            id: { pipeline: [{ rule: "record", options: { expected_table: "catalogue_relation" } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 40);
    IF !$report.valid {
        RETURN fn::error_result("CATALOGUE_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $relation_id = $p.id;
    LET $language = $p.language;

    LET $rel = (SELECT * FROM ONLY $relation_id);
    IF $rel == NONE {
        RETURN fn::error_result("CATALOGUE_RELATION_NOT_FOUND", $language, { id: <string> $relation_id });
    };

    -- Si bidirectionnelle, suppression de la réciproque
    LET $rel_type = (SELECT * FROM ONLY $rel.relation_type);
    IF $rel_type != NONE AND $rel_type.is_bidirectionnelle == true {
        DELETE catalogue_relation WHERE source = $rel.cible AND cible = $rel.source AND relation_type = $rel.relation_type;
    };

    DELETE ONLY $relation_id;

    RETURN fn::result_ok({ id: <string> $relation_id, deleted: true });
} COMMENT "Supprime une relation entre deux éléments";

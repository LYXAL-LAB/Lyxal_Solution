-- ============================================================================
-- FONCTION : fn::catalogue_composition_publish
-- MODULE   : lyxal_catalogue
-- RÔLE     : Publication et verrouillage irréversible d'une composition
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::catalogue_composition_publish($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            composition_id: { pipeline: [{ rule: "record", options: { expected_table: "catalogue_composition" } }], required: true },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 40);
    IF !$report.valid {
        RETURN fn::error_result("CATALOGUE_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = $report.value;
    LET $comp_id = $p.composition_id;
    LET $language = $p.language;

    -- 1. Contrôle d'existence
    LET $comp = (SELECT * FROM ONLY $comp_id);
    IF $comp = NONE {
        RETURN fn::error_result("CATALOGUE_COMPOSITION_NOT_FOUND", $language, { id: <string> $comp_id });
    };

    -- 2. Contrôle du statut
    IF $comp.statut != "DRAFT" {
        RETURN fn::error_result("CATALOGUE_COMPOSITION_NOT_DRAFT", $language, { statut: $comp.statut });
    };

    -- 3. Contrôle de présence de lignes
    LET $lignes_count = count(SELECT id FROM catalogue_composition_ligne WHERE composition = $comp_id);
    IF $lignes_count = 0 {
        RETURN fn::error_result("CATALOGUE_COMPOSITION_EMPTY", $language, { composition_id: <string> $comp_id });
    };

    -- 4. Archivage atomique de l'ancienne version publiée s'il en existe une
    UPDATE catalogue_composition 
        SET statut = "ARCHIVED" 
        WHERE parent_item = $comp.parent_item AND statut = "PUBLISHED" AND id != $comp_id;

    -- 5. Publication et verrouillage de la version actuelle
    LET $published = (UPDATE ONLY $comp_id SET 
        statut = "PUBLISHED",
        is_locked = true,
        published_at = time::now()
    );
    IF $published == NONE {
        RETURN fn::error_result("CATALOGUE_WRITE_FORBIDDEN", $language, { table: "catalogue_composition" });
    };

    -- 6. Mise à jour du flag is_composite sur l'item parent
    UPDATE ONLY $comp.parent_item SET is_composite = true;

    RETURN fn::result_ok($published);
} COMMENT "Publie une version de composition : elle devient la version active du parent et les autres versions publiées sont archivées.";

-- ============================================================================
-- FONCTION : fn::catalogue_composition_publish
-- MODULE   : lyxal_catalogue
-- RÔLE     : Publication et verrouillage irréversible d'une composition
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::catalogue_composition_publish($params: object) {
    LET $comp_id = <record<catalogue_composition>> $params.composition_id;
    LET $language = IF $params.language != NONE { $params.language } ELSE { "fr" };

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
    LET $lignes_count = (SELECT count() FROM catalogue_composition_ligne WHERE composition = $comp_id)[0].count;
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

    -- 6. Mise à jour du flag is_composite sur l'item parent
    UPDATE ONLY $comp.parent_item SET is_composite = true;

    RETURN fn::result_ok($published);
};

-- ============================================================================
-- FONCTION : fn::catalogue_relation_delete
-- MODULE   : lyxal_catalogue
-- RÔLE     : Suppression d'une relation transversale
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::catalogue_relation_delete($params: object) {
    LET $relation_id = <record<catalogue_relation>> $params.id;
    LET $language = IF $params.language != NONE { $params.language } ELSE { "fr" };

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

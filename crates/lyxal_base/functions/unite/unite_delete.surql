-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::base_unite_delete                                                   │
-- │  Suppression physique d'une unité de mesure avec protection socle      │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION OVERWRITE fn::base_unite_delete($params: object) {
    LET $id = $params.id;
    LET $language = IF $params.language != NONE AND string::len(string::trim($params.language)) > 0 {
        string::lowercase(string::trim($params.language))
    } ELSE {
        "fr"
    };

    IF $id == NONE {
        RETURN fn::error_result("BASE_UNITE_NOT_FOUND", $language, { field: "id" });
    };

    -- Normalisation du Record ID si passé sous forme de chaîne JSON
    LET $record_id = IF type::is_record($id) {
        $id
    } ELSE IF type::is_string($id) {
        IF string::starts_with($id, "base_unite:") {
            type::record($id)
        } ELSE {
            type::record("base_unite", $id)
        }
    } ELSE {
        $id
    };

    -- Vérification de l'existence de l'unité dans base_unite
    LET $existing = SELECT id, is_system FROM ONLY $record_id;
    IF $existing == NONE {
        RETURN fn::error_result("BASE_UNITE_NOT_FOUND", $language, { id: $record_id });
    };

    -- Règle d'or : Protection du socle système (interdiction de supprimer m², kg, h, etc.)
    IF $existing.is_system == true {
        RETURN fn::error_result("BASE_UNITE_IS_SYSTEM", $language, {
            id: $record_id,
            recommendation: "Cette unité fait partie du socle système. Utilisez fn::base_unite_update({ id: $record_id, enabled: false }) pour la désactiver."
        });
    };

    -- Contrôle d'intégrité applicative (modules BTP, devis, etc.)
    DELETE ONLY $record_id;

    RETURN fn::result_ok({
        deleted: true,
        id: $record_id
    });
} COMMENT "Supprime physiquement une unité de mesure non système et non référencée";

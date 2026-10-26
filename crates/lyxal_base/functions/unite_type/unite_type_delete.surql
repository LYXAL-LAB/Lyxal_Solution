-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::base_unite_type_delete                                              │
-- │  Suppression physique contrôlée d'un type d'unité (protection socle)    │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION OVERWRITE fn::base_unite_type_delete($params: object) {
    LET $id = $params.id;
    LET $language = IF $params.language != NONE AND string::len(string::trim($params.language)) > 0 {
        string::lowercase(string::trim($params.language))
    } ELSE {
        "fr"
    };

    IF $id == NONE {
        RETURN fn::error_result("BASE_UNITE_TYPE_NOT_FOUND", $language, { field: "id" });
    };

    -- Normalisation du Record ID si passé sous forme de chaîne JSON
    LET $record_id = IF type::is_record($id) {
        $id
    } ELSE IF type::is_string($id) {
        IF string::starts_with($id, "base_unite_type:") {
            type::record($id)
        } ELSE {
            type::record("base_unite_type", $id)
        }
    } ELSE {
        $id
    };

    -- Vérification de l'existence
    LET $existing = SELECT id, is_system FROM ONLY $record_id;
    IF $existing == NONE {
        RETURN fn::error_result("BASE_UNITE_TYPE_NOT_FOUND", $language, { id: $record_id });
    };

    -- Règle d'or : Protection du socle système
    IF $existing.is_system == true {
        RETURN fn::error_result("BASE_UNITE_TYPE_IS_SYSTEM", $language, {
            id: $record_id,
            recommendation: "Ce type d'unité fait partie du socle système. Utilisez fn::base_unite_type_update({ id: $record_id, enabled: false }) pour le désactiver."
        });
    };

    -- Contrôle d'intégrité référentielle : vérifier si des unités y sont rattachées dans base_unite
    LET $usage = SELECT count() FROM base_unite WHERE type = $record_id GROUP ALL;
    LET $count = IF array::len($usage) > 0 { $usage[0].count } ELSE { 0 };

    IF $count > 0 {
        RETURN fn::error_result("BASE_UNITE_TYPE_IN_USE", $language, {
            id: $record_id,
            references: $count,
            recommendation: "Désactivez le type d'unité plutôt que de le supprimer."
        });
    };

    -- Suppression physique
    DELETE ONLY $record_id;

    RETURN fn::result_ok({
        deleted: true,
        id: $record_id
    });
} COMMENT "Supprime un type d'unité uniquement s'il n'est ni système ni rattaché à une unité";

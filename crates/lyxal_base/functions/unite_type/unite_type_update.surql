-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::base_unite_type_update                                              │
-- │  Mise à jour sélective d'un type d'unité (libellé, activation)          │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION OVERWRITE fn::base_unite_type_update($params: object) {
    LET $id = $params.id;
    LET $raw_libelle = $params.libelle;
    LET $enabled = $params.enabled;
    LET $language = IF type::is_string($params.language) AND string::len(string::trim($params.language)) > 0 {
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
    LET $existing = SELECT * FROM ONLY $record_id;
    IF $existing == NONE {
        RETURN fn::error_result("BASE_UNITE_TYPE_NOT_FOUND", $language, { id: $record_id });
    };

    -- Vérification qu'au moins un champ modifiable est fourni
    IF $raw_libelle == NONE AND $enabled == NONE {
        RETURN fn::error_result("BASE_NO_UPDATABLE_FIELDS_PROVIDED", $language, { allowed_fields: ["libelle", "enabled"] });
    };

    -- Vérification et nettoyage du libellé si fourni
    IF $raw_libelle != NONE AND string::len(string::trim($raw_libelle)) == 0 {
        RETURN fn::error_result("BASE_UNITE_TYPE_LIBELLE_REQUIRED", $language, { field: "libelle" });
    };

    IF $raw_libelle != NONE AND string::len(string::trim($raw_libelle)) > 128 {
        RETURN fn::error_result("BASE_UNITE_TYPE_LIBELLE_INVALID", $language, { field: "libelle", value: $raw_libelle });
    };

    LET $final_libelle = IF $raw_libelle != NONE {
        string::uppercase(string::trim($raw_libelle))
    } ELSE {
        $existing.libelle
    };
    LET $final_enabled = IF $enabled != NONE { <bool> $enabled } ELSE { $existing.enabled };

    LET $updated = UPDATE ONLY $record_id MERGE {
        libelle: $final_libelle,
        enabled: $final_enabled,
        updated_at: time::now()
    };

    RETURN fn::result_ok($updated);
} COMMENT "Met à jour sélectivement le libellé ou l'état d'un type d'unité de mesure";

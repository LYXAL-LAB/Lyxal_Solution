-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │  fn::base_unite_update                                                   │
-- │  Mise à jour sélective d'une unité avec vérification de réactivation    │
-- └──────────────────────────────────────────────────────────────────────────┘

DEFINE FUNCTION OVERWRITE fn::base_unite_update($params: object) {
    LET $id = $params.id;
    LET $raw_libelle = $params.libelle;
    LET $raw_abreviation = $params.abreviation;
    LET $type = $params.type;
    LET $enabled = $params.enabled;
    LET $language = IF type::is_string($params.language) AND string::len(string::trim($params.language)) > 0 {
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

    -- Vérification de l'existence de l'unité
    LET $existing = SELECT * FROM ONLY $record_id;
    IF $existing == NONE {
        RETURN fn::error_result("BASE_UNITE_NOT_FOUND", $language, { id: $record_id });
    };

    -- Vérification qu'au moins un champ modifiable est fourni
    IF $raw_libelle == NONE AND $raw_abreviation == NONE AND $type == NONE AND $enabled == NONE {
        RETURN fn::error_result("BASE_NO_UPDATABLE_FIELDS_PROVIDED", $language, {
            allowed_fields: ["libelle", "abreviation", "type", "enabled"]
        });
    };

    -- Validation du libellé si fourni
    IF $raw_libelle != NONE AND string::len(string::trim($raw_libelle)) == 0 {
        RETURN fn::error_result("BASE_UNITE_LIBELLE_REQUIRED", $language, { field: "libelle" });
    };

    IF $raw_libelle != NONE AND string::len(string::trim($raw_libelle)) > 128 {
        RETURN fn::error_result("BASE_UNITE_LIBELLE_INVALID", $language, { field: "libelle", value: $raw_libelle });
    };

    -- Validation de l'abréviation si fournie
    IF $raw_abreviation != NONE AND string::len(string::trim($raw_abreviation)) == 0 {
        RETURN fn::error_result("BASE_UNITE_ABREVIATION_REQUIRED", $language, { field: "abreviation" });
    };

    IF $raw_abreviation != NONE AND string::len(string::trim($raw_abreviation)) > 10 {
        RETURN fn::error_result("BASE_UNITE_ABREVIATION_INVALID", $language, { field: "abreviation", value: $raw_abreviation });
    };

    -- Normalisation éventuelle du type si fourni
    LET $type_id = IF $type != NONE {
        IF type::is_record($type) {
            $type
        } ELSE IF type::is_string($type) {
            IF string::starts_with($type, "base_unite_type:") {
                type::record($type)
            } ELSE {
                type::record("base_unite_type", $type)
            }
        } ELSE {
            $type
        }
    } ELSE {
        NONE
    };

    -- Détermination du type cible (nouveau type ou type actuel)
    LET $target_type_id = IF $type_id != NONE { $type_id } ELSE { $existing.type };

    -- Vérification si le type change
    IF $type_id != NONE {
        LET $parent_type = SELECT id, enabled FROM ONLY $type_id;
        IF $parent_type == NONE {
            RETURN fn::error_result("BASE_UNITE_TYPE_INVALID", $language, { type: $type_id });
        };
        IF $parent_type.enabled != true {
            RETURN fn::error_result("BASE_UNITE_TYPE_DISABLED", $language, { type: $type_id });
        };
    };

    -- Validation si activation demandée
    IF $enabled != NONE AND <bool> $enabled == true {
        LET $parent_type = SELECT id, enabled FROM ONLY $target_type_id;
        IF $parent_type == NONE OR $parent_type.enabled != true {
            RETURN fn::error_result("BASE_UNITE_TYPE_DISABLED", $language, {
                type: $target_type_id,
                reason: "Impossible d'activer une unité dont le type d'unité est inactif."
            });
        };
    };

    LET $final_libelle = IF $raw_libelle != NONE {
        string::uppercase(string::trim($raw_libelle))
    } ELSE {
        $existing.libelle
    };
    LET $final_abreviation = IF $raw_abreviation != NONE {
        string::trim($raw_abreviation)
    } ELSE {
        $existing.abreviation
    };
    LET $final_type = IF $type_id != NONE { $type_id } ELSE { $existing.type };
    LET $final_enabled = IF $enabled != NONE { <bool> $enabled } ELSE { $existing.enabled };

    LET $updated = UPDATE ONLY $record_id MERGE {
        libelle: $final_libelle,
        abreviation: $final_abreviation,
        type: $final_type,
        enabled: $final_enabled,
        updated_at: time::now()
    };

    RETURN fn::result_ok($updated);
} COMMENT "Met à jour sélectivement une unité avec contrôle de cohérence hiérarchique sur le type parent";

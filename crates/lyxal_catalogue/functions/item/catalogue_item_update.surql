-- ============================================================================
-- FONCTION : fn::catalogue_item_update
-- MODULE   : lyxal_catalogue
-- RÔLE     : Mise à jour sécurisée d'un élément du catalogue avec protection des champs synchronisés
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::catalogue_item_update($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            id: { pipeline: [{ rule: "record", options: { expected_table: "catalogue_item" } }], required: true },
            code: { pipeline: [{ rule: "optional_string", options: { max_length: 64 } }] },
            type: { pipeline: [{ rule: "record", options: { expected_table: "catalogue_type" } }] },
            nature_reference: { pipeline: [{ rule: "enum", options: { allowed: ["GENERIQUE", "COMMERCIALE"], case_sensitive: false } }] },
            libelle: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 255 } }] },
            description: { pipeline: [{ rule: "optional_string", options: { max_length: 4000 } }] },
            unite_reference: { pipeline: [{ rule: "record", options: { expected_table: "base_unite" } }] },
            enabled: { pipeline: [{ rule: "boolean" }] },
            statut_commercial: { pipeline: [{ rule: "enum", options: { allowed: ["ACTIF", "FIN_DE_SERIE", "OBSOLETE", "REMPLACE"], case_sensitive: false } }] },
            documents: { pipeline: [{ rule: "array_objects", options: { allow_empty_objects: false } }] },
            conditionnement: { pipeline: [{ rule: "object_non_empty" }] },
            unite_conditionnement: { pipeline: [{ rule: "record", options: { expected_table: "base_unite" } }] },
            code_barre: { pipeline: [{ rule: "gtin" }] },
            fabricant: { pipeline: [{ rule: "optional_string", options: { max_length: 128 } }] },
            marque: { pipeline: [{ rule: "optional_string", options: { max_length: 128 } }] },
            reference_fabricant: { pipeline: [{ rule: "optional_string", options: { max_length: 64 } }] },
            master_id: { pipeline: [{ rule: "optional_string", options: { max_length: 128 } }] },
            is_custom: { pipeline: [{ rule: "boolean" }] },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 60);
    IF !$report.valid {
        RETURN fn::error_result("CATALOGUE_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = fn::sanitize_object_execute($report.value, {
        fields: {
            code: { pipeline: [{ rule: "uppercase" }] },
            nature_reference: { pipeline: [{ rule: "uppercase" }] },
            statut_commercial: { pipeline: [{ rule: "uppercase" }] },
            fabricant: { pipeline: [{ rule: "uppercase" }] },
            marque: { pipeline: [{ rule: "uppercase" }] }
        },
        unknown_keys: "keep"
    }, 60);
    LET $id = $p.id;
    LET $raw_libelle = $p.libelle;
    LET $description = $p.description;
    LET $unite_id = $p.unite_reference;
    LET $enabled = $p.enabled;
    LET $statut_comm = $p.statut_commercial;
    LET $documents = $p.documents;
    LET $conditionnement = $p.conditionnement;
    LET $unite_cond = $p.unite_conditionnement;
    LET $code_barre = $p.code_barre;
    LET $fabricant = $p.fabricant;
    LET $marque = $p.marque;
    LET $ref_fab = $p.reference_fabricant;
    LET $language = $p.language;

    LET $item = (SELECT * FROM ONLY $id);
    IF $item == NONE {
        RETURN fn::error_result("CATALOGUE_ITEM_NOT_FOUND", $language, { id: <string> $id });
    };

    -- Contrôle d'immutabilité du socle système
    IF $item.is_system == true AND $enabled = false {
        RETURN fn::error_result("CATALOGUE_ITEM_SYSTEM_IMMUTABLE", $language, { id: <string> $id });
    };

    -- Contrôle d'immutabilité structurelle (code, type, nature_reference)
    IF $p.code != NONE AND $p.code != $item.code {
        RETURN fn::error_result("CATALOGUE_ITEM_CODE_IMMUTABLE", $language, { code: $item.code });
    };
    IF $p.type != NONE AND $p.type != $item.type {
        RETURN fn::error_result("CATALOGUE_ITEM_TYPE_IMMUTABLE", $language, { type: $item.type });
    };
    IF $p.nature_reference != NONE AND $p.nature_reference != $item.nature_reference {
        RETURN fn::error_result("CATALOGUE_ITEM_NATURE_IMMUTABLE", $language, { nature_reference: $item.nature_reference });
    };

    -- Unités modifiées : existantes et utilisables (unité et type actifs), selon lyxal_base
    IF $unite_id != NONE AND !(fn::base_unite_get({ id: <string> $unite_id }).data.usable ?? false) {
        RETURN fn::error_result("CATALOGUE_ITEM_UNITE_INVALID", $language, { unite_reference: <string> $unite_id });
    };
    IF $unite_cond != NONE AND !(fn::base_unite_get({ id: <string> $unite_cond }).data.usable ?? false) {
        RETURN fn::error_result("CATALOGUE_ITEM_UNITE_INVALID", $language, { unite_conditionnement: <string> $unite_cond });
    };

    -- Droits de l'appelant (sessions lyxal_auth)
    LET $c = fn::catalogue_caller({});
    LET $is_sync_auth = $c.sync;

    -- Contrôle de propriété strict de l'article privé
    IF $item.is_custom == true AND !$c.system {
        IF $c.sync {
            RETURN fn::error_result("CATALOGUE_ITEM_SYNC_CANNOT_ACCESS_CUSTOM", $language, {
                id: <string> $id,
                notice: "Le compte de synchronisation ne doit pas lire ou modifier les articles privés des clients."
            });
        };
        IF $item.tenant IS NONE {
            RETURN fn::error_result("CATALOGUE_ITEM_TENANT_ORPHAN", $language, {
                id: <string> $id,
                notice: "Article privé orphelin sans organisation propriétaire : modification interdite."
            });
        };
        IF $c.tenant IS NONE {
            RETURN fn::error_result("CATALOGUE_ITEM_TENANT_REQUIRED", $language, {
                id: <string> $id,
                notice: "La modification d'un article privé exige une session rattachée à une organisation."
            });
        };
        IF $c.tenant != $item.tenant {
            RETURN fn::error_result("CATALOGUE_ITEM_TENANT_FORBIDDEN", $language, {
                id: <string> $id,
                notice: "Cet article privé appartient exclusivement à une autre organisation."
            });
        };
        IF !$c.manage {
            RETURN fn::error_result("CATALOGUE_WRITE_FORBIDDEN", $language, { table: "catalogue_item", permission: "catalogue.item.manage" });
        };
    };
    IF $item.is_custom == true {
        IF $p.is_custom == false {
            RETURN fn::error_result("CATALOGUE_ITEM_CUSTOM_CANNOT_CONVERT_MASTER", $language, {
                id: <string> $id,
                notice: "Un article privé ne peut pas être converti en article maître."
            });
        };
    };

    -- Protection des champs synchronisés du Master
    IF $item.is_custom == false AND $item.master_id != NONE {
        IF $p.master_id != NONE AND $p.master_id != $item.master_id {
            RETURN fn::error_result("CATALOGUE_ITEM_MASTER_ID_IMMUTABLE", $language, { master_id: $item.master_id });
        };
        IF $p.is_custom == true {
            RETURN fn::error_result("CATALOGUE_ITEM_SYNC_CANNOT_CONVERT_CUSTOM", $language, { id: <string> $id });
        };

        -- Si la mise à jour n'est pas un flux Master officiel, les caractéristiques maîtres sont
        -- verrouillées, disponibilité comprise : un locataire personnalise ou désactive un article
        -- maître pour lui seul par fn::catalogue_item_personnaliser
        IF !$is_sync_auth {
            IF ($fabricant != NONE AND $fabricant != $item.fabricant)
               OR ($marque != NONE AND $marque != $item.marque)
               OR ($ref_fab != NONE AND $ref_fab != $item.reference_fabricant)
               OR ($code_barre != NONE AND $code_barre != $item.code_barre)
               OR ($unite_id != NONE AND $unite_id != $item.unite_reference)
               OR ($conditionnement != NONE AND $conditionnement != $item.conditionnement)
               OR ($unite_cond != NONE AND $unite_cond != $item.unite_conditionnement)
               OR ($documents != NONE AND $documents != $item.documents)
               OR ($raw_libelle != NONE AND $raw_libelle != $item.libelle)
               OR ($description != NONE AND $description != $item.description)
               OR ($statut_comm != NONE AND $statut_comm != $item.statut_commercial)
               OR ($enabled != NONE AND $enabled != $item.enabled) {
                RETURN fn::error_result("CATALOGUE_ITEM_SYNC_FIELD_PROTECTED", $language, { 
                    id: <string> $id,
                    notice: "Les champs maîtres d'un article synchronisé ne peuvent pas être modifiés localement. Utilisez fn::catalogue_item_personnaliser."
                });
            };
        };
    };

    -- Unicité du GTIN s'il est modifié (format et clé GS1 contrôlés par la règle gtin de lyxal_core)
    LET $final_gtin = $code_barre ?? $item.code_barre;
    IF $code_barre != NONE AND $code_barre != $item.code_barre {
        LET $existing_gtin = (SELECT id FROM catalogue_item WHERE code_barre = $code_barre AND id != $id);
        IF array::len($existing_gtin) > 0 {
            RETURN fn::error_result("CATALOGUE_ITEM_GTIN_ALREADY_EXISTS", $language, { code_barre: $code_barre });
        };
    };

    -- Contrôle d'unicité fabricant + ref_fab si modifié
    LET $final_fab = $fabricant ?? $item.fabricant;
    LET $final_ref = $ref_fab ?? $item.reference_fabricant;
    IF $final_fab != NONE AND $final_ref != NONE AND ($final_fab != $item.fabricant OR $final_ref != $item.reference_fabricant) {
        LET $existing_fab_ref = (SELECT id FROM catalogue_item WHERE fabricant = $final_fab AND reference_fabricant = $final_ref AND id != $id);
        IF array::len($existing_fab_ref) > 0 {
            RETURN fn::error_result("CATALOGUE_ITEM_FAB_REF_DUPLICATE", $language, { fabricant: $final_fab, reference_fabricant: $final_ref });
        };
    };

    LET $updated = (UPDATE ONLY $id MERGE {
        libelle: $raw_libelle ?? $item.libelle,
        description: $description ?? $item.description,
        unite_reference: $unite_id ?? $item.unite_reference,
        enabled: $enabled ?? $item.enabled,
        statut_commercial: $statut_comm ?? $item.statut_commercial,
        documents: $documents ?? $item.documents,
        conditionnement: $conditionnement ?? $item.conditionnement,
        unite_conditionnement: $unite_cond ?? $item.unite_conditionnement,
        code_barre: $final_gtin,
        fabricant: $final_fab,
        marque: $marque ?? $item.marque,
        reference_fabricant: $final_ref,
        updated_at: time::now()
    });
    IF $updated == NONE {
        RETURN fn::error_result("CATALOGUE_WRITE_FORBIDDEN", $language, { table: "catalogue_item" });
    };

    RETURN fn::result_ok($updated);
} COMMENT "Met à jour les informations éditables d'un élément avec protection des données maîtres";

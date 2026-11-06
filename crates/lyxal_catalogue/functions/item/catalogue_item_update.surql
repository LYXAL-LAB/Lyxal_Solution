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
            code_interne_client: { pipeline: [{ rule: "optional_string", options: { max_length: 64 } }] },
            libelle_personnalise: { pipeline: [{ rule: "optional_string", options: { max_length: 255 } }] },
            master_id: { pipeline: [{ rule: "optional_string", options: { max_length: 128 } }] },
            is_custom: { pipeline: [{ rule: "boolean" }] },
            tenant_id: { pipeline: [{ rule: "optional_string", options: { max_length: 128 } }] },
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
    LET $code_interne = $p.code_interne_client;
    LET $libelle_custom = $p.libelle_personnalise;
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

    LET $is_sync_auth = (
        ($token != NONE 
        AND $token.role = "catalogue_sync_agent" 
        AND $token.iss = "lyxal-os"
        AND $token.aud = "lyxal-catalogue"
        AND "catalogue:sync:write" IN $token.scope)
        OR
        ($auth != NONE 
        AND $auth.role = "catalogue_sync_agent" 
        AND "catalogue:sync:write" IN $auth.permissions)
    );

    -- Contrôle de propriété strict de l'article privé
    IF $item.is_custom == true {
        IF $is_sync_auth {
            RETURN fn::error_result("CATALOGUE_ITEM_SYNC_CANNOT_ACCESS_CUSTOM", $language, {
                id: <string> $id,
                notice: "Le service catalogue_sync_agent ne doit pas lire ou modifier les articles privés des clients."
            });
        };
        LET $caller_role = IF $token != NONE AND $token.role != NONE { 
            string::trim($token.role) 
        } ELSE IF $auth != NONE AND $auth.role != NONE { 
            string::trim($auth.role) 
        } ELSE { 
            NONE 
        };
        IF $caller_role != "tenant_user" {
            RETURN fn::error_result("CATALOGUE_ITEM_TENANT_REQUIRED", $language, {
                id: <string> $id,
                notice: "La modification d'un article privé exige une identité cliente avec le rôle tenant_user."
            });
        };
        IF $item.tenant_id == NONE OR string::len(string::trim($item.tenant_id)) == 0 {
            RETURN fn::error_result("CATALOGUE_ITEM_TENANT_ORPHAN", $language, {
                id: <string> $id,
                notice: "Article privé orphelin sans propriétaire vérifiable : modification interdite."
            });
        };
        LET $caller_tenant = IF $token != NONE AND $token.tenant_id != NONE { 
            string::trim($token.tenant_id) 
        } ELSE IF $auth != NONE AND $auth.tenant_id != NONE { 
            string::trim($auth.tenant_id) 
        } ELSE { 
            NONE 
        };
        IF $caller_tenant == NONE OR string::len($caller_tenant) == 0 {
            RETURN fn::error_result("CATALOGUE_ITEM_TENANT_REQUIRED", $language, {
                id: <string> $id,
                notice: "Une identité sans tenant_id valide ne peut pas modifier un article privé."
            });
        };
        IF $caller_tenant != $item.tenant_id {
            RETURN fn::error_result("CATALOGUE_ITEM_TENANT_FORBIDDEN", $language, {
                id: <string> $id,
                notice: "Cet article privé appartient exclusivement à une autre organisation."
            });
        };
        IF $p.tenant_id != NONE AND $p.tenant_id != $item.tenant_id {
            RETURN fn::error_result("CATALOGUE_ITEM_TENANT_ID_IMMUTABLE", $language, {
                tenant_id: $item.tenant_id,
                notice: "Le propriétaire tenant_id d'un article est strictement immuable."
            });
        };
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

        -- Si la mise à jour n'est pas un flux Master officiel, les caractéristiques maîtres sont verrouillées
        -- (enabled est modifiable localement par le locataire, statut_commercial reste exclusif Master)
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
               OR ($statut_comm != NONE AND $statut_comm != $item.statut_commercial) {
                RETURN fn::error_result("CATALOGUE_ITEM_SYNC_FIELD_PROTECTED", $language, { 
                    id: <string> $id,
                    notice: "Les champs maîtres d'un article synchronisé ne peuvent pas être modifiés localement. Utilisez 'libelle_personnalise' ou 'code_interne_client'."
                });
            };
        };

        -- Si la mise à jour est effectuée par l'agent de synchronisation :
        -- 1. Interdiction d'écraser les personnalisations locales
        -- 2. Interdiction de réactiver un article localement désactivé
        IF $is_sync_auth {
            IF ($code_interne != NONE AND $code_interne != $item.code_interne_client)
               OR ($libelle_custom != NONE AND $libelle_custom != $item.libelle_personnalise) {
                RETURN fn::error_result("CATALOGUE_ITEM_SYNC_CANNOT_OVERWRITE_LOCAL_CUSTOMIZATION", $language, {
                    id: <string> $id,
                    notice: "Le flux Master de synchronisation ne peut en aucun cas modifier ou écraser les personnalisations locales du client."
                });
            };
            IF $item.enabled == false AND $enabled == true {
                RETURN fn::error_result("CATALOGUE_ITEM_SYNC_CANNOT_REACTIVATE_DISABLED", $language, {
                    id: <string> $id,
                    notice: "Une mise à jour Master ne peut jamais réactiver un article désactivé localement par l'organisation cliente."
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

    -- Préservation stricte de la désactivation locale lors des flux Master
    LET $final_enabled = IF $is_sync_auth {
        IF $item.enabled == false {
            false
        } ELSE {
            $enabled ?? $item.enabled
        }
    } ELSE {
        $enabled ?? $item.enabled
    };

    LET $updated = (UPDATE ONLY $id MERGE {
        libelle: $raw_libelle ?? $item.libelle,
        description: $description ?? $item.description,
        unite_reference: $unite_id ?? $item.unite_reference,
        enabled: $final_enabled,
        statut_commercial: $statut_comm ?? $item.statut_commercial,
        documents: $documents ?? $item.documents,
        conditionnement: $conditionnement ?? $item.conditionnement,
        unite_conditionnement: $unite_cond ?? $item.unite_conditionnement,
        code_barre: $final_gtin,
        fabricant: $final_fab,
        marque: $marque ?? $item.marque,
        reference_fabricant: $final_ref,
        code_interne_client: $code_interne ?? $item.code_interne_client,
        libelle_personnalise: $libelle_custom ?? $item.libelle_personnalise,
        updated_at: time::now()
    });
    IF $updated == NONE {
        RETURN fn::error_result("CATALOGUE_WRITE_FORBIDDEN", $language, { table: "catalogue_item" });
    };

    RETURN fn::result_ok($updated);
} COMMENT "Met à jour les informations éditables d'un élément avec protection des données maîtres";

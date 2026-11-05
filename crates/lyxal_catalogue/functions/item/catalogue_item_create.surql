-- ============================================================================
-- FONCTION : fn::catalogue_item_create
-- MODULE   : lyxal_catalogue
-- RÔLE     : Création d'un élément universel du catalogue (générique ou commercial)
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::catalogue_item_create($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            code: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 64 } }], required: true },
            type: { pipeline: [{ rule: "record", options: { expected_table: "catalogue_type" } }], required: true },
            libelle: { pipeline: [{ rule: "required_string", options: { min_length: 1, max_length: 255 } }], required: true },
            unite_reference: { pipeline: [{ rule: "record", options: { expected_table: "base_unite" } }], required: true },
            description: { pipeline: [{ rule: "optional_string", options: { max_length: 4000 } }] },
            has_variants: { pipeline: [{ rule: "boolean" }], default: false },
            categories: { pipeline: [{ rule: "array" }], default: [] },
            nature_reference: { pipeline: [{ rule: "enum", options: { allowed: ["GENERIQUE", "COMMERCIALE"], case_sensitive: false } }], default: "GENERIQUE" },
            fabricant: { pipeline: [{ rule: "optional_string", options: { max_length: 128 } }] },
            marque: { pipeline: [{ rule: "optional_string", options: { max_length: 128 } }] },
            reference_fabricant: { pipeline: [{ rule: "optional_string", options: { max_length: 64 } }] },
            code_barre: { pipeline: [{ rule: "gtin" }] },
            statut_commercial: { pipeline: [{ rule: "enum", options: { allowed: ["ACTIF", "FIN_DE_SERIE", "OBSOLETE", "REMPLACE"], case_sensitive: false } }], default: "ACTIF" },
            documents: { pipeline: [{ rule: "array_objects", options: { allow_empty_objects: false } }] },
            conditionnement: { pipeline: [{ rule: "object_non_empty" }] },
            master_id: { pipeline: [{ rule: "optional_string", options: { max_length: 128 } }] },
            is_custom: { pipeline: [{ rule: "boolean" }] },
            code_interne_client: { pipeline: [{ rule: "optional_string", options: { max_length: 64 } }] },
            libelle_personnalise: { pipeline: [{ rule: "optional_string", options: { max_length: 255 } }] },
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
            fabricant: { pipeline: [{ rule: "uppercase" }] },
            marque: { pipeline: [{ rule: "uppercase" }] },
            statut_commercial: { pipeline: [{ rule: "uppercase" }] }
        },
        unknown_keys: "keep"
    }, 60);
    LET $code = $p.code;
    LET $type_id = $p.type;
    LET $libelle = $p.libelle;
    LET $unite_id = $p.unite_reference;
    LET $description = $p.description;
    LET $has_variants = $p.has_variants;
    LET $categories = $p.categories;
    LET $language = $p.language;
    
    -- Paramètres de référence commerciale
    LET $nature = $p.nature_reference;
    LET $fabricant = $p.fabricant;
    LET $marque = $p.marque;
    LET $ref_fab = $p.reference_fabricant;
    LET $code_barre = $p.code_barre;
    LET $statut_comm = $p.statut_commercial;
    LET $documents = $p.documents ?? [];
    LET $conditionnement = $p.conditionnement;
    
    -- Paramètres de synchronisation et personnalisation locale
    LET $master_id = $p.master_id;
    LET $is_custom = $p.is_custom ?? ($master_id == NONE);
    LET $code_interne = $p.code_interne_client;
    LET $libelle_custom = $p.libelle_personnalise;
    
    -- Catégories : identifiant seul ou { id, is_primary }, convertis par lyxal_core, erreur par position
    LET $checked = array::map($categories, |$cat, $index| {
        LET $raw = IF type::is_object($cat) { $cat.id } ELSE { $cat };
        LET $categorie = fn::validation_record($raw, "catalogue_categorie");
        LET $primary = fn::validation_boolean(IF type::is_object($cat) { $cat.is_primary ?? false } ELSE { false });
        RETURN { index: $index, categorie: $categorie, primary: $primary };
    });
    LET $invalid = array::filter($checked, |$c| !$c.categorie.valid OR !$c.primary.valid);
    IF array::len($invalid) > 0 {
        RETURN fn::error_result("CATALOGUE_INVALID_PARAMETERS", $language, {
            fields: { categories: array::map($invalid, |$c| { index: $c.index, id: $c.categorie.code, is_primary: $c.primary.code }) }
        });
    };
    LET $categories = array::map($checked, |$c| { categorie: $c.categorie.value, is_primary: $c.primary.value });

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

    -- Détermination et contrôle de propriété pour les articles privés
    LET $caller_tenant = IF $token != NONE AND $token.tenant_id != NONE { 
        string::trim($token.tenant_id) 
    } ELSE IF $auth != NONE AND $auth.tenant_id != NONE { 
        string::trim($auth.tenant_id) 
    } ELSE { 
        NONE 
    };

    -- Contrôle d'autorisation pour les articles maîtres vs privés
    IF $is_custom == false {
        IF !$is_sync_auth {
            RETURN fn::error_result("CATALOGUE_ITEM_SYNC_CANNOT_CREATE_MASTER", $language, {
                notice: "Seul l'agent de synchronisation officiel peut injecter des articles maîtres."
            });
        };
    } ELSE {
        -- Article privé
        IF $is_sync_auth {
            RETURN fn::error_result("CATALOGUE_ITEM_SYNC_CANNOT_CREATE_CUSTOM", $language, {
                notice: "Le service catalogue_sync_agent ne peut pas créer d'articles privés pour les clients."
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
                field: "role",
                notice: "La création d'un article privé exige une identité cliente avec le rôle tenant_user."
            });
        };
        IF $master_id != NONE {
            RETURN fn::error_result("CATALOGUE_ITEM_CUSTOM_CANNOT_HAVE_MASTER_ID", $language, {
                master_id: $master_id,
                notice: "Un article privé ne peut pas avoir d'identifiant maître."
            });
        };
        IF $caller_tenant == NONE OR string::len($caller_tenant) == 0 {
            RETURN fn::error_result("CATALOGUE_ITEM_TENANT_REQUIRED", $language, {
                field: "tenant_id",
                notice: "La création d'un article privé exige une identité cliente authentifiée avec un tenant_id valide."
            });
        };
        IF $p.tenant_id != NONE AND $p.tenant_id != $caller_tenant {
            RETURN fn::error_result("CATALOGUE_ITEM_TENANT_FORBIDDEN", $language, {
                tenant_id: $p.tenant_id,
                notice: "Tentative d'usurpation de propriété : le tenant_id ne correspond pas à l'identité authentifiée."
            });
        };
    };

    LET $final_tenant_id = IF $is_custom == true { $caller_tenant } ELSE { NONE };

    -- 1. Contrôle d'unicité du code
    LET $existing = (SELECT id FROM catalogue_item WHERE code = $code);
    IF array::len($existing) > 0 {
        RETURN fn::error_result("CATALOGUE_ITEM_ALREADY_EXISTS", $language, { code: $code });
    };

    -- 2. Contrôle du type fondamental
    LET $type_rec = (SELECT * FROM ONLY $type_id);
    IF $type_rec == NONE OR $type_rec.enabled != true {
        RETURN fn::error_result("CATALOGUE_ITEM_TYPE_NOT_FOUND", $language, { type: <string> $type_id });
    };

    -- 3. Contrôle de l'unité de référence
    LET $unite_rec = (SELECT * FROM ONLY $unite_id);
    IF $unite_rec == NONE OR $unite_rec.enabled != true {
        RETURN fn::error_result("CATALOGUE_ITEM_UNITE_INVALID", $language, { unite_reference: <string> $unite_id });
    };

    -- 4. Contrôles de cohérence nature générique vs commerciale
    IF $nature == "GENERIQUE" {
        IF $fabricant != NONE OR $marque != NONE OR $ref_fab != NONE OR $code_barre != NONE {
            RETURN fn::error_result("CATALOGUE_ITEM_GENERIC_CANNOT_HAVE_BRAND", $language, { code: $code });
        };
    } ELSE IF $fabricant == NONE AND $marque == NONE {
        RETURN fn::error_result("CATALOGUE_ITEM_COMMERCIAL_REQUIRES_BRAND", $language, { code: $code });
    };

    -- 5. Unicité du GTIN (format et clé GS1 contrôlés par la règle gtin de lyxal_core)
    IF $code_barre != NONE {
        LET $existing_gtin = (SELECT id FROM catalogue_item WHERE code_barre = $code_barre);
        IF array::len($existing_gtin) > 0 {
            RETURN fn::error_result("CATALOGUE_ITEM_GTIN_ALREADY_EXISTS", $language, { code_barre: $code_barre });
        };
    };

    -- 6. Contrôle d'unicité du couple (fabricant, reference_fabricant)
    IF $fabricant != NONE AND $ref_fab != NONE {
        LET $existing_fab_ref = (SELECT id FROM catalogue_item WHERE fabricant = $fabricant AND reference_fabricant = $ref_fab);
        IF array::len($existing_fab_ref) > 0 {
            RETURN fn::error_result("CATALOGUE_ITEM_FAB_REF_DUPLICATE", $language, { fabricant: $fabricant, reference_fabricant: $ref_fab });
        };
    };

    -- 7. Contrôle d'unicité de master_id pour les articles synchronisés
    IF $master_id != NONE {
        LET $existing_master = (SELECT id FROM catalogue_item WHERE master_id = $master_id);
        IF array::len($existing_master) > 0 {
            RETURN fn::error_result("CATALOGUE_ITEM_MASTER_ID_DUPLICATE", $language, { master_id: $master_id });
        };
    };

    -- 8. Création de l'élément maître
    LET $created = (CREATE catalogue_item CONTENT {
        code: $code,
        type: $type_id,
        libelle: $libelle,
        description: $description,
        unite_reference: $unite_id,
        is_composite: false,
        has_variants: $has_variants,
        nature_reference: $nature,
        fabricant: $fabricant,
        marque: $marque,
        reference_fabricant: $ref_fab,
        code_barre: $code_barre,
        statut_commercial: $statut_comm,
        documents: $documents,
        conditionnement: $conditionnement,
        master_id: $master_id,
        is_custom: $is_custom,
        tenant_id: $final_tenant_id,
        code_interne_client: $code_interne,
        libelle_personnalise: $libelle_custom,
        metadata: {},
        enabled: true,
        is_system: false,
        created_at: time::now(),
        updated_at: time::now()
    });
    IF array::len($created) == 0 {
        RETURN fn::error_result("CATALOGUE_WRITE_FORBIDDEN", $language, { table: "catalogue_item" });
    };

    LET $new_item = $created[0];

    -- 9. Affectation facultative aux catégories
    FOR $link IN $categories {
        LET $linked = (CREATE catalogue_item_categorie CONTENT {
            item: $new_item.id,
            categorie: $link.categorie,
            is_primary: $link.is_primary
        });
        IF array::len($linked) == 0 {
            RETURN fn::error_result("CATALOGUE_WRITE_FORBIDDEN", $language, { table: "catalogue_item_categorie" });
        };
    };

    RETURN fn::result_ok($new_item);
} COMMENT "Crée un nouvel élément universel au catalogue avec validation GS1 et contrôles d'intégrité";

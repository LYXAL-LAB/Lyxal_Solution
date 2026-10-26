-- ============================================================================
-- FONCTION : fn::catalogue_item_create
-- MODULE   : lyxal_catalogue
-- RÔLE     : Création d'un élément universel du catalogue (générique ou commercial)
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::catalogue_item_create($params: object) {
    LET $raw_code = $params.code;
    LET $type_id = <record<catalogue_type>> $params.type;
    LET $raw_libelle = $params.libelle;
    LET $unite_id = <record<base_unite>> $params.unite_reference;
    LET $description = IF $params.description != NONE { string::trim($params.description) } ELSE { NONE };
    LET $has_variants = IF $params.has_variants != NONE { <bool> $params.has_variants } ELSE { false };
    LET $categories = IF $params.categories != NONE { $params.categories } ELSE { [] };
    LET $language = IF $params.language != NONE { $params.language } ELSE { "fr" };

    -- Paramètres de référence commerciale
    LET $nature = IF $params.nature_reference != NONE { string::uppercase(string::trim($params.nature_reference)) } ELSE { "GENERIQUE" };
    LET $fabricant = IF $params.fabricant != NONE { string::uppercase(string::trim($params.fabricant)) } ELSE { NONE };
    LET $marque = IF $params.marque != NONE { string::uppercase(string::trim($params.marque)) } ELSE { NONE };
    LET $ref_fab = IF $params.reference_fabricant != NONE { string::trim($params.reference_fabricant) } ELSE { NONE };
    LET $code_barre = IF $params.code_barre != NONE { string::trim($params.code_barre) } ELSE { NONE };
    LET $statut_comm = IF $params.statut_commercial != NONE { string::uppercase(string::trim($params.statut_commercial)) } ELSE { "ACTIF" };
    LET $documents = IF $params.documents != NONE { $params.documents } ELSE { [] };
    LET $conditionnement = IF $params.conditionnement != NONE { $params.conditionnement } ELSE { NONE };

    -- Paramètres de synchronisation et personnalisation locale
    LET $master_id = IF $params.master_id != NONE { string::trim($params.master_id) } ELSE { NONE };
    LET $is_custom = IF $params.is_custom != NONE { 
        <bool> $params.is_custom 
    } ELSE { 
        IF $master_id != NONE { false } ELSE { true } 
    };
    LET $code_interne = IF $params.code_interne_client != NONE { string::trim($params.code_interne_client) } ELSE { NONE };
    LET $libelle_custom = IF $params.libelle_personnalise != NONE { string::trim($params.libelle_personnalise) } ELSE { NONE };

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
        IF $params.tenant_id != NONE AND string::trim($params.tenant_id) != $caller_tenant {
            RETURN fn::error_result("CATALOGUE_ITEM_TENANT_FORBIDDEN", $language, {
                tenant_id: $params.tenant_id,
                notice: "Tentative d'usurpation de propriété : le tenant_id ne correspond pas à l'identité authentifiée."
            });
        };
    };

    LET $final_tenant_id = IF $is_custom == true { $caller_tenant } ELSE { NONE };

    -- 1. Validation code & libelle
    IF $raw_code == NONE OR string::len(string::trim($raw_code)) == 0 {
        RETURN fn::error_result("CATALOGUE_ITEM_CODE_REQUIRED", $language, { field: "code" });
    };
    IF $raw_libelle == NONE OR string::len(string::trim($raw_libelle)) == 0 {
        RETURN fn::error_result("CATALOGUE_ITEM_LIBELLE_REQUIRED", $language, { field: "libelle" });
    };

    LET $code = string::uppercase(string::trim($raw_code));
    LET $libelle = string::trim($raw_libelle);

    -- 2. Contrôle d'unicité du code
    LET $existing = (SELECT id FROM catalogue_item WHERE code = $code);
    IF array::len($existing) > 0 {
        RETURN fn::error_result("CATALOGUE_ITEM_ALREADY_EXISTS", $language, { code: $code });
    };

    -- 3. Contrôle du type fondamental
    LET $type_rec = (SELECT * FROM ONLY $type_id);
    IF $type_rec == NONE OR $type_rec.enabled != true {
        RETURN fn::error_result("CATALOGUE_ITEM_TYPE_NOT_FOUND", $language, { type: <string> $type_id });
    };

    -- 4. Contrôle de l'unité de référence
    LET $unite_rec = (SELECT * FROM ONLY $unite_id);
    IF $unite_rec == NONE OR $unite_rec.enabled != true {
        RETURN fn::error_result("CATALOGUE_ITEM_UNITE_INVALID", $language, { unite_reference: <string> $unite_id });
    };

    -- 5. Contrôles de cohérence nature générique vs commerciale
    IF $nature == "GENERIQUE" {
        IF $fabricant != NONE OR $marque != NONE OR $ref_fab != NONE OR $code_barre != NONE {
            RETURN fn::error_result("CATALOGUE_ITEM_GENERIC_CANNOT_HAVE_BRAND", $language, { code: $code });
        };
    } ELSE IF $nature == "COMMERCIALE" {
        IF $fabricant == NONE AND $marque == NONE {
            RETURN fn::error_result("CATALOGUE_ITEM_COMMERCIAL_REQUIRES_BRAND", $language, { code: $code });
        };
    } ELSE {
        RETURN fn::error_result("CATALOGUE_ITEM_NATURE_INVALID", $language, { nature: $nature });
    };

    -- 6. Contrôle de validité du GTIN (Modulo 10 GS1)
    IF $code_barre != NONE {
        LET $is_gtin_valid = fn::catalogue_validate_gtin($code_barre);
        IF $is_gtin_valid != true {
            RETURN fn::error_result("CATALOGUE_ITEM_GTIN_INVALID", $language, { code_barre: $code_barre });
        };
        LET $existing_gtin = (SELECT id FROM catalogue_item WHERE code_barre = $code_barre);
        IF array::len($existing_gtin) > 0 {
            RETURN fn::error_result("CATALOGUE_ITEM_GTIN_ALREADY_EXISTS", $language, { code_barre: $code_barre });
        };
    };

    -- 7. Contrôle d'unicité du couple (fabricant, reference_fabricant)
    IF $fabricant != NONE AND $ref_fab != NONE {
        LET $existing_fab_ref = (SELECT id FROM catalogue_item WHERE fabricant = $fabricant AND reference_fabricant = $ref_fab);
        IF array::len($existing_fab_ref) > 0 {
            RETURN fn::error_result("CATALOGUE_ITEM_FAB_REF_DUPLICATE", $language, { fabricant: $fabricant, reference_fabricant: $ref_fab });
        };
    };

    -- 8. Contrôle d'unicité de master_id pour les articles synchronisés
    IF $master_id != NONE {
        LET $existing_master = (SELECT id FROM catalogue_item WHERE master_id = $master_id);
        IF array::len($existing_master) > 0 {
            RETURN fn::error_result("CATALOGUE_ITEM_MASTER_ID_DUPLICATE", $language, { master_id: $master_id });
        };
    };

    -- 9. Création de l'élément maître
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

    LET $new_item = $created[0];

    -- 10. Affectation facultative aux catégories
    FOR $cat IN $categories {
        LET $cat_rec_id = <record<catalogue_categorie>> (IF type::is_record($cat) { $cat } ELSE IF type::is_object($cat) { $cat.id } ELSE { $cat });
        LET $is_primary = IF type::is_object($cat) AND $cat.is_primary != NONE { <bool> $cat.is_primary } ELSE { false };
        CREATE catalogue_item_categorie CONTENT {
            item: $new_item.id,
            categorie: $cat_rec_id,
            is_primary: $is_primary
        };
    };

    RETURN fn::result_ok($new_item);
} COMMENT "Crée un nouvel élément universel au catalogue avec validation GS1 et contrôles d'intégrité";

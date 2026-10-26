-- ============================================================================
-- FONCTION : fn::catalogue_item_update
-- MODULE   : lyxal_catalogue
-- RÔLE     : Mise à jour sécurisée d'un élément du catalogue avec protection des champs synchronisés
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::catalogue_item_update($params: object) {
    LET $id = <record<catalogue_item>> $params.id;
    LET $raw_libelle = $params.libelle;
    LET $description = $params.description;
    LET $unite_id = IF $params.unite_reference != NONE { <record<base_unite>> $params.unite_reference } ELSE { NONE };
    LET $enabled = $params.enabled;
    LET $statut_comm = IF $params.statut_commercial != NONE { string::uppercase(string::trim($params.statut_commercial)) } ELSE { NONE };
    LET $documents = $params.documents;
    LET $conditionnement = $params.conditionnement;
    LET $code_barre = IF $params.code_barre != NONE { string::trim($params.code_barre) } ELSE { NONE };
    LET $fabricant = IF $params.fabricant != NONE { string::uppercase(string::trim($params.fabricant)) } ELSE { NONE };
    LET $marque = IF $params.marque != NONE { string::uppercase(string::trim($params.marque)) } ELSE { NONE };
    LET $ref_fab = IF $params.reference_fabricant != NONE { string::trim($params.reference_fabricant) } ELSE { NONE };
    LET $code_interne = IF $params.code_interne_client != NONE { string::trim($params.code_interne_client) } ELSE { NONE };
    LET $libelle_custom = IF $params.libelle_personnalise != NONE { string::trim($params.libelle_personnalise) } ELSE { NONE };
    LET $language = IF $params.language != NONE { $params.language } ELSE { "fr" };

    LET $item = (SELECT * FROM ONLY $id);
    IF $item == NONE {
        RETURN fn::error_result("CATALOGUE_ITEM_NOT_FOUND", $language, { id: <string> $id });
    };

    -- Contrôle d'immutabilité du socle système
    IF $item.is_system == true AND $enabled = false {
        RETURN fn::error_result("CATALOGUE_ITEM_SYSTEM_IMMUTABLE", $language, { id: <string> $id });
    };

    -- Contrôle d'immutabilité structurelle (code, type, nature_reference)
    IF $params.code != NONE AND string::uppercase(string::trim($params.code)) != $item.code {
        RETURN fn::error_result("CATALOGUE_ITEM_CODE_IMMUTABLE", $language, { code: $item.code });
    };
    IF $params.type != NONE AND <record<catalogue_type>> $params.type != $item.type {
        RETURN fn::error_result("CATALOGUE_ITEM_TYPE_IMMUTABLE", $language, { type: $item.type });
    };
    IF $params.nature_reference != NONE AND string::uppercase(string::trim($params.nature_reference)) != $item.nature_reference {
        RETURN fn::error_result("CATALOGUE_ITEM_NATURE_IMMUTABLE", $language, { nature_reference: $item.nature_reference });
    };

    -- Contrôle de l'unité de référence si modifiée
    IF $unite_id != NONE {
        LET $unite_rec = (SELECT * FROM ONLY $unite_id);
        IF $unite_rec == NONE OR $unite_rec.enabled != true {
            RETURN fn::error_result("CATALOGUE_ITEM_UNITE_INVALID", $language, { unite_reference: <string> $unite_id });
        };
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
        IF $params.tenant_id != NONE AND string::trim($params.tenant_id) != $item.tenant_id {
            RETURN fn::error_result("CATALOGUE_ITEM_TENANT_ID_IMMUTABLE", $language, {
                tenant_id: $item.tenant_id,
                notice: "Le propriétaire tenant_id d'un article est strictement immuable."
            });
        };
        IF $params.is_custom != NONE AND <bool> $params.is_custom == false {
            RETURN fn::error_result("CATALOGUE_ITEM_CUSTOM_CANNOT_CONVERT_MASTER", $language, {
                id: <string> $id,
                notice: "Un article privé ne peut pas être converti en article maître."
            });
        };
    };

    -- Protection des champs synchronisés du Master
    IF $item.is_custom == false AND $item.master_id != NONE {
        IF $params.master_id != NONE AND $params.master_id != $item.master_id {
            RETURN fn::error_result("CATALOGUE_ITEM_MASTER_ID_IMMUTABLE", $language, { master_id: $item.master_id });
        };
        IF $params.is_custom != NONE AND <bool> $params.is_custom == true {
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
               OR ($documents != NONE AND $documents != $item.documents)
               OR ($raw_libelle != NONE AND string::trim($raw_libelle) != $item.libelle)
               OR ($description != NONE AND string::trim($description) != $item.description)
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
            IF $item.enabled == false AND $enabled != NONE AND <bool> $enabled == true {
                RETURN fn::error_result("CATALOGUE_ITEM_SYNC_CANNOT_REACTIVATE_DISABLED", $language, {
                    id: <string> $id,
                    notice: "Une mise à jour Master ne peut jamais réactiver un article désactivé localement par l'organisation cliente."
                });
            };
        };
    };

    -- Validation GS1 si le code-barres est modifié
    LET $final_gtin = IF $code_barre != NONE { $code_barre } ELSE { $item.code_barre };
    IF $code_barre != NONE AND $code_barre != $item.code_barre {
        LET $is_gtin_valid = fn::catalogue_validate_gtin($code_barre);
        IF $is_gtin_valid != true {
            RETURN fn::error_result("CATALOGUE_ITEM_GTIN_INVALID", $language, { code_barre: $code_barre });
        };
        LET $existing_gtin = (SELECT id FROM catalogue_item WHERE code_barre = $code_barre AND id != $id);
        IF array::len($existing_gtin) > 0 {
            RETURN fn::error_result("CATALOGUE_ITEM_GTIN_ALREADY_EXISTS", $language, { code_barre: $code_barre });
        };
    };

    -- Contrôle d'unicité fabricant + ref_fab si modifié
    LET $final_fab = IF $fabricant != NONE { $fabricant } ELSE { $item.fabricant };
    LET $final_ref = IF $ref_fab != NONE { $ref_fab } ELSE { $item.reference_fabricant };
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
        } ELSE IF $enabled != NONE {
            <bool> $enabled
        } ELSE {
            $item.enabled
        }
    } ELSE {
        IF $enabled != NONE { <bool> $enabled } ELSE { $item.enabled }
    };

    LET $updated = (UPDATE ONLY $id MERGE {
        libelle: IF $raw_libelle != NONE { string::trim($raw_libelle) } ELSE { $item.libelle },
        description: IF $description != NONE { string::trim($description) } ELSE { $item.description },
        unite_reference: IF $unite_id != NONE { $unite_id } ELSE { $item.unite_reference },
        enabled: $final_enabled,
        statut_commercial: IF $statut_comm != NONE { $statut_comm } ELSE { $item.statut_commercial },
        documents: IF $documents != NONE { $documents } ELSE { $item.documents },
        conditionnement: IF $conditionnement != NONE { $conditionnement } ELSE { $item.conditionnement },
        code_barre: $final_gtin,
        fabricant: $final_fab,
        marque: IF $marque != NONE { $marque } ELSE { $item.marque },
        reference_fabricant: $final_ref,
        code_interne_client: IF $code_interne != NONE { $code_interne } ELSE { $item.code_interne_client },
        libelle_personnalise: IF $libelle_custom != NONE { $libelle_custom } ELSE { $item.libelle_personnalise },
        updated_at: time::now()
    });

    RETURN fn::result_ok($updated);
} COMMENT "Met à jour les informations éditables d'un élément avec protection des données maîtres";

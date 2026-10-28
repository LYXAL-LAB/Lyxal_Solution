-- ============================================================================
-- FONCTION : fn::ingestion_staged_requalify
-- MODULE   : lyxal_pipeline_ingestion
-- RÔLE     : Requalification formelle et auditable d'un article par le Data Steward
-- SÉCURITÉ : Contrôle de session steward_admin obligatoire et preuve formelle
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::ingestion_staged_requalify($params: object) {
    LET $item_id = <string> $params.item_id;
    LET $language = IF $params.language != NONE { <string> $params.language } ELSE { "fr" };
    
    -- 1. Contrôle d'habilitation strict depuis la session authentifiée
    LET $role = IF $auth != NONE AND $auth.role != NONE { 
        <string> $auth.role 
    } ELSE IF $params._session_auth != NONE AND $params._session_auth.role != NONE { 
        <string> $params._session_auth.role 
    } ELSE { 
        "guest" 
    };

    LET $operator = IF $auth != NONE AND $auth.id != NONE { 
        <string> $auth.id 
    } ELSE IF $params._session_auth != NONE AND $params._session_auth.user_id != NONE { 
        <string> $params._session_auth.user_id 
    } ELSE { 
        "anonymous" 
    };

    IF $role != "steward_admin" {
        RETURN fn::error_result("INGESTION_UNAUTHORIZED_APPROVER", $language, { 
            role: $role, 
            expected_role: "steward_admin",
            message: "Seul un Data Steward authentifié peut requalifier un article"
        });
    };

    -- 2. Validation du statut cible
    LET $target_qual = string::uppercase(string::trim(<string> $params.new_qualification));
    IF $target_qual NOT IN ["VERIFIED", "TO_CONFIRM", "REJECTED"] {
        RETURN fn::error_result("INGESTION_INVALID_QUALIFICATION", $language, { 
            qualification: $target_qual,
            allowed: ["VERIFIED", "TO_CONFIRM", "REJECTED"]
        });
    };

    -- 3. Validation de la justification obligatoire (min 10 caractères)
    LET $justification = IF $params.justification != NONE { string::trim(<string> $params.justification) } ELSE { "" };
    IF string::len($justification) < 10 {
        RETURN fn::error_result("INGESTION_JUSTIFICATION_TOO_SHORT", $language, { 
            length: string::len($justification), 
            min_required: 10 
        });
    };

    -- 4. Recherche de l'article en staging
    LET $clean_id = string::replace($item_id, "ingestion_staged_item:", "");
    LET $item_rec = <record> string::concat('ingestion_staged_item:', $clean_id);
    LET $items = (SELECT * FROM $item_rec);
    IF array::len($items) == 0 {
        RETURN fn::error_result("INGESTION_ITEM_NOT_FOUND", $language, { item_id: $item_id });
    };
    LET $cur = $items[0];

    -- 5. RÈGLE D'OR CTO : Preuve commerciale authentifiée OBLIGATOIRE pour passage en VERIFIED
    LET $proof = IF $params.proof != NONE { $params.proof } ELSE { NONE };
    IF $target_qual == "VERIFIED" {
        IF $proof == NONE {
            RETURN fn::error_result("INGESTION_PROOF_MISSING", $language, {
                item_id: $item_id,
                message: "Toute requalification vers VERIFIED exige une preuve commerciale formelle authentifiée (CommercialProof)"
            });
        };

        LET $proof_ref = IF $proof.proof_reference != NONE { string::trim(<string> $proof.proof_reference) } ELSE { "" };
        LET $source_auth = IF $proof.source_authority != NONE { string::trim(<string> $proof.source_authority) } ELSE { "" };
        LET $proof_type = IF $proof.proof_type != NONE { string::uppercase(string::trim(<string> $proof.proof_type)) } ELSE { "" };

        IF string::len($proof_ref) < 3 OR string::len($source_auth) < 3 {
            RETURN fn::error_result("INGESTION_PROOF_INVALID", $language, {
                proof_reference: $proof_ref,
                source_authority: $source_auth,
                message: "La référence documentaire et l'autorité émettrice de la preuve sont obligatoires"
            });
        };

        IF $proof_type NOT IN ["CERTIFIED_MANUFACTURER_EDI", "SIGNED_VENDOR_CATALOG", "OFFICIAL_TARIFF_CERTIFICATE", "STEWARD_DOCUMENTED_VALIDATION"] {
            RETURN fn::error_result("INGESTION_PROOF_TYPE_UNKNOWN", $language, {
                proof_type: $proof_type
            });
        };
    };

    -- 6. Journalisation et transition d'état atomique
    LET $now = time::now();
    LET $trans = {
        from_state: $cur.qualification,
        to_state: $target_qual,
        triggered_by: $operator,
        reason: $justification,
        transitioned_at: $now,
        proof_reference: IF $target_qual == "VERIFIED" { $proof.proof_reference } ELSE { NONE }
    };

    UPDATE $item_rec SET
        qualification = $target_qual,
        qualification_reason = $justification,
        commercial_proof = IF $target_qual == "VERIFIED" { $proof } ELSE { commercial_proof },
        is_approved = IF $target_qual == "VERIFIED" { true } ELSE { is_approved },
        approved_by = IF $target_qual == "VERIFIED" { $operator } ELSE { approved_by },
        approved_at = IF $target_qual == "VERIFIED" { $now } ELSE { approved_at },
        transitions = array::concat(IF transitions != NONE { transitions } ELSE { [] }, [$trans]);

    RETURN fn::result_ok(true);
} COMMENT "Requalifie formellement un article en staging sous contrôle strict de session steward_admin et exigence de preuve commerciale";

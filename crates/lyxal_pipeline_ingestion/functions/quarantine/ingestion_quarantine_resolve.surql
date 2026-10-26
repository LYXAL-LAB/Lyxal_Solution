-- ============================================================================
-- FONCTION : fn::ingestion_quarantine_resolve
-- MODULE   : lyxal_pipeline_ingestion
-- RÔLE     : Résolution auditable d'une anomalie en quarantaine par le Data Steward
-- SÉCURITÉ : Contrôle de session steward_admin obligatoire
-- RÈGLE CTO: Une correction repasse l'article en TO_CONFIRM, JAMAIS en VERIFIED
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::ingestion_quarantine_resolve($params: object) {
    LET $quarantine_id = <string> $params.quarantine_id;
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
            message: "Seul un Data Steward authentifié peut résoudre une anomalie en quarantaine"
        });
    };

    -- 2. Validation de la justification obligatoire (min 10 caractères)
    LET $justification = IF $params.comment != NONE { 
        string::trim(<string> $params.comment) 
    } ELSE IF $params.justification != NONE { 
        string::trim(<string> $params.justification) 
    } ELSE { 
        "" 
    };

    IF string::len($justification) < 10 {
        RETURN fn::error_result("INGESTION_JUSTIFICATION_TOO_SHORT", $language, { 
            length: string::len($justification), 
            min_required: 10,
            message: "La justification de résolution d'anomalie doit contenir au moins 10 caractères"
        });
    };

    -- 3. Recherche du record de quarantaine
    LET $clean_id = string::replace($quarantine_id, "ingestion_quarantine_record:", "");
    LET $rec_thing = <record> string::concat('ingestion_quarantine_record:', $clean_id);
    LET $records = (SELECT * FROM $rec_thing);
    IF array::len($records) == 0 {
        RETURN fn::error_result("INGESTION_RECORD_NOT_FOUND", $language, { quarantine_id: $quarantine_id });
    };
    LET $q_item = $records[0];

    -- 4. Marquer la quarantaine comme résolue
    LET $now = time::now();
    UPDATE $rec_thing SET
        is_resolved = true,
        resolved_by = $operator,
        resolved_at = $now,
        resolution_comment = $justification;

    -- 5. Si corrections fournies pour un article staged lié
    -- RÈGLE STRICTE CTO : Toute correction d'anomalie repasse l'article en TO_CONFIRM (JAMAIS VERIFIED direct)
    LET $corrections = IF $params.corrections != NONE { $params.corrections } ELSE { NONE };
    LET $staged_item_id = IF $params.staged_item_id != NONE { <string> $params.staged_item_id } ELSE { NONE };

    IF $staged_item_id != NONE {
        LET $clean_staged = string::replace($staged_item_id, "ingestion_staged_item:", "");
        LET $staged_rec = <record> string::concat('ingestion_staged_item:', $clean_staged);
        LET $staged_items = (SELECT * FROM $staged_rec);
        
        IF array::len($staged_items) > 0 {
            LET $cur_staged = $staged_items[0];
            LET $trans = {
                from_state: $cur_staged.qualification,
                to_state: "TO_CONFIRM",
                triggered_by: $operator,
                reason: string::concat("Correction suite anomalie quarantaine: ", $justification),
                transitioned_at: $now
            };

            -- Application des corrections éventuelles de données
            LET $new_gtin = IF $corrections != NONE AND $corrections.corrected_gtin != NONE { 
                <string> $corrections.corrected_gtin 
            } ELSE { 
                $cur_staged.code_barre_gtin 
            };

            LET $new_unit = IF $corrections != NONE AND $corrections.corrected_unit != NONE { 
                <string> $corrections.corrected_unit 
            } ELSE { 
                $cur_staged.unite_reference 
            };

            UPDATE $staged_rec SET
                qualification = "TO_CONFIRM",
                qualification_reason = string::concat("Correction anomalie quarantaine: ", $justification),
                code_barre_gtin = $new_gtin,
                unite_reference = $new_unit,
                transitions = array::concat(IF transitions != NONE { transitions } ELSE { [] }, [$trans]);
        };
    };

    RETURN fn::result_ok(true);
} COMMENT "Résout de manière auditable une anomalie en quarantaine sous contrôle steward_admin et repasse l'article en TO_CONFIRM";

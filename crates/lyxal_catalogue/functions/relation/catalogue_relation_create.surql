-- ============================================================================
-- FONCTION : fn::catalogue_relation_create
-- MODULE   : lyxal_catalogue
-- RÔLE     : Création d'un lien relationnel entre éléments avec contrôles d'intégrité métier
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::catalogue_relation_create($params: object) {
    LET $source_id = <record<catalogue_item>> $params.source;
    LET $cible_id = <record<catalogue_item>> $params.cible;
    LET $type_id = <record<catalogue_relation_type>> $params.relation_type;
    LET $ordre = IF $params.ordre != NONE { <int> $params.ordre } ELSE { 0 };
    LET $commentaire = IF $params.commentaire != NONE { string::trim($params.commentaire) } ELSE { NONE };
    LET $language = IF $params.language != NONE { $params.language } ELSE { "fr" };

    -- Contrôle d'auto-référence
    IF $source_id == $cible_id {
        RETURN fn::error_result("CATALOGUE_RELATION_SELF_REFERENCED", $language, { source: <string> $source_id });
    };

    -- Contrôle d'existence des éléments
    LET $src_rec = (SELECT * FROM ONLY $source_id);
    IF $src_rec == NONE {
        RETURN fn::error_result("CATALOGUE_ITEM_NOT_FOUND", $language, { id: <string> $source_id });
    };
    LET $tgt_rec = (SELECT * FROM ONLY $cible_id);
    IF $tgt_rec == NONE {
        RETURN fn::error_result("CATALOGUE_ITEM_NOT_FOUND", $language, { id: <string> $cible_id });
    };

    -- Contrôle du type de relation
    LET $rel_type = (SELECT * FROM ONLY $type_id);
    IF $rel_type == NONE OR $rel_type.enabled != true {
        RETURN fn::error_result("CATALOGUE_RELATION_TYPE_NOT_FOUND", $language, { id: <string> $type_id });
    };

    -- 1. Contrôle spécifique pour COMMERCIAL_SPECIFICATION (Commerciale -> Générique)
    IF $rel_type.code == "COMMERCIAL_SPECIFICATION" {
        IF $src_rec.nature_reference != "COMMERCIALE" OR $tgt_rec.nature_reference != "GENERIQUE" {
            RETURN fn::error_result("CATALOGUE_RELATION_COMMERCIAL_SPEC_INVALID", $language, { 
                source_nature: $src_rec.nature_reference, 
                cible_nature: $tgt_rec.nature_reference 
            });
        };
    };

    -- 2. Contrôle spécifique pour REMPLACEMENT (Cible active et détection anti-cycle)
    IF $rel_type.code == "REMPLACEMENT" {
        IF $tgt_rec.enabled != true OR $tgt_rec.statut_commercial == "OBSOLETE" {
            RETURN fn::error_result("CATALOGUE_RELATION_REMPLACEMENT_TARGET_INVALID", $language, { 
                cible: <string> $cible_id, 
                statut: $tgt_rec.statut_commercial 
            });
        };
        LET $cycle_res = fn::catalogue_relation_check_cycle({
            source: $source_id,
            cible: $cible_id,
            relation_type: $type_id
        });
        IF $cycle_res == "CYCLE_DETECTED" OR $cycle_res == true {
            RETURN fn::error_result("CATALOGUE_RELATION_REMPLACEMENT_CYCLE", $language, { 
                source: <string> $source_id, 
                cible: <string> $cible_id 
            });
        };
        IF $cycle_res == "DEPTH_EXCEEDED" {
            RETURN fn::error_result("CATALOGUE_RELATION_CYCLE_DEPTH_EXCEEDED", $language, { 
                source: <string> $source_id, 
                cible: <string> $cible_id,
                max_depth: 50
            });
        };
    };

    LET $created = (CREATE catalogue_relation CONTENT {
        source: $source_id,
        cible: $cible_id,
        relation_type: $type_id,
        ordre: $ordre,
        commentaire: $commentaire,
        enabled: true,
        created_at: time::now()
    });

    -- Si bidirectionnelle, création de la réciproque si elle n'existe pas
    IF $rel_type.is_bidirectionnelle == true {
        LET $existing_recip = (SELECT id FROM catalogue_relation WHERE source = $cible_id AND cible = $source_id AND relation_type = $type_id);
        IF array::len($existing_recip) == 0 {
            CREATE catalogue_relation CONTENT {
                source: $cible_id,
                cible: $source_id,
                relation_type: $type_id,
                ordre: $ordre,
                commentaire: $commentaire,
                enabled: true,
                created_at: time::now()
            };
        };
    };

    RETURN fn::result_ok($created[0]);
} COMMENT "Crée une relation transversale entre deux éléments du catalogue avec validation des règles métier";

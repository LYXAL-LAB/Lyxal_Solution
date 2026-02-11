-- ============================================================================
-- Fichier : knowledge/function/enrichment/fn_knowledge_enrich_process_gaps.surql
-- Module : knowledge
-- Fonction : fn::knowledge_enrich_process_gaps()
-- Description : Traite automatiquement les gaps critiques/haute priorité pour générer des propositions
-- ============================================================================

DEFINE FUNCTION fn::knowledge_enrich_process_gaps(
    $severity_filter: option<string>,
    $min_priority: option<int>,
    $content_types: option<array<string>>,
    $generation_method: string,
    $generation_model: option<string>
) {
    -- Default values
    LET $min_priority = IF $min_priority IS NONE {0} ELSE {$min_priority};

    -- Récupérer les gaps éligibles (array d'IDs)
    LET $gaps_sorted = (
        SELECT id, metadata.priority, severity
        FROM knowledge_gap
        WHERE resolution.status = "pending"
            AND metadata.is_active = true
            AND metadata.priority >= $min_priority
            AND (
                $severity_filter IS NONE
                OR severity = $severity_filter
            )
            AND gap_type IN ["missing_content", "incomplete_content"]
            AND topic != NONE
        ORDER BY metadata.priority DESC, severity DESC
    );
    
    LET $gap_ids = (SELECT VALUE id FROM $gaps_sorted);
    
    -- Déterminer les types de contenu à générer selon le type de gap
    LET $default_content_types = ["SYNTAX", "RULE", "EXAMPLE_CORRECT"];
    LET $types_to_use = IF $content_types != NONE { $content_types } ELSE { $default_content_types };
    
    -- Si aucun gap trouvé, retourner immédiatement
    IF array::len($gap_ids) = 0 {
        RETURN {
            success: true,
            gaps_processed: 0,
            proposals_created: 0,
            proposals: [],
            filters: {
                severity_filter: $severity_filter,
                min_priority: $min_priority,
                content_types: $types_to_use,
                generation_method: $generation_method
            },
            processed_at: time::now()
        };
    };
    
    -- Créer les propositions en utilisant array::map pour itérer sur les gaps
    LET $proposals_nested = array::map($gap_ids, |$gap_id| {
        -- Récupérer le gap pour connaître son type
        LET $gap = (SELECT * FROM $gap_id)[0];
        
        -- Déterminer quels types de contenu créer selon le type de gap
        LET $types_for_gap = IF $gap.gap_type = "missing_content" {
            $types_to_use  -- Pour missing_content : tous les types
        } ELSE IF $gap.gap_type = "incomplete_content" {
            ["SYNTAX"]  -- Pour incomplete_content : seulement SYNTAX
        } ELSE {
            []
        };
        
        -- Créer une proposition pour chaque type de contenu
        RETURN array::map($types_for_gap, |$content_type| {
            LET $confidence = IF $gap.gap_type = "missing_content" { 0.7 } ELSE { 0.8 };
            LET $proposal_result = (SELECT * FROM fn::knowledge_enrich_propose_content(
                $gap_id,
                $content_type,
                $generation_method,
                $generation_model,
                $confidence,
                $gap.metadata.priority
            ))[0];
            RETURN $proposal_result;
        });
    });
    
    -- Aplatir le tableau imbriqué en un tableau simple
    LET $proposals = array::flatten($proposals_nested);
    
    -- Filtrer seulement les propositions réussies
    LET $successful_proposals = array::filter($proposals, |$proposal| {
        RETURN $proposal.success = true;
    });
    
    RETURN {
        success: true,
        gaps_processed: array::len($gap_ids),
        proposals_created: array::len($successful_proposals),
        proposals: $successful_proposals,
        filters: {
            severity_filter: $severity_filter,
            min_priority: $min_priority,
            content_types: $types_to_use,
            generation_method: $generation_method
        },
        processed_at: time::now()
    };
};

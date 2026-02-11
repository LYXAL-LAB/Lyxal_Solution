-- ============================================================================
-- Fichier : knowledge/function/enrichment/fn_knowledge_enrich_approve_proposal.surql
-- Module : knowledge
-- Fonction : fn::knowledge_enrich_approve_proposal()
-- Description : Approuve une proposition et la transforme en contenu réel dans knowledge_content
-- ============================================================================

DEFINE FUNCTION fn::knowledge_enrich_approve_proposal(
    $proposal_id: record<knowledge_content_proposal>,
    $approved_by: string,
    $review_notes: option<string>,
    $quality_score: option<number>
) {
    -- Récupérer la proposition
    LET $proposal = (
        SELECT * FROM $proposal_id FETCH topic, content_type
    )[0];
    
    IF $proposal = NONE {
        RETURN {
            success: false,
            error: "Proposal not found",
            proposal_id: $proposal_id
        };
    };
    
    -- Vérifier que la proposition est en état d'être approuvée
    IF $proposal.review.status NOT IN ["draft", "pending_review"] {
        RETURN {
            success: false,
            error: "Proposal cannot be approved in current status",
            current_status: $proposal.review.status,
            proposal_id: $proposal_id
        };
    };
    
    -- Créer le contenu réel dans knowledge_content
    LET $final_quality_score = IF $quality_score != NONE { $quality_score } ELSE { $proposal.metadata.quality_score };
    
    -- Générer un slug final pour le contenu (sans "_proposal")
    LET $final_slug = string::replace($proposal.identity.slug, "_proposal_", "_");
    
    LET $content = CREATE knowledge_content SET
        topic = $proposal.topic,
        identity.content_type = $proposal.content_type,
        identity.slug = $final_slug,
        identity.title_key = $proposal.identity.title_key,
        identity.description_key = $proposal.identity.description_key,
        content.text_key = $proposal.content.text_key,
        content.code = $proposal.content.code,
        content.examples = $proposal.content.examples,
        content.prompt = $proposal.content.prompt,
        content.json = $proposal.content.json,
        metadata.quality_score = $final_quality_score,
        metadata.version_label = $proposal.metadata.version_label,
        metadata.is_active = true;
    
    -- Mettre à jour la proposition pour indiquer qu'elle a été mergée
    UPDATE $proposal_id SET
        review.status = "merged",
        review.reviewed_at = time::now(),
        review.reviewed_by = $approved_by,
        review.review_notes = $review_notes,
        review.merged_content = $content[0].id;
    
    -- Si un gap était associé, le marquer comme résolu
    IF $proposal.gap != NONE {
        UPDATE $proposal.gap SET
            resolution.status = "resolved",
            resolution.resolved_at = time::now(),
            resolution.resolved_by = $approved_by,
            resolution.resolution_content = $content[0].id,
            resolution.notes = "Résolu automatiquement via proposition approuvée";
    };
    
    RETURN {
        success: true,
        proposal_id: $proposal_id,
        content_id: $content[0].id,
        gap_id: $proposal.gap,
        gap_resolved: $proposal.gap != NONE,
        status: "merged"
    };
};


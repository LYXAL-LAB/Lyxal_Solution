-- ============================================================================
-- Fichier : knowledge/function/enrichment/fn_knowledge_enrich_propose_content.surql
-- Module : knowledge
-- Fonction : fn::knowledge_enrich_propose_content()
-- Description : Propose un nouveau contenu basé sur un gap détecté
-- ============================================================================

DEFINE FUNCTION fn::knowledge_enrich_propose_content(
    $gap_id: record<knowledge_gap>,
    $content_type_code: string,
    $generation_method: string,
    $generation_model: option<string>,
    $confidence: number,
    $priority: int
) {
    -- Récupérer le gap et ses informations
    LET $gap = (SELECT * FROM $gap_id)[0];
    
    IF $gap = NONE {
        RETURN {
            success: false,
            error: "Gap not found",
            gap_id: $gap_id
        };
    };
    
    -- Récupérer le topic depuis le gap
    LET $topic_id = IF $gap.topic != NONE { $gap.topic } ELSE { NONE };
    
    IF $topic_id = NONE {
        RETURN {
            success: false,
            error: "Gap has no associated topic",
            gap_id: $gap_id
        };
    };
    
    -- Récupérer le type de contenu
    LET $content_type = (
        SELECT * FROM knowledge_content_type
        WHERE identity.code = $content_type_code
            AND metadata.is_active = true
        LIMIT 1
    )[0];
    
    IF $content_type = NONE {
        RETURN {
            success: false,
            error: "Content type not found",
            content_type_code: $content_type_code
        };
    };
    
    -- Générer un slug unique basé sur le topic et le type
    LET $topic_slug = (SELECT VALUE identity.slug FROM $topic_id)[0];
    LET $uuid_part = string::replace(rand::uuid(), "-", "");
    LET $proposal_slug = $topic_slug + "_" + $content_type_code + "_proposal_" + $uuid_part;
    
    -- Créer la proposition
    LET $proposal = CREATE knowledge_content_proposal SET
        gap = $gap_id,
        topic = $topic_id,
        content_type = $content_type.id,
        identity.slug = $proposal_slug,
        generation.method = $generation_method,
        generation.model = $generation_model,
        generation.generated_at = time::now(),
        generation.confidence = $confidence,
        generation.source_context = $gap.description,
        review.status = "draft",
        metadata.priority = $priority,
        metadata.quality_score = $confidence,
        metadata.is_active = true;
    
    RETURN {
        success: true,
        proposal_id: $proposal[0].id,
        gap_id: $gap_id,
        topic_id: $topic_id,
        content_type_code: $content_type_code,
        slug: $proposal_slug,
        status: "draft"
    };
};


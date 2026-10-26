-- ============================================================================
-- FONCTION : fn::catalogue_composition_check_cycle
-- MODULE   : lyxal_catalogue
-- RÔLE     : Détection robuste de cycles à profondeur arbitraire (parcours récursif)
-- RÈGLE    : Ne jamais retourner false sur coupure technique (garde-fou explicite)
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::catalogue_composition_check_cycle($params: object) {
    LET $parent_id = <record<catalogue_item>> $params.parent_item;
    LET $current_id = <record<catalogue_item>> (IF $params.current_item != NONE { $params.current_item } ELSE { $params.composant_item });
    LET $depth = IF $params.depth != NONE { <int> $params.depth } ELSE { 1 };
    LET $visited = IF $params.visited != NONE { $params.visited } ELSE { [$current_id] };

    -- 1. Cycle direct immédiat (A -> A)
    IF $parent_id == $current_id {
        RETURN true;
    };

    -- Limite technique de sécurité (200 niveaux de nomenclature)
    IF $depth > 200 {
        THROW "CATALOGUE_COMPOSITION_CYCLE_DEPTH_EXCEEDED: Limite technique de profondeur atteinte lors du contrôle anti-cycle.";
    };

    -- 2. Récupère les composants enfants directs de $current_id
    LET $next_items = (SELECT VALUE composant_item FROM catalogue_composition_ligne 
                       WHERE composition.parent_item = $current_id 
                         AND composition.statut IN ["DRAFT", "PUBLISHED"]);

    -- Détection immédiate si le parent est atteint (cycle fermé)
    IF $parent_id IN $next_items {
        RETURN true;
    };

    -- 3. Parcours récursif des composants enfants non encore visités
    FOR $nxt IN $next_items {
        IF !($nxt IN $visited) {
            LET $has_sub = fn::catalogue_composition_check_cycle({
                parent_item: $parent_id,
                current_item: $nxt,
                depth: $depth + 1,
                visited: array::add($visited, $nxt)
            });
            IF $has_sub == true {
                RETURN true;
            };
        };
    };

    RETURN false;
} COMMENT "Vérifie récursivement l'absence de cycles directs ou indirects avec parcours complet du graphe";

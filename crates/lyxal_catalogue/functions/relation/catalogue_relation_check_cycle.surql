-- ============================================================================
-- FONCTION : fn::catalogue_relation_check_cycle
-- MODULE   : lyxal_catalogue
-- RÔLE     : Détection récursive anti-cycles pour les relations orientées (notamment REMPLACEMENT)
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::catalogue_relation_check_cycle($params: object) {
    LET $source = <record<catalogue_item>> $params.source;
    LET $current = <record<catalogue_item>> (IF $params.current != NONE { $params.current } ELSE { $params.cible });
    LET $rel_type = <record<catalogue_relation_type>> $params.relation_type;
    LET $depth = IF $params.depth != NONE { <int> $params.depth } ELSE { 1 };
    LET $visited = IF $params.visited != NONE { $params.visited } ELSE { [$current] };

    -- Cycle direct immédiat (A -> A)
    IF $source == $current {
        RETURN "CYCLE_DETECTED";
    };

    -- Limite technique de sécurité (50 niveaux)
    IF $depth > 50 {
        RETURN "DEPTH_EXCEEDED";
    };

    -- Récupère les cibles directes pointées par $current
    LET $next_items = (SELECT VALUE cible FROM catalogue_relation 
                       WHERE source = $current AND relation_type = $rel_type);

    -- Détection si la source est atteinte
    IF $source IN $next_items {
        RETURN "CYCLE_DETECTED";
    };

    -- Parcours récursif des remplaçants non encore visités
    FOR $nxt IN $next_items {
        IF !($nxt IN $visited) {
            LET $sub_res = fn::catalogue_relation_check_cycle({
                source: $source,
                current: $nxt,
                relation_type: $rel_type,
                depth: $depth + 1,
                visited: array::add($visited, $nxt)
            });
            IF $sub_res == "CYCLE_DETECTED" {
                RETURN "CYCLE_DETECTED";
            };
            IF $sub_res == "DEPTH_EXCEEDED" {
                RETURN "DEPTH_EXCEEDED";
            };
        };
    };

    RETURN "OK";
} COMMENT "Vérifie récursivement l'absence de cycles directs ou indirects dans les relations orientées en distinguant cycle réel et limite de profondeur";

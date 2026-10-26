-- ============================================================================
-- FONCTION : fn::catalogue_categorie_tree
-- MODULE   : lyxal_catalogue
-- RÔLE     : Arborescence complète hiérarchique des catégories
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::catalogue_categorie_tree($params: object) {
    LET $enabled = $params.enabled;

    -- Récupère l'ensemble des catégories
    LET $all_cats = IF $enabled != NONE {
        SELECT * FROM catalogue_categorie WHERE enabled = $enabled ORDER BY ordre ASC, libelle ASC
    } ELSE {
        SELECT * FROM catalogue_categorie ORDER BY ordre ASC, libelle ASC
    };

    -- Sépare les racines (parent IS NONE) des sous-catégories
    LET $roots = array::filter($all_cats, |$c| $c.parent == NONE);

    LET $tree = array::map($roots, |$r| {
        LET $children = array::filter($all_cats, |$c| $c.parent == $r.id);
        RETURN {
            id: $r.id,
            code: $r.code,
            libelle: $r.libelle,
            ordre: $r.ordre,
            enabled: $r.enabled,
            is_system: $r.is_system,
            children: array::map($children, |$ch| {
                LET $sub_children = array::filter($all_cats, |$c| $c.parent == $ch.id);
                RETURN {
                    id: $ch.id,
                    code: $ch.code,
                    libelle: $ch.libelle,
                    ordre: $ch.ordre,
                    enabled: $ch.enabled,
                    is_system: $ch.is_system,
                    children: $sub_children
                };
            })
        };
    });

    RETURN fn::result_ok($tree);
} COMMENT "Retourne l'arborescence structurée des catégories du catalogue";

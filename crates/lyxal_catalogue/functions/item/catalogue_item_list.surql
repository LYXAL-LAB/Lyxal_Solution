-- ============================================================================
-- FONCTION : fn::catalogue_item_list
-- MODULE   : lyxal_catalogue
-- RÔLE     : Liste paginée et filtrable des éléments du catalogue
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::catalogue_item_list($params: object) {
    LET $report = fn::validation_object_execute($params, {
        fields: {
            type: { pipeline: [{ rule: "record", options: { expected_table: "catalogue_type" } }] },
            categorie: { pipeline: [{ rule: "record", options: { expected_table: "catalogue_categorie" } }] },
            enabled: { pipeline: [{ rule: "boolean" }] },
            search: { pipeline: [{ rule: "optional_string", options: { max_length: 255 } }] },
            limit: { pipeline: [{ rule: "integer", options: { min_value: 1, max_value: 200 } }], default: 50 },
            start: { pipeline: [{ rule: "integer", options: { min_value: 0, max_value: 1000000 } }], default: 0 },
            language: { pipeline: [{ rule: "language_code", options: { allow_alpha3: false } }], default: "fr" }
        },
        unknown_keys: "reject"
    }, 40);
    IF !$report.valid {
        RETURN fn::error_result("CATALOGUE_INVALID_PARAMETERS", IF type::is_string($params.language) { $params.language } ELSE { NONE }, { fields: $report.by_field });
    };
    LET $p = fn::sanitize_object_execute($report.value, {
        fields: {
            search: { pipeline: [{ rule: "lowercase" }] }
        },
        unknown_keys: "keep"
    }, 40);
    LET $type = $p.type;
    LET $categorie = $p.categorie;
    LET $enabled = $p.enabled;
    LET $search = $p.search;
    LET $limit = $p.limit;
    LET $start = $p.start;
    LET $language = $p.language;

    -- Locataire de la session : sa personnalisation et sa disponibilité accompagnent chaque article maître
    LET $tenant = fn::catalogue_caller({}).tenant;

    -- Si filtrage par catégorie demandé, on sélectionne via catalogue_item_categorie
    LET $category_item_ids = IF $categorie != NONE {
        (SELECT VALUE item FROM catalogue_item_categorie WHERE categorie = $categorie)
    } ELSE {
        NONE
    };

    -- Personnalisations du locataire, lues une fois et rangées par article : le libellé affiché et
    -- la disponibilité se calculent sans sous-requête sur `$parent` (vide quand la fonction est
    -- appelée depuis une fermeture : le tri et le filtre retomberaient sur le référentiel).
    LET $personnalisations = IF $tenant == NONE { [] } ELSE {
        (SELECT item, libelle_personnalise, enabled FROM catalogue_item_personnalisation WHERE tenant = $tenant)
    };
    LET $libelles = object::from_entries($personnalisations.filter(|$row| $row.libelle_personnalise != NONE).map(|$row| [<string> $row.item, $row.libelle_personnalise]));
    LET $desactives = $personnalisations.filter(|$row| $row.enabled == false).map(|$row| $row.item);

    -- Tri sur le libellé affiché au locataire : son libellé personnalisé s'il existe, sinon celui
    -- du référentiel ; le code de l'article, unique, départage les libellés égaux (ordre total :
    -- deux pages ne se recouvrent pas). La clé de tri reste parmi les champs lus (une clé absente
    -- peut être ignorée par le moteur) et est retirée de chaque article avant le renvoi.
    LET $records = (SELECT *,
            ((IF is_custom == false { $libelles[<string> id] } ELSE { NONE }) ?? libelle) AS libelle_affiche
        FROM catalogue_item WHERE
        ($type == NONE OR type = $type) AND
        -- enabled filtre la disponibilité pour le locataire de la session (article actif et non
        -- désactivé par lui)
        ($enabled == NONE OR (enabled AND !(is_custom == false AND id IN $desactives)) = $enabled) AND
        ($category_item_ids == NONE OR id IN $category_item_ids) AND
        ($search == NONE OR string::lowercase(code) CONTAINS $search OR string::lowercase(libelle) CONTAINS $search)
        ORDER BY libelle_affiche ASC, code ASC LIMIT $limit START $start
    );

    RETURN fn::result_ok($records.map(|$item| {
        LET $personnalisation = IF $item.is_custom == false AND $tenant != NONE {
            (SELECT libelle_personnalise, code_interne_client, enabled FROM ONLY catalogue_item_personnalisation WHERE item = $item.id AND tenant = $tenant LIMIT 1)
        } ELSE { NONE };
        RETURN object::extend(object::remove($item, "libelle_affiche"), {
            personnalisation: $personnalisation,
            disponible: $item.enabled AND ($personnalisation.enabled ?? true)
        });
    }));
} COMMENT "Liste paginée des éléments du catalogue avec multi-filtres (type, catégorie, disponibilité pour le locataire de la session, recherche) ; chaque article porte la personnalisation du locataire (ou NONE) et sa disponibilité pour lui ; triée sur le libellé affiché (libellé personnalisé du locataire s'il existe, sinon libellé du référentiel) puis sur le code de l'article (ordre total)";

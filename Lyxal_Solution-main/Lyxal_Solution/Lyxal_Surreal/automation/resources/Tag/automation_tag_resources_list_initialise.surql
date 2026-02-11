-- =================================================================================================
-- |
-- | Fichier : automation_tag_resources_list_initialise.surql
-- | Module : automation
-- | Description : Initialise la fonction de listing des tags.
-- |
-- =================================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::automation_tag_resources_list_initialise(
    $parent_run_id: option<string>
) {
    -- Paramètres
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_automation'];
    LET $run_id = rand::uuid();

    -- Journalisation: début
    fn::system_log_helper_initialise(
        'function', 'start', 'automation_tag_resources_list',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    -- Définition de la fonction
    DEFINE FUNCTION IF NOT EXISTS fn::automation_tag_resources_list(
        $name_contains: option<string>,
        $sort_order: option<string>,
        $limit: option<number>,
        $start: option<number>
    ) {
        LET $sort = $sort_order ?? 'ASC';
        LET $lim = $limit ?? 50;
        LET $st = $start ?? 0;

        -- 1. Obtenir le nombre total d'enregistrements correspondants
        LET $total = (
            SELECT count() FROM automation_tag
            WHERE ($name_contains = NONE OR name CONTAINS $name_contains)
            GROUP ALL
        )[0].count ?? 0;

        -- Si aucun résultat, retourner une réponse vide immédiatement
        IF $total = 0 {
            RETURN {
                data: [],
                total: 0
            };
        };

        -- 2. Obtenir les données paginées et triées
        LET $data = IF $sort = 'DESC' {
            RETURN (
                SELECT * FROM automation_tag
                WHERE ($name_contains = NONE OR name CONTAINS $name_contains)
                ORDER BY name DESC
                LIMIT $lim
                START $st
            );
        } ELSE {
            RETURN (
                SELECT * FROM automation_tag
                WHERE ($name_contains = NONE OR name CONTAINS $name_contains)
                ORDER BY name ASC
                LIMIT $lim
                START $st
            );
        };

        -- 3. Retourner les données et le total
        RETURN {
            data: $data,
            total: $total
        };
    }
    COMMENT 'Récupère une liste de tags, avec des options de filtre et de tri, et inclut le 
    nombre total pour la pagination.'
    PERMISSIONS FULL;

    -- Journalisation: fin
    fn::system_log_helper_initialise(
        'function', 'done', 'automation_tag_resources_list',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    RETURN {
        success: true,
        run_id: $run_id,
        parent_run_id: $parent_run_id
    };
}
COMMENT 'Initialise la fonction de listing des tags.'
PERMISSIONS FULL;

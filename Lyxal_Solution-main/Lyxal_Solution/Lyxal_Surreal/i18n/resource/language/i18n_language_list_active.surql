-- =============================================================================================
-- |
-- | Fichier     : i18n_language_list_active.surql
-- | Module      : i18n
-- | Description : Récupère la liste de toutes les langues actives, avec leur nom traduit.
-- |               Gère le cas où la liste est vide.
-- |
-- | Remarques   :
-- |   - Conçue pour être utilisée par le frontend pour peupler les sélecteurs de langue.
-- |
-- | Paramètres  :
-- |   - $langue_id: string - La langue dans laquelle traduire les noms des langues.
-- |   - $user_id: record<user> - L'utilisateur effectuant la requête.
-- |   - $parent_run_id: option<string> - L'ID du run parent, si applicable.
-- |
-- =============================================================================================

DEFINE FUNCTION fn::i18n_language_list_active(
    $langue_id: string,
    $user_id: record<user>,
    $parent_run_id: option<string>
) {
    -- 1. Définir le contexte de l'opération
    LET $operation = {
        run_id: rand::uuid(),
        parent_run_id: $parent_run_id,
        function_id: "fn::i18n_language_list_active"
    };

    -- 2. Récupérer l'URL de base du CDN pour la concaténation
    LET $cdn_base_url = (SELECT VALUE asset_configuration.cdn_base_url FROM app_configuration:default)[0];

    -- 3. Sélectionner, enrichir ET trier les langues en une seule requête atomique
    LET $languages_sorted = (
        SELECT 
            *, 
            (
                SELECT VALUE text 
                FROM i18n_translation 
                WHERE 
                    in = $parent.key.name AND out = <record>$langue_id
            )[0] ?? name AS translated_name,
            
            IF icon_drapeau.path THEN
                string::concat($parent.$cdn_base_url, icon_drapeau.path)
            ELSE
                NONE
            END AS flag_url

        FROM i18n_language
        WHERE isActive = true
        FETCH icon_drapeau
        ORDER BY translated_name ASC
    );

    -- 4. Gérer le cas où la liste est vide
    IF array::len($languages_sorted) = 0 {
        RETURN fn::lib_standard_return(
            "i18n.language.list.empty",
            $operation, 
            $langue_id, 
            { data: [] },
            { table_id: "i18n_language" }, 
            NONE, 
            $user_id, 
            NONE, 
            NONE, 
            {}, 
            {}
        );
    };
    
    -- 5. Retourner le résultat final
    RETURN fn::lib_standard_return(
        "i18n.language.list.success",
        $operation, 
        $langue_id, 
        { data: $languages_sorted },
        { table_id: "i18n_language" }, 
        NONE, 
        $user_id, 
        NONE, 
        NONE, 
        {}, 
        {}
    );
};

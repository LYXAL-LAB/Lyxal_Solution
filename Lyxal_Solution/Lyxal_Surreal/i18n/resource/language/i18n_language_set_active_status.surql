-- =============================================================================================
-- |
-- | Fichier     : i18n_language_set_active_status.surql
-- | Module      : i18n
-- | Description : Active ou désactive une ou plusieurs langues, avec un log individuel pour
-- |               chaque modification.
-- |
-- | Paramètres  :
-- |   - $lang_codes: array<string> - La liste des codes de langue à modifier.
-- |   - $is_active: bool          - Le nouvel état d'activation (true ou false).
-- |   - $langue_id: string        - L'ID de la langue pour la traduction des retours.
-- |   - $user_id: record<user>     - L'utilisateur effectuant l'opération.
-- |   - $parent_run_id: option<string> - L'ID du run parent, si applicable.
-- |
-- =============================================================================================

DEFINE FUNCTION fn::i18n_language_set_active_status(
    $lang_codes: array<string>,
    $is_active: bool,
    $langue_id: string,
    $user_id: record<user>,
    $parent_run_id: option<string>
) {
    -- 1. Définir le contexte de l'opération de lot
    LET $batch_run_id = rand::uuid();
    LET $operation = {
        run_id: $batch_run_id,
        parent_run_id: $parent_run_id,
        function_id: "function_i18n_language_set_active_status"
    };
    
    -- 2. Vérifier que tous les codes fournis existent (logique d'erreur)
    LET $found_codes = SELECT VALUE code FROM i18n_language WHERE code IN $lang_codes;
    IF array::len($found_codes) != array::len($lang_codes) {
        LET $invalid_codes = array::difference($lang_codes, $found_codes);
        RETURN fn::lib_standard_return(
            "i18n.language.some_not_found", 
            $operation,
            $langue_id,
            { invalid_codes: $invalid_codes },
            { table_id: "table_i18n_language", id: $lang_codes },
            NONE, $user_id, NONE, NONE, {}, {}
        );
    };

    -- 3. Boucler sur chaque langue pour la mettre à jour et la logger individuellement
    FOR $lang_code IN $lang_codes {
        
        -- a. Capturer l'état "avant" pour cette langue unique
        LET $before_state = (SELECT * FROM i18n_language WHERE code = $lang_code)[0];

        -- b. Effectuer la mise à jour et capturer l'état "après"
        LET $after_state = (UPDATE i18n_language SET isActive = $is_active WHERE code = $lang_code RETURN AFTER)[0];

        -- c. Créer le log individuel pour cette modification
        fn::log_create_record(
            { success: true, reason_key: type::thing('error_code', 'i18n.language.update.success') },
            { run_id: rand::uuid(), parent_run_id: $batch_run_id, function_id: "function_i18n_language_set_active_status" },
            { table_id: "table_i18n_language", id: $lang_code },
            NONE,
            {},
            $user_id,
            {},
            { data: $after_state },
            $before_state,
            $after_state
        );
    };

    -- 4. Récupérer l'état final de toutes les langues modifiées pour la réponse
    LET $final_updated_languages = SELECT * FROM i18n_language WHERE code IN $lang_codes;

    -- 5. Retourner une réponse de succès globale pour le lot
    RETURN fn::lib_standard_return(
        "i18n.language.update_batch.success",
        $operation,
        $langue_id,
        { data: $final_updated_languages },
        { table_id: "table_i18n_language", id: $lang_codes },
        NONE,
        $user_id,
        NONE,
        NONE,
        {},
        {}
    );
};

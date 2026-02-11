-- =================================================================================================
-- |
-- | Fichier : automation_tag_resources_update_initialise.surql
-- | Module : automation
-- | Description : Initialise la fonction de mise à jour de tag pour les noeuds d'automatisation.
-- |
-- =================================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::automation_tag_resources_update_initialise(
    $parent_run_id: option<string>
) {
    -- Paramètres
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_automation'];
    LET $run_id = rand::uuid();

    -- Journalisation: début
    fn::system_log_helper_initialise(
        'function', 'start', 'automation_tag_resources_update',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    -- Définition de la fonction
    DEFINE FUNCTION IF NOT EXISTS fn::automation_tag_resources_update(
        $id: string,
        $etag: number,
        $is_visible: option<bool>,
        $is_editable: option<bool>,
        $color: option<string>
    ) {
        -- 1. Récupérer le tag et vérifier l'ETag
        LET $tag = fn::automation_tag_resources_get_by_id($id);

        IF $tag.etag != $etag {
            THROW "Le tag a été modifié par un autre utilisateur. Veuillez rafraîchir les données et réessayer.";
        };

        -- 2. Préparer les données de mise à jour
        LET $update_data = {};

        IF $is_visible != NONE {
            $update_data.is_visible = $is_visible;
        };
        IF $is_editable != NONE {
            $update_data.is_editable = $is_editable;
        };
        IF $color != NONE {
            LET $validated = fn::system_validate_color_bulk([$color]);
            IF !$validated.success {
                THROW "La couleur fournie est invalide.";
            };
            IF $validated.valids[0].type != 'daisyui' {
                THROW "La couleur doit être un nom de thème daisyUI (ex: primary, success).";
            };
            $update_data.color = $validated.valids[0].original;
        };

        -- Si aucune donnée n'est à mettre à jour, retourner le tag actuel.
        IF object::keys($update_data) = [] {
            RETURN $tag;
        };

        -- 3. Mettre à jour le tag et incrémenter l'ETag
        -- On ajoute les champs de versioning à l'objet de mise à jour
        $update_data.etag = $tag.etag + 1;
        $update_data.updated_at = time::now();

        LET $updated_tag = UPDATE $tag.id MERGE $update_data;
        
        RETURN $updated_tag[0];
    }
    COMMENT 'Met à jour un tag existant après vérification de l\'ETag.'
    PERMISSIONS FULL;

    -- Journalisation: fin
    fn::system_log_helper_initialise(
        'function', 'done', 'automation_tag_resources_update',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    RETURN {
        success: true,
        run_id: $run_id,
        parent_run_id: $parent_run_id
    };
}
COMMENT 'Initialise la fonction de mise à jour de tag pour les noeuds d\'automatisation.'
PERMISSIONS FULL;

-- =================================================================================================
-- |
-- | Fichier : deploy_log_helper.surql
-- | Module : deploy
-- | Description : Helper de journalisation unifié pour les wrappers de déploiement.
-- |
-- =================================================================================================
        -- Définition de la fonction helper
    DEFINE FUNCTION IF NOT EXISTS fn::deploy_log_helper(
        $type: string, -- 'module', 'table', 'function',     
        $status: string, -- 'start', 'done' ou 'inprogress'
        $result: string, -- 'initialise', 'success', 'advanced', 'error','warning','info', 'failure'
        $target_name: string, -- ex: 'Organisation'
        $run_id: string, -- ex: '123e4567-e89b-12d3-a456-426614174000'
        $parent_run_id: string, -- ex: '123e4567-e89b-12d3-a456-426614174000'
        $extra_tags: option<array<string>>,
        $steps_number: number,
        $steps_success: number,
        $steps_total: number
    ) {
        -- Construction des tags de base
        LET $phase_tag = 'orchestration_deploy';
        LET $action_tag = 'deploy_create';
        LET $type_tag = string::concat('deploy_', $type);
        LET $status_tag = string::concat('deploy_', $status);
        LET $result_tag = string::concat('deploy_', $result);

        -- Assemblage des tags
        LET $tags = [$phase_tag, $type_tag, $action_tag, $status_tag, $result_tag];
        LET $final_tags = array::union($tags, ($extra_tags OR []));

        -- Construction du message (sans string::uppercase_first)
        LET $statusLabel = 
            IF $status == 'start' 
            THEN 'Début de l\'opération ' 
            ELSE IF $status == 'inprogress' 
            THEN 'En cours de l\'opération ' 
            ELSE IF $status == 'done' 
            THEN 'Fin de l\'opération ' 
            END;
        LET $message = $statusLabel  + $phase + ": " + $action + " " + $type +  " `" + $target_name
         + "`";

        ---- Construction des détails
        -- Construction de message résultat
        LET $steps_total_s = <string>($steps_total OR 0);
        LET $steps_number_s = <string>($steps_number OR 0);
        LET $steps_success_s = <string>($steps_success OR 0);

        LET $message_etape = 
            IF $status == 'start' 
            THEN 'Initialisation de l\'opération : ' + $steps_total_s + ' étapes à réaliser' 
            ELSE IF $status == 'inprogress' 
            THEN 'En cours de l\'opération : ' + $steps_number_s + '/' + $steps_total_s + 
            ' étapes.'
            ELSE IF $status == 'done' 
            THEN 'Fin de l\'opération : ' + $steps_success_s + '/' + $steps_total_s + 
            ' étapes réalisées'
            END;

        LET $message_result = 
            IF $result == 'advanced' 
            THEN 'Opération avancée:'
            ELSE IF $result == 'success' 
            THEN 'Opération réussie:'
            ELSE IF $result == 'failure' 
            THEN 'Opération échouée:'
            ELSE IF $result == 'error' 
            THEN 'Opération en erreur:'
            ELSE IF $result == 'warning' 
            THEN 'Opération avec avertissement:'
            ELSE IF $result == 'info' 
            THEN 'Opération avec information:'
            END;

        -- Dérivés pour l'UI
        LET $progress_pct = IF ($steps_total OR 0) > 0 THEN math::round((($steps_success OR 0) * 100) / ($steps_total OR 0)) ELSE 0 END;
        LET $severity = 
            IF $result == 'error' OR $result == 'failure' THEN 'error'
            ELSE IF $result == 'warning' THEN 'warning'
            ELSE 'info' END;

        -- Détails structurés (lisibles côté UI)
        LET $details = {
            run: {
                run_id: $run_id,
                parent_run_id: $parent_run_id
            },
            operation: {
                phase: $phase,
                type: $type,
                action: $action,
                status: $status,
                result: $result,
                target_name: $target_name
            },
            steps: {
                number: $steps_number OR 0,
                success: $steps_success OR 0,
                total: $steps_total OR 0,
                progress_pct: $progress_pct
            },
            messages: {
                summary: $message,
                result: $message_result,
                step: $message_etape
            },
            ui: {
                severity: $severity,
                progress_pct: $progress_pct
            }
        };


        -- Création directe de l'enregistrement de log
        LET $distinct_tag_names = array::distinct($final_tags);
        LET $tag_records = array::map(
          array::filter($distinct_tag_names, |$s| $s != NONE && $s != ''),
          |$s| type::thing('system_tag', $s)
        );

        LET $created = CREATE system_log SET
          timestamp = time::now(),
          tags      = $tag_records,
          details   = $details;

        RETURN { success: true, log: $created, details: $details };
    }
    COMMENT "Helper unifié pour journaliser start/done/inprogress avec tags et résumé d\'étapes."
    PERMISSIONS FULL;

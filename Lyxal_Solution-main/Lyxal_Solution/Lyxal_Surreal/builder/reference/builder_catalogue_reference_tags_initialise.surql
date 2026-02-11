DEFINE FUNCTION fn::builder_catalogue_reference_tags(
        $parent_run_id: option<string>
    ) {
        LET $parent_run_id = $parent_run_id OR NONE;
        LET $run_id = rand::uuid();
        LET $local_log_extra_tags = ['module_builder', 'sub_module_builder_catalogue', 'log_reference_tags'];

        fn::system_log_create_record_system(
            array::union(['log_function', 'log_start'], $local_log_extra_tags),
            'Start: création des tags de référence pour les types du catalogue',
            { run_id: $run_id, parent_run_id: $parent_run_id }
        );

        -- Création des tags de type
        LET $tags_to_create = [
            -- Tags de Type
            { name: 'builder_type_module', label: 'Type - Module', description: 'Tag pour les éléments de type Module.', color: '#3498DB', order: 100 },
            { name: 'builder_type_sub_module', label: 'Type - Sous-Module', description: 'Tag pour les éléments de type Sous-Module.', color: '#2980B9', order: 110 },
            { name: 'builder_type_table', label: 'Type - Table', description: 'Tag pour les éléments de type Table.', color: '#1ABC9C', order: 120 },
            { name: 'builder_type_function', label: 'Type - Fonction', description: 'Tag pour les éléments de type Fonction.', color: '#16A085', order: 130 },
            
            -- Tags de Déploiement
            { name: 'builder_deploy_core', label: 'Deploy - Core', description: 'Élément essentiel au cœur du système.', color: '#C0392B', order: 200 },
            { name: 'builder_deploy_addon', label: 'Deploy - Addon', description: 'Extension ou plugin.', color: '#27AE60', order: 210 },
            { name: 'builder_deploy_optional', label: 'Deploy - Optional', description: 'Élément optionnel.', color: '#7F8C8D', order: 220 },
            { name: 'builder_deploy_required', label: 'Deploy - Required', description: 'Élément obligatoire au déploiement.', color: '#D35400', order: 230 },

            -- Tags de Statut
            { name: 'builder_status_active', label: 'Status - Active', description: 'Élément actif et utilisable.', color: '#2ECC71', order: 300 },
            { name: 'builder_status_inactive', label: 'Status - Inactive', description: 'Élément inactif ou désactivé.', color: '#95A5A6', order: 310 },
            { name: 'builder_status_deprecated', label: 'Status - Deprecated', description: 'Élément obsolète et déprécié.', color: '#E74C3C', order: 320 },
            { name: 'builder_status_archived', label: 'Status - Archived', description: 'Élément archivé.', color: '#BDC3C7', order: 330 },

            -- Tags de Catégorie
            { name: 'builder_category_system', label: 'Category - System', description: 'Élément interne au système.', color: '#34495E', order: 400 },
            { name: 'builder_category_custom', label: 'Category - Custom', description: 'Élément personnalisé ou ajouté.', color: '#16A085', order: 410 },
            { name: 'builder_category_api', label: 'Category - API', description: 'Concerne une API ou une intégration externe.', color: '#3498DB', order: 420 },
            { name: 'builder_category_ui', label: 'Category - UI', description: 'Concerne l interface utilisateur.', color: '#8E44AD', order: 430 },
            { name: 'builder_category_relation', label: 'Category - Relation', description: 'Définit une relation (edge) entre des enregistrements.', color: '#3498DB', order: 440 },
            { name: 'builder_category_audit', label: 'Category - Audit', description: 'Trace les changements et l activité.', color: '#E67E22', order: 450 },
            { name: 'builder_category_catalog', label: 'Category - Catalog', description: 'Contient des métadonnées ou une liste de référence.', color: '#8E44AD', order: 460 },
            { name: 'builder_category_config', label: 'Category - Config', description: 'Contient des paramètres de configuration.', color: '#9B59B6', order: 470 },
            { name: 'builder_category_data', label: 'Category - Data', description: 'Contient des données métier principales.', color: '#16A085', order: 480 },

            -- Tags de Schéma (spécifique aux tables)
            { name: 'builder_table_schema_schemafull', label: 'Table Schema - SchemaFull', description: 'Le schéma de la table est strict.', color: '#F39C12', order: 500 },
            { name: 'builder_table_schema_schemaless', label: 'Table Schema - Schemaless', description: 'Le schéma de la table est flexible.', color: '#F1C40F', order: 510 },

            -- Tags de Type de Schéma (spécifique aux tables)
            { name: 'builder_table_schema_type_any', label: 'Table Schema Type - Any', description: 'La table peut contenir tout type d enregistrement.', color: '#34495E', order: 600 },
            { name: 'builder_table_schema_type_normal', label: 'Table Schema Type - Normal', description: 'La table est une table standard (noeud).', color: '#2C3E50', order: 610 },
            { name: 'builder_table_schema_type_relation', label: 'Table Schema Type - Relation', description: 'La table est une table de relation (edge).', color: '#3498DB', order: 620 },

            -- Tags de Rôle de Fonction
            { name: 'builder_function_role_validate', label: 'Function Role - Validate', description: 'Fonction de validation de données.', color: '#f1c40f', order: 700 },
            { name: 'builder_function_role_trigger', label: 'Function Role - Trigger', description: 'Fonction déclenchée par un événement.', color: '#e67e22', order: 701 },
            { name: 'builder_function_role_transform', label: 'Function Role - Transform', description: 'Fonction de transformation de données.', color: '#e74c3c', order: 702 },
            { name: 'builder_function_role_compute', label: 'Function Role - Compute', description: 'Fonction de calcul.', color: '#9b59b6', order: 703 },
            { name: 'builder_function_role_io', label: 'Function Role - I/O', description: 'Fonction d entrée/sortie.', color: '#34495e', order: 704 },
            { name: 'builder_function_role_auth', label: 'Function Role - Auth', description: 'Fonction liée à l authentification.', color: '#c0392b', order: 705 },
            { name: 'builder_function_role_policy', label: 'Function Role - Policy', description: 'Fonction de politique de sécurité.', color: '#d35400', order: 706 },
            { name: 'builder_function_role_analytics', label: 'Function Role - Analytics', description: 'Fonction d analyse de données.', color: '#27ae60', order: 707 },
            { name: 'builder_function_role_integration', label: 'Function Role - Integration', description: 'Fonction d intégration avec un service tiers.', color: '#2980b9', order: 708 },
            { name: 'builder_function_role_notification', label: 'Function Role - Notification', description: 'Fonction d envoi de notifications.', color: '#8e44ad', order: 709 },
            { name: 'builder_function_role_cache', label: 'Function Role - Cache', description: 'Fonction de gestion de cache.', color: '#16a085', order: 710 },
            { name: 'builder_function_role_migration', label: 'Function Role - Migration', description: 'Fonction de migration de données.', color: '#7f8c8d', order: 711 },
            { name: 'builder_function_role_deploy', label: 'Function Role - Deploy', description: 'Fonction de déploiement.', color: '#2c3e50', order: 712 },
            { name: 'builder_function_role_util', label: 'Function Role - Util', description: 'Fonction utilitaire.', color: '#95a5a6', order: 713 },
            { name: 'builder_function_role_sanitize', label: 'Function Role - Sanitize', description: 'Fonction de nettoyage de données.', color: '#bdc3c7', order: 714 },
            { name: 'builder_function_role_initialise', label: 'Function Role - Initialise', description: 'Fonction d initialisation.', color: '#1abc9c', order: 715 },
            { name: 'builder_function_role_record', label: 'Function Role - Record', description: 'Fonction de gestion d enregistrements (CRUD).', color: '#3498db', order: 716 }
        ];

        LET $results = [];
        FOR $tag IN $tags_to_create {
            LET $result = fn::system_tag_create_record_system(
                $tag.name, $tag.label, $tag.description,
                $tag.color, $tag.order, true, 
                ['log_data_reference'], -- $log_extra_tags
                $run_id                 -- $parent_run_id
            );
            LET $results = array::push($results, $result);
        };

        fn::system_log_create_record_system(
            array::union(['log_function', 'log_done', 'log_success'], $local_log_extra_tags),
            'Done: création des tags de référence terminée.',
            { run_id: $run_id, parent_run_id: $parent_run_id, count: array::len($results) }
        );
        
        RETURN {
            success: true,
            run_id: $run_id,
            parent_run_id: $parent_run_id,
            data: $results
        };
    }
    COMMENT 'Crée les tags de référence pour le catalogue.'
    PERMISSIONS FULL;

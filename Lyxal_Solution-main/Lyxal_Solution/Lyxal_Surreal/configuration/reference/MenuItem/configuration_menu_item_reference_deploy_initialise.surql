-- =============================================================================================
-- |
-- | Fichier : configuration_menu_item_reference_deploy_initialise.surql
-- | Module : configuration / MenuItem
-- | Description : Données de référence pour `ui_menu_item` (menu par défaut).
-- |
-- =============================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::configuration_menu_item_reference_deploy_initialise(
    $parent_run_id: option<string>
) {
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_configuration'];
    LET $run_id = rand::uuid();

    fn::system_log_helper_deploy_initialise(
        'reference', 'start', 'MenuItem reference',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    DEFINE FUNCTION IF NOT EXISTS fn::configuration_menu_item_reference_deploy(
        $parent_run_id: option<string>
    ) {
        LET $parent_run_id = $parent_run_id OR NONE;
        LET $log_extra_tags = ['module_configuration'];
        LET $run_id = rand::uuid();

        -- Dashboard
        fn::i18n_key_create('menu.dashboard.name', NONE);
        fn::i18n_key_create('menu.dashboard.tooltip', NONE);
        fn::i18n_translation_upsert('menu.dashboard.name', 'fr', 'Tableau de bord');
        fn::i18n_translation_upsert('menu.dashboard.tooltip', 'fr', 'Accéder au tableau de bord');
        fn::configuration_menu_item_create('dashboard', 'menu.dashboard.name', 'menu.dashboard.tooltip', 'dashboard', 10, NONE, 'dashboard', NONE, true);

        -- Investors
        fn::i18n_key_create('menu.investors.name', NONE);
        fn::i18n_key_create('menu.investors.tooltip', NONE);
        fn::i18n_translation_upsert('menu.investors.name', 'fr', 'Investisseurs');
        fn::i18n_translation_upsert('menu.investors.tooltip', 'fr', 'Gérer les investisseurs');
        fn::configuration_menu_item_create('investors', 'menu.investors.name', 'menu.investors.tooltip', 'investors', 20, NONE, 'investors', NONE, true);

        -- Platforms
        fn::i18n_key_create('menu.platforms.name', NONE);
        fn::i18n_key_create('menu.platforms.tooltip', NONE);
        fn::i18n_translation_upsert('menu.platforms.name', 'fr', 'Plateformes');
        fn::i18n_translation_upsert('menu.platforms.tooltip', 'fr', 'Gérer les plateformes');
        fn::configuration_menu_item_create('platforms', 'menu.platforms.name', 'menu.platforms.tooltip', 'platforms', 30, NONE, 'platforms', NONE, true);

        -- Analytics
        fn::i18n_key_create('menu.analytics.name', NONE);
        fn::i18n_key_create('menu.analytics.tooltip', NONE);
        fn::i18n_translation_upsert('menu.analytics.name', 'fr', 'Analyses');
        fn::i18n_translation_upsert('menu.analytics.tooltip', 'fr', 'Consulter les analyses');
        fn::configuration_menu_item_create('analytics', 'menu.analytics.name', 'menu.analytics.tooltip', 'analytics', 40, NONE, 'analytics', NONE, true);

        -- Finance
        fn::i18n_key_create('menu.finance.name', NONE);
        fn::i18n_key_create('menu.finance.tooltip', NONE);
        fn::i18n_translation_upsert('menu.finance.name', 'fr', 'Finance');
        fn::i18n_translation_upsert('menu.finance.tooltip', 'fr', 'Suivre la finance');
        fn::configuration_menu_item_create('finance', 'menu.finance.name', 'menu.finance.tooltip', 'finance', 50, NONE, 'finance', NONE, true);

        -- Integrations
        fn::i18n_key_create('menu.integrations.name', NONE);
        fn::i18n_key_create('menu.integrations.tooltip', NONE);
        fn::i18n_translation_upsert('menu.integrations.name', 'fr', 'Intégrations');
        fn::i18n_translation_upsert('menu.integrations.tooltip', 'fr', 'Gérer les intégrations');
        fn::configuration_menu_item_create('integrations', 'menu.integrations.name', 'menu.integrations.tooltip', 'integrations', 60, NONE, 'integrations', NONE, true);

        -- Settings
        fn::i18n_key_create('menu.settings.name', NONE);
        fn::i18n_key_create('menu.settings.tooltip', NONE);
        fn::i18n_translation_upsert('menu.settings.name', 'fr', 'Paramètres');
        fn::i18n_translation_upsert('menu.settings.tooltip', 'fr', 'Configurer l’application');
        fn::configuration_menu_item_create('settings', 'menu.settings.name', 'menu.settings.tooltip', 'settings', 90, NONE, 'settings', NONE, true);

        RETURN { success: true };
    }
    COMMENT 'Déploie les références de base pour ui_menu_item.'
    PERMISSIONS FULL;

    fn::system_log_helper_deploy_initialise(
        'reference', 'done', 'MenuItem reference',
        { run_id: $run_id, parent_run_id: $parent_run_id },
        $log_extra_tags
    );

    RETURN {
        success: true,
        run_id: $run_id,
        parent_run_id: $parent_run_id
    };
}
COMMENT 'Initialise la fonction de déploiement des références MenuItem.'
PERMISSIONS FULL;



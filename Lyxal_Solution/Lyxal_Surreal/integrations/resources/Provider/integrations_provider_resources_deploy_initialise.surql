-- =============================================================================================
-- |
-- | Fichier : integrations_provider_resources_deploy_initialise.surql
-- | Module : integrations
-- | Description : Déploie les fonctions ressources pour `integrations_provider`.
-- |
-- =============================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::integrations_provider_resources_deploy_initialise(
	$parent_run_id: option<string>
) {
	LET $parent_run_id = $parent_run_id OR NONE;
	LET $log_extra_tags = ['module_integrations'];
	LET $run_id = rand::uuid();

	fn::system_log_helper_deploy_initialise(
		'function', 'start', 'Integrations Provider Resources',
		{ run_id: $run_id, parent_run_id: $parent_run_id },
		$log_extra_tags
	);

	DEFINE FUNCTION IF NOT EXISTS fn::integrations_provider_resources_deploy(
		$parent_run_id: option<string>
	) {
		LET $parent_run_id = $parent_run_id OR NONE;
		LET $log_extra_tags = ['module_integrations'];
		LET $total_steps = 1; -- CRUD
		LET $step = 0;
		LET $run_id = rand::uuid();

		fn::system_log_deploy_helper_summary('Déploiement des ressources `Provider`', 'start',
		$run_id, $parent_run_id, $log_extra_tags);

		-- Étape : CRUD
		LET $step = $step + 1;
		fn::system_log_deploy_helper_step($step, $total_steps, 'log_resource',
		'Création des fonctions CRUD provider', 'start', $run_id, $parent_run_id, $log_extra_tags);
		fn::integrations_provider_resources_create_initialise($run_id);
		fn::integrations_provider_resources_get_initialise($run_id);
		fn::integrations_provider_resources_get_list_initialise($run_id);
		fn::integrations_provider_resources_update_initialise($run_id);
		fn::integrations_provider_resources_delete_initialise($run_id);
		fn::system_log_deploy_helper_step($step, $total_steps, 'log_resource',
		'Création des fonctions CRUD provider', 'done', $run_id, $parent_run_id, $log_extra_tags);

		LET $summary = fn::system_log_deploy_helper_summary('Déploiement des ressources `Provider`', 'finish',
		$run_id, $parent_run_id, $log_extra_tags);

		RETURN { success: true, run_id: $run_id, parent_run_id: $parent_run_id, summary: $summary };
	}
	COMMENT 'Déploie les fonctions ressources (CRUD) pour integrations_provider.'
	PERMISSIONS FULL;

	fn::system_log_helper_deploy_initialise(
		'function', 'done', 'Integrations Provider Resources',
		{ run_id: $run_id, parent_run_id: $parent_run_id },
		$log_extra_tags
	);

	RETURN { success: true, run_id: $run_id, parent_run_id: $parent_run_id };
}
COMMENT 'Initialise le déployeur des ressources Provider (CRUD).'
PERMISSIONS FULL;



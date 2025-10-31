-- =============================================================================================
-- |
-- | Fichier : integrations_deploy_initialise.surql
-- | Module : integrations
-- | Description : Déploie le module Integrations (Database -> Resources -> Reference).
-- |
-- =============================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::integrations_deploy_initialise(
	$parent_run_id: option<string>
) {
	LET $parent_run_id = $parent_run_id OR NONE;
	LET $log_extra_tags = ['module_integrations'];
	LET $run_id = rand::uuid();

	fn::system_log_helper_deploy_initialise(
		'module', 'start', 'Integrations',
		{ run_id: $run_id, parent_run_id: $parent_run_id },
		$log_extra_tags
	);

	DEFINE FUNCTION IF NOT EXISTS fn::integrations_deploy(
		$parent_run_id: option<string>
	) {
		LET $parent_run_id = $parent_run_id OR NONE;
		LET $log_extra_tags = ['module_integrations'];
		LET $total_steps = 3; -- Database, Resources, Reference
		LET $step = 0;
		LET $run_id = rand::uuid();

		fn::system_log_deploy_helper_summary('Déploiement du module `Integrations`', 'start',
		$run_id, $parent_run_id, $log_extra_tags);

		-- Étape 1 : Database (pour l'instant, provider déjà créé via sa fonction dédiée)
		LET $step = $step + 1;
		fn::system_log_deploy_helper_step($step, $total_steps, 'log_module_section',
		'Déploiement des tables du module Integrations.', 'start', $run_id, $parent_run_id, $log_extra_tags);
		-- Ici, on pourrait appeler d'autres create_initialise au besoin
		fn::integrations_provider_table_create_initialise($run_id);
		fn::system_log_deploy_helper_step($step, $total_steps, 'log_module_section',
		'Déploiement des tables du module Integrations.', 'done', $run_id, $parent_run_id, $log_extra_tags);

		-- Étape 2 : Resources
		LET $step = $step + 1;
		fn::system_log_deploy_helper_step($step, $total_steps, 'log_module_section',
		'Déploiement des ressources du module Integrations.', 'start', $run_id, $parent_run_id, $log_extra_tags);
		fn::integrations_resources_deploy_initialise($run_id);
		fn::integrations_resources_deploy($run_id);
		fn::system_log_deploy_helper_step($step, $total_steps, 'log_module_section',
		'Déploiement des ressources du module Integrations.', 'done', $run_id, $parent_run_id, $log_extra_tags);

		-- Étape 3 : Reference
		LET $step = $step + 1;
		fn::system_log_deploy_helper_step($step, $total_steps, 'log_module_section',
		'Déploiement des données de référence du module Integrations.', 'start', $run_id, $parent_run_id, $log_extra_tags);
		fn::integrations_reference_deploy_initialise($run_id);
		fn::integrations_reference_deploy($run_id);
		fn::system_log_deploy_helper_step($step, $total_steps, 'log_module_section',
		'Déploiement des données de référence du module Integrations.', 'done', $run_id, $parent_run_id, $log_extra_tags);

		LET $summary = fn::system_log_deploy_helper_summary('Déploiement du module `Integrations`', 'finish',
		$run_id, $parent_run_id, $log_extra_tags);

		RETURN {
			success: true,
			run_id: $run_id,
			parent_run_id: $parent_run_id,
			summary: $summary
		};
	}
	COMMENT 'Déploie le module Integrations en orchestrant Database, Resources, Reference.'
	PERMISSIONS FULL;

	fn::system_log_helper_deploy_initialise(
		'function', 'done', 'Integrations',
		{ run_id: $run_id, parent_run_id: $parent_run_id },
		$log_extra_tags
	);

	RETURN {
		success: true,
		run_id: $run_id,
		parent_run_id: $parent_run_id
	};
}
COMMENT 'Initialise la fonction de déploiement du module Integrations.'
PERMISSIONS FULL;



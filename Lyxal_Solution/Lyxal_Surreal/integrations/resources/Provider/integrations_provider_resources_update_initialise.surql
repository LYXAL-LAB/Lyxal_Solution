-- =============================================================================================
-- |
-- | Fichier : integrations_provider_resources_update_initialise.surql
-- | Module : integrations
-- | Description : Fonction ressource pour mettre à jour un provider.
-- |
-- =============================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::integrations_provider_resources_update_initialise(
	$parent_run_id: option<string>
) {
	LET $parent_run_id = $parent_run_id OR NONE;
	LET $log_extra_tags = ['module_integrations'];
	LET $run_id = rand::uuid();

	fn::system_log_helper_initialise(
		'ressource', 'start', 'integrations_provider.update',
		{ run_id: $run_id, parent_run_id: $parent_run_id },
		$log_extra_tags
	);

	DEFINE FUNCTION IF NOT EXISTS fn::integrations_provider_update(
		$id: string, $data: object
	) {
		RETURN UPDATE type::thing('integrations_provider', $id) MERGE $data;
	}
	COMMENT 'Met à jour un provider (par id).'
	PERMISSIONS FULL;

	fn::system_log_helper_initialise(
		'ressource', 'done', 'integrations_provider.update',
		{ run_id: $run_id, parent_run_id: $parent_run_id },
		$log_extra_tags
	);

	RETURN { success: true, run_id: $run_id, parent_run_id: $parent_run_id };
}
COMMENT 'Initialise la ressource de mise à jour provider.'
PERMISSIONS FULL;



-- =============================================================================================
-- |
-- | Fichier : integrations_provider_resources_delete_initialise.surql
-- | Module : integrations
-- | Description : Fonction ressource pour supprimer un provider.
-- |
-- =============================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::integrations_provider_resources_delete_initialise(
	$parent_run_id: option<string>
) {
	LET $parent_run_id = $parent_run_id OR NONE;
	LET $log_extra_tags = ['module_integrations'];
	LET $run_id = rand::uuid();

	fn::system_log_helper_initialise(
		'ressource', 'start', 'integrations_provider.delete',
		{ run_id: $run_id, parent_run_id: $parent_run_id },
		$log_extra_tags
	);

	DEFINE FUNCTION IF NOT EXISTS fn::integrations_provider_delete(
		$id: string
	) {
		RETURN DELETE type::thing('integrations_provider', $id);
	}
	COMMENT 'Supprime un provider par id.'
	PERMISSIONS FULL;

	fn::system_log_helper_initialise(
		'ressource', 'done', 'integrations_provider.delete',
		{ run_id: $run_id, parent_run_id: $parent_run_id },
		$log_extra_tags
	);

	RETURN { success: true, run_id: $run_id, parent_run_id: $parent_run_id };
}
COMMENT 'Initialise la ressource de suppression provider.'
PERMISSIONS FULL;



-- =============================================================================================
-- |
-- | Fichier : integrations_provider_resources_get_initialise.surql
-- | Module : integrations
-- | Description : Fonction ressource pour récupérer un provider par id ou key.
-- |
-- =============================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::integrations_provider_resources_get_initialise(
	$parent_run_id: option<string>
) {
	LET $parent_run_id = $parent_run_id OR NONE;
	LET $log_extra_tags = ['module_integrations'];
	LET $run_id = rand::uuid();

	fn::system_log_helper_initialise(
		'ressource', 'start', 'integrations_provider.get',
		{ run_id: $run_id, parent_run_id: $parent_run_id },
		$log_extra_tags
	);

	DEFINE FUNCTION IF NOT EXISTS fn::integrations_provider_get(
		$id_or_key: any
	) {
		IF $id_or_key = NONE THEN RETURN NONE END;
		IF type::is::string($id_or_key) THEN
			RETURN (SELECT * FROM integrations_provider WHERE key = $id_or_key LIMIT 1)[0];
		END;
		RETURN (SELECT * FROM type::thing('integrations_provider', $id_or_key))[0];
	}
	COMMENT 'Récupère un provider par id ou par key.'
	PERMISSIONS FULL;

	fn::system_log_helper_initialise(
		'ressource', 'done', 'integrations_provider.get',
		{ run_id: $run_id, parent_run_id: $parent_run_id },
		$log_extra_tags
	);

	RETURN { success: true, run_id: $run_id, parent_run_id: $parent_run_id };
}
COMMENT 'Initialise la ressource de lecture provider.'
PERMISSIONS FULL;



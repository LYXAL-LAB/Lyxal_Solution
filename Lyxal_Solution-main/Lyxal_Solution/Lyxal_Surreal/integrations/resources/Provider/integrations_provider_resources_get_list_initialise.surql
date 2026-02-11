-- =============================================================================================
-- |
-- | Fichier : integrations_provider_resources_get_list_initialise.surql
-- | Module : integrations
-- | Description : Fonction ressource pour lister les providers avec pagination simple.
-- |
-- =============================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::integrations_provider_resources_get_list_initialise(
	$parent_run_id: option<string>
) {
	LET $parent_run_id = $parent_run_id OR NONE;
	LET $log_extra_tags = ['module_integrations'];
	LET $run_id = rand::uuid();

	fn::system_log_helper_initialise(
		'ressource', 'start', 'integrations_provider.list',
		{ run_id: $run_id, parent_run_id: $parent_run_id },
		$log_extra_tags
	);

	DEFINE FUNCTION IF NOT EXISTS fn::integrations_provider_list(
		$limit: option<number>, $start: option<number>
	) {
		LET $l = $limit OR 50;
		LET $s = $start OR 0;
		RETURN SELECT * FROM integrations_provider ORDER BY name LIMIT $l START $s;
	}
	COMMENT 'Liste les providers (simple pagination).'
	PERMISSIONS FULL;

	fn::system_log_helper_initialise(
		'ressource', 'done', 'integrations_provider.list',
		{ run_id: $run_id, parent_run_id: $parent_run_id },
		$log_extra_tags
	);

	RETURN { success: true, run_id: $run_id, parent_run_id: $parent_run_id };
}
COMMENT 'Initialise la ressource de liste provider.'
PERMISSIONS FULL;



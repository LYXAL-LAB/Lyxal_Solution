-- =============================================================================================
-- |
-- | Fichier : integrations_provider_table_create_initialise.surql
-- | Module : integrations
-- | Description : Initialise la table `integrations_provider` (fournisseurs/organisations).
-- |
-- =============================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::integrations_provider_table_create_initialise(
	$parent_run_id: option<string>
) {
	LET $parent_run_id = $parent_run_id OR NONE;
	LET $log_extra_tags = ['module_integrations'];
	LET $run_id = rand::uuid();

	fn::system_log_helper_initialise(
		'table', 'start', 'integrations_provider',
		{ run_id: $run_id, parent_run_id: $parent_run_id },
		$log_extra_tags
	);

	DEFINE TABLE IF NOT EXISTS integrations_provider SCHEMAFULL TYPE NORMAL
		COMMENT 'Fournisseur/organisation exposant des APIs consommées par des nodes.'
		PERMISSIONS FULL;

	DEFINE FIELD IF NOT EXISTS key ON TABLE integrations_provider 
		TYPE option<string>
		ASSERT $value = NONE OR string::len($value) > 0 AND string::len($value) <= 128
		COMMENT 'Identifiant technique (ex: bunny, github).';

	DEFINE FIELD IF NOT EXISTS name ON TABLE integrations_provider 
		TYPE string
		ASSERT string::len($value) > 0 AND string::len($value) <= 128
		COMMENT 'Nom affiché (ex: Bunny, GitHub).';

	DEFINE FIELD IF NOT EXISTS icon ON TABLE integrations_provider 
		TYPE option<record<storage_file>>
		VALUE type::thing('storage_file', $value)
		COMMENT 'Icône du provider.';

	DEFINE FIELD IF NOT EXISTS icon_dark ON TABLE integrations_provider 
		TYPE option<record<storage_file>>
		VALUE type::thing('storage_file', $value)
		COMMENT 'Icône (thème sombre).';

	DEFINE FIELD IF NOT EXISTS website_url ON TABLE integrations_provider 
		TYPE option<string>
		COMMENT 'URL du site web.';

	DEFINE FIELD IF NOT EXISTS docs_url ON TABLE integrations_provider 
		TYPE option<string>
		COMMENT 'URL de documentation.';

	DEFINE FIELD IF NOT EXISTS created_at ON TABLE integrations_provider 
		TYPE datetime
		VALUE $value OR time::now();

	DEFINE FIELD IF NOT EXISTS updated_at ON TABLE integrations_provider 
		TYPE datetime
		VALUE $value OR time::now();

	DEFINE INDEX IF NOT EXISTS provider_name_unique ON TABLE integrations_provider 
	FIELDS name UNIQUE
	COMMENT 'Unicité du nom.';

	DEFINE INDEX IF NOT EXISTS provider_key_unique ON TABLE integrations_provider
	FIELDS key UNIQUE
	COMMENT 'Unicité de la clé technique.';

	fn::system_log_helper_initialise(
		'table', 'done', 'integrations_provider',
		{ run_id: $run_id, parent_run_id: $parent_run_id },
		$log_extra_tags
	);

	RETURN { success: true, run_id: $run_id, parent_run_id: $parent_run_id };
}
COMMENT 'Initialise la table `integrations_provider`.'
PERMISSIONS FULL;

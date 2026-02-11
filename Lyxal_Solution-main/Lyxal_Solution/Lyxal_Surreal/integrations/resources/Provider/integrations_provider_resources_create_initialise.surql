-- =============================================================================================
-- |
-- | Fichier : integrations_provider_resources_create_initialise.surql
-- | Module : integrations
-- | Description : Fonction ressource pour créer un provider.
-- |
-- =============================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::integrations_provider_resources_create_initialise(
	$parent_run_id: option<string>
) {
	LET $parent_run_id = $parent_run_id OR NONE;
	LET $log_extra_tags = ['module_integrations'];
	LET $run_id = rand::uuid();

	fn::system_log_helper_initialise(
		'function', 'start', 'integrations_provider_resources_create',
		{ run_id: $run_id, parent_run_id: $parent_run_id },
		$log_extra_tags
	);

	DEFINE FUNCTION IF NOT EXISTS fn::integrations_provider_create(
		$name: string,
		$key: option<string>,
		$icon: option<string>,
		$icon_dark: option<string>,
		$website_url: option<string>,
		$docs_url: option<string>
	) {
		-- Validation des paramètres requis
		IF $name = NONE OR string::len(string::trim($name)) = 0 {
			THROW "Le nom du provider est requis.";
		};

		-- Résolution des icônes par nom de fichier (si fourni)
		LET $icon_record = IF $icon != NONE {
			RETURN fn::storage_file_resources_get_by_name($icon);
		} ELSE {
			RETURN NONE;
		};
		LET $icon_dark_record = IF $icon_dark != NONE {
			RETURN fn::storage_file_resources_get_by_name($icon_dark);
		} ELSE {
			RETURN NONE;
		};

		-- Création du provider
		LET $provider = CREATE integrations_provider SET
			name = $name,
			key = $key,
			icon = $icon_record,
			icon_dark = $icon_dark_record,
			website_url = $website_url,
			docs_url = $docs_url,
			created_at = time::now(),
			updated_at = time::now();

		-- Journalisation de fin
		fn::system_log_helper_initialise(
			'function', 'done', 'integrations_provider_create',
			{ run_id: $run_id, parent_run_id: $parent_run_id, data: $provider[0] },
			$log_extra_tags
		);

		RETURN {
			success: true,
			run_id: $run_id,
			parent_run_id: $parent_run_id,
			data: $provider[0]
		};
	}
	COMMENT 'Crée un nouveau provider (pattern aligné avec la création de node).'
	PERMISSIONS FULL;

	fn::system_log_helper_initialise(
		'function', 'done', 'integrations_provider_resources_create',
		{ run_id: $run_id, parent_run_id: $parent_run_id },
		$log_extra_tags
	);

	RETURN {
		success: true,
		run_id: $run_id,
		parent_run_id: $parent_run_id
	};
}
COMMENT 'Initialise la fonction de création de provider (Resources).'
PERMISSIONS FULL;



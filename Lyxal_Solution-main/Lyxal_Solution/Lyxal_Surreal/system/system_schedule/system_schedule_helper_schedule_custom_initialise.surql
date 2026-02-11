-- =================================================================================================
-- | Fichier : system_schedule_helper_schedule_custom_initialise.surql
-- | Module  : system_schedule
-- | Desc.   : Helper - schedule custom (toutes les clés)
-- =================================================================================================

DEFINE FUNCTION IF NOT EXISTS fn::system_schedule_helper_schedule_custom_initialise(
	$parent_run_id: option<string>
) {
	LET $parent_run_id = $parent_run_id OR NONE;
        LET $log_extra_tags = ['module_system'];
	LET $run_id = rand::uuid();

	fn::system_log_create_record_system(
		array::union(['log_initialisation', 'log_function', 'log_create', 'log_start'], $log_extra_tags),
		'Start: initialisation helper schedule_custom', { run_id: $run_id, parent_run_id: $parent_run_id }
	);

	DEFINE FUNCTION IF NOT EXISTS fn::system_schedule_cronjoborg_build_schedule_custom(
		$timezone: string,
		$expiresAt: int,
		$hours: array<int>,
		$minutes: array<int>,
		$mdays: array<int>,
		$months: array<int>,
		$wdays: array<int>
	) {
		RETURN {
			timezone: $timezone,
			expiresAt: $expiresAt,
			hours: $hours,
			minutes: $minutes,
			mdays: $mdays,
			months: $months,
			wdays: $wdays
		};
	}
	COMMENT 'Construit un schedule custom conforme au type JobSchedule.'
	PERMISSIONS FULL;

	fn::system_log_create_record_system(
		array::union(['log_initialisation', 'log_function', 'log_create', 'log_done', 'log_success'], $log_extra_tags),
		'Done: initialisation helper schedule_custom', { run_id: $run_id, parent_run_id: $parent_run_id }
	);

	RETURN { success: true, run_id: $run_id };
}
COMMENT 'Initialise le helper de schedule custom.'
PERMISSIONS FULL;

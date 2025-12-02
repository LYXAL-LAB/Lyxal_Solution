-- Incrémente le numéro de version pour un workflow (retourne la nouvelle version)

DEFINE FUNCTION IF NOT EXISTS fn::logic_version_create(
    $tenant: string, $workflow: string, $changelog: string, $created_by: string) {

    LET $current_max = (SELECT math::max(number) AS max FROM logic_version 
    WHERE workflow = type::record('logic_workflow', $workflow))[0].max;

    LET $next = if $current_max = NONE THEN 1 ELSE $current_max + 1 END;

    CREATE logic_version SET
        tenant = type::record('tenant', $tenant),
        workflow = type::record('logic_workflow', $workflow),
        number = $next,
        status = "draft",
        changelog = $changelog,
        created_by = $created_by;

}
COMMENT "Incémente le numéro de version pour un workflow (retourne la nouvelle version)"
PERMISSIONS FULL;
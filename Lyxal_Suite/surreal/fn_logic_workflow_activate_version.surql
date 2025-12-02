-- Active une version donnée (et met le workflow en active)

DEFINE FUNCTION IF NOT EXISTS fn::logic_workflow_activate_version(
    $workflow: string, $version: string) {

    UPDATE type::record('logic_workflow', $workflow) SET active_version = type::record('logic_version', $version), status = "active";

    UPDATE type::record('logic_version', $version) SET status = "released";

    RETURN { success: true, message: "Version activée avec succès" };

}
COMMENT "Active une version donnée (et met le workflow en active)"
PERMISSIONS FULL;
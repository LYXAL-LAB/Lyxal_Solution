-- Trigger pour mettre à jour les dates de modification
DEFINE EVENT project_updated ON TABLE project WHEN $event = "UPDATE" THEN {
    UPDATE project SET updated_on = time::now() WHERE id = $after.id;
};

-- Trigger pour gérer l'auto-numérotation des projets
DEFINE EVENT project_auto_numbering ON TABLE project WHEN $event = "CREATE" THEN {
    LET $company_config = (SELECT * FROM company_project_extension WHERE company_id = $after.company_id);
    IF $company_config.project_numbering_auto AND ($after.code IS NONE OR $after.code = "") THEN {
        LET $sequence = (SELECT * FROM sequence_project WHERE code = "PROJECT" AND company_id = $after.company_id);
        IF $sequence IS NOT NONE THEN {
            UPDATE project SET code = fn::generate_project_sequence($sequence.id) WHERE id = $after.id;
        };
    };
};
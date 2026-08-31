-- ============================================================================
-- LYXAL OS — BOOKING EVENT TYPES
-- ============================================================================
-- Fichier  : functions/event_types/fn_update_event_type_resources.surql
-- Fonction : fn::booking_update_event_type_resources
-- Version  : 1.0.0
-- ============================================================================

DEFINE FUNCTION OVERWRITE fn::booking_update_event_type_resources($params: object) {
    LET $user_id = $params.user_id;
    LET $slug = $params.slug;
    LET $resource_ids = $params.resource_ids;

    IF $slug IS NONE OR string::len(string::trim($slug)) = 0 {
        THROW "BOOKING_INVALID_PARAMS: slug est obligatoire";
    };

    -- 1. Recherche du créneau d'événement
    LET $et_list = SELECT * FROM booking_event_type WHERE slug = $slug LIMIT 1;
    IF array::len($et_list) = 0 {
        THROW "BOOKING_EVENT_TYPE_NOT_FOUND: Type d'événement introuvable pour ce slug";
    };
    LET $et = $et_list[0];

    -- 2. Nettoyage des anciennes relations ressources
    DELETE booking_event_type_resource WHERE in = $et.id;

    LET $et_id = $et.id;
    -- 3. Inscription des nouvelles associations de ressources physiques
    IF $resource_ids IS NOT NONE AND type::is::array($resource_ids) {
        FOR $res_id IN $resource_ids {
            LET $clean_res_id = type::thing($res_id);
            RELATE $et_id->booking_event_type_resource->$clean_res_id CONTENT {
                created_at: time::now()
            };
        };
    };

    -- 4. Retour des identifiants des ressources rattachées
    LET $attached = SELECT VALUE out FROM booking_event_type_resource WHERE in = $et.id;

    RETURN {
        event_type_id: string::concat("", $et.id),
        resource_ids: array::map($attached, |$r| string::concat("", $r))
    };
};

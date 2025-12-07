-- ============================================================================
-- Fichier : resource/calendar/gestion_calendar/deleteCalendar.surql
-- Module : calendar
-- Fonction : fn::calendar_delete
-- Description : Supprime un calendrier, soit en le mettant à la corbeille (par défaut),
--               soit de manière permanente.
--
-- Paramètres :
--   - $id (string) : L'ID du calendrier à supprimer (ex: "calendars:xyz").
--   - $force_delete (bool) : Si true, la suppression est permanente.
--
-- Retourne :
--   - Le calendrier mis à jour (pour le soft delete) ou l'objet du calendrier supprimé (pour le hard delete).
-- ============================================================================
DEFINE FUNCTION fn::calendar_delete(
    $id: string,
    $force_delete: bool
) {
    -- Convertir la chaîne en record ID
    LET $record_id = type::thing($id);
    
    -- On récupère le calendrier pour s'assurer qu'il existe
    LET $calendar = SELECT * FROM ONLY $record_id;
    
    IF $calendar == NONE {
        THROW "Le calendrier que vous essayez de supprimer n'a pas été trouvé.";
    };

    IF $force_delete == true {
        -- LOGIQUE DE SUPPRESSION PERMANENTE (HARD DELETE)
        
        -- 1. Supprimer les données dépendantes
        DELETE calendarobjectprops WHERE calendar = $record_id;
        DELETE calendarchanges WHERE calendar = $record_id;
        DELETE calendarobjects WHERE calendar = $record_id;
        DELETE davshares WHERE resource = $record_id;

        -- 2. Supprimer le calendrier lui-même
        DELETE $record_id;

        -- Optionnellement, dispatcher un événement "CalendarDeleted"
        -- RETURN fn::dispatchEvent("CalendarDeleted", { calendarId: $id });
        
        RETURN $calendar;

    } ELSE {
        -- LOGIQUE DE MISE À LA CORBEILLE (SOFT DELETE)

        -- On met à jour le calendrier pour y ajouter un timestamp de suppression
        LET $updated = UPDATE $record_id MERGE {
            metadata: {
                status: {
                    deleted_at: time::now()
                }
            }
        };

        -- Optionnellement, dispatcher un événement "CalendarMovedToTrash"
        -- RETURN fn::dispatchEvent("CalendarMovedToTrash", { calendarId: $id, data: $updated });

        RETURN $updated;
    };
};
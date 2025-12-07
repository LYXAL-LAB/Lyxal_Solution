-- ============================================================================
-- Fichier : resource/calendar/gestion_calendar/restoreCalendar.surql
-- Module : calendar
-- Fonction : fn::calendar_restore
-- Description : Restaure un calendrier qui a été mis à la corbeille (soft delete).
--
-- Paramètres :
--   - $id (string) : L'ID du calendrier à restaurer (ex: "calendars:xyz").
--
-- Retourne :
--   - L'enregistrement complet du calendrier restauré.
-- ============================================================================
DEFINE FUNCTION fn::calendar_restore($id: string) {

    -- On vérifie que le calendrier existe avant de le restaurer
    LET $calendar = SELECT * FROM ONLY type::thing($id);
    IF $calendar == NONE {
        THROW "Le calendrier que vous essayez de restaurer n'a pas été trouvé.";
    };

    -- On restaure le calendrier en mettant le champ `deleted_at` à NONE.
    -- On utilise MERGE pour ne modifier que ce champ spécifique.
    LET $restored = UPDATE $id MERGE {
        metadata: {
            status: {
                deleted_at: NONE
            }
        }
    };
    
    -- Optionnellement, dispatcher un événement "CalendarRestored"
    -- fn::dispatchEvent("CalendarRestored", { calendarId: $id, data: $restored });

    RETURN $restored;
};

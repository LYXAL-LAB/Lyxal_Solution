-- ============================================================================
-- Fichier : resource/calendar/gestion_calendar/getCalendarById.surql
-- Module : calendar
-- Fonction : fn::calendar_get_by_id
-- Description : Récupère un calendrier complet par son ID.
--
-- Paramètres :
--   - $id (string) : L'ID du calendrier à récupérer (ex: "calendars:xyz").
--
-- Retourne :
--   - L'enregistrement complet du calendrier si trouvé, sinon NONE.
-- ============================================================================
DEFINE FUNCTION fn::calendar_get_by_id($id: string) {
    -- Utilise la méthode la plus performante pour récupérer un seul enregistrement par son ID.
    -- Le `SELECT * FROM ONLY ...` retourne directement l'objet ou NONE.
    RETURN (SELECT * FROM ONLY type::thing($id));
};

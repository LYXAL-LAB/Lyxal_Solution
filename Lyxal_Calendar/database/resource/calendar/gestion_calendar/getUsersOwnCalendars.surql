-- ============================================================================
-- Fichier : resource/calendar/gestion_calendar/getUsersOwnCalendars.surql
-- Module : calendar
-- Fonction : fn::calendar_get_own
-- Description : Récupère la liste de tous les calendriers appartenant en propre à l'utilisateur.
--               Exclut les calendriers qui sont dans la corbeille.
--
-- Paramètres :
--   - Aucun
--
-- Retourne :
--   - (array) : Un tableau contenant les enregistrements complets des calendriers de l'utilisateur.
-- ============================================================================
DEFINE FUNCTION fn::calendar_get_own() {
    -- La fonction s'exécute dans le contexte de la base de l'utilisateur,
    -- donc un simple SELECT suffit.
    -- On filtre pour exclure les calendriers qui ont été "soft-deleted".
    RETURN (
        SELECT * FROM calendars 
        WHERE metadata.status.deleted_at IS NONE
        ORDER BY identity.displayname ASC
    );
};

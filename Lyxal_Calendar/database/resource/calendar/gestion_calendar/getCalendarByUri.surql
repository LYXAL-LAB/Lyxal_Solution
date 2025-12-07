-- ============================================================================
-- Fichier : resource/calendar/gestion_calendar/getCalendarByUri.surql
-- Module : calendar
-- Fonction : fn::calendar_get_by_uri
-- Description : Récupère un calendrier complet par son URI/slug.
--
-- Paramètres :
--   - $slug (string) : Le slug du calendrier à récupérer (ex: "mon-projet").
--
-- Retourne :
--   - L'enregistrement complet du calendrier si trouvé, sinon NONE.
-- ============================================================================
DEFINE FUNCTION fn::calendar_get_by_uri($slug: string) {
    -- La recherche sur `identity.slug` est efficace grâce à notre index UNIQUE.
    LET $calendars = (SELECT * FROM calendars WHERE identity.slug = $slug);
    
    -- SurrealDB retourne NONE si on essaie d'accéder à l'index [0] d'un tableau vide.
    -- Ce qui gère parfaitement le cas "non trouvé".
    RETURN $calendars[0];
};

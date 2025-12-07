-- ============================================================================
-- Fichier : resource/calendar/utils/getPropertyMap.surql
-- Module : calendar
-- Fonction : fn::calendar::utils::getPropertyMap
-- Description : Retourne la table de correspondance (dictionnaire) pour traduire
--               les noms de propriétés CalDAV en noms de champs de base de données,
--               en respectant la structure imbriquée du schéma.
--
-- UTILISATION :
-- Cette fonction centralise le mappage pour assurer la cohérence entre les
-- différentes fonctions (create, update, etc.). Pour ajouter ou modifier une
-- propriété supportée, il suffit de modifier cet objet.
-- ============================================================================
DEFINE FUNCTION fn::calendar_utils_getPropertyMap() {
    RETURN {
        "{DAV:}displayname": "identity.displayname",
        "{urn:ietf:params:xml:ns:caldav}calendar-description": "identity.description",
        "{urn:ietf:params:xml:ns:caldav}calendar-timezone": "content.timezone",
        "{http://apple.com/ns/ical/}calendar-color": "content.calendarcolor"
    };
};

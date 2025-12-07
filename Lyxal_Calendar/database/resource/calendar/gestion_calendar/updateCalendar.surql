-- ============================================================================
-- Fichier : resource/calendar/gestion_calendar/updateCalendar.surql
-- Module : calendar
-- Fonction : fn::calendar_update
-- Description : Met à jour les propriétés d'un calendrier existant.
--
-- Logique d'Exécution :
-- 1. Prend un ID de calendrier et un objet de "mutations" (propriétés CalDAV).
-- 2. Valide que le calendrier existe.
-- 3. Gère les cas spéciaux comme la transparence.
-- 4. Utilise `fn::calendar_utils_applyPropertyMap` pour traduire les noms de propriétés.
-- 5. Construit un objet de mise à jour structuré en utilisant un pattern de réassignation sécurisé.
-- 6. Applique les modifications et incrémente le `synctoken` de manière atomique.
-- 7. Retourne l'enregistrement du calendrier mis à jour.
--
-- Paramètres :
--   - $id (string) : L'ID du calendrier à mettre à jour (ex: "calendars:xyz").
--   - $mutations (object) : Objet contenant les propriétés CalDAV à modifier.
--
-- Retourne :
--   - (object) : L'enregistrement complet du calendrier mis à jour.
-- ============================================================================
DEFINE FUNCTION fn::calendar_update(
    $id: string,
    $mutations: object
) {
    -- 1. On vérifie que le calendrier existe
    LET $calendar = SELECT * FROM ONLY type::thing($id);
    IF $calendar == NONE {
        THROW "Le calendrier que vous essayez de mettre à jour n'a pas été trouvé.";
    };

    -- 2. Initialisation des objets de mise à jour
    LET $update_identity = {};
    LET $update_content = {};

    -- 3. Traduction des propriétés standards
    LET $mapped = fn::calendar_utils_applyPropertyMap($mutations, false);

    -- 4. Construction des objets de mise à jour imbriqués avec le pattern de réassignation sécurisé
    
    -- Pour $update_identity
    LET $update_identity = IF $mapped['identity.displayname'] != NONE {
        object::merge($update_identity, { displayname: $mapped['identity.displayname'] })
    } ELSE { $update_identity };
    
    LET $update_identity = IF $mapped['identity.description'] != NONE {
        object::merge($update_identity, { description: $mapped['identity.description'] })
    } ELSE { $update_identity };

    -- Pour $update_content
    LET $transp_key = "{urn:ietf:params:xml:ns:caldav}schedule-calendar-transp";
    LET $update_content = IF $mutations[$transp_key] != NONE {
        object::merge($update_content, { transparent: ($mutations[$transp_key].value == "transparent") })
    } ELSE { $update_content };
    
    LET $update_content = IF $mapped['content.timezone'] != NONE {
        object::merge($update_content, { timezone: $mapped['content.timezone'] })
    } ELSE { $update_content };

    LET $update_content = IF $mapped['content.calendarcolor'] != NONE {
        object::merge($update_content, { calendarcolor: $mapped['content.calendarcolor'] })
    } ELSE { $update_content };

    -- 5. Construction de l'objet de MERGE final
    LET $update_data = {};
    IF count(object::keys($update_identity)) > 0 {
        LET $update_data.identity = $update_identity;
    };
    IF count(object::keys($update_content)) > 0 {
        LET $update_data.content = $update_content;
    };
    
    -- Si aucune donnée n'a été mappée, on ne fait rien.
    IF count(object::keys($update_data)) == 0 {
        RETURN $calendar;
    };

    -- 6. Exécution de la mise à jour atomique
    -- On MERGE les nouvelles données et on SET le synctoken pour l'incrémenter.
    LET $updated = UPDATE $id 
        MERGE $update_data
        SET metadata.status.synctoken += 1;
    
    -- TODO pour le futur : Gérer l'ajout dans la table `calendarchanges`
    -- C'est l'équivalent de `addChanges` dans le code PHP.
    -- CREATE calendarchanges SET calendar = $id, ... ;

    RETURN $updated;
};

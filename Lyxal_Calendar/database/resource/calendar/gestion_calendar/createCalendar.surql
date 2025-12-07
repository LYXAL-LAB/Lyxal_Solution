-- ============================================================================
-- Fichier : resource/calendar/gestion_calendar/createCalendar.surql
-- Module : calendar
-- Fonction : fn::createCalendar
-- Description : Crée un nouveau calendrier de manière autonome et robuste.
--
-- Logique d'Exécution :
-- 1. Prend un objet de propriétés CalDAV en entrée.
-- 2. Exige la présence de la propriété `{DAV:}displayname`.
-- 3. Appelle `fn::generateSlugCalendar` pour créer un slug unique et propre.
-- 4. Traite les propriétés CalDAV spéciales (`components`, `transparent`).
-- 5. Mappe les autres propriétés standards via `fn::applyPropertyMap`.
-- 6. Construit l'enregistrement final en respectant le schéma de la table `calendars`.
-- 7. Crée l'enregistrement et vérifie que la création a réussi.
-- 8. Retourne l'enregistrement complet du calendrier nouvellement créé.
--
-- Paramètres :
--   - $properties (object) : Objet contenant les propriétés CalDAV du calendrier à créer.
--     `{DAV:}displayname` est requis.
--
-- Retourne :
--   - (object) : Un objet contenant `calendarId` et `calendarData` (l'enregistrement complet).
-- ============================================================================

-- La fonction ne prend plus de $principalUri car il est implicite dans un contexte multi-tenant.
DEFINE FUNCTION fn::createCalendar(
    $properties: object
) {
    -- On s'assure qu'un nom d'affichage est fourni, car il sert de base au slug
    LET $displayName = $properties['{DAV:}displayname'];
    IF $displayName == NONE {
        THROW "Un nom d'affichage ('displayname') est requis pour créer un calendrier.";
    };

    -- Générer un slug unique et propre en utilisant notre nouvelle fonction.
    -- On passe `NONE` pour $exclude_id car c'est une création.
    -- On passe `NONE` pour $counter pour le premier appel.
    LET $slug = fn::generateSlugCalendar($displayName, NONE, NONE);

    -- Il n'y a plus d'objet `$values` car les défauts sont dans la table.
    -- On gère juste le cas spécial des `components` qui peuvent surcharger le défaut.
    LET $components_override = IF type::is::object($properties) 
        AND $properties["{urn:ietf:params:xml:ns:caldav}supported-calendar-component-set"] != NONE {
            array::join($properties["{urn:ietf:params:xml:ns:caldav}supported-calendar-component-set"].value, ",")
    } ELSE IF $properties.components != NONE {
        $properties.components
    } ELSE {
        NONE
    };

    -- Traduire les propriétés additionnelles fournies par le client via la fonction utilitaire
    LET $mappedProperties = fn::calendar_utils_applyPropertyMap($properties, false);

    -- Création du calendrier dans la base de données
    LET $calendar = CREATE calendars SET
        identity = {
            name: $slug,
            slug: $slug,
            code: string::uppercase(string::replace($slug, '-', '_')),
            displayname: $mappedProperties['identity.displayname'],
            description: $mappedProperties['identity.description']
        },
        content = {
            calendarcolor: $mappedProperties['content.calendarcolor'],
            timezone: $mappedProperties['content.timezone'],
            components: $components_override,
            -- On gère ici le cas spécial de 'transparent' qui vient directement des propriétés
            transparent: IF $properties['{urn:ietf:params:xml:ns:caldav}schedule-calendar-transp'].value == 'transparent' {
                true
            } ELSE {
                NONE -- Laisse la BDD utiliser le DEFAULT (false)
            }
        };

    -- Vérification explicite pour s'assurer que la création a bien eu lieu
    IF count($calendar) == 0 {
        CANCEL;
        THROW "La création du calendrier a échoué de manière inattendue.";
    };

    -- La commande CREATE retourne un tableau avec l'enregistrement complet.
    -- Nous retournons directement cet enregistrement, sans faire de SELECT supplémentaire.
    RETURN {
        calendarId: $calendar[0].id,
        calendarData: $calendar[0]
    };
};
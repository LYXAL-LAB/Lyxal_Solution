-- =============================================================================
-- CalDAV API - Version Corrigée (Une seule DEFINE API par chemin)
-- =============================================================================

-- Table pour stocker les événements
DEFINE TABLE IF NOT EXISTS calendarobjects SCHEMAFULL;
DEFINE FIELD IF NOT EXISTS uri ON calendarobjects TYPE string;
DEFINE FIELD IF NOT EXISTS calendardata ON calendarobjects TYPE string;
DEFINE FIELD IF NOT EXISTS etag ON calendarobjects TYPE string;
DEFINE FIELD IF NOT EXISTS lastmodified ON calendarobjects TYPE datetime;
DEFINE INDEX IF NOT EXISTS idx_uri ON calendarobjects FIELDS uri UNIQUE;

-- UNE SEULE API avec tous les handlers
DEFINE API OVERWRITE "/calendars/:user/:calendar/:object"
    -- GET: Récupérer un événement
    FOR get
        MIDDLEWARE api::res::raw_body(true)
        THEN {
            LET $obj = (SELECT calendardata, etag FROM calendarobjects 
                        WHERE uri = $request.params.object LIMIT 1)[0];
            
            IF $obj != NONE {
                RETURN {
                    status: 200,
                    headers: {
                        "Content-Type": "text/calendar; charset=utf-8",
                        "ETag": <string>$obj.etag
                    },
                    body: $obj.calendardata
                };
            } ELSE {
                RETURN { status: 404, body: "Not Found" };
            };
        }
    -- PUT: Créer/Modifier un événement
    FOR put
        MIDDLEWARE api::req::raw_body(true)
        THEN {
            LET $ical = <string>$request.body;
            LET $etag = <string>rand::uuid();
            LET $uri = $request.params.object;
            
            DELETE calendarobjects WHERE uri = $uri;
            CREATE calendarobjects SET
                uri = $uri,
                calendardata = $ical,
                etag = $etag,
                lastmodified = time::now();
            
            RETURN {
                status: 201,
                headers: { "ETag": $etag },
                body: "Created"
            };
        }
    -- DELETE: Supprimer un événement
    FOR delete
        THEN {
            LET $deleted = (DELETE calendarobjects WHERE uri = $request.params.object RETURN BEFORE);
            
            IF $deleted != [] {
                RETURN { status: 204 };
            } ELSE {
                RETURN { status: 404, body: "Not Found" };
            };
        };

-- Vérification
INFO FOR DB;

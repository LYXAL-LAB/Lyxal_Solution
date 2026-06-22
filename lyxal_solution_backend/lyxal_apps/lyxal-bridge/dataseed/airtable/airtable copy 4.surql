-- ============================================================================
-- Lyxal Bridge — Airtable Provider
-- Fichier : datafunction/airtable.surql
-- 
-- 5 opérations CRUD complètes pour l'API Airtable v0
-- Chaque fonction est autonome : auth, construction URL, appel HTTP, trace
-- ============================================================================

-- ─── Helper Auth (réutilisé par chaque opération) ───────────────────────────

DEFINE FUNCTION fn::bridge::airtable::auth() {
    LET $creds = (SELECT * FROM bridge_user_credentials 
                  WHERE provider = bridge_providers:airtable)[0];
    IF $creds == NONE { 
        THROW "Aucun credential configuré pour Airtable. Créez un record dans bridge_user_credentials." 
    };
    RETURN $creds.encrypted_data;
};

-- ─── 1. LIST RECORDS (GET) ──────────────────────────────────────────────────

DEFINE FUNCTION fn::bridge::airtable::list_records(
    $baseId: string, 
    $table: string, 
    $params: option<object>
) {
    LET $token = fn::bridge::airtable::auth();
    LET $url = "https://api.airtable.com/v0/" + $baseId + "/" + $table;
    
    -- Query params optionnels (maxRecords, view, filterByFormula, etc.)
    LET $query = $params ?? {};
    
    LET $response = bridge::http("GET", $url, {
        "Authorization": "Bearer " + $token,
        "Content-Type": "application/json"
    }, NONE, $query);

    -- Trace d'exécution
    INSERT INTO bridge_execution_logs {
        trace_id: rand::uuid(),
        context: { provider: "airtable", operation: "list_records" },
        request: { method: "GET", url: $url },
        response: { status: $response.status },
        timestamp: { started_at: time::now() }
    };

    RETURN $response.body;
};

-- ─── 2. GET RECORD (GET) ────────────────────────────────────────────────────

DEFINE FUNCTION fn::bridge::airtable::get_record(
    $baseId: string, 
    $table: string, 
    $recordId: string
) {
    LET $token = fn::bridge::airtable::auth();
    LET $url = "https://api.airtable.com/v0/" + $baseId + "/" + $table + "/" + $recordId;

    LET $response = bridge::http("GET", $url, {
        "Authorization": "Bearer " + $token
    });

    INSERT INTO bridge_execution_logs {
        trace_id: rand::uuid(),
        context: { provider: "airtable", operation: "get_record" },
        request: { method: "GET", url: $url },
        response: { status: $response.status },
        timestamp: { started_at: time::now() }
    };

    RETURN $response.body;
};

-- ─── 3. CREATE RECORD (POST) ────────────────────────────────────────────────

DEFINE FUNCTION fn::bridge::airtable::create_record(
    $baseId: string, 
    $table: string, 
    $fields: object
) {
    LET $token = fn::bridge::airtable::auth();
    LET $url = "https://api.airtable.com/v0/" + $baseId + "/" + $table;
    LET $body = { fields: $fields };

    LET $response = bridge::http("POST", $url, {
        "Authorization": "Bearer " + $token,
        "Content-Type": "application/json"
    }, $body);

    INSERT INTO bridge_execution_logs {
        trace_id: rand::uuid(),
        context: { provider: "airtable", operation: "create_record" },
        request: { method: "POST", url: $url },
        response: { status: $response.status },
        timestamp: { started_at: time::now() }
    };

    RETURN $response.body;
};

-- ─── 4. UPDATE RECORD (PATCH) ───────────────────────────────────────────────

DEFINE FUNCTION fn::bridge::airtable::update_record(
    $baseId: string, 
    $table: string, 
    $recordId: string, 
    $fields: object
) {
    LET $token = fn::bridge::airtable::auth();
    LET $url = "https://api.airtable.com/v0/" + $baseId + "/" + $table + "/" + $recordId;
    LET $body = { fields: $fields };

    LET $response = bridge::http("PATCH", $url, {
        "Authorization": "Bearer " + $token,
        "Content-Type": "application/json"
    }, $body);

    INSERT INTO bridge_execution_logs {
        trace_id: rand::uuid(),
        context: { provider: "airtable", operation: "update_record" },
        request: { method: "PATCH", url: $url },
        response: { status: $response.status },
        timestamp: { started_at: time::now() }
    };

    RETURN $response.body;
};

-- ─── 5. DELETE RECORD (DELETE) ──────────────────────────────────────────────

DEFINE FUNCTION fn::bridge::airtable::delete_record(
    $baseId: string, 
    $table: string, 
    $recordId: string
) {
    LET $token = fn::bridge::airtable::auth();
    LET $url = "https://api.airtable.com/v0/" + $baseId + "/" + $table + "/" + $recordId;

    LET $response = bridge::http("DELETE", $url, {
        "Authorization": "Bearer " + $token
    });

    INSERT INTO bridge_execution_logs {
        trace_id: rand::uuid(),
        context: { provider: "airtable", operation: "delete_record" },
        request: { method: "DELETE", url: $url },
        response: { status: $response.status },
        timestamp: { started_at: time::now() }
    };

    RETURN $response.body;
};

-- ============================================================================
-- UTILISATION DEPUIS SURREALQL
-- ============================================================================
--
-- Lister les records :
--   LET $records = fn::bridge::airtable::list_records("appXYZ", "Contacts", { maxRecords: 10 });
--
-- Lire un record :
--   LET $contact = fn::bridge::airtable::get_record("appXYZ", "Contacts", "recABC123");
--
-- Créer un record :
--   LET $new = fn::bridge::airtable::create_record("appXYZ", "Contacts", {
--       Name: "Alice Dupont",
--       Email: "alice@example.com",
--       Phone: "+33612345678"
--   });
--
-- Mettre à jour :
--   LET $updated = fn::bridge::airtable::update_record("appXYZ", "Contacts", "recABC123", {
--       Phone: "+33698765432"
--   });
--
-- Supprimer :
--   LET $deleted = fn::bridge::airtable::delete_record("appXYZ", "Contacts", "recABC123");
--
-- Dans un EVENT :
--   DEFINE EVENT sync_to_airtable ON TABLE clients WHEN $event = 'CREATE' THEN {
--       fn::bridge::airtable::create_record("appXYZ", "Contacts", {
--           Name: $after.name,
--           Email: $after.email
--       });
--   };
-- ============================================================================

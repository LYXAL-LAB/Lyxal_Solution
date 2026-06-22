-- ============================================================================
-- Lyxal Bridge — Airtable Provider
-- Fichier : datafunction/fn_bridge_airtable_list_records.surql
-- 
-- 5 opérations CRUD complètes pour l'API Airtable v0
-- Chaque fonction est autonome : auth, construction URL, appel HTTP, trace
-- ============================================================================


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
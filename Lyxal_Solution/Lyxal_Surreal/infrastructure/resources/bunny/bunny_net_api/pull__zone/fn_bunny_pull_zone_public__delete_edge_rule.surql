-- Fonction: fn::bunny_pull_zone_public__delete_edge_rule
-- Endpoint: DELETE /pullzone/{pullZoneId}/edgerules/{edgeRuleId}
-- Description: Delete Edge Rule

DEFINE FUNCTION IF NOT EXISTS fn::bunny_pull_zone_public__delete_edge_rule(
  $pullZoneId: int, $edgeRuleId: string
) {

  RETURN function() {

    // Récupérer la clé API
    const apiKey = await surrealdb.value("$bunny_api_key");

    if (!apiKey) {
      return {
        success: false,
        error: 'api_key_missing',
        message: 'Bunny API key is not configured'
      };
    }

    // Construire l'URL
    const pullZoneIdParam = await surrealdb.value("$pullZoneId");
    const edgeRuleIdParam = await surrealdb.value("$edgeRuleId");
    let url = 'https://api.bunny.net/pullzone/{pullZoneId}/edgerules/{edgeRuleId}';
    url = url.replace('{pullZoneId}', pullZoneIdParam);
    url = url.replace('{edgeRuleId}', edgeRuleIdParam);

    try {
      // Appel API
      const response = await fetch(url, {
        method: 'DELETE',
        headers: {
          'Accept': 'application/json',
          'Accesskey': apiKey
        }
      });

      // Logger l'appel API
      await surrealdb.query(`
        CREATE infrastructure_log CONTENT {
          type: 'api_call',
          resource_type: 'Pull Zone',
          bunny_api: {
            endpoint: '/pullzone/{pullZoneId}/edgerules/{edgeRuleId}',
            method: 'DELETE',
            status_code: ${response.status}
          },
          status: '${response.ok ? 'success' : 'failed'}',
          timestamp: time::now()
        }
      `);

      // Gestion des erreurs HTTP
      if (!response.ok) {
        const errorData = response.status !== 401 ? await response.json() : null;
        return {
          success: false,
          status: response.status,
          error: errorData?.ErrorKey || 'http_error',
          message: errorData?.Message || `HTTP error! status: ${response.status}`
        };
      }

      const data = await response.json();
      return {
        success: true,
        data: data
      };

    } catch (e) {
      return {
        success: false,
        error: 'exception',
        message: e.message
      };
    }
  };
};
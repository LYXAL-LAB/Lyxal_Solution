-- Fonction: fn::bunny_upsert_edge_script_variable_endpoint__upsert_edge_script_variable
-- Endpoint: PUT /compute/script/{id}/variables
-- Description: Upsert Variable

DEFINE FUNCTION IF NOT EXISTS fn::bunny_upsert_edge_script_variable_endpoint__upsert_edge_script_variable(
  $id: int
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
    const idParam = await surrealdb.value("$id");
    let url = 'https://api.bunny.net/compute/script/{id}/variables';
    url = url.replace('{id}', idParam);

    try {
      // Appel API
      const response = await fetch(url, {
        method: 'PUT',
        headers: {
          'Accept': 'application/json',
          'Accesskey': apiKey
        }
      });

      // Logger l'appel API
      await surrealdb.query(`
        CREATE infrastructure_log CONTENT {
          type: 'api_call',
          resource_type: 'Variable',
          bunny_api: {
            endpoint: '/compute/script/{id}/variables',
            method: 'PUT',
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
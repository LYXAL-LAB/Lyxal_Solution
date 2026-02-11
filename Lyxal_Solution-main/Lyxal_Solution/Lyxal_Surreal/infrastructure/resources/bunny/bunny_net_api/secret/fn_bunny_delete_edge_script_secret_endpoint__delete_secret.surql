-- Fonction: fn::bunny_delete_edge_script_secret_endpoint__delete_secret
-- Endpoint: DELETE /compute/script/{id}/secrets/{secretId}
-- Description: Delete Secret

DEFINE FUNCTION IF NOT EXISTS fn::bunny_delete_edge_script_secret_endpoint__delete_secret(
  $id: int, $secretId: int
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
    const secretIdParam = await surrealdb.value("$secretId");
    let url = 'https://api.bunny.net/compute/script/{id}/secrets/{secretId}';
    url = url.replace('{id}', idParam);
    url = url.replace('{secretId}', secretIdParam);

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
          resource_type: 'Secret',
          bunny_api: {
            endpoint: '/compute/script/{id}/secrets/{secretId}',
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
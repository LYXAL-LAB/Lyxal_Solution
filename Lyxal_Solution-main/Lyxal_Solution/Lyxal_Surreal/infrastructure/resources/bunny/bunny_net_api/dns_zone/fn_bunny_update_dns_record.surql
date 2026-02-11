-- Fonction: fn::bunny_update_dns_record
-- Endpoint: POST /dnszone/{zoneId}/records/{id}
-- Description: Update DNS Record

DEFINE FUNCTION IF NOT EXISTS fn::bunny_update_dns_record(
  $zoneId: int,
  $id: int,
  $record_data: object
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
    const zoneIdParam = await surrealdb.value("$zoneId");
    const idParam = await surrealdb.value("$id");
    let url = 'https://api.bunny.net/dnszone/{zoneId}/records/{id}';
    url = url.replace('{zoneId}', zoneIdParam);
    url = url.replace('{id}', idParam);

    try {
      // Appel API
      const response = await fetch(url, {
        method: 'POST',
        headers: {
          'Accept': 'application/json',
          'Accesskey': apiKey
        }
      });

      // Logger l'appel API
      await surrealdb.query(`
        CREATE infrastructure_log CONTENT {
          type: 'api_call',
          resource_type: 'DNS Zone',
          bunny_api: {
            endpoint: '/dnszone/{zoneId}/records/{id}',
            method: 'POST',
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
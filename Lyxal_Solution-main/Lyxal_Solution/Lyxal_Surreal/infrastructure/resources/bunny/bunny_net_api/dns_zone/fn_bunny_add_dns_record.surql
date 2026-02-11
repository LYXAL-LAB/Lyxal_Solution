-- Fonction: fn::bunny_add_dns_record
-- Endpoint: PUT /dnszone/{zoneId}/records
-- Description: Add DNS Record

DEFINE FUNCTION IF NOT EXISTS fn::bunny_add_dns_record(
  $zoneId: int,
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
    let url = 'https://api.bunny.net/dnszone/{zoneId}/records';
    url = url.replace('{zoneId}', zoneIdParam);

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
          resource_type: 'DNS Zone',
          bunny_api: {
            endpoint: '/dnszone/{zoneId}/records',
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
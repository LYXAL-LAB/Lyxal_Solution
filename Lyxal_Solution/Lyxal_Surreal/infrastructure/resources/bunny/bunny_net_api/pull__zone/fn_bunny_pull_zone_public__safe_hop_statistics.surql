-- Fonction: fn::bunny_pull_zone_public__safe_hop_statistics
-- Endpoint: GET /pullzone/{pullZoneId}/safehop/statistics
-- Description: Get SafeHop Statistics

DEFINE FUNCTION IF NOT EXISTS fn::bunny_pull_zone_public__safe_hop_statistics(
  $pullZoneId: int, $dateFrom: option<datetime>, $dateTo: option<datetime>, $hourly: option<bool>
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
    const dateFromParam = await surrealdb.value("$dateFrom");
    const dateToParam = await surrealdb.value("$dateTo");
    const hourlyParam = await surrealdb.value("$hourly");
    let url = 'https://api.bunny.net/pullzone/{pullZoneId}/safehop/statistics';
    url = url.replace('{pullZoneId}', pullZoneIdParam);

    const params = [];
    if (dateFromParam !== null && dateFromParam !== undefined) {
      params.push('dateFrom=' + encodeURIComponent(dateFromParam));
    }
    if (dateToParam !== null && dateToParam !== undefined) {
      params.push('dateTo=' + encodeURIComponent(dateToParam));
    }
    if (hourlyParam !== null && hourlyParam !== undefined) {
      params.push('hourly=' + encodeURIComponent(hourlyParam));
    }

    if (params.length > 0) {
      url += '?' + params.join('&');
    }

    try {
      // Appel API
      const response = await fetch(url, {
        method: 'GET',
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
            endpoint: '/pullzone/{pullZoneId}/safehop/statistics',
            method: 'GET',
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
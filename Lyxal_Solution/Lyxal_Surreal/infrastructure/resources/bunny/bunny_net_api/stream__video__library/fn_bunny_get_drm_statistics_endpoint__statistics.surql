-- Fonction: fn::bunny_get_drm_statistics_endpoint__statistics
-- Endpoint: GET /videolibrary/{id}/drm/statistics
-- Description: Get Video Library DRM Statistics

DEFINE FUNCTION IF NOT EXISTS fn::bunny_get_drm_statistics_endpoint__statistics(
  $id: int, $dateFrom: option<datetime>, $dateTo: option<datetime>
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
    const dateFromParam = await surrealdb.value("$dateFrom");
    const dateToParam = await surrealdb.value("$dateTo");
    let url = 'https://api.bunny.net/videolibrary/{id}/drm/statistics';
    url = url.replace('{id}', idParam);

    const params = [];
    if (dateFromParam !== null && dateFromParam !== undefined) {
      params.push('dateFrom=' + encodeURIComponent(dateFromParam));
    }
    if (dateToParam !== null && dateToParam !== undefined) {
      params.push('dateTo=' + encodeURIComponent(dateToParam));
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
          resource_type: 'Stream Video Library',
          bunny_api: {
            endpoint: '/videolibrary/{id}/drm/statistics',
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
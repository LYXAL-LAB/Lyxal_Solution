-- Fonction: fn::bunny_video__get_video_statistics
-- Endpoint: GET /library/{libraryId}/statistics
-- Description: Get Video Statistics

DEFINE FUNCTION IF NOT EXISTS fn::bunny_video__get_video_statistics(
  $libraryId: int, $dateFrom: option<datetime>, $dateTo: option<datetime>, $hourly: option<bool>, $videoGuid: option<string>
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
    const libraryIdParam = await surrealdb.value("$libraryId");
    const dateFromParam = await surrealdb.value("$dateFrom");
    const dateToParam = await surrealdb.value("$dateTo");
    const hourlyParam = await surrealdb.value("$hourly");
    const videoGuidParam = await surrealdb.value("$videoGuid");
    let url = 'https://video.bunnycdn.com/library/{libraryId}/statistics';
    url = url.replace('{libraryId}', libraryIdParam);

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
    if (videoGuidParam !== null && videoGuidParam !== undefined) {
      params.push('videoGuid=' + encodeURIComponent(videoGuidParam));
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
          resource_type: 'Manage Videos',
          bunny_api: {
            endpoint: '/library/{libraryId}/statistics',
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
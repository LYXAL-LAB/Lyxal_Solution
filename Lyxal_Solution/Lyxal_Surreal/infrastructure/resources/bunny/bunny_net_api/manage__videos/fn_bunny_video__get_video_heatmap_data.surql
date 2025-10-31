-- Fonction: fn::bunny_video__get_video_heatmap_data
-- Endpoint: GET /library/{libraryId}/videos/{videoId}/play/heatmap
-- Description: Get Video heatmap data

DEFINE FUNCTION IF NOT EXISTS fn::bunny_video__get_video_heatmap_data(
  $libraryId: int, $videoId: string, $token: option<string>, $expires: option<int>
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
    const videoIdParam = await surrealdb.value("$videoId");
    const tokenParam = await surrealdb.value("$token");
    const expiresParam = await surrealdb.value("$expires");
    let url = 'https://video.bunnycdn.com/library/{libraryId}/videos/{videoId}/play/heatmap';
    url = url.replace('{libraryId}', libraryIdParam);
    url = url.replace('{videoId}', videoIdParam);

    const params = [];
    if (tokenParam !== null && tokenParam !== undefined) {
      params.push('token=' + encodeURIComponent(tokenParam));
    }
    if (expiresParam !== null && expiresParam !== undefined) {
      params.push('expires=' + encodeURIComponent(expiresParam));
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
            endpoint: '/library/{libraryId}/videos/{videoId}/play/heatmap',
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
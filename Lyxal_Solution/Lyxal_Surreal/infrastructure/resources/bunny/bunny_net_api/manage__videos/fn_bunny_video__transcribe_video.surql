-- Fonction: fn::bunny_video__transcribe_video
-- Endpoint: POST /library/{libraryId}/videos/{videoId}/transcribe
-- Description: Transcribe video

DEFINE FUNCTION IF NOT EXISTS fn::bunny_video__transcribe_video(
  $libraryId: int, $videoId: string, $force: option<bool>
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
    const forceParam = await surrealdb.value("$force");
    let url = 'https://video.bunnycdn.com/library/{libraryId}/videos/{videoId}/transcribe';
    url = url.replace('{libraryId}', libraryIdParam);
    url = url.replace('{videoId}', videoIdParam);

    const params = [];
    if (forceParam !== null && forceParam !== undefined) {
      params.push('force=' + encodeURIComponent(forceParam));
    }

    if (params.length > 0) {
      url += '?' + params.join('&');
    }

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
          resource_type: 'Manage Videos',
          bunny_api: {
            endpoint: '/library/{libraryId}/videos/{videoId}/transcribe',
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
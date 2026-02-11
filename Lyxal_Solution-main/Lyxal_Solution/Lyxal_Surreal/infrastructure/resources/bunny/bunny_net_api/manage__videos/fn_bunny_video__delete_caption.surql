-- Fonction: fn::bunny_video__delete_caption
-- Endpoint: DELETE /library/{libraryId}/videos/{videoId}/captions/{srclang}
-- Description: Delete Caption

DEFINE FUNCTION IF NOT EXISTS fn::bunny_video__delete_caption(
  $libraryId: int, $videoId: string, $srclang: string
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
    const srclangParam = await surrealdb.value("$srclang");
    let url = 'https://video.bunnycdn.com/library/{libraryId}/videos/{videoId}/captions/{srclang}';
    url = url.replace('{libraryId}', libraryIdParam);
    url = url.replace('{videoId}', videoIdParam);
    url = url.replace('{srclang}', srclangParam);

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
          resource_type: 'Manage Videos',
          bunny_api: {
            endpoint: '/library/{libraryId}/videos/{videoId}/captions/{srclang}',
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
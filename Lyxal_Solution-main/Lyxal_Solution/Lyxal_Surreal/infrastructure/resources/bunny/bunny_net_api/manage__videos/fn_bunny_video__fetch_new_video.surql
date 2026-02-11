-- Fonction: fn::bunny_video__fetch_new_video
-- Endpoint: POST /library/{libraryId}/videos/fetch
-- Description: Fetch Video

DEFINE FUNCTION IF NOT EXISTS fn::bunny_video__fetch_new_video(
  $libraryId: int, $collectionId: option<string>, $thumbnailTime: option<int>
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
    const collectionIdParam = await surrealdb.value("$collectionId");
    const thumbnailTimeParam = await surrealdb.value("$thumbnailTime");
    let url = 'https://video.bunnycdn.com/library/{libraryId}/videos/fetch';
    url = url.replace('{libraryId}', libraryIdParam);

    const params = [];
    if (collectionIdParam !== null && collectionIdParam !== undefined) {
      params.push('collectionId=' + encodeURIComponent(collectionIdParam));
    }
    if (thumbnailTimeParam !== null && thumbnailTimeParam !== undefined) {
      params.push('thumbnailTime=' + encodeURIComponent(thumbnailTimeParam));
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
            endpoint: '/library/{libraryId}/videos/fetch',
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
-- Fonction: fn::bunny_collection__update_collection
-- Endpoint: POST /library/{libraryId}/collections/{collectionId}
-- Description: Update Collection

DEFINE FUNCTION IF NOT EXISTS fn::bunny_collection__update_collection(
  $libraryId: int, $collectionId: string
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
    let url = 'https://video.bunnycdn.com/library/{libraryId}/collections/{collectionId}';
    url = url.replace('{libraryId}', libraryIdParam);
    url = url.replace('{collectionId}', collectionIdParam);

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
          resource_type: 'Manage Collections',
          bunny_api: {
            endpoint: '/library/{libraryId}/collections/{collectionId}',
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
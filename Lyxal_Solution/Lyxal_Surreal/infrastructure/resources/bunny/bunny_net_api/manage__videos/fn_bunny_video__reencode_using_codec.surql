-- Fonction: fn::bunny_video__reencode_using_codec
-- Endpoint: PUT /library/{libraryId}/videos/{videoId}/outputs/{outputCodecId}
-- Description: Add output codec to video

DEFINE FUNCTION IF NOT EXISTS fn::bunny_video__reencode_using_codec(
  $libraryId: int, $videoId: string, $outputCodecId: record<encoder_output_codec>
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
    const outputCodecIdParam = await surrealdb.value("$outputCodecId");
    let url = 'https://video.bunnycdn.com/library/{libraryId}/videos/{videoId}/outputs/{outputCodecId}';
    url = url.replace('{libraryId}', libraryIdParam);
    url = url.replace('{videoId}', videoIdParam);
    url = url.replace('{outputCodecId}', outputCodecIdParam);

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
          resource_type: 'Manage Videos',
          bunny_api: {
            endpoint: '/library/{libraryId}/videos/{videoId}/outputs/{outputCodecId}',
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
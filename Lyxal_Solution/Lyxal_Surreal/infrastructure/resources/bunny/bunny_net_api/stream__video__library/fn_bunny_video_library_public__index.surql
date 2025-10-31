-- Fonction: fn::bunny_video_library_public__index
-- Endpoint: GET /videolibrary
-- Description: List Video Libraries

DEFINE FUNCTION IF NOT EXISTS fn::bunny_video_library_public__index(
  $page: option<int>, $perPage: option<int>, $search: option<string>
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
    const pageParam = await surrealdb.value("$page");
    const perPageParam = await surrealdb.value("$perPage");
    const searchParam = await surrealdb.value("$search");
    let url = 'https://api.bunny.net/videolibrary';

    const params = [];
    if (pageParam !== null && pageParam !== undefined) {
      params.push('page=' + encodeURIComponent(pageParam));
    }
    if (perPageParam !== null && perPageParam !== undefined) {
      params.push('perPage=' + encodeURIComponent(perPageParam));
    }
    if (searchParam !== null && searchParam !== undefined) {
      params.push('search=' + encodeURIComponent(searchParam));
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
            endpoint: '/videolibrary',
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
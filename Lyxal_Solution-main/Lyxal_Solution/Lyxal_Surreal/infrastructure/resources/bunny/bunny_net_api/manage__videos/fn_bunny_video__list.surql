-- Fonction: fn::bunny_video__list
-- Endpoint: GET /library/{libraryId}/videos
-- Description: List Videos

DEFINE FUNCTION IF NOT EXISTS fn::bunny_video__list(
  $libraryId: int, $page: option<int>, $itemsPerPage: option<int>, $search: option<string>, $collection: option<string>, $orderBy: option<string>
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
    const pageParam = await surrealdb.value("$page");
    const itemsPerPageParam = await surrealdb.value("$itemsPerPage");
    const searchParam = await surrealdb.value("$search");
    const collectionParam = await surrealdb.value("$collection");
    const orderByParam = await surrealdb.value("$orderBy");
    let url = 'https://video.bunnycdn.com/library/{libraryId}/videos';
    url = url.replace('{libraryId}', libraryIdParam);

    const params = [];
    if (pageParam !== null && pageParam !== undefined) {
      params.push('page=' + encodeURIComponent(pageParam));
    }
    if (itemsPerPageParam !== null && itemsPerPageParam !== undefined) {
      params.push('itemsPerPage=' + encodeURIComponent(itemsPerPageParam));
    }
    if (searchParam !== null && searchParam !== undefined) {
      params.push('search=' + encodeURIComponent(searchParam));
    }
    if (collectionParam !== null && collectionParam !== undefined) {
      params.push('collection=' + encodeURIComponent(collectionParam));
    }
    if (orderByParam !== null && orderByParam !== undefined) {
      params.push('orderBy=' + encodeURIComponent(orderByParam));
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
            endpoint: '/library/{libraryId}/videos',
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
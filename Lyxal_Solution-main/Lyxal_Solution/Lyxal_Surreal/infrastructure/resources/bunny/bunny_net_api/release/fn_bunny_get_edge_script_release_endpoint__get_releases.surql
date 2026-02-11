-- Fonction: fn::bunny_get_edge_script_release_endpoint__get_releases
-- Endpoint: GET /compute/script/{id}/releases
-- Description: Get Releases

DEFINE FUNCTION IF NOT EXISTS fn::bunny_get_edge_script_release_endpoint__get_releases(
  $id: int, $page: option<int>, $perPage: option<int>
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
    const pageParam = await surrealdb.value("$page");
    const perPageParam = await surrealdb.value("$perPage");
    let url = 'https://api.bunny.net/compute/script/{id}/releases';
    url = url.replace('{id}', idParam);

    const params = [];
    if (pageParam !== null && pageParam !== undefined) {
      params.push('page=' + encodeURIComponent(pageParam));
    }
    if (perPageParam !== null && perPageParam !== undefined) {
      params.push('perPage=' + encodeURIComponent(perPageParam));
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
          resource_type: 'Release',
          bunny_api: {
            endpoint: '/compute/script/{id}/releases',
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
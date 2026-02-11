-- Fonction: fn::bunny_storage_zone_public__index
-- Endpoint: GET /storagezone
-- Description: List Storage Zones

DEFINE FUNCTION IF NOT EXISTS fn::bunny_storage_zone_public__index(
  $page: option<int>, $perPage: option<int>, $includeDeleted: option<bool>, $search: option<string>
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
    const includeDeletedParam = await surrealdb.value("$includeDeleted");
    const searchParam = await surrealdb.value("$search");
    let url = 'https://api.bunny.net/storagezone';

    const params = [];
    if (pageParam !== null && pageParam !== undefined) {
      params.push('page=' + encodeURIComponent(pageParam));
    }
    if (perPageParam !== null && perPageParam !== undefined) {
      params.push('perPage=' + encodeURIComponent(perPageParam));
    }
    if (includeDeletedParam !== null && includeDeletedParam !== undefined) {
      params.push('includeDeleted=' + encodeURIComponent(includeDeletedParam));
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
          resource_type: 'Storage Zone',
          bunny_api: {
            endpoint: '/storagezone',
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
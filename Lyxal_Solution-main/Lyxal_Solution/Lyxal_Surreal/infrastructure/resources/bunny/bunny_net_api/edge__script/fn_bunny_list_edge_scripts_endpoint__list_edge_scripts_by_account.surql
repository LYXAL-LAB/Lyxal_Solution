-- Fonction: fn::bunny_list_edge_scripts_endpoint__list_edge_scripts_by_account
-- Endpoint: GET /compute/script
-- Description: List Edge Scripts

DEFINE FUNCTION IF NOT EXISTS fn::bunny_list_edge_scripts_endpoint__list_edge_scripts_by_account(
  $type: option<array<option<record<edge_script_types2>>>>, $page: option<int>, $perPage: option<int>, $search: option<string>, $includeLinkedPullzones: option<bool>, $integrationId: option<int>
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
    const typeParam = await surrealdb.value("$type");
    const pageParam = await surrealdb.value("$page");
    const perPageParam = await surrealdb.value("$perPage");
    const searchParam = await surrealdb.value("$search");
    const includeLinkedPullzonesParam = await surrealdb.value("$includeLinkedPullzones");
    const integrationIdParam = await surrealdb.value("$integrationId");
    let url = 'https://api.bunny.net/compute/script';

    const params = [];
    if (typeParam !== null && typeParam !== undefined) {
      params.push('type=' + encodeURIComponent(typeParam));
    }
    if (pageParam !== null && pageParam !== undefined) {
      params.push('page=' + encodeURIComponent(pageParam));
    }
    if (perPageParam !== null && perPageParam !== undefined) {
      params.push('perPage=' + encodeURIComponent(perPageParam));
    }
    if (searchParam !== null && searchParam !== undefined) {
      params.push('search=' + encodeURIComponent(searchParam));
    }
    if (includeLinkedPullzonesParam !== null && includeLinkedPullzonesParam !== undefined) {
      params.push('includeLinkedPullzones=' + encodeURIComponent(includeLinkedPullzonesParam));
    }
    if (integrationIdParam !== null && integrationIdParam !== undefined) {
      params.push('integrationId=' + encodeURIComponent(integrationIdParam));
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
          resource_type: 'Edge Script',
          bunny_api: {
            endpoint: '/compute/script',
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
-- ============================================================================
-- BUNNY.NET API - List DNS Zones
-- ============================================================================
-- Description : Récupère la liste des zones DNS sur le compte Bunny.net
-- Endpoint    : GET /dnszone
-- ============================================================================

-- ============================================================================
-- FUNCTION : fn::bunny_list_dns_zones
-- ============================================================================
-- Description : Liste toutes les zones DNS avec pagination et recherche
-- Paramètres  : 
--   $page (int, optionnel)     - Numéro de page (défaut: 1)
--   $per_page (int, optionnel) - Nombre par page 5-1000 (défaut: 1000)
--   $search (string, optionnel)- Terme de recherche pour filtrer
-- ============================================================================

DEFINE FUNCTION IF NOT EXISTS fn::bunny_list_dns_zones(
  $page: option<int>,
  $per_page: option<int>,
  $search: option<string>
) {
  
  RETURN function() {
    
    // Récupérer la clé API depuis les paramètres globaux
    const apiKey = await surrealdb.value("$bunny_api_key");
    
    if (!apiKey) {
      return {
        success: false,
        error: 'api_key_missing',
        message: 'Bunny API key is not configured'
      };
    }
    
    // Récupérer les paramètres depuis SurrealDB
    const pageParam = await surrealdb.value("$page");
    const perPageParam = await surrealdb.value("$per_page");
    const searchParam = await surrealdb.value("$search");
    
    // Construire l'URL avec les paramètres de requête
    let url = 'https://api.bunny.net/dnszone';
    const params = [];
    
    // Ajouter les paramètres optionnels
    if (pageParam !== null && pageParam !== undefined) {
      params.push('page=' + pageParam.toString());
    }
    if (perPageParam !== null && perPageParam !== undefined) {
      params.push('perPage=' + perPageParam.toString());
    }
    if (searchParam !== null && searchParam !== undefined && searchParam !== '') {
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
          service: 'bunny',
          endpoint: 'dnszone',
          method: 'GET',
          status: ${response.status},
          timestamp: time::now()
        }
      `);
      
      // Gestion des erreurs HTTP
      if (response.status === 400) {
        return {
          success: false,
          error: 'bad_request',
          message: 'Invalid request parameters',
          status: 400
        };
      }
      
      if (response.status === 401) {
        return {
          success: false,
          error: 'unauthorized',
          message: 'Invalid or missing API key',
          status: 401
        };
      }
      
      if (response.status === 500) {
        return {
          success: false,
          error: 'server_error',
          message: 'Bunny.net internal server error',
          status: 500
        };
      }
      
      if (response.status === 503) {
        return {
          success: false,
          error: 'service_unavailable',
          message: 'Bunny.net service temporarily unavailable',
          status: 503
        };
      }
      
      if (response.status !== 200) {
        return {
          success: false,
          error: 'http_error',
          message: `HTTP error ${response.status}`,
          status: response.status
        };
      }
      
      // Parse de la réponse
      const data = await response.json();
      
      return {
        success: true,
        zones: data.Items || [],
        pagination: {
          current_page: data.CurrentPage,
          total_items: data.TotalItems,
          has_more: data.HasMoreItems
        }
      };
      
    } catch (error) {
      
      return {
        success: false,
        error: 'fetch_error',
        message: error.message || 'Failed to fetch DNS zones'
      };
      
    }
    
  };
  
};


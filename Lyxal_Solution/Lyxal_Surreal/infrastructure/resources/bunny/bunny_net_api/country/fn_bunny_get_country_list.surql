-- ============================================================================
-- BUNNY.NET API - Get Country List
-- ============================================================================
-- Description : Récupère la liste des pays disponibles sur Bunny.net
-- Endpoint    : GET https://api.bunny.net/country
-- Auth        : Accesskey header avec API key
-- Docs        : https://docs.bunny.net/reference/countriespublic_getcountrylist
-- ============================================================================

-- ============================================================================
-- FUNCTION : fn::bunny_get_country_list
-- ============================================================================
-- Description : Récupère la liste complète des pays depuis l'API Bunny
-- ============================================================================

DEFINE FUNCTION IF NOT EXISTS fn::bunny_get_country_list() {
  
  RETURN function() {
    
    // Récupérer l'API key depuis SurrealDB
    const apiKey = await surrealdb.value("$bunny_api_key");
    
    // Appeler l'API Bunny.net
    const response = await fetch('https://api.bunny.net/country', {
      method: 'GET',
      headers: {
        'Accept': 'application/json',
        'Accesskey': apiKey
      }
    });
    
    const now = new Date().toISOString();
    
    // Gérer les erreurs HTTP
    if (response.status === 400) {
      const errorData = await response.json();
      
      // Logger l'erreur
      await surrealdb.query(`
        CREATE infrastructure_log CONTENT {
          action: 'bunny_api_call',
          resource_type: 'country',
          bunny_api: {
            endpoint: '/country',
            method: 'GET',
            status_code: 400
          },
          status: 'failed',
          error_code: $error_key,
          error_message: $message,
          metadata: {
            timestamp: type::datetime($now)
          }
        }
      `, {
        error_key: errorData.ErrorKey,
        message: errorData.Message,
        now: now
      });
      
      return {
        success: false,
        error: 'bad_request',
        error_key: errorData.ErrorKey,
        field: errorData.Field,
        message: errorData.Message,
        status_code: 400
      };
    }
    
    if (response.status === 401) {
      // Logger l'erreur
      await surrealdb.query(`
        CREATE infrastructure_log CONTENT {
          action: 'bunny_api_call',
          resource_type: 'country',
          bunny_api: {
            endpoint: '/country',
            method: 'GET',
            status_code: 401
          },
          status: 'failed',
          error_message: 'Authorization failed',
          metadata: {
            timestamp: type::datetime($now)
          }
        }
      `, {
        now: now
      });
      
      return {
        success: false,
        error: 'unauthorized',
        message: 'The request authorization failed - check API key',
        status_code: 401
      };
    }
    
    if (response.status === 500) {
      // Logger l'erreur
      await surrealdb.query(`
        CREATE infrastructure_log CONTENT {
          action: 'bunny_api_call',
          resource_type: 'country',
          bunny_api: {
            endpoint: '/country',
            method: 'GET',
            status_code: 500
          },
          status: 'failed',
          error_message: 'Internal Server Error',
          metadata: {
            timestamp: type::datetime($now)
          }
        }
      `, {
        now: now
      });
      
      return {
        success: false,
        error: 'server_error',
        message: 'Internal Server Error - try again later',
        status_code: 500
      };
    }
    
    if (response.status === 503) {
      // Logger l'erreur
      await surrealdb.query(`
        CREATE infrastructure_log CONTENT {
          action: 'bunny_api_call',
          resource_type: 'country',
          bunny_api: {
            endpoint: '/country',
            method: 'GET',
            status_code: 503
          },
          status: 'failed',
          error_message: 'Service Unavailable',
          metadata: {
            timestamp: type::datetime($now)
          }
        }
      `, {
        now: now
      });
      
      return {
        success: false,
        error: 'service_unavailable',
        message: 'The service is currently unavailable - try again later',
        status_code: 503
      };
    }
    
    if (response.status !== 200) {
      // Logger l'erreur générique
      await surrealdb.query(`
        CREATE infrastructure_log CONTENT {
          action: 'bunny_api_call',
          resource_type: 'country',
          bunny_api: {
            endpoint: '/country',
            method: 'GET',
            status_code: $status
          },
          status: 'failed',
          error_message: 'Failed to fetch country list',
          metadata: {
            timestamp: type::datetime($now)
          }
        }
      `, {
        status: response.status,
        now: now
      });
      
      return {
        success: false,
        error: 'api_error',
        status_code: response.status,
        message: 'Failed to fetch country list from Bunny.net'
      };
    }
    
    // Parser la réponse JSON
    const countries = await response.json();
    
    // Logger le succès
    await surrealdb.query(`
      CREATE infrastructure_log CONTENT {
        action: 'bunny_api_call',
        resource_type: 'country',
        bunny_api: {
          endpoint: '/country',
          method: 'GET',
          status_code: 200
        },
        status: 'success',
        details: {
          countries_count: $count
        },
        metadata: {
          timestamp: type::datetime($now)
        }
      }
    `, {
      count: countries.length,
      now: now
    });
    
    // Retourner la liste des pays
    return {
      success: true,
      countries: countries,
      count: countries.length,
      fetched_at: now
    };
    
  };
};

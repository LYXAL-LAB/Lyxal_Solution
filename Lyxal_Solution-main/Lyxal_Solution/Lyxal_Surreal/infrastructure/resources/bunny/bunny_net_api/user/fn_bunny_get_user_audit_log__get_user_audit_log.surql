-- Fonction: fn::bunny_get_user_audit_log__get_user_audit_log
-- Endpoint: GET /user/audit/{date}
-- Description: GetUserAuditLog

DEFINE FUNCTION IF NOT EXISTS fn::bunny_get_user_audit_log__get_user_audit_log(
  $date: datetime, $request: option<record<get_user_audit_log_request>>
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
    const dateParam = await surrealdb.value("$date");
    const requestParam = await surrealdb.value("$request");
    let url = 'https://api.bunny.net/user/audit/{date}';
    url = url.replace('{date}', dateParam);

    const params = [];
    if (requestParam !== null && requestParam !== undefined) {
      params.push('request=' + encodeURIComponent(requestParam));
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
          resource_type: 'User',
          bunny_api: {
            endpoint: '/user/audit/{date}',
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
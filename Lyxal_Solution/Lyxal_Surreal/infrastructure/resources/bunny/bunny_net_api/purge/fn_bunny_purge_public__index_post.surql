-- Fonction: fn::bunny_purge_public__index_post
-- Endpoint: POST /purge
-- Description: Purge URL

DEFINE FUNCTION IF NOT EXISTS fn::bunny_purge_public__index_post(
  $url: option<string>, $async: option<bool>
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
    const urlParam = await surrealdb.value("$url");
    const asyncParam = await surrealdb.value("$async");
    let url = 'https://api.bunny.net/purge';

    const params = [];
    if (urlParam !== null && urlParam !== undefined) {
      params.push('url=' + encodeURIComponent(urlParam));
    }
    if (asyncParam !== null && asyncParam !== undefined) {
      params.push('async=' + encodeURIComponent(asyncParam));
    }

    if (params.length > 0) {
      url += '?' + params.join('&');
    }

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
          resource_type: 'Purge',
          bunny_api: {
            endpoint: '/purge',
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
-- Fonction: fn::bunny_o_embed__get_o_embed
-- Endpoint: GET /OEmbed
-- Description: 

DEFINE FUNCTION IF NOT EXISTS fn::bunny_o_embed__get_o_embed(
  $url: option<string>, $maxWidth: option<int>, $maxHeight: option<int>, $token: option<string>, $expires: option<int>
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
    const maxWidthParam = await surrealdb.value("$maxWidth");
    const maxHeightParam = await surrealdb.value("$maxHeight");
    const tokenParam = await surrealdb.value("$token");
    const expiresParam = await surrealdb.value("$expires");
    let url = 'https://video.bunnycdn.com/OEmbed';

    const params = [];
    if (urlParam !== null && urlParam !== undefined) {
      params.push('url=' + encodeURIComponent(urlParam));
    }
    if (maxWidthParam !== null && maxWidthParam !== undefined) {
      params.push('maxWidth=' + encodeURIComponent(maxWidthParam));
    }
    if (maxHeightParam !== null && maxHeightParam !== undefined) {
      params.push('maxHeight=' + encodeURIComponent(maxHeightParam));
    }
    if (tokenParam !== null && tokenParam !== undefined) {
      params.push('token=' + encodeURIComponent(tokenParam));
    }
    if (expiresParam !== null && expiresParam !== undefined) {
      params.push('expires=' + encodeURIComponent(expiresParam));
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
          resource_type: 'OEmbed',
          bunny_api: {
            endpoint: '/OEmbed',
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
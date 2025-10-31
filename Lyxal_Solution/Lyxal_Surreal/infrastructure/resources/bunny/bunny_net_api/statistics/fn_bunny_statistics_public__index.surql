-- Fonction: fn::bunny_statistics_public__index
-- Endpoint: GET /statistics
-- Description: Get Statistics

DEFINE FUNCTION IF NOT EXISTS fn::bunny_statistics_public__index(
  $dateFrom: option<datetime>, $dateTo: option<datetime>, $pullZone: option<int>, $serverZoneId: option<int>, $loadErrors: option<bool>, $hourly: option<bool>, $loadOriginResponseTimes: option<bool>, $loadOriginTraffic: option<bool>, $loadRequestsServed: option<bool>, $loadBandwidthUsed: option<bool>, $loadOriginShieldBandwidth: option<bool>, $loadGeographicTrafficDistribution: option<bool>, $loadUserBalanceHistory: option<bool>
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
    const dateFromParam = await surrealdb.value("$dateFrom");
    const dateToParam = await surrealdb.value("$dateTo");
    const pullZoneParam = await surrealdb.value("$pullZone");
    const serverZoneIdParam = await surrealdb.value("$serverZoneId");
    const loadErrorsParam = await surrealdb.value("$loadErrors");
    const hourlyParam = await surrealdb.value("$hourly");
    const loadOriginResponseTimesParam = await surrealdb.value("$loadOriginResponseTimes");
    const loadOriginTrafficParam = await surrealdb.value("$loadOriginTraffic");
    const loadRequestsServedParam = await surrealdb.value("$loadRequestsServed");
    const loadBandwidthUsedParam = await surrealdb.value("$loadBandwidthUsed");
    const loadOriginShieldBandwidthParam = await surrealdb.value("$loadOriginShieldBandwidth");
    const loadGeographicTrafficDistributionParam = await surrealdb.value("$loadGeographicTrafficDistribution");
    const loadUserBalanceHistoryParam = await surrealdb.value("$loadUserBalanceHistory");
    let url = 'https://api.bunny.net/statistics';

    const params = [];
    if (dateFromParam !== null && dateFromParam !== undefined) {
      params.push('dateFrom=' + encodeURIComponent(dateFromParam));
    }
    if (dateToParam !== null && dateToParam !== undefined) {
      params.push('dateTo=' + encodeURIComponent(dateToParam));
    }
    if (pullZoneParam !== null && pullZoneParam !== undefined) {
      params.push('pullZone=' + encodeURIComponent(pullZoneParam));
    }
    if (serverZoneIdParam !== null && serverZoneIdParam !== undefined) {
      params.push('serverZoneId=' + encodeURIComponent(serverZoneIdParam));
    }
    if (loadErrorsParam !== null && loadErrorsParam !== undefined) {
      params.push('loadErrors=' + encodeURIComponent(loadErrorsParam));
    }
    if (hourlyParam !== null && hourlyParam !== undefined) {
      params.push('hourly=' + encodeURIComponent(hourlyParam));
    }
    if (loadOriginResponseTimesParam !== null && loadOriginResponseTimesParam !== undefined) {
      params.push('loadOriginResponseTimes=' + encodeURIComponent(loadOriginResponseTimesParam));
    }
    if (loadOriginTrafficParam !== null && loadOriginTrafficParam !== undefined) {
      params.push('loadOriginTraffic=' + encodeURIComponent(loadOriginTrafficParam));
    }
    if (loadRequestsServedParam !== null && loadRequestsServedParam !== undefined) {
      params.push('loadRequestsServed=' + encodeURIComponent(loadRequestsServedParam));
    }
    if (loadBandwidthUsedParam !== null && loadBandwidthUsedParam !== undefined) {
      params.push('loadBandwidthUsed=' + encodeURIComponent(loadBandwidthUsedParam));
    }
    if (loadOriginShieldBandwidthParam !== null && loadOriginShieldBandwidthParam !== undefined) {
      params.push('loadOriginShieldBandwidth=' + encodeURIComponent(loadOriginShieldBandwidthParam));
    }
    if (loadGeographicTrafficDistributionParam !== null && loadGeographicTrafficDistributionParam !== undefined) {
      params.push('loadGeographicTrafficDistribution=' + encodeURIComponent(loadGeographicTrafficDistributionParam));
    }
    if (loadUserBalanceHistoryParam !== null && loadUserBalanceHistoryParam !== undefined) {
      params.push('loadUserBalanceHistory=' + encodeURIComponent(loadUserBalanceHistoryParam));
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
          resource_type: 'Statistics',
          bunny_api: {
            endpoint: '/statistics',
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
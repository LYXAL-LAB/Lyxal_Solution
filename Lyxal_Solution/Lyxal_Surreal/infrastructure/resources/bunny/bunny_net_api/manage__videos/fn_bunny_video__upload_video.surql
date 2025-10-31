-- Fonction: fn::bunny_video__upload_video
-- Endpoint: PUT /library/{libraryId}/videos/{videoId}
-- Description: Upload Video

DEFINE FUNCTION IF NOT EXISTS fn::bunny_video__upload_video(
  $libraryId: int, $videoId: string, $jitEnabled: option<bool>, $enabledResolutions: option<string>, $enabledOutputCodecs: option<string>, $transcribeEnabled: option<bool>, $transcribeLanguages: option<string>, $sourceLanguage: option<string>, $generateTitle: option<bool>, $generateDescription: option<bool>, $generateChapters: option<bool>, $generateMoments: option<bool>
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
    const videoIdParam = await surrealdb.value("$videoId");
    const jitEnabledParam = await surrealdb.value("$jitEnabled");
    const enabledResolutionsParam = await surrealdb.value("$enabledResolutions");
    const enabledOutputCodecsParam = await surrealdb.value("$enabledOutputCodecs");
    const transcribeEnabledParam = await surrealdb.value("$transcribeEnabled");
    const transcribeLanguagesParam = await surrealdb.value("$transcribeLanguages");
    const sourceLanguageParam = await surrealdb.value("$sourceLanguage");
    const generateTitleParam = await surrealdb.value("$generateTitle");
    const generateDescriptionParam = await surrealdb.value("$generateDescription");
    const generateChaptersParam = await surrealdb.value("$generateChapters");
    const generateMomentsParam = await surrealdb.value("$generateMoments");
    let url = 'https://video.bunnycdn.com/library/{libraryId}/videos/{videoId}';
    url = url.replace('{libraryId}', libraryIdParam);
    url = url.replace('{videoId}', videoIdParam);

    const params = [];
    if (jitEnabledParam !== null && jitEnabledParam !== undefined) {
      params.push('jitEnabled=' + encodeURIComponent(jitEnabledParam));
    }
    if (enabledResolutionsParam !== null && enabledResolutionsParam !== undefined) {
      params.push('enabledResolutions=' + encodeURIComponent(enabledResolutionsParam));
    }
    if (enabledOutputCodecsParam !== null && enabledOutputCodecsParam !== undefined) {
      params.push('enabledOutputCodecs=' + encodeURIComponent(enabledOutputCodecsParam));
    }
    if (transcribeEnabledParam !== null && transcribeEnabledParam !== undefined) {
      params.push('transcribeEnabled=' + encodeURIComponent(transcribeEnabledParam));
    }
    if (transcribeLanguagesParam !== null && transcribeLanguagesParam !== undefined) {
      params.push('transcribeLanguages=' + encodeURIComponent(transcribeLanguagesParam));
    }
    if (sourceLanguageParam !== null && sourceLanguageParam !== undefined) {
      params.push('sourceLanguage=' + encodeURIComponent(sourceLanguageParam));
    }
    if (generateTitleParam !== null && generateTitleParam !== undefined) {
      params.push('generateTitle=' + encodeURIComponent(generateTitleParam));
    }
    if (generateDescriptionParam !== null && generateDescriptionParam !== undefined) {
      params.push('generateDescription=' + encodeURIComponent(generateDescriptionParam));
    }
    if (generateChaptersParam !== null && generateChaptersParam !== undefined) {
      params.push('generateChapters=' + encodeURIComponent(generateChaptersParam));
    }
    if (generateMomentsParam !== null && generateMomentsParam !== undefined) {
      params.push('generateMoments=' + encodeURIComponent(generateMomentsParam));
    }

    if (params.length > 0) {
      url += '?' + params.join('&');
    }

    try {
      // Appel API
      const response = await fetch(url, {
        method: 'PUT',
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
            endpoint: '/library/{libraryId}/videos/{videoId}',
            method: 'PUT',
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
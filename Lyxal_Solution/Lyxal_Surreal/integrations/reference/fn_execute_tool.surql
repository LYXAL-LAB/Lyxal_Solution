-- ============================================================================
-- FONCTION GÉNÉRIQUE : fn::execute_tool
-- ============================================================================
-- Description : Fonction universelle pour exécuter n'importe quel tool
--               en lisant sa configuration depuis les tables SQL
-- ============================================================================
-- Avantages :
--   - 1 seule fonction pour 2,436 tools (pas de duplication)
--   - Utilise les tables SQL (AI-ready, maintenable)
--   - Appels API directs (pas de backend nécessaire)
--   - Logging automatique
--   - Gestion d'erreurs centralisée
-- ============================================================================

-- ============================================================================
-- FONCTION PRINCIPALE
-- ============================================================================

DEFINE FUNCTION IF NOT EXISTS fn::execute_tool(
  $tool_id: record<tool>,
  $params: object,
  $user_id: record<user>
) {
  
  RETURN function() {
    
    // ========================================================================
    // 1. RÉCUPÉRER LA CONFIGURATION DU TOOL
    // ========================================================================
    
    const toolIdValue = await surrealdb.value("$tool_id");
    
    const toolQuery = await surrealdb.query(`
      SELECT 
        identity.value,
        identity.slug,
        config.request,
        config.response,
        service_id,
        resource_id,
        is_active
      FROM ${toolIdValue}
    `);
    
    if (!toolQuery || toolQuery.length === 0) {
      return {
        success: false,
        error: 'tool_not_found',
        message: `Tool ${toolIdValue} does not exist`,
        tool_id: toolIdValue
      };
    }
    
    const tool = toolQuery[0];
    
    // Vérifier si le tool est actif
    if (!tool.is_active) {
      return {
        success: false,
        error: 'tool_inactive',
        message: `Tool ${tool.identity.slug} is not active`,
        tool_id: toolIdValue
      };
    }
    
    // ========================================================================
    // 2. RÉCUPÉRER LE SERVICE ET SES INFOS
    // ========================================================================
    
    const serviceQuery = await surrealdb.query(`
      SELECT 
        identity.slug,
        config.base_url,
        config.api_version,
        config.auth_type,
        provider_id
      FROM ${tool.service_id}
    `);
    
    if (!serviceQuery || serviceQuery.length === 0) {
      return {
        success: false,
        error: 'service_not_found',
        message: 'Service configuration not found',
        service_id: tool.service_id
      };
    }
    
    const service = serviceQuery[0];
    
    // ========================================================================
    // 3. RÉCUPÉRER LES CREDENTIALS DE L'UTILISATEUR
    // ========================================================================
    
    const userId = await surrealdb.value("$user_id");
    
    const credentialsQuery = await surrealdb.query(`
      SELECT 
        credentials,
        is_active,
        expires_at
      FROM user_service_credential
      WHERE user_id = ${userId}
      AND service_id = ${tool.service_id}
      AND is_active = true
      LIMIT 1
    `);
    
    if (!credentialsQuery || credentialsQuery.length === 0) {
      return {
        success: false,
        error: 'credentials_not_found',
        message: `No credentials found for service ${service.identity.slug}`,
        service_id: tool.service_id
      };
    }
    
    const userCredentials = credentialsQuery[0];
    
    // Vérifier expiration
    if (userCredentials.expires_at) {
      const now = new Date();
      const expiresAt = new Date(userCredentials.expires_at);
      if (expiresAt < now) {
        return {
          success: false,
          error: 'credentials_expired',
          message: 'Credentials have expired, please reconnect',
          service_id: tool.service_id,
          expires_at: userCredentials.expires_at
        };
      }
    }
    
    // ========================================================================
    // 4. CONSTRUIRE L'URL
    // ========================================================================
    
    let endpoint = tool.config.request.endpoint;
    
    // Remplacer les variables de path (ex: /users/{userId})
    const params = await surrealdb.value("$params");
    for (const [key, value] of Object.entries(params)) {
      endpoint = endpoint.replace(`{${key}}`, value);
      endpoint = endpoint.replace(`{{${key}}}`, value);
    }
    
    // Construire l'URL complète
    const baseUrl = service.config.base_url;
    const apiVersion = service.config.api_version ? `/${service.config.api_version}` : '';
    const fullUrl = `${baseUrl}${apiVersion}${endpoint}`;
    
    // ========================================================================
    // 5. CONSTRUIRE LE BODY
    // ========================================================================
    
    let body = null;
    
    if (tool.config.request.method !== 'GET' && tool.config.request.body_template) {
      // Remplacer les variables dans le body_template
      let bodyStr = JSON.stringify(tool.config.request.body_template);
      
      for (const [key, value] of Object.entries(params)) {
        const regex = new RegExp(`"{{${key}}}"`, 'g');
        // Si la valeur est un nombre ou boolean, ne pas mettre de quotes
        if (typeof value === 'number' || typeof value === 'boolean') {
          bodyStr = bodyStr.replace(regex, value);
        } else {
          bodyStr = bodyStr.replace(regex, `"${value}"`);
        }
      }
      
      body = bodyStr;
    }
    
    // ========================================================================
    // 6. CONSTRUIRE LES HEADERS
    // ========================================================================
    
    const headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    };
    
    // Ajouter l'authentification selon le type
    const authType = service.config.auth_type;
    
    if (authType === 'oauth2' || authType === 'bearer') {
      headers['Authorization'] = `Bearer ${userCredentials.credentials.access_token}`;
    } else if (authType === 'api_key') {
      // Vérifier si header ou query param
      if (userCredentials.credentials.header_name) {
        headers[userCredentials.credentials.header_name] = userCredentials.credentials.api_key;
      }
    } else if (authType === 'basic') {
      const basicAuth = btoa(`${userCredentials.credentials.username}:${userCredentials.credentials.password}`);
      headers['Authorization'] = `Basic ${basicAuth}`;
    }
    
    // Ajouter les headers custom du tool
    if (tool.config.request.headers) {
      for (const [key, value] of Object.entries(tool.config.request.headers)) {
        headers[key] = value;
      }
    }
    
    // ========================================================================
    // 7. FAIRE L'APPEL API
    // ========================================================================
    
    const startTime = Date.now();
    
    try {
      const fetchOptions = {
        method: tool.config.request.method,
        headers: headers
      };
      
      if (body) {
        fetchOptions.body = body;
      }
      
      const response = await fetch(fullUrl, fetchOptions);
      
      const duration = Date.now() - startTime;
      const responseData = await response.json();
      
      // ======================================================================
      // 8. LOGGER L'APPEL
      // ======================================================================
      
      await surrealdb.query(`
        CREATE integration_log CONTENT {
          type: 'api_call',
          user_id: ${userId},
          service_id: ${tool.service_id},
          tool_id: ${toolIdValue},
          request: {
            method: $method,
            url: $url,
            has_body: $has_body
          },
          response: {
            status_code: $status,
            duration_ms: $duration
          },
          status: $status_text,
          timestamp: time::now()
        }
      `, {
        method: tool.config.request.method,
        url: fullUrl,
        has_body: body !== null,
        status: response.status,
        duration: duration,
        status_text: response.ok ? 'success' : 'failed'
      });
      
      // ======================================================================
      // 9. GÉRER LES ERREURS HTTP
      // ======================================================================
      
      if (!response.ok) {
        // Chercher l'erreur dans error_mapping
        const errorQuery = await surrealdb.query(`
          SELECT 
            message_i18n,
            solution_i18n,
            is_retryable,
            retry_delay_seconds
          FROM error_mapping
          WHERE service_id = ${tool.service_id}
          AND http_code = ${response.status}
          LIMIT 1
        `);
        
        let errorMessage = responseData.message || responseData.error || `HTTP ${response.status}`;
        let solution = null;
        let isRetryable = false;
        
        if (errorQuery && errorQuery.length > 0) {
          const error = errorQuery[0];
          // TODO: Récupérer la traduction selon la langue de l'utilisateur
          errorMessage = error.message_i18n.translations.en || errorMessage;
          solution = error.solution_i18n?.translations.en;
          isRetryable = error.is_retryable;
        }
        
        return {
          success: false,
          error: 'api_error',
          status_code: response.status,
          message: errorMessage,
          solution: solution,
          is_retryable: isRetryable,
          raw_response: responseData,
          tool_id: toolIdValue,
          service_id: tool.service_id
        };
      }
      
      // ======================================================================
      // 10. EXTRAIRE LES DONNÉES SELON LA CONFIG
      // ======================================================================
      
      let finalData = responseData;
      
      // Si un data_path est spécifié, extraire seulement cette partie
      if (tool.config.response?.data_path) {
        const path = tool.config.response.data_path;
        finalData = responseData[path] || responseData;
      }
      
      // Si fields_to_extract est spécifié, filtrer les champs
      if (tool.config.response?.fields_to_extract) {
        if (Array.isArray(finalData)) {
          finalData = finalData.map(item => {
            const filtered = {};
            for (const field of tool.config.response.fields_to_extract) {
              if (item[field] !== undefined) {
                filtered[field] = item[field];
              }
            }
            return filtered;
          });
        } else {
          const filtered = {};
          for (const field of tool.config.response.fields_to_extract) {
            if (finalData[field] !== undefined) {
              filtered[field] = finalData[field];
            }
          }
          finalData = filtered;
        }
      }
      
      // ======================================================================
      // 11. RETOURNER LE RÉSULTAT
      // ======================================================================
      
      return {
        success: true,
        data: finalData,
        metadata: {
          tool_id: toolIdValue,
          service_id: tool.service_id,
          status_code: response.status,
          duration_ms: duration,
          timestamp: new Date().toISOString()
        }
      };
      
    } catch (error) {
      // ======================================================================
      // 12. GÉRER LES EXCEPTIONS
      // ======================================================================
      
      await surrealdb.query(`
        CREATE integration_log CONTENT {
          type: 'api_call',
          user_id: ${userId},
          service_id: ${tool.service_id},
          tool_id: ${toolIdValue},
          status: 'exception',
          error_message: $error,
          timestamp: time::now()
        }
      `, {
        error: error.message
      });
      
      return {
        success: false,
        error: 'exception',
        message: error.message,
        tool_id: toolIdValue,
        service_id: tool.service_id
      };
    }
    
  };
};

-- ============================================================================
-- EXEMPLES D'UTILISATION
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Exemple 1 : Poster un message Slack
-- ----------------------------------------------------------------------------

/*
LET $result = fn::execute_tool(
  tool:slack_message_post,
  {
    channel: 'C123456',
    text: 'Hello from Lyxal!',
    as_user: true
  },
  user:john_doe
);

RETURN $result;

// Réponse success:
{
  "success": true,
  "data": {
    "ok": true,
    "channel": "C123456",
    "ts": "1234567890.123456",
    "message": {
      "text": "Hello from Lyxal!",
      "user": "U123456"
    }
  },
  "metadata": {
    "tool_id": "tool:slack_message_post",
    "service_id": "service:slack",
    "status_code": 200,
    "duration_ms": 345,
    "timestamp": "2025-10-30T12:00:00Z"
  }
}

// Réponse erreur:
{
  "success": false,
  "error": "api_error",
  "status_code": 400,
  "message": "Invalid channel",
  "solution": "Check that the channel exists and the bot has access",
  "is_retryable": false,
  "tool_id": "tool:slack_message_post",
  "service_id": "service:slack"
}
*/

-- ----------------------------------------------------------------------------
-- Exemple 2 : Créer une issue GitHub
-- ----------------------------------------------------------------------------

/*
LET $result = fn::execute_tool(
  tool:github_issue_create,
  {
    owner: 'lyxal',
    repo: 'lyxal-app',
    title: 'Bug: Login form not working',
    body: 'When I click submit, nothing happens.',
    labels: ['bug', 'ui']
  },
  user:john_doe
);

RETURN $result;

// Réponse success:
{
  "success": true,
  "data": {
    "id": 1234567890,
    "number": 42,
    "title": "Bug: Login form not working",
    "state": "open",
    "html_url": "https://github.com/lyxal/lyxal-app/issues/42"
  },
  "metadata": {
    "tool_id": "tool:github_issue_create",
    "service_id": "service:github",
    "status_code": 201,
    "duration_ms": 456,
    "timestamp": "2025-10-30T12:00:00Z"
  }
}
*/

-- ----------------------------------------------------------------------------
-- Exemple 3 : Ajouter un événement Google Calendar
-- ----------------------------------------------------------------------------

/*
LET $result = fn::execute_tool(
  tool:google_calendar_event_create,
  {
    calendarId: 'primary',
    summary: 'Meeting with team',
    start: {
      dateTime: '2025-11-01T10:00:00Z',
      timeZone: 'Europe/Paris'
    },
    end: {
      dateTime: '2025-11-01T11:00:00Z',
      timeZone: 'Europe/Paris'
    }
  },
  user:john_doe
);

RETURN $result;

// Réponse success:
{
  "success": true,
  "data": {
    "id": "abc123",
    "summary": "Meeting with team",
    "htmlLink": "https://calendar.google.com/event?eid=abc123",
    "start": {
      "dateTime": "2025-11-01T10:00:00Z"
    }
  },
  "metadata": {
    "tool_id": "tool:google_calendar_event_create",
    "service_id": "service:google_calendar",
    "status_code": 200,
    "duration_ms": 234,
    "timestamp": "2025-10-30T12:00:00Z"
  }
}
*/

-- ----------------------------------------------------------------------------
-- Exemple 4 : Lister les issues GitHub (avec path params)
-- ----------------------------------------------------------------------------

/*
LET $result = fn::execute_tool(
  tool:github_issue_list,
  {
    owner: 'lyxal',
    repo: 'lyxal-app',
    state: 'open',
    per_page: 10
  },
  user:john_doe
);

RETURN $result;

// L'endpoint /repos/{owner}/{repo}/issues devient
// /repos/lyxal/lyxal-app/issues?state=open&per_page=10
*/

-- ----------------------------------------------------------------------------
-- Exemple 5 : Envoyer un email SendGrid
-- ----------------------------------------------------------------------------

/*
LET $result = fn::execute_tool(
  tool:sendgrid_email_send,
  {
    to: 'user@example.com',
    from: 'noreply@lyxal.com',
    subject: 'Welcome to Lyxal!',
    html: '<h1>Welcome!</h1><p>Thank you for signing up.</p>'
  },
  user:john_doe
);

RETURN $result;
*/

-- ============================================================================
-- GESTION DES ERREURS PAR TYPE
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Erreur 1 : Tool not found
-- ----------------------------------------------------------------------------

/*
LET $result = fn::execute_tool(
  tool:invalid_tool,
  {},
  user:john_doe
);

// Réponse:
{
  "success": false,
  "error": "tool_not_found",
  "message": "Tool tool:invalid_tool does not exist",
  "tool_id": "tool:invalid_tool"
}
*/

-- ----------------------------------------------------------------------------
-- Erreur 2 : Credentials not found
-- ----------------------------------------------------------------------------

/*
LET $result = fn::execute_tool(
  tool:slack_message_post,
  { channel: 'C123456', text: 'Hello' },
  user:new_user  // Pas de credentials Slack
);

// Réponse:
{
  "success": false,
  "error": "credentials_not_found",
  "message": "No credentials found for service slack",
  "service_id": "service:slack"
}
*/

-- ----------------------------------------------------------------------------
-- Erreur 3 : Credentials expired
-- ----------------------------------------------------------------------------

/*
// Si expires_at < maintenant
{
  "success": false,
  "error": "credentials_expired",
  "message": "Credentials have expired, please reconnect",
  "service_id": "service:slack",
  "expires_at": "2025-10-29T12:00:00Z"
}
*/

-- ----------------------------------------------------------------------------
-- Erreur 4 : API error (400, 401, 404, 500, etc.)
-- ----------------------------------------------------------------------------

/*
// Si l'API répond avec un code d'erreur
{
  "success": false,
  "error": "api_error",
  "status_code": 400,
  "message": "Invalid channel",  // Depuis error_mapping
  "solution": "Check that the channel exists",  // Depuis error_mapping
  "is_retryable": false,
  "raw_response": {
    "ok": false,
    "error": "channel_not_found"
  },
  "tool_id": "tool:slack_message_post",
  "service_id": "service:slack"
}
*/

-- ----------------------------------------------------------------------------
-- Erreur 5 : Exception (réseau, timeout, etc.)
-- ----------------------------------------------------------------------------

/*
// Si fetch() lance une exception
{
  "success": false,
  "error": "exception",
  "message": "Failed to fetch",
  "tool_id": "tool:slack_message_post",
  "service_id": "service:slack"
}
*/

-- ============================================================================
-- UTILISATION AVEC L'IA
-- ============================================================================

/*
// L'utilisateur dit : "Envoie un message '#general' sur Slack"

// 1. L'IA cherche le tool
LET $tool = (
  SELECT * FROM tool 
  WHERE service_id = service:slack 
  AND value CONTAINS 'message'
  AND value CONTAINS 'post'
  LIMIT 1
)[0];

// 2. L'IA récupère les paramètres requis
LET $required_params = SELECT * FROM parameter 
WHERE tool_id = $tool.id 
AND validation.is_required = true;

// 3. L'IA demande les valeurs manquantes à l'utilisateur
// (channel déjà fourni: '#general', text manquant)

// 4. L'IA appelle la fonction
LET $result = fn::execute_tool(
  $tool.id,
  {
    channel: '#general',
    text: 'Hello from Lyxal AI!'
  },
  $current_user_id
);

// 5. L'IA retourne le résultat à l'utilisateur
IF $result.success THEN
  RETURN "✅ Message envoyé avec succès !";
ELSE
  RETURN "❌ Erreur: " + $result.message;
END;
*/

-- ============================================================================
-- TABLES NÉCESSAIRES
-- ============================================================================

-- Cette fonction nécessite les tables suivantes :
--
-- 1. tool (✅ existe)
-- 2. service (✅ existe)
-- 3. parameter (✅ existe)
-- 4. error_mapping (✅ existe)
-- 5. user_service_credential (❌ à créer)
-- 6. integration_log (❌ à créer)

-- ============================================================================
-- TABLE : user_service_credential
-- ============================================================================

/*
DEFINE TABLE user_service_credential TYPE NORMAL SCHEMAFULL
COMMENT 'Credentials des utilisateurs pour chaque service';

DEFINE FIELD user_id TYPE record<user> ASSERT $value != NONE;
DEFINE FIELD service_id TYPE record<service> ASSERT $value != NONE;

DEFINE FIELD credentials TYPE object {
  -- OAuth2
  DEFINE FIELD access_token TYPE option<string>;
  DEFINE FIELD refresh_token TYPE option<string>;
  DEFINE FIELD token_type TYPE option<string>;
  
  -- API Key
  DEFINE FIELD api_key TYPE option<string>;
  DEFINE FIELD header_name TYPE option<string>;
  
  -- Basic Auth
  DEFINE FIELD username TYPE option<string>;
  DEFINE FIELD password TYPE option<string>;
};

DEFINE FIELD is_active TYPE bool DEFAULT true;
DEFINE FIELD expires_at TYPE option<datetime>;
DEFINE FIELD created_at TYPE datetime DEFAULT time::now() READONLY;
DEFINE FIELD updated_at TYPE datetime DEFAULT time::now() READONLY;

DEFINE INDEX idx_user_service ON user_service_credential FIELDS user_id, service_id UNIQUE;
*/

-- ============================================================================
-- TABLE : integration_log
-- ============================================================================

/*
DEFINE TABLE integration_log TYPE NORMAL SCHEMAFULL
COMMENT 'Logs de tous les appels API via fn::execute_tool';

DEFINE FIELD type TYPE string DEFAULT 'api_call';
DEFINE FIELD user_id TYPE record<user>;
DEFINE FIELD service_id TYPE record<service>;
DEFINE FIELD tool_id TYPE record<tool>;

DEFINE FIELD request TYPE object {
  DEFINE FIELD method TYPE string;
  DEFINE FIELD url TYPE string;
  DEFINE FIELD has_body TYPE bool;
};

DEFINE FIELD response TYPE option<object> {
  DEFINE FIELD status_code TYPE int;
  DEFINE FIELD duration_ms TYPE int;
};

DEFINE FIELD status TYPE string 
  ASSERT $value INSIDE ['success', 'failed', 'exception'];

DEFINE FIELD error_message TYPE option<string>;
DEFINE FIELD timestamp TYPE datetime DEFAULT time::now() READONLY;

DEFINE INDEX idx_user_timestamp ON integration_log FIELDS user_id, timestamp;
DEFINE INDEX idx_service_timestamp ON integration_log FIELDS service_id, timestamp;
*/

-- ============================================================================
-- STATISTIQUES D'UTILISATION
-- ============================================================================

/*
-- Nombre d'appels par service (dernières 24h)
SELECT 
  service_id,
  count() AS total_calls,
  count() FILTER (WHERE status = 'success') AS success_calls,
  count() FILTER (WHERE status = 'failed') AS failed_calls,
  math::mean(response.duration_ms) AS avg_duration_ms
FROM integration_log
WHERE timestamp > time::now() - 1d
GROUP BY service_id
ORDER BY total_calls DESC;

-- Appels les plus lents
SELECT 
  tool_id,
  request.url,
  response.duration_ms,
  timestamp
FROM integration_log
WHERE status = 'success'
ORDER BY response.duration_ms DESC
LIMIT 10;

-- Taux d'erreur par tool
SELECT 
  tool_id,
  count() AS total_calls,
  count() FILTER (WHERE status = 'success') AS success,
  count() FILTER (WHERE status = 'failed') AS failed,
  (count() FILTER (WHERE status = 'failed') * 100.0 / count()) AS error_rate
FROM integration_log
GROUP BY tool_id
HAVING error_rate > 5
ORDER BY error_rate DESC;
*/


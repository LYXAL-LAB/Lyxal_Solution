-- =====================================================
-- REQUÊTES D'EXEMPLE POUR MODULE D'INTÉGRATION
-- =====================================================

-- =====================================================
-- SECTION 1: REQUÊTES DE BASE
-- =====================================================

-- 1.1 Lister tous les providers actifs
SELECT * FROM provider WHERE is_active = true ORDER BY display_name;

-- 1.2 Lister tous les services d'un provider
SELECT * FROM service WHERE provider_id = provider:google ORDER BY display_name;

-- 1.3 Lister toutes les resources d'un service
SELECT * FROM resource WHERE service_id = service:google_sheets ORDER BY display_name;

-- 1.4 Lister tous les tools d'une resource
SELECT * FROM tool WHERE resource_id = resource:sheet ORDER BY display_name;

-- 1.5 Lister tous les paramètres d'un tool
SELECT * FROM parameter WHERE tool_id = tool:append_row ORDER BY display_order;

-- =====================================================
-- SECTION 2: REQUÊTES AVEC JOINTURES
-- =====================================================

-- 2.1 Services avec informations du provider
SELECT 
    service.id,
    service.display_name AS service_name,
    service.version,
    provider.display_name AS provider_name,
    provider.slug AS provider_slug
FROM service
INNER JOIN provider ON service.provider_id = provider.id
ORDER BY provider.display_name, service.display_name;

-- 2.2 Tools avec contexte complet (provider, service, resource)
SELECT 
    tool.id,
    tool.display_name AS tool_name,
    tool.operation_type,
    tool.http_method,
    resource.display_name AS resource_name,
    service.display_name AS service_name,
    provider.display_name AS provider_name
FROM tool
INNER JOIN resource ON tool.resource_id = resource.id
INNER JOIN service ON resource.service_id = service.id
INNER JOIN provider ON service.provider_id = provider.id
ORDER BY provider.display_name, service.display_name, resource.display_name, tool.display_name;

-- 2.3 Paramètres avec contexte du tool
SELECT 
    parameter.*,
    tool.display_name AS tool_name,
    resource.display_name AS resource_name
FROM parameter
INNER JOIN tool ON parameter.tool_id = tool.id
INNER JOIN resource ON tool.resource_id = resource.id
WHERE parameter.is_required = true
ORDER BY resource.display_name, tool.display_name, parameter.display_order;

-- =====================================================
-- SECTION 3: RECHERCHES AVANCÉES
-- =====================================================

-- 3.1 Rechercher tous les services qui supportent les webhooks
SELECT 
    service.*,
    provider.display_name AS provider_name
FROM service
INNER JOIN provider ON service.provider_id = provider.id
WHERE service.is_webhook = true
ORDER BY provider.display_name;

-- 3.2 Rechercher tous les tools qui supportent la pagination
SELECT 
    tool.*,
    resource.display_name AS resource_name,
    service.display_name AS service_name
FROM tool
INNER JOIN resource ON tool.resource_id = resource.id
INNER JOIN service ON resource.service_id = service.id
WHERE tool.supports_pagination = true
ORDER BY service.display_name;

-- 3.3 Rechercher tous les providers avec OAuth2
SELECT * FROM provider 
WHERE support_oauth2 = true 
ORDER BY display_name;

-- 3.4 Rechercher services par catégorie
SELECT * FROM service 
WHERE "Communication" IN categories 
ORDER BY display_name;

-- 3.5 Rechercher services par tag
SELECT * FROM service 
WHERE "popular" IN tags 
ORDER BY display_name;

-- 3.6 Rechercher tous les tools de type "create"
SELECT 
    tool.*,
    resource.display_name AS resource_name,
    service.display_name AS service_name
FROM tool
INNER JOIN resource ON tool.resource_id = resource.id
INNER JOIN service ON resource.service_id = service.id
WHERE tool.operation_type = "create"
ORDER BY service.display_name;

-- =====================================================
-- SECTION 4: AGRÉGATIONS ET STATISTIQUES
-- =====================================================

-- 4.1 Compter les services par provider
SELECT 
    provider.display_name AS provider_name,
    count() AS service_count
FROM service
INNER JOIN provider ON service.provider_id = provider.id
GROUP BY provider.id, provider.display_name
ORDER BY service_count DESC;

-- 4.2 Compter les resources par service
SELECT 
    service.display_name AS service_name,
    count() AS resource_count
FROM resource
INNER JOIN service ON resource.service_id = service.id
GROUP BY service.id, service.display_name
ORDER BY resource_count DESC;

-- 4.3 Compter les tools par resource
SELECT 
    resource.display_name AS resource_name,
    service.display_name AS service_name,
    count() AS tool_count
FROM tool
INNER JOIN resource ON tool.resource_id = resource.id
INNER JOIN service ON resource.service_id = service.id
GROUP BY resource.id, resource.display_name, service.display_name
ORDER BY tool_count DESC;

-- 4.4 Compter les tools par type d'opération
SELECT 
    operation_type,
    count() AS tool_count
FROM tool
GROUP BY operation_type
ORDER BY tool_count DESC;

-- 4.5 Statistiques globales
SELECT 
    (SELECT count() FROM provider WHERE is_active = true) AS active_providers,
    (SELECT count() FROM service WHERE is_active = true) AS active_services,
    (SELECT count() FROM resource WHERE is_active = true) AS active_resources,
    (SELECT count() FROM tool WHERE is_active = true) AS active_tools,
    (SELECT count() FROM parameter) AS total_parameters,
    (SELECT count() FROM credential_type WHERE is_active = true) AS active_credential_types;

-- 4.6 Tools par méthode HTTP
SELECT 
    http_method,
    count() AS tool_count
FROM tool
WHERE http_method IS NOT NONE
GROUP BY http_method
ORDER BY tool_count DESC;

-- =====================================================
-- SECTION 5: REQUÊTES POUR CONSTRUCTION D'UI
-- =====================================================

-- 5.1 Récupérer la structure complète pour un formulaire de configuration
-- (ex: pour Google Sheets Append Row)
LET $tool = (SELECT * FROM tool WHERE slug = "append" AND resource_id IN (
    SELECT id FROM resource WHERE slug = "sheet"
))[0];

SELECT {
    tool: $tool,
    resource: (SELECT * FROM resource WHERE id = $tool.resource_id),
    service: (SELECT * FROM service WHERE id IN (
        SELECT service_id FROM resource WHERE id = $tool.resource_id
    )),
    provider: (SELECT * FROM provider WHERE id IN (
        SELECT provider_id FROM service WHERE id IN (
            SELECT service_id FROM resource WHERE id = $tool.resource_id
        )
    )),
    parameters: (SELECT * FROM parameter WHERE tool_id = $tool.id ORDER BY display_order),
    credentials: (SELECT * FROM credential_type WHERE provider_id IN (
        SELECT provider_id FROM service WHERE id IN (
            SELECT service_id FROM resource WHERE id = $tool.resource_id
        )
    ))
};

-- 5.2 Menu de navigation hiérarchique
SELECT 
    provider.id AS provider_id,
    provider.display_name AS provider_name,
    provider.icon_light AS provider_icon,
    array::group(
        {
            service_id: service.id,
            service_name: service.display_name,
            service_icon: service.icon,
            categories: service.categories
        }
    ) AS services
FROM provider
INNER JOIN service ON service.provider_id = provider.id
WHERE provider.is_active = true AND service.is_active = true
GROUP BY provider.id, provider.display_name, provider.icon_light
ORDER BY provider.display_name;

-- 5.3 Picker de resource pour un service
SELECT 
    resource.id,
    resource.display_name,
    resource.slug,
    (SELECT count() FROM tool WHERE resource_id = resource.id) AS tool_count
FROM resource
WHERE service_id = service:slack
ORDER BY resource.display_name;

-- 5.4 Picker d'opérations pour une resource
SELECT 
    id,
    display_name,
    description,
    operation_type
FROM tool
WHERE resource_id = resource:message
AND is_active = true
ORDER BY operation_type, display_name;

-- =====================================================
-- SECTION 6: GESTION DES CREDENTIALS
-- =====================================================

-- 6.1 Lister tous les types de credentials pour un service
SELECT 
    credential_type.*
FROM credential_type
WHERE provider_id IN (
    SELECT provider_id FROM service WHERE id = service:google_sheets
)
ORDER BY display_name;

-- 6.2 Récupérer la configuration OAuth2 pour un provider
SELECT 
    name,
    display_name,
    auth_type,
    oauth2_config,
    required_fields
FROM credential_type
WHERE provider_id = provider:google
AND auth_type = "oauth2";

-- =====================================================
-- SECTION 7: VERSIONING
-- =====================================================

-- 7.1 Lister toutes les versions d'un service
SELECT * FROM service_version 
WHERE service_id = service:google_sheets 
ORDER BY version DESC;

-- 7.2 Récupérer la version par défaut d'un service
SELECT * FROM service_version 
WHERE service_id = service:google_sheets 
AND is_default = true;

-- 7.3 Lister les versions dépréciées
SELECT 
    service.display_name AS service_name,
    service_version.version,
    service_version.deprecation_date
FROM service_version
INNER JOIN service ON service_version.service_id = service.id
WHERE service_version.is_deprecated = true
ORDER BY service_version.deprecation_date DESC;

-- =====================================================
-- SECTION 8: ERROR HANDLING
-- =====================================================

-- 8.1 Récupérer les mappings d'erreurs pour un service
SELECT * FROM error_mapping 
WHERE service_id = service:google_sheets 
ORDER BY http_status_code;

-- 8.2 Trouver l'erreur correspondant à un code HTTP
SELECT * FROM error_mapping 
WHERE service_id = service:google_sheets 
AND http_status_code = 429;

-- 8.3 Lister toutes les erreurs réessayables
SELECT 
    service.display_name AS service_name,
    error_mapping.http_status_code,
    error_mapping.normalized_message,
    error_mapping.recommended_action
FROM error_mapping
INNER JOIN service ON error_mapping.service_id = service.id
WHERE error_mapping.is_retryable = true
ORDER BY service.display_name, error_mapping.http_status_code;

-- =====================================================
-- SECTION 9: WEBHOOKS
-- =====================================================

-- 9.1 Lister tous les services avec webhooks configurés
SELECT 
    service.display_name AS service_name,
    webhook_config.name AS webhook_name,
    webhook_config.event_type,
    webhook_config.http_method
FROM webhook_config
INNER JOIN service ON webhook_config.service_id = service.id
WHERE webhook_config.is_active = true
ORDER BY service.display_name;

-- 9.2 Configuration de webhook pour un service spécifique
SELECT * FROM webhook_config 
WHERE service_id = service:github 
AND is_active = true;

-- =====================================================
-- SECTION 10: VALIDATION ET QUALITÉ
-- =====================================================

-- 10.1 Services sans icône
SELECT 
    provider.display_name AS provider_name,
    service.display_name AS service_name,
    service.icon
FROM service
INNER JOIN provider ON service.provider_id = provider.id
WHERE service.icon IS NONE;

-- 10.2 Tools sans endpoint API défini
SELECT 
    service.display_name AS service_name,
    resource.display_name AS resource_name,
    tool.display_name AS tool_name
FROM tool
INNER JOIN resource ON tool.resource_id = resource.id
INNER JOIN service ON resource.service_id = service.id
WHERE tool.api_endpoint IS NONE
ORDER BY service.display_name;

-- 10.3 Paramètres requis sans valeur par défaut
SELECT 
    service.display_name AS service_name,
    tool.display_name AS tool_name,
    parameter.display_name AS parameter_name,
    parameter.is_required,
    parameter.default_value
FROM parameter
INNER JOIN tool ON parameter.tool_id = tool.id
INNER JOIN resource ON tool.resource_id = resource.id
INNER JOIN service ON resource.service_id = service.id
WHERE parameter.is_required = true 
AND parameter.default_value IS NONE
ORDER BY service.display_name;

-- =====================================================
-- SECTION 11: RECHERCHE FULL-TEXT
-- =====================================================

-- 11.1 Rechercher providers par nom ou description
SELECT * FROM provider 
WHERE string::lowercase(display_name) CONTAINS "google" 
   OR string::lowercase(description) CONTAINS "google"
ORDER BY display_name;

-- 11.2 Rechercher services par nom, description ou alias
SELECT 
    service.*,
    provider.display_name AS provider_name
FROM service
INNER JOIN provider ON service.provider_id = provider.id
WHERE string::lowercase(service.display_name) CONTAINS "sheet"
   OR string::lowercase(service.description) CONTAINS "sheet"
   OR array::any(service.aliases, |$alias| string::lowercase($alias) CONTAINS "sheet")
ORDER BY service.display_name;

-- =====================================================
-- SECTION 12: EXPORT / DOCUMENTATION
-- =====================================================

-- 12.1 Export complet d'un service pour documentation
SELECT {
    provider: (
        SELECT * FROM provider WHERE id IN (
            SELECT provider_id FROM service WHERE id = service:google_sheets
        )
    )[0],
    service: (SELECT * FROM service WHERE id = service:google_sheets)[0],
    resources: (
        SELECT {
            resource: resource.*,
            tools: (
                SELECT {
                    tool: tool.*,
                    parameters: (SELECT * FROM parameter WHERE tool_id = tool.id ORDER BY display_order)
                } FROM tool WHERE resource_id = resource.id
            )
        } FROM resource WHERE service_id = service:google_sheets
    ),
    credentials: (
        SELECT * FROM credential_type WHERE provider_id IN (
            SELECT provider_id FROM service WHERE id = service:google_sheets
        )
    ),
    webhooks: (SELECT * FROM webhook_config WHERE service_id = service:google_sheets),
    error_mappings: (SELECT * FROM error_mapping WHERE service_id = service:google_sheets)
};

-- 12.2 Matrice des opérations disponibles
SELECT 
    service.display_name AS service,
    resource.display_name AS resource,
    array::group(tool.operation_type) AS available_operations
FROM tool
INNER JOIN resource ON tool.resource_id = resource.id
INNER JOIN service ON resource.service_id = service.id
WHERE tool.is_active = true
GROUP BY service.id, service.display_name, resource.id, resource.display_name
ORDER BY service.display_name, resource.display_name;

-- =====================================================
-- SECTION 13: MAINTENANCE
-- =====================================================

-- 13.1 Identifier les services inactifs
SELECT 
    provider.display_name AS provider_name,
    service.display_name AS service_name,
    service.is_active,
    service.updated_at
FROM service
INNER JOIN provider ON service.provider_id = provider.id
WHERE service.is_active = false
ORDER BY service.updated_at DESC;

-- 13.2 Services sans tools actifs
SELECT 
    service.display_name AS service_name,
    (SELECT count() FROM resource WHERE service_id = service.id) AS resource_count,
    (SELECT count() FROM tool WHERE resource_id IN (
        SELECT id FROM resource WHERE service_id = service.id
    ) AND is_active = true) AS active_tool_count
FROM service
WHERE (SELECT count() FROM tool WHERE resource_id IN (
    SELECT id FROM resource WHERE service_id = service.id
) AND is_active = true) = 0;

-- 13.3 Audit des dernières modifications
SELECT 
    'provider' AS entity_type,
    display_name AS entity_name,
    updated_at
FROM provider
UNION ALL
SELECT 
    'service' AS entity_type,
    display_name AS entity_name,
    updated_at
FROM service
UNION ALL
SELECT 
    'resource' AS entity_type,
    display_name AS entity_name,
    updated_at
FROM resource
ORDER BY updated_at DESC
LIMIT 50;

-- =====================================================
-- SECTION 14: REQUÊTES UTILITAIRES
-- =====================================================

-- 14.1 Vérifier l'intégrité référentielle
-- Services avec provider invalide
SELECT * FROM service WHERE provider_id NOT IN (SELECT id FROM provider);

-- Resources avec service invalide
SELECT * FROM resource WHERE service_id NOT IN (SELECT id FROM service);

-- Tools avec resource invalide
SELECT * FROM tool WHERE resource_id NOT IN (SELECT id FROM resource);

-- Parameters avec tool invalide
SELECT * FROM parameter WHERE tool_id NOT IN (SELECT id FROM tool);

-- 14.2 Statistiques par tag
SELECT 
    tag,
    count() AS usage_count
FROM (
    SELECT array::flatten(tags) AS tag FROM provider
    UNION ALL
    SELECT array::flatten(tags) AS tag FROM service
)
WHERE tag IS NOT NONE
GROUP BY tag
ORDER BY usage_count DESC;

-- 14.3 Distribution des types de paramètres
SELECT 
    parameter_type,
    count() AS parameter_count
FROM parameter
GROUP BY parameter_type
ORDER BY parameter_count DESC;

-- =====================================================
-- FIN DES REQUÊTES D'EXEMPLE
-- =====================================================


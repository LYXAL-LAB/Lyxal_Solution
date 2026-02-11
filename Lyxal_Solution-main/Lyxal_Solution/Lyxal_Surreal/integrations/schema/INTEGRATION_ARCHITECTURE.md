# Architecture de Base de Données pour Module d'Intégration
## Inspirée de l'analyse approfondie de n8n

---

## 📋 Table des Matières

1. [Vue d'ensemble](#vue-densemble)
2. [Structure hiérarchique](#structure-hiérarchique)
3. [Tables principales](#tables-principales)
4. [Relations](#relations)
5. [Exemples d'utilisation](#exemples-dutilisation)
6. [Requêtes utiles](#requêtes-utiles)
7. [Bonnes pratiques](#bonnes-pratiques)

---

## 🎯 Vue d'ensemble

Cette architecture de base de données SurrealDB a été conçue après une analyse approfondie de n8n, la plateforme d'automatisation workflow leader. Elle capture tous les concepts clés découverts dans n8n :

### Concepts Principaux

```
PROVIDER (ex: Google, Facebook, Slack)
    └─ SERVICE (ex: Google Sheets, Google Ads, Slack Messages)
        └─ RESOURCE (ex: Sheet, Message, Channel)
            └─ TOOL/OPERATION (ex: Create, Read, Update, Delete)
                └─ PARAMETER (ex: documentId, sheetName, message)
```

### Ce qui est couvert

- ✅ **Providers** : Fournisseurs de services (Google, Slack, GitHub, etc.)
- ✅ **Services** : Produits spécifiques (Google Sheets, Slack API, etc.)
- ✅ **Resources** : Entités manipulables (Messages, Channels, Sheets, Issues)
- ✅ **Tools/Operations** : Actions disponibles (Create, Read, Update, Delete, Search)
- ✅ **Parameters** : Paramètres des outils avec validation
- ✅ **Credentials** : Systèmes d'authentification (OAuth2, API Key, etc.)
- ✅ **Webhooks** : Configuration des webhooks pour les triggers
- ✅ **Versioning** : Gestion des versions de services
- ✅ **Error Mapping** : Gestion centralisée des erreurs
- ✅ **Response Mapping** : Transformation des réponses API

---

## 📊 Structure hiérarchique

### Niveau 1 : PROVIDER

Le **Provider** représente l'organisation ou la plateforme qui fournit les services.

**Exemples** :
- Google
- Facebook
- Microsoft
- GitHub
- Slack
- Stripe

**Caractéristiques clés** :
```surql
{
    name: "Google",
    display_name: "Google",
    slug: "google",
    description: "Services et APIs Google",
    icon_light: "google-icon-light.svg",
    icon_dark: "google-icon-dark.svg",
    api_base_url: "https://www.googleapis.com",
    support_oauth2: true,
    support_api_key: true,
    tags: ["productivity", "cloud"]
}
```

### Niveau 2 : SERVICE

Le **Service** représente un produit ou une API spécifique du provider.

**Exemples pour Google** :
- Google Sheets
- Google Ads
- Google Calendar
- Google Drive
- Gmail
- Google Analytics

**Exemples pour Slack** :
- Slack API (un seul service principal)

**Caractéristiques clés** :
```surql
{
    name: "googleSheets",
    display_name: "Google Sheets",
    slug: "google-sheets",
    provider_id: provider:google,
    version: "4.7",
    categories: ["Data & Storage", "Productivity"],
    is_trigger: false,
    is_webhook: false,
    aliases: ["CSV", "Sheet", "Spreadsheet"]
}
```

### Niveau 3 : RESOURCE

La **Resource** représente une entité ou un type d'objet manipulable dans le service.

**Exemples pour Google Sheets** :
- Sheet Within Document
- Spreadsheet/Document

**Exemples pour Slack** :
- Channel
- Message
- File
- User
- Reaction
- User Group

**Exemples pour GitHub** :
- Issue
- Repository
- File
- Pull Request
- Release
- Workflow

**Caractéristiques clés** :
```surql
{
    name: "message",
    display_name: "Message",
    slug: "message",
    service_id: service:slack,
    description: "Operations on Slack messages"
}
```

### Niveau 4 : TOOL (Operation/Action)

Le **Tool** représente une action ou opération disponible sur une resource.

**Types d'opérations courantes** :
- `create` : Créer une nouvelle entité
- `read` : Lire/récupérer une entité
- `update` : Mettre à jour une entité
- `delete` : Supprimer une entité
- `list` : Lister plusieurs entités
- `search` : Rechercher des entités
- `upload` : Téléverser un fichier
- `download` : Télécharger un fichier
- `execute` : Exécuter une action
- `custom` : Opération personnalisée

**Exemples pour Slack Message** :
- Post Message
- Update Message
- Delete Message
- Search Messages
- Get Permalink

**Exemples pour Google Sheets** :
- Append Row
- Update Row
- Read Rows
- Delete Row
- Clear Sheet
- Create Sheet

**Caractéristiques clés** :
```surql
{
    name: "append",
    display_name: "Append Row",
    slug: "append",
    resource_id: resource:sheet,
    operation_type: "create",
    http_method: "POST",
    api_endpoint: "/v4/spreadsheets/{spreadsheetId}/values/{range}:append",
    supports_batch: true,
    supports_pagination: false
}
```

### Niveau 5 : PARAMETER

Le **Parameter** représente un paramètre d'entrée pour un outil.

**Types de paramètres** :
- `string` : Texte
- `number` : Nombre
- `boolean` : Vrai/Faux
- `object` : Objet JSON
- `array` : Tableau
- `options` : Liste de choix
- `resourceLocator` : Sélecteur de ressource (par ID, URL, liste)
- `file` : Fichier
- `date/datetime` : Date/heure
- `json` : JSON brut
- `hidden` : Caché

**Exemple de paramètre avec options** :
```surql
{
    name: "dataMode",
    display_name: "Data Mode",
    tool_id: tool:append_row,
    parameter_type: "options",
    is_required: true,
    options: [
        {name: "Auto-Map Input Data", value: "autoMapInputData"},
        {name: "Map Each Column", value: "defineBelow"}
    ],
    default_value: "autoMapInputData"
}
```

**Exemple de resourceLocator** :
```surql
{
    name: "documentId",
    display_name: "Document",
    tool_id: tool:append_row,
    parameter_type: "resourceLocator",
    is_required: true,
    validation_rules: {
        modes: ["list", "url", "id"],
        url_pattern: "https://docs.google.com/spreadsheets/d/([^/]+)"
    }
}
```

---

## 🗂️ Tables principales

### 1. `provider`
Stocke les fournisseurs de services.

**Champs importants** :
- `name`, `display_name`, `slug`
- `icon_light`, `icon_dark`
- `api_base_url`
- `support_oauth2`, `support_api_key`, `support_basic_auth`
- `documentation_url`
- `tags[]`

### 2. `service`
Stocke les services/produits d'un provider.

**Champs importants** :
- `name`, `display_name`, `slug`
- `provider_id` (FK vers provider)
- `version`, `default_version`
- `categories[]`
- `is_trigger`, `is_webhook`
- `aliases[]`
- `tags[]`

### 3. `resource`
Stocke les ressources manipulables d'un service.

**Champs importants** :
- `name`, `display_name`, `slug`
- `service_id` (FK vers service)
- `is_active`

### 4. `tool`
Stocke les opérations/actions disponibles.

**Champs importants** :
- `name`, `display_name`, `slug`
- `resource_id` (FK vers resource)
- `operation_type` (create, read, update, delete, etc.)
- `http_method` (GET, POST, PUT, PATCH, DELETE)
- `api_endpoint`
- `supports_pagination`, `supports_filtering`, `supports_batch`
- `rate_limit_requests`, `rate_limit_period`

### 5. `parameter`
Stocke les paramètres des outils.

**Champs importants** :
- `name`, `display_name`
- `tool_id` (FK vers tool)
- `parameter_type`
- `is_required`, `default_value`
- `options[]` (pour type "options")
- `validation_rules`
- `display_conditions` (conditions d'affichage)
- `display_order`

### 6. `credential_type`
Stocke les types d'authentification.

**Champs importants** :
- `name`, `display_name`, `slug`
- `auth_type` (oauth2, apiKey, basicAuth, etc.)
- `provider_id` (FK vers provider, optionnel)
- `oauth2_config` (configuration OAuth2)
- `required_fields[]` (champs requis)

### 7. `webhook_config`
Configuration des webhooks.

**Champs importants** :
- `service_id` (FK vers service)
- `event_type`
- `http_method`
- `validation_config`
- `signature_config`

### 8. `service_version`
Gestion des versions.

**Champs importants** :
- `service_id` (FK vers service)
- `version`
- `is_default`, `is_deprecated`
- `breaking_changes[]`
- `changelog`

### 9. `error_mapping`
Gestion centralisée des erreurs.

**Champs importants** :
- `service_id` (FK vers service)
- `http_status_code`
- `api_error_code`
- `normalized_message`
- `severity` (info, warning, error, critical)
- `is_retryable`

### 10. `response_mapping`
Transformation des réponses API.

**Champs importants** :
- `tool_id` (FK vers tool)
- `json_path` (ex: "data.items")
- `data_type`
- `transform_function`

---

## 🔗 Relations

### Relations principales

```surql
-- Service appartient à Provider
provider -> belongs_to <- service

-- Service utilise CredentialType
service -> uses_credential <- credential_type

-- Service a des Resources
service -> has_resource <- resource

-- Resource a des Tools
resource -> has_tool <- tool

-- Tool a des Parameters
tool -> has_parameter <- parameter
```

### Exemples de requêtes avec relations

```surql
-- Récupérer tous les services d'un provider
SELECT * FROM service WHERE provider_id = provider:google;

-- Récupérer toutes les ressources d'un service
SELECT * FROM resource WHERE service_id = service:google_sheets;

-- Récupérer tous les outils d'une ressource
SELECT * FROM tool WHERE resource_id = resource:sheet;

-- Récupérer tous les paramètres d'un outil
SELECT * FROM parameter WHERE tool_id = tool:append_row;
```

---

## 💡 Exemples d'utilisation

### Exemple 1 : Créer un nouveau provider avec service

```surql
-- 1. Créer le provider
LET $stripe_provider = CREATE provider SET
    name = "Stripe",
    display_name = "Stripe",
    slug = "stripe",
    description = "Plateforme de paiement en ligne",
    icon_light = "stripe.svg",
    api_base_url = "https://api.stripe.com",
    support_oauth2 = true,
    support_api_key = true,
    tags = ["payment", "ecommerce"];

-- 2. Créer le service
LET $stripe_service = CREATE service SET
    name = "stripe",
    display_name = "Stripe",
    slug = "stripe",
    description = "Accept payments and manage customers",
    provider_id = $stripe_provider.id,
    version = "1.0",
    categories = ["Payment", "Finance"],
    is_active = true;

-- 3. Créer les resources
LET $customer_resource = CREATE resource SET
    name = "customer",
    display_name = "Customer",
    slug = "customer",
    service_id = $stripe_service.id;

LET $charge_resource = CREATE resource SET
    name = "charge",
    display_name = "Charge",
    slug = "charge",
    service_id = $stripe_service.id;

-- 4. Créer les tools
CREATE tool SET
    name = "create",
    display_name = "Create Customer",
    slug = "create",
    resource_id = $customer_resource.id,
    operation_type = "create",
    http_method = "POST",
    api_endpoint = "/v1/customers";

CREATE tool SET
    name = "createCharge",
    display_name = "Create Charge",
    slug = "create-charge",
    resource_id = $charge_resource.id,
    operation_type = "create",
    http_method = "POST",
    api_endpoint = "/v1/charges";
```

### Exemple 2 : Récupérer la structure complète d'un service

```surql
-- Récupérer tout le contexte de Google Sheets
LET $service = SELECT * FROM service WHERE slug = "google-sheets";

LET $provider = SELECT * FROM provider WHERE id = $service.provider_id;

LET $resources = SELECT * FROM resource WHERE service_id = $service.id;

LET $tools = SELECT * FROM tool WHERE resource_id IN (
    SELECT id FROM resource WHERE service_id = $service.id
);

LET $parameters = SELECT * FROM parameter WHERE tool_id IN (
    SELECT id FROM tool WHERE resource_id IN (
        SELECT id FROM resource WHERE service_id = $service.id
    )
);

RETURN {
    provider: $provider,
    service: $service,
    resources: $resources,
    tools: $tools,
    parameters: $parameters
};
```

### Exemple 3 : Rechercher tous les outils de type "create"

```surql
-- Tous les outils de création avec leur contexte
SELECT 
    tool.*,
    resource.display_name AS resource_name,
    service.display_name AS service_name,
    provider.display_name AS provider_name
FROM tool
INNER JOIN resource ON tool.resource_id = resource.id
INNER JOIN service ON resource.service_id = service.id
INNER JOIN provider ON service.provider_id = provider.id
WHERE tool.operation_type = "create";
```

### Exemple 4 : Ajouter un système d'authentification

```surql
-- Créer un credential type OAuth2 pour Stripe
LET $stripe_oauth2 = CREATE credential_type SET
    name = "stripeOAuth2Api",
    display_name = "Stripe OAuth2 API",
    slug = "stripe-oauth2",
    auth_type = "oauth2",
    provider_id = provider:stripe,
    oauth2_config = {
        auth_url: "https://connect.stripe.com/oauth/authorize",
        token_url: "https://connect.stripe.com/oauth/token",
        scope: "read_write",
        grant_type: "authorization_code"
    },
    required_fields = [
        {
            name: "client_id",
            display_name: "Client ID",
            type: "string",
            is_secret: false
        },
        {
            name: "client_secret",
            display_name: "Client Secret",
            type: "string",
            is_secret: true
        }
    ];

-- Lier le credential au service
RELATE service:stripe->uses_credential->$stripe_oauth2.id SET
    is_required = true;
```

---

## 🔍 Requêtes utiles

### Recherche et filtrage

```surql
-- 1. Rechercher tous les providers avec OAuth2
SELECT * FROM provider WHERE support_oauth2 = true;

-- 2. Rechercher tous les services d'une catégorie
SELECT * FROM service WHERE "Communication" IN categories;

-- 3. Rechercher tous les outils avec pagination
SELECT * FROM tool WHERE supports_pagination = true;

-- 4. Rechercher par tags
SELECT * FROM provider WHERE "popular" IN tags;

-- 5. Rechercher services actifs avec triggers
SELECT * FROM service WHERE is_active = true AND is_trigger = true;
```

### Agrégations

```surql
-- 1. Compter les services par provider
SELECT 
    provider.display_name,
    count() AS service_count
FROM service
INNER JOIN provider ON service.provider_id = provider.id
GROUP BY provider.id, provider.display_name;

-- 2. Compter les outils par type d'opération
SELECT 
    operation_type,
    count() AS tool_count
FROM tool
GROUP BY operation_type;

-- 3. Statistiques complètes
SELECT 
    (SELECT count() FROM provider) AS total_providers,
    (SELECT count() FROM service) AS total_services,
    (SELECT count() FROM resource) AS total_resources,
    (SELECT count() FROM tool) AS total_tools,
    (SELECT count() FROM parameter) AS total_parameters;
```

### Navigation hiérarchique

```surql
-- Parcourir du provider jusqu'aux parameters
SELECT 
    provider.display_name AS provider_name,
    service.display_name AS service_name,
    resource.display_name AS resource_name,
    tool.display_name AS tool_name,
    tool.operation_type,
    (SELECT * FROM parameter WHERE tool_id = tool.id) AS parameters
FROM provider
INNER JOIN service ON service.provider_id = provider.id
INNER JOIN resource ON resource.service_id = service.id
INNER JOIN tool ON tool.resource_id = resource.id
WHERE provider.slug = "google";
```

---

## ✅ Bonnes pratiques

### 1. Nommage

**Slugs** :
- Toujours en minuscules
- Utiliser des tirets `-` pour séparer les mots
- Ex: `google-sheets`, `slack-message`, `github-issue`

**Names (identifiants techniques)** :
- CamelCase pour les providers et services
- camelCase pour les resources et tools
- Ex: `googleSheets`, `append`, `createMessage`

**Display Names** :
- Utiliser des noms lisibles par l'humain
- Ex: "Google Sheets", "Append Row", "Post Message"

### 2. Versioning

- Toujours spécifier une version pour les services
- Utiliser le format sémantique : `major.minor.patch`
- Marquer les versions obsolètes dans `service_version`
- Documenter les breaking changes

```surql
CREATE service_version SET
    service_id = service:google_sheets,
    version = "5.0",
    is_default = true,
    release_date = time::now(),
    breaking_changes = [
        "Authentication now requires OAuth2 only",
        "Parameter 'range' is now required"
    ];
```

### 3. Documentation

- Toujours remplir les champs `description`
- Fournir des URLs de documentation
- Utiliser les metadata pour informations supplémentaires

### 4. Validation

- Utiliser `validation_rules` pour les paramètres
- Définir les `min_value` et `max_value` appropriés
- Utiliser `pattern` pour les regex de validation

```surql
CREATE parameter SET
    name = "email",
    display_name = "Email Address",
    tool_id = tool:create_user,
    parameter_type = "string",
    is_required = true,
    pattern = "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$",
    validation_rules = {
        format: "email",
        error_message: "Please enter a valid email address"
    };
```

### 5. Error Handling

- Mapper toutes les erreurs courantes dans `error_mapping`
- Indiquer si une erreur est réessayable (`is_retryable`)
- Fournir des actions recommandées

```surql
CREATE error_mapping SET
    service_id = service:google_sheets,
    http_status_code = 429,
    api_error_code = "RATE_LIMIT_EXCEEDED",
    normalized_message = "Taux de requêtes dépassé. Veuillez réessayer plus tard.",
    severity = "warning",
    is_retryable = true,
    recommended_action = "Attendre 60 secondes puis réessayer";
```

### 6. Tags et catégorisation

- Utiliser des tags cohérents
- Créer des catégories standardisées
- Faciliter la découverte des services

**Catégories recommandées** :
- Communication
- Data & Storage
- Development
- Finance & Payment
- Marketing
- Productivity
- Security
- Analytics

**Tags recommandés** :
- popular (services populaires)
- premium (services payants)
- beta (en version bêta)
- enterprise (pour entreprises)
- real-time (temps réel)

### 7. Performance

- Créer des index sur les champs fréquemment recherchés
- Utiliser `display_order` pour optimiser l'affichage
- Limiter la taille des metadata

### 8. Sécurité

- Marquer les champs sensibles comme `is_secret` dans credentials
- Ne jamais stocker de credentials réels dans la BDD de configuration
- Utiliser des références vers un vault externe

---

## 📈 Extensions possibles

### 1. Système de permissions

```surql
DEFINE TABLE permission SCHEMAFULL;
DEFINE FIELD role ON permission TYPE string;
DEFINE FIELD resource_type ON permission TYPE string;
DEFINE FIELD can_create ON permission TYPE bool DEFAULT false;
DEFINE FIELD can_read ON permission TYPE bool DEFAULT false;
DEFINE FIELD can_update ON permission TYPE bool DEFAULT false;
DEFINE FIELD can_delete ON permission TYPE bool DEFAULT false;
```

### 2. Historique des modifications

```surql
DEFINE TABLE audit_log SCHEMAFULL;
DEFINE FIELD entity_type ON audit_log TYPE string;
DEFINE FIELD entity_id ON audit_log TYPE record;
DEFINE FIELD action ON audit_log TYPE string;
DEFINE FIELD old_value ON audit_log TYPE option<object>;
DEFINE FIELD new_value ON audit_log TYPE option<object>;
DEFINE FIELD changed_by ON audit_log TYPE string;
DEFINE FIELD changed_at ON audit_log TYPE datetime DEFAULT time::now();
```

### 3. Rate limiting avancé

```surql
DEFINE TABLE rate_limit SCHEMAFULL;
DEFINE FIELD service_id ON rate_limit TYPE record<service>;
DEFINE FIELD endpoint_pattern ON rate_limit TYPE string;
DEFINE FIELD requests_per_minute ON rate_limit TYPE int;
DEFINE FIELD requests_per_hour ON rate_limit TYPE int;
DEFINE FIELD requests_per_day ON rate_limit TYPE int;
DEFINE FIELD burst_size ON rate_limit TYPE option<int>;
```

### 4. Métriques et monitoring

```surql
DEFINE TABLE usage_metric SCHEMAFULL;
DEFINE FIELD service_id ON usage_metric TYPE record<service>;
DEFINE FIELD tool_id ON usage_metric TYPE option<record<tool>>;
DEFINE FIELD execution_count ON usage_metric TYPE int DEFAULT 0;
DEFINE FIELD success_count ON usage_metric TYPE int DEFAULT 0;
DEFINE FIELD error_count ON usage_metric TYPE int DEFAULT 0;
DEFINE FIELD avg_response_time_ms ON usage_metric TYPE float;
DEFINE FIELD last_execution_at ON usage_metric TYPE datetime;
```

---

## 🎓 Conclusion

Cette architecture de base de données capture l'essence de la structure n8n :

1. **Hiérarchie claire** : Provider → Service → Resource → Tool → Parameter
2. **Flexibilité** : Support de multiples types d'auth, versioning, webhooks
3. **Extensibilité** : Metadata, tags, et tables de configuration
4. **Maintenabilité** : Relations claires, indexes optimisés
5. **Complétude** : Gestion des erreurs, mapping des réponses, rate limiting

Cette structure vous permet de créer un module d'intégration robuste et scalable, capable de s'adapter à n'importe quel fournisseur de services tiers.


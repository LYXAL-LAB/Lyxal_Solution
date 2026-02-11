# 📦 Module d'Intégration - Structure de Base de Données SurrealDB

Bienvenue dans la documentation complète de l'architecture de base de données pour votre module d'intégration, inspirée d'une analyse approfondie du code source de **n8n**.

---

## 📂 Structure des Fichiers

```
schema/
├── README.md                          # Ce fichier
├── ARCHITECTURE_SUMMARY.md            # Résumé visuel de l'architecture
├── INTEGRATION_ARCHITECTURE.md        # Documentation complète et détaillée
├── integration_schema.surql           # Schéma complet de la BDD
├── example_queries.surql              # 100+ requêtes d'exemple
└── seed_data_extended.surql           # Données d'exemple (15+ providers)
```

---

## 🚀 Démarrage Rapide

### 1. Créer la base de données

```bash
# Démarrer SurrealDB
surreal start --bind 0.0.0.0:8000

# Dans un autre terminal, se connecter
surreal sql --endpoint http://localhost:8000 --namespace myapp --database integrations
```

### 2. Importer le schéma

```bash
# Importer le schéma principal
surreal import --endpoint http://localhost:8000 \
  --namespace myapp \
  --database integrations \
  integration_schema.surql
```

### 3. Charger les données d'exemple (optionnel)

Le schéma `integration_schema.surql` contient déjà des exemples pour :
- Google (Google Sheets)
- Slack
- GitHub

Pour ajouter plus d'exemples :

```bash
surreal import --endpoint http://localhost:8000 \
  --namespace myapp \
  --database integrations \
  seed_data_extended.surql
```

Cela ajoutera :
- Facebook (Lead Ads)
- Microsoft (Teams, Excel, Outlook)
- Stripe
- Trello
- Notion
- Airtable
- Mailchimp
- Twilio
- HubSpot
- Salesforce

---

## 📖 Guides de Lecture

### Pour comprendre l'architecture

1. **Commencez par** : [`ARCHITECTURE_SUMMARY.md`](./ARCHITECTURE_SUMMARY.md)
   - Vue d'ensemble rapide
   - Diagrammes et schémas visuels
   - Patterns identifiés dans n8n
   - Statistiques et cas d'usage

2. **Approfondissez avec** : [`INTEGRATION_ARCHITECTURE.md`](./INTEGRATION_ARCHITECTURE.md)
   - Documentation complète de chaque table
   - Explications détaillées des champs
   - Relations et contraintes
   - Bonnes pratiques
   - Extensions possibles

### Pour implémenter

1. **Schéma** : [`integration_schema.surql`](./integration_schema.surql)
   - Définitions complètes des tables
   - Index et contraintes
   - Relations
   - Exemples de données pour Google, Slack, GitHub

2. **Requêtes** : [`example_queries.surql`](./example_queries.surql)
   - 100+ requêtes prêtes à l'emploi
   - Recherches simples et avancées
   - Agrégations et statistiques
   - Requêtes pour construction d'UI
   - Maintenance et debugging

3. **Données** : [`seed_data_extended.surql`](./seed_data_extended.surql)
   - 15+ providers populaires
   - 20+ services configurés
   - 50+ resources
   - 100+ tools/opérations
   - Error mappings
   - Webhook configurations

---

## 🎯 Concepts Clés

### Hiérarchie Principale

```
PROVIDER (Fournisseur)
    ↓ possède plusieurs
SERVICE (Produit/API)
    ↓ possède plusieurs
RESOURCE (Entité)
    ↓ possède plusieurs
TOOL (Action/Opération)
    ↓ possède plusieurs
PARAMETER (Paramètre)
```

### Exemple Concret : Google Sheets

```
Google (Provider)
    └── Google Sheets (Service)
        ├── Sheet Within Document (Resource)
        │   ├── Append Row (Tool)
        │   │   ├── documentId (Parameter)
        │   │   ├── sheetName (Parameter)
        │   │   └── dataMode (Parameter)
        │   ├── Update Row (Tool)
        │   ├── Read Rows (Tool)
        │   └── Delete Row (Tool)
        └── Spreadsheet (Resource)
            ├── Create Spreadsheet (Tool)
            └── Delete Spreadsheet (Tool)
```

---

## 📊 Tables Principales

| Table | Description | Nb Champs |
|-------|-------------|-----------|
| **provider** | Fournisseurs (Google, Slack, etc.) | 15 |
| **service** | Services/APIs | 20 |
| **resource** | Entités manipulables | 8 |
| **tool** | Actions/Opérations | 20 |
| **parameter** | Paramètres des outils | 18 |
| **credential_type** | Types d'authentification | 12 |
| **webhook_config** | Configuration webhooks | 11 |
| **service_version** | Gestion des versions | 10 |
| **error_mapping** | Mapping des erreurs | 11 |
| **response_mapping** | Transformation des réponses | 9 |
| **tag** | Tags pour catégorisation | 5 |

---

## 🔍 Requêtes Fréquentes

### Lister tous les providers actifs

```surql
SELECT * FROM provider WHERE is_active = true ORDER BY display_name;
```

### Trouver tous les services d'un provider

```surql
SELECT * FROM service WHERE provider_id = provider:google;
```

### Obtenir la structure complète d'un tool

```surql
SELECT {
    tool: tool.*,
    resource: (SELECT * FROM resource WHERE id = tool.resource_id),
    service: (SELECT * FROM service WHERE id IN (
        SELECT service_id FROM resource WHERE id = tool.resource_id
    )),
    provider: (SELECT * FROM provider WHERE id IN (
        SELECT provider_id FROM service WHERE id IN (
            SELECT service_id FROM resource WHERE id = tool.resource_id
        )
    )),
    parameters: (SELECT * FROM parameter WHERE tool_id = tool.id ORDER BY display_order)
} FROM tool WHERE slug = "append";
```

### Rechercher par catégorie

```surql
SELECT * FROM service WHERE "Communication" IN categories;
```

### Statistiques globales

```surql
SELECT 
    (SELECT count() FROM provider WHERE is_active = true) AS active_providers,
    (SELECT count() FROM service WHERE is_active = true) AS active_services,
    (SELECT count() FROM tool WHERE is_active = true) AS active_tools;
```

➡️ **Plus de 100 requêtes dans** [`example_queries.surql`](./example_queries.surql)

---

## 🎨 Cas d'Usage

### Use Case 1 : Ajouter un nouveau provider

```surql
-- 1. Créer le provider
LET $my_provider = CREATE provider SET
    name = "MyService",
    display_name = "My Service",
    slug = "my-service",
    description = "Description de mon service",
    api_base_url = "https://api.myservice.com",
    support_oauth2 = true,
    tags = ["custom"];

-- 2. Créer le service
LET $my_service = CREATE service SET
    name = "myService",
    display_name = "My Service",
    slug = "my-service",
    provider_id = $my_provider.id,
    version = "1.0",
    categories = ["Custom"];

-- 3. Créer une resource
LET $my_resource = CREATE resource SET
    name = "item",
    display_name = "Item",
    slug = "item",
    service_id = $my_service.id;

-- 4. Créer un tool
CREATE tool SET
    name = "create",
    display_name = "Create Item",
    slug = "create",
    resource_id = $my_resource.id,
    operation_type = "create",
    http_method = "POST",
    api_endpoint = "/items";
```

### Use Case 2 : Configurer l'authentification

```surql
-- OAuth2
CREATE credential_type SET
    name = "myServiceOAuth2",
    display_name = "My Service OAuth2",
    slug = "my-service-oauth2",
    auth_type = "oauth2",
    provider_id = provider:my_service,
    oauth2_config = {
        auth_url: "https://myservice.com/oauth/authorize",
        token_url: "https://myservice.com/oauth/token",
        scope: "read write",
        grant_type: "authorization_code"
    };

-- OU API Key
CREATE credential_type SET
    name = "myServiceApiKey",
    display_name = "My Service API Key",
    slug = "my-service-api-key",
    auth_type = "apiKey",
    provider_id = provider:my_service,
    required_fields = [
        {name: "api_key", display_name: "API Key", type: "string", is_secret: true}
    ];
```

### Use Case 3 : Ajouter la gestion d'erreurs

```surql
-- Rate limiting
CREATE error_mapping SET
    service_id = service:my_service,
    http_status_code = 429,
    normalized_message = "Trop de requêtes",
    severity = "warning",
    is_retryable = true,
    recommended_action = "Attendez quelques secondes puis réessayez";

-- Unauthorized
CREATE error_mapping SET
    service_id = service:my_service,
    http_status_code = 401,
    normalized_message = "Non autorisé",
    severity = "error",
    is_retryable = false,
    recommended_action = "Vérifiez vos credentials";
```

---

## 🔐 Types d'Authentification Supportés

| Type | Description | Exemples |
|------|-------------|----------|
| `oauth2` | OAuth 2.0 | Google, GitHub, Slack |
| `oauth1` | OAuth 1.0a | Twitter |
| `apiKey` | Clé API | Stripe, Twilio |
| `basicAuth` | Basic Auth | Nombreux services |
| `bearerToken` | Token Bearer | APIs modernes |
| `headerAuth` | Header personnalisé | APIs custom |
| `queryAuth` | Query params | APIs simples |
| `custom` | Personnalisé | Cas spéciaux |

---

## 📈 Extensions Disponibles

La documentation détaille les extensions suivantes dans [`INTEGRATION_ARCHITECTURE.md`](./INTEGRATION_ARCHITECTURE.md) :

1. **Système de permissions** (RBAC)
2. **Historique des modifications** (Audit Log)
3. **Rate limiting avancé**
4. **Métriques et monitoring**
5. **Multi-tenancy**

---

## 🧪 Tests et Validation

### Vérifier l'intégrité référentielle

```surql
-- Services avec provider invalide
SELECT * FROM service WHERE provider_id NOT IN (SELECT id FROM provider);

-- Resources avec service invalide
SELECT * FROM resource WHERE service_id NOT IN (SELECT id FROM service);

-- Tools avec resource invalide
SELECT * FROM tool WHERE resource_id NOT IN (SELECT id FROM resource);
```

### Trouver les incohérences

```surql
-- Services sans icône
SELECT * FROM service WHERE icon IS NONE;

-- Tools sans endpoint
SELECT * FROM tool WHERE api_endpoint IS NONE;

-- Paramètres requis sans valeur par défaut
SELECT * FROM parameter 
WHERE is_required = true 
AND default_value IS NONE;
```

---

## 🎓 Analyse de n8n

Cette architecture est le résultat d'une analyse approfondie de n8n :

### Fichiers Analysés

**Core Architecture** :
- `/packages/nodes-base/nodes/` (5,463 fichiers)
- `/packages/nodes-base/credentials/` (443 fichiers)
- Structure de 300+ providers
- 600+ services/intégrations

**Exemples Étudiés** :
- Google (15 services : Sheets, Ads, Calendar, Drive, Gmail, etc.)
- Slack (7 resources : Channel, Message, File, User, etc.)
- GitHub (8 resources : Issue, Repository, File, etc.)
- Microsoft (10+ services)

### Patterns Identifiés

1. **Hiérarchie stricte** : Provider → Service → Resource → Tool
2. **Resource Locators** : 3 modes de sélection (list, url, id)
3. **Versioning intelligent** : Versions multiples actives
4. **Metadata everywhere** : Extensibilité maximale
5. **Display conditions** : UI dynamique
6. **Validation déclarative** : Rules dans metadata

---

## 📚 Documentation Complète

### Fichiers de Documentation

| Fichier | Contenu | Pages |
|---------|---------|-------|
| **ARCHITECTURE_SUMMARY.md** | Vue d'ensemble visuelle | ~15 pages |
| **INTEGRATION_ARCHITECTURE.md** | Documentation détaillée | ~50 pages |
| **README.md** | Ce fichier | ~10 pages |

### Fichiers d'Implémentation

| Fichier | Contenu | Lignes |
|---------|---------|--------|
| **integration_schema.surql** | Schéma complet + exemples | ~1,200 lignes |
| **example_queries.surql** | Requêtes d'exemple | ~600 lignes |
| **seed_data_extended.surql** | Données 15+ providers | ~800 lignes |

---

## 🤝 Contribution

### Ajouter un nouveau provider

1. Consulter [`seed_data_extended.surql`](./seed_data_extended.surql) pour des exemples
2. Suivre la structure hiérarchique
3. Ajouter les error mappings
4. Configurer les credentials
5. Tester avec les requêtes de validation

### Ajouter une nouvelle fonctionnalité

1. Consulter la section "Extensions" dans [`INTEGRATION_ARCHITECTURE.md`](./INTEGRATION_ARCHITECTURE.md)
2. Créer une nouvelle table si nécessaire
3. Ajouter les relations appropriées
4. Documenter dans le README
5. Ajouter des exemples de requêtes

---

## 🐛 Debugging

### Logs et Monitoring

```surql
-- Services inactifs
SELECT * FROM service WHERE is_active = false;

-- Dernières modifications
SELECT 'provider' AS type, display_name, updated_at FROM provider
UNION ALL
SELECT 'service' AS type, display_name, updated_at FROM service
ORDER BY updated_at DESC LIMIT 20;

-- Statistiques par provider
SELECT 
    provider.display_name,
    count() AS service_count
FROM service
INNER JOIN provider ON service.provider_id = provider.id
GROUP BY provider.display_name;
```

---

## 📞 Support

Pour toute question :

1. **Documentation** : Consultez [`INTEGRATION_ARCHITECTURE.md`](./INTEGRATION_ARCHITECTURE.md)
2. **Exemples** : Voir [`example_queries.surql`](./example_queries.surql)
3. **Patterns** : Référez-vous à [`ARCHITECTURE_SUMMARY.md`](./ARCHITECTURE_SUMMARY.md)

---

## 🎯 Roadmap

### ✅ Phase 1 : Core (Terminé)
- [x] Schéma de base
- [x] Relations principales
- [x] Documentation complète
- [x] Exemples de données

### ✅ Phase 2 : Authentication (Terminé)
- [x] OAuth2, API Key, Basic Auth
- [x] Configuration flexible
- [x] Exemples pour providers populaires

### ✅ Phase 3 : Advanced Features (Terminé)
- [x] Webhooks
- [x] Versioning
- [x] Error mapping
- [x] Response mapping

### 🔄 Phase 4 : Extensions (En cours)
- [ ] Rate limiting avancé
- [ ] Monitoring & metrics
- [ ] RBAC & permissions
- [ ] Multi-tenancy

### 📅 Phase 5 : Future
- [ ] API Gateway
- [ ] Circuit breaker
- [ ] Cache management
- [ ] Analytics dashboard

---

## 📄 Licence

Ce projet est fourni tel quel pour usage éducatif et commercial.

L'analyse de n8n est basée sur leur code open source (Apache 2.0).

---

## 🙏 Remerciements

Merci à l'équipe n8n pour leur excellente architecture open source qui a servi d'inspiration pour cette base de données.

---

**Dernière mise à jour** : 2025-10-28  
**Version** : 1.0.0  
**Auteur** : Équipe Lyxal Solution

---

## 🚀 Prochaines Étapes

1. ✅ Importer le schéma : `integration_schema.surql`
2. ✅ Charger les exemples : `seed_data_extended.surql`
3. 📖 Lire la documentation : `INTEGRATION_ARCHITECTURE.md`
4. 🔍 Tester les requêtes : `example_queries.surql`
5. 🎨 Commencer à construire votre module !

**Bon développement ! 🎉**


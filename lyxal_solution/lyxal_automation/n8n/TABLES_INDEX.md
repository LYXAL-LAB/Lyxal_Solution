# 📋 Index des Tables n8n

## Référence rapide par nom de table

| Table | Catégorie | Description |
|-------|-----------|-------------|
| `annotation_tag_entity` | Tags | Tags pour annotations d'exécution (EE) |
| `auth_identity` | Identity | Identités SSO/LDAP liées aux utilisateurs |
| `auth_provider_sync_history` | Identity | Historique synchros LDAP/SAML |
| `binary_data` | Binary | Fichiers binaires stockés en base |
| `chat_hub_agents` | ChatHub | Configuration agents IA |
| `chat_hub_messages` | ChatHub | Messages de conversation |
| `chat_hub_sessions` | ChatHub | Sessions de chat |
| `credentials_entity` | Credentials | Identifiants chiffrés |
| `data_table` | DataTables | Tables de données utilisateur |
| `data_table_column` | DataTables | Colonnes des DataTables |
| `event_destinations` | Logs | Destinations log streaming (EE) |
| `execution_annotation_tags` | Tags | Jonction annotations ↔ tags |
| `execution_annotations` | Executions | Annotations sur exécutions (EE) |
| `execution_data` | Executions | Données détaillées d'exécution |
| `execution_entity` | Executions | Enregistrement des exécutions |
| `execution_metadata` | Executions | Métadonnées key-value |
| `folder` | Projects | Dossiers d'organisation |
| `folder_tag` | Tags | Jonction dossiers ↔ tags |
| `installed_nodes` | Packages | Nœuds des packages npm |
| `installed_packages` | Packages | Packages npm installés |
| `invalid_auth_token` | Identity | Tokens révoqués |
| `oauth_access_tokens` | OAuth | Tokens d'accès MCP |
| `oauth_authorization_codes` | OAuth | Codes d'autorisation MCP |
| `oauth_clients` | OAuth | Clients OAuth enregistrés |
| `oauth_refresh_tokens` | OAuth | Refresh tokens MCP |
| `oauth_user_consents` | OAuth | Consentements utilisateur |
| `processed_data` | Variables | Données de déduplication |
| `project` | Projects | Espaces de travail |
| `project_relation` | Projects | Membres des projets |
| `role` | Identity | Rôles (global/projet) |
| `role_scope` | Identity | Jonction rôles ↔ permissions |
| `scope` | Identity | Permissions atomiques |
| `settings` | Variables | Paramètres système |
| `shared_credentials` | Projects | Partage credentials ↔ projets |
| `shared_workflow` | Projects | Partage workflows ↔ projets |
| `tag_entity` | Tags | Définition des tags |
| `test_case_execution` | Tests | Cas de test individuels (EE) |
| `test_run` | Tests | Sessions de test (EE) |
| `user` | Identity | Utilisateurs |
| `user_api_keys` | Identity | Clés API utilisateur |
| `variables` | Variables | Variables d'environnement |
| `webhook_entity` | Workflows | Webhooks actifs |
| `workflow_dependency` | Workflows | Index des dépendances |
| `workflow_entity` | Workflows | Définitions de workflows |
| `workflow_history` | Workflows | Historique des versions |
| `workflow_publish_history` | Workflows | Journal activations |
| `workflow_statistics` | Workflows | Statistiques d'exécution |
| `workflows_tags` | Tags | Jonction workflows ↔ tags |

---

## Par catégorie

### 🔐 Identity & Auth
- `user` - Utilisateurs
- `role` - Rôles
- `scope` - Permissions
- `role_scope` - Jonction rôles ↔ scopes
- `auth_identity` - Identités SSO
- `user_api_keys` - Clés API
- `auth_provider_sync_history` - Historique synchro
- `invalid_auth_token` - Tokens révoqués

### ⚙️ Workflows
- `workflow_entity` - Définitions
- `workflow_history` - Versions
- `workflow_publish_history` - Activations
- `workflow_statistics` - Stats
- `workflow_dependency` - Dépendances
- `webhook_entity` - Webhooks

### 🚀 Executions
- `execution_entity` - Exécutions
- `execution_data` - Données
- `execution_metadata` - Métadonnées
- `execution_annotations` - Annotations (EE)

### 📁 Projects & Sharing
- `project` - Projets
- `project_relation` - Membres
- `shared_workflow` - Partage workflows
- `shared_credentials` - Partage credentials
- `folder` - Dossiers

### 🔑 Credentials
- `credentials_entity` - Identifiants

### 🏷️ Tags
- `tag_entity` - Tags
- `annotation_tag_entity` - Tags annotations (EE)
- `workflows_tags` - Jonction
- `folder_tag` - Jonction
- `execution_annotation_tags` - Jonction

### 📝 Variables & Settings
- `variables` - Variables
- `settings` - Paramètres
- `processed_data` - Cache déduplication

### 📎 Binary Data
- `binary_data` - Fichiers

### 🧪 Tests (Enterprise)
- `test_run` - Sessions de test
- `test_case_execution` - Cas de test

### 🔑 OAuth/MCP
- `oauth_clients` - Clients
- `oauth_access_tokens` - Access tokens
- `oauth_refresh_tokens` - Refresh tokens
- `oauth_authorization_codes` - Auth codes
- `oauth_user_consents` - Consentements

### 💬 ChatHub
- `chat_hub_agents` - Agents IA
- `chat_hub_sessions` - Sessions
- `chat_hub_messages` - Messages

### 📊 DataTables
- `data_table` - Tables
- `data_table_column` - Colonnes

### 📦 Community Packages
- `installed_packages` - Packages
- `installed_nodes` - Nœuds

### 📡 Log Streaming (Enterprise)
- `event_destinations` - Destinations

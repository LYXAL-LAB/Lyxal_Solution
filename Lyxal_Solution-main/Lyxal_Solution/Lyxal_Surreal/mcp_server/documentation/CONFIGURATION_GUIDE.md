# ⚙️ Guide de configuration MCP Server pour Lyxal

## 📋 Prérequis

- ✅ SurrealDB installé et en cours d'exécution
- ✅ Node.js (pour le MCP Server)
- ✅ Claude Desktop ou autre client MCP
- ✅ Compte Bunny.net avec API Key

---

## 🚀 Installation rapide

### Étape 1 : Démarrer SurrealDB

```bash
# Démarrer SurrealDB (WebSocket sur port 8000)
surreal start --bind 0.0.0.0:8000 --user root --pass root memory

# Ou avec persistence :
surreal start --bind 0.0.0.0:8000 --user root --pass root file://lyxal.db
```

### Étape 2 : Configurer le MCP Server

#### Pour Claude Desktop

Créer/éditer : `%APPDATA%\Claude\claude_desktop_config.json` (Windows)

```json
{
  "mcpServers": {
    "lyxal-surrealdb": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-surrealdb",
        "ws://localhost:8000",
        "--namespace", "lyxal",
        "--database", "infrastructure",
        "--username", "root",
        "--password", "root"
      ]
    }
  }
}
```

#### Pour Cursor AI

Créer/éditer : `.cursor/mcp.json` dans votre workspace

```json
{
  "mcpServers": {
    "lyxal-surrealdb": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-surrealdb",
        "ws://localhost:8000",
        "--namespace", "lyxal",
        "--database", "infrastructure",
        "--username", "root",
        "--password", "root"
      ]
    }
  }
}
```

### Étape 3 : Initialiser la base de données

```bash
# Se connecter à SurrealDB
surreal sql --endpoint ws://localhost:8000 --namespace lyxal --database infrastructure --username root --password root
```

```sql
-- Définir le namespace et la database
USE NS lyxal;
USE DB infrastructure;

-- Configurer la clé API Bunny.net
DEFINE PARAM $bunny_api_key VALUE "votre-api-key-bunny-ici";

-- Importer toutes les tables et fonctions
-- (exécuter tous les fichiers .surql de votre projet)
```

### Étape 4 : Vérifier la connexion

Dans Claude Desktop ou Cursor, l'IA peut maintenant exécuter :

```sql
-- Test de connexion
INFO FOR DB;

-- Lister les fonctions Bunny disponibles
INFO FOR DB;

-- Test d'une fonction (lecture seule)
RETURN fn::bunny_list_dns_zones(1, 10);
```

---

## 🔐 Configuration de sécurité

### Créer un utilisateur dédié pour l'IA

```sql
-- Créer un scope pour l'IA
DEFINE SCOPE ai_access 
SESSION 24h
SIGNIN (
  SELECT * FROM ai_user WHERE username = $username AND crypto::argon2::compare(password, $password)
)
SIGNUP (
  CREATE ai_user CONTENT {
    username: $username,
    password: crypto::argon2::generate($password)
  }
);

-- Créer un utilisateur IA
CREATE ai_user:claude CONTENT {
  username: "claude",
  password: crypto::argon2::generate("secure-password-here"),
  permissions: ["read", "execute_functions"]
};

-- Définir les permissions
DEFINE TABLE bunny_dns_zone PERMISSIONS
  FOR select WHERE $auth.permissions CONTAINS "read"
  FOR create, update, delete WHERE $auth.permissions CONTAINS "write";

DEFINE FUNCTION fn::bunny_add_dns_zone PERMISSIONS
  FOR execute WHERE $auth.permissions CONTAINS "execute_functions";
```

### Configuration MCP avec authentification

```json
{
  "mcpServers": {
    "lyxal-surrealdb": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-surrealdb",
        "ws://localhost:8000",
        "--namespace", "lyxal",
        "--database", "infrastructure",
        "--scope", "ai_access",
        "--username", "claude",
        "--password", "secure-password-here"
      ]
    }
  }
}
```

---

## 🎯 Commandes utiles pour l'IA

### Découverte de l'infrastructure

#### 1. Structure native SurrealDB

```sql
-- Vue d'ensemble complète
INFO FOR DB;

-- Lister toutes les tables
SELECT name FROM information_schema.tables;

-- Lister toutes les fonctions Bunny
INFO FOR DB;
-- Puis filtrer sur "fn::bunny_*"

-- Inspecter une table spécifique
INFO FOR TABLE bunny_dns_zone;
INFO FOR TABLE bunny_pull_zone;

-- Inspecter une fonction
INFO FOR FUNCTION fn::bunny_add_dns_zone;
```

#### 2. Catalogue enrichi (`builder_catalogue`)

```sql
-- Découvrir toutes les ressources Bunny
SELECT * FROM builder_catalogue 
WHERE metadata.category IN ['bunny_infrastructure', 'bunny_api']
ORDER BY metadata.module, name;

-- Voir les fonctions d'un module
SELECT * FROM builder_catalogue 
WHERE metadata.module = 'dns' 
AND metadata.type = 'function';

-- Voir la doc complète d'une fonction avec exemples
SELECT 
  name,
  description,
  metadata.parameters,
  metadata.returns,
  metadata.examples,
  metadata.api_docs
FROM builder_catalogue 
WHERE code = 'fn_bunny_add_dns_zone';

-- Rechercher par endpoint API
SELECT * FROM builder_catalogue 
WHERE metadata.api_endpoint CONTAINS '/dnszone';

-- Voir les relations entre ressources
SELECT * FROM builder_catalogue 
WHERE metadata.related_tables CONTAINS 'bunny_dns_zone';

-- Voir la hiérarchie des modules
SELECT * FROM builder_catalogue 
WHERE parent = builder_catalogue:bunny_infrastructure
ORDER BY metadata.module;
```

### Opérations courantes

```sql
-- Lister les zones DNS
RETURN fn::bunny_list_dns_zones(1, 1000);

-- Créer une zone DNS
RETURN fn::bunny_add_dns_zone("example.com");

-- Ajouter un record DNS
RETURN fn::bunny_add_dns_record(123456, {
  type: "A",
  name: "www",
  value: "192.0.2.1",
  ttl: 3600
});

-- Lister les Pull Zones
RETURN fn::bunny_list_pull_zones();

-- Consulter les logs
SELECT * FROM infrastructure_log 
ORDER BY timestamp DESC 
LIMIT 50;
```

---

## 📊 Structure des données retournées

### Format standard des fonctions Bunny

Toutes les fonctions `fn::bunny_*` retournent un objet standardisé :

```json
{
  "success": true,
  "data": { /* Données de l'API Bunny.net */ },
  "status": 200,
  "error": null
}
```

Ou en cas d'erreur :

```json
{
  "success": false,
  "data": null,
  "status": 400,
  "error": {
    "message": "Description de l'erreur",
    "code": "ERROR_CODE"
  }
}
```

### Logs automatiques

Chaque appel à une fonction `fn::bunny_*` est automatiquement loggé :

```sql
SELECT * FROM infrastructure_log WHERE function_name = 'fn::bunny_add_dns_zone';
```

Structure d'un log :

```json
{
  "id": "infrastructure_log:abc123",
  "timestamp": "2025-10-27T01:30:00Z",
  "function_name": "fn::bunny_add_dns_zone",
  "parameters": {
    "domain": "example.com"
  },
  "status": "success",
  "response_code": 201,
  "error": null,
  "execution_time_ms": 234
}
```

---

## 🐛 Dépannage

### L'IA ne voit pas les fonctions

```sql
-- Vérifier que les fonctions sont définies
INFO FOR DB;

-- Si vides, importer les fichiers .surql
-- Depuis le dossier : infrastructure/resources/bunny/
```

### Erreur d'authentification Bunny.net

```sql
-- Vérifier la clé API
SELECT VALUE $bunny_api_key;

-- Redéfinir si nécessaire
DEFINE PARAM $bunny_api_key VALUE "nouvelle-cle-api";
```

### L'IA n'arrive pas à se connecter

```bash
# Vérifier que SurrealDB est démarré
surreal is-ready --endpoint ws://localhost:8000

# Tester la connexion manuellement
surreal sql --endpoint ws://localhost:8000 --namespace lyxal --database infrastructure --username root --password root
```

### Logs pour déboguer

```sql
-- Voir les dernières erreurs
SELECT * FROM infrastructure_log 
WHERE status = 'error' 
ORDER BY timestamp DESC 
LIMIT 20;

-- Voir les appels lents
SELECT * FROM infrastructure_log 
WHERE execution_time_ms > 1000 
ORDER BY timestamp DESC;
```

---

## 🔄 Mise à jour et maintenance

### Ajouter de nouvelles fonctions

1. Créer le fichier `.surql` dans `infrastructure/resources/bunny/`
2. Exécuter le fichier dans SurrealDB
3. L'IA découvrira automatiquement la nouvelle fonction via `INFO FOR DB`

### Mettre à jour une table

1. Modifier le fichier `.surql` de la table
2. Exécuter les modifications dans SurrealDB
3. L'IA verra les changements immédiatement

### Backup de l'infrastructure

```bash
# Exporter toute la base
surreal export --endpoint ws://localhost:8000 --namespace lyxal --database infrastructure --username root --password root backup.surql

# Restaurer
surreal import --endpoint ws://localhost:8000 --namespace lyxal --database infrastructure --username root --password root backup.surql
```

---

## 📈 Monitoring

### Métriques d'utilisation par l'IA

```sql
-- Fonctions les plus utilisées
SELECT 
  function_name, 
  count() AS total_calls,
  count(status = 'error') AS errors,
  avg(execution_time_ms) AS avg_time
FROM infrastructure_log
GROUP BY function_name
ORDER BY total_calls DESC;

-- Activité par jour
SELECT 
  time::format(timestamp, '%Y-%m-%d') AS date,
  count() AS calls
FROM infrastructure_log
GROUP BY date
ORDER BY date DESC;

-- Taux d'erreur
SELECT 
  count() AS total,
  count(status = 'error') AS errors,
  (count(status = 'error') / count() * 100) AS error_rate
FROM infrastructure_log
WHERE timestamp > time::now() - 1d;
```

---

## 🎓 Ressources supplémentaires

### Documentation

- **MCP Protocol** : https://modelcontextprotocol.io
- **SurrealDB Docs** : https://surrealdb.com/docs
- **Bunny.net API** : https://docs.bunny.net

### Fichiers de configuration du projet

- **Tables** : `infrastructure/database/`
- **Fonctions** : `infrastructure/resources/bunny/`
- **Documentation** : `mcp_server/documentation/`

---

**Date de création** : 27 octobre 2025  
**Version** : 1.0.0  
**Projet** : Lyxal Infrastructure


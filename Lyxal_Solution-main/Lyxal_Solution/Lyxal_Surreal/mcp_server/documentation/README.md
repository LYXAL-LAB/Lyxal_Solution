# 🤖 Documentation MCP Server - Lyxal Infrastructure

## 📚 Vue d'ensemble

Ce dossier contient la documentation complète pour l'utilisation du **MCP (Model Context Protocol)** avec **SurrealDB** dans le cadre du projet **Lyxal Infrastructure**.

L'architecture permet à une **IA** (Claude, GPT, etc.) de :
- ✅ **Découvrir automatiquement** toute l'infrastructure Bunny.net
- ✅ **Exécuter directement** les 120+ fonctions disponibles
- ✅ **Gérer de manière autonome** DNS, CDN, Storage, Stream, Shield
- ✅ **Accéder à la documentation** directement depuis la base de données

---

## 📖 Documents disponibles

### 1. [MCP_AUTO_DISCOVERY.md](./MCP_AUTO_DISCOVERY.md) 🔍

**Documentation principale** expliquant :
- Concept du MCP et pourquoi SurrealDB est parfait
- Architecture complète du système
- Auto-découverte de l'infrastructure
- Exemples pratiques d'utilisation
- Cas d'usage avancés

**👉 Commencez par ce document pour comprendre les concepts.**

### 2. [CONFIGURATION_GUIDE.md](./CONFIGURATION_GUIDE.md) ⚙️

**Guide pratique** pour :
- Installation et configuration du MCP Server
- Connexion avec Claude Desktop / Cursor
- Configuration de sécurité
- Dépannage
- Monitoring et maintenance

**👉 Utilisez ce guide pour la mise en place technique.**

---

## 🚀 Démarrage rapide (5 minutes)

### Étape 1 : Démarrer SurrealDB

```bash
surreal start --bind 0.0.0.0:8000 --user root --pass root memory
```

### Étape 2 : Configurer le MCP Server

**Claude Desktop** : Éditer `%APPDATA%\Claude\claude_desktop_config.json`

```json
{
  "mcpServers": {
    "lyxal": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-surrealdb", "ws://localhost:8000", 
               "--namespace", "lyxal", "--database", "infrastructure",
               "--username", "root", "--password", "root"]
    }
  }
}
```

### Étape 3 : L'IA découvre tout automatiquement

Dans Claude ou votre IA :

```sql
-- Scanner toute l'infrastructure
INFO FOR DB;

-- Test : lister les zones DNS
RETURN fn::bunny_list_dns_zones(1, 10);
```

**C'est tout ! L'IA a maintenant accès à toute l'infrastructure Bunny.net. 🎉**

---

## 🎯 Fonctionnalités clés

### 🔍 Auto-découverte

L'IA dispose de **3 sources d'information complémentaires** :

#### 1. **Structure native SurrealDB** (`INFO FOR DB`)

```sql
INFO FOR DB;
```

**Retourne :**
- 📊 50+ tables (DNS, CDN, Storage, Stream, Shield)
- 🔧 120+ fonctions `fn::bunny_*`
- 🔗 Relations entre tables
- 📝 Documentation dans les COMMENT

#### 2. **Catalogue enrichi** (`builder_catalogue`)

```sql
-- Voir toutes les ressources Bunny avec doc enrichie
SELECT * FROM builder_catalogue 
WHERE metadata.category IN ['bunny_infrastructure', 'bunny_api'];
```

**Retourne :**
- 📚 Documentation enrichie (exemples, enums, relations)
- 🔗 Relations explicites (related_functions, related_tables)
- 📖 Exemples de code
- 🌐 Liens vers API docs Bunny.net
- 🏗️ Hiérarchie des modules

#### 3. **Fichiers source** (via MCP File System, optionnel)

```sql
-- L'IA peut lire les fichiers .surql directement
-- Header, commentaires, notes complètes
```

### 🚀 Exécution directe

```sql
-- L'IA crée une zone DNS
RETURN fn::bunny_add_dns_zone("example.com");

-- L'IA configure un CDN
RETURN fn::bunny_create_pull_zone({
  name: "mon-cdn",
  origin_url: "https://origin.com"
});

-- L'IA active DNSSEC
RETURN fn::bunny_enable_dnssec(123456);
```

### 📊 Inspection détaillée

```sql
-- L'IA inspecte une table
INFO FOR TABLE bunny_dns_zone;

-- L'IA lit une fonction
INFO FOR FUNCTION fn::bunny_add_dns_zone;

-- L'IA consulte les logs
SELECT * FROM infrastructure_log 
ORDER BY timestamp DESC 
LIMIT 10;
```

---

## 🏗️ Architecture du projet

```
Lyxal_Surreal/
├── infrastructure/
│   ├── database/              ← Tables SurrealDB
│   │   ├── dns/
│   │   │   ├── bunny_dns_zone.surql
│   │   │   └── bunny_dns_record.surql
│   │   ├── cdn/
│   │   ├── storage/
│   │   ├── stream/
│   │   └── shield/
│   │
│   └── resources/             ← Fonctions API Bunny.net
│       └── bunny/
│           └── bunny_net_api/
│               ├── dns_zone/  (13 fonctions)
│               ├── pull_zone/ (40+ fonctions)
│               ├── storage/   (20+ fonctions)
│               ├── stream/    (25+ fonctions)
│               └── shield/    (15+ fonctions)
│
└── mcp_server/
    └── documentation/         ← Ce dossier
        ├── README.md          ← Vous êtes ici
        ├── MCP_AUTO_DISCOVERY.md
        └── CONFIGURATION_GUIDE.md
```

---

## 📊 Modules Bunny.net disponibles

L'IA peut découvrir et utiliser automatiquement :

| Module | Fonctions | Description |
|--------|-----------|-------------|
| **DNS Management** | 13 | Gestion complète DNS + DNSSEC |
| **CDN (Pull Zones)** | 40+ | Configuration CDN, cache, hostnames |
| **Edge Storage** | 20+ | Stockage distribué Bunny.net |
| **Stream** | 25+ | Streaming vidéo et live |
| **Shield/WAF** | 15+ | Sécurité, DDoS protection |
| **Edge Scripting** | 10+ | Scripts edge computing |

**Total : 120+ fonctions prêtes à l'emploi** 🚀

---

## 💡 Cas d'usage

### 1. Provisionnement automatique

L'IA peut créer une infrastructure complète :

```sql
-- Zone DNS
LET $zone = fn::bunny_add_dns_zone("lyxal.com");

-- Records DNS
LET $www = fn::bunny_add_dns_record($zone.id, {...});
LET $mail = fn::bunny_add_dns_record($zone.id, {...});

-- CDN
LET $cdn = fn::bunny_create_pull_zone({...});

-- DNSSEC
LET $dnssec = fn::bunny_enable_dnssec($zone.id);
```

### 2. Monitoring intelligent

```sql
-- L'IA analyse les logs
SELECT 
  function_name,
  count() AS calls,
  avg(execution_time_ms) AS avg_time
FROM infrastructure_log
WHERE timestamp > time::now() - 1h
GROUP BY function_name;
```

### 3. Gestion multi-tenant

```sql
-- L'IA gère plusieurs clients
FOR $tenant IN (SELECT * FROM tenant) {
  -- Créer infrastructure pour chaque tenant
  LET $zone = fn::bunny_add_dns_zone($tenant.domain);
};
```

---

## 🔐 Sécurité

### Authentification

- ✅ Authentification SurrealDB native
- ✅ Scopes dédiés pour l'IA
- ✅ Permissions granulaires par fonction

### Logs et audit

- ✅ Tous les appels API sont loggés automatiquement
- ✅ Traçabilité complète (qui, quoi, quand)
- ✅ Logs consultables par l'IA

### Isolation

- ✅ Chaque fonction gère ses propres erreurs
- ✅ Pas d'exposition directe de la clé API Bunny
- ✅ Validation des paramètres côté SurrealDB

---

## 📈 Avantages de cette architecture

| Critère | Traditionnel | Lyxal + MCP |
|---------|--------------|-------------|
| **Documentation** | Fichiers externes à maintenir | Auto-générée depuis la DB |
| **Découverte** | Manuelle, lecture de docs | Automatique (`INFO FOR DB`) |
| **Synchronisation** | Risque de désync doc/code | Toujours synchronisé |
| **Évolution** | Mise à jour manuelle | Instantanée |
| **Learning curve** | L'IA doit lire et comprendre | L'IA exécute directement |
| **Multi-module** | Configuration par module | Tout centralisé |
| **Sécurité** | API keys exposées | Encapsulées dans SurrealDB |

---

## 🎓 Pour aller plus loin

### Liens utiles

- **MCP Protocol** : https://modelcontextprotocol.io
- **SurrealDB MCP Server** : https://github.com/modelcontextprotocol/servers/tree/main/src/surrealdb
- **Bunny.net API Docs** : https://docs.bunny.net
- **SurrealDB Docs** : https://surrealdb.com/docs

### Commandes essentielles

```sql
-- Découverte complète
INFO FOR DB;

-- Inspecter une table
INFO FOR TABLE bunny_dns_zone;

-- Inspecter une fonction
INFO FOR FUNCTION fn::bunny_add_dns_zone;

-- Tester une fonction
RETURN fn::bunny_list_dns_zones(1, 10);

-- Consulter les logs
SELECT * FROM infrastructure_log 
ORDER BY timestamp DESC 
LIMIT 20;
```

---

## 🤝 Contribution

Pour ajouter de nouvelles fonctionnalités :

1. **Créer la fonction** dans `infrastructure/resources/bunny/`
2. **Ajouter les commentaires** de documentation dans le `.surql`
3. **Exécuter** le fichier dans SurrealDB
4. **L'IA découvre** automatiquement la nouvelle fonction

**Pas besoin de mettre à jour cette documentation !** Tout est auto-découvert. ✨

---

## ✅ Checklist de démarrage

- [ ] SurrealDB installé et démarré
- [ ] MCP Server configuré (Claude Desktop ou Cursor)
- [ ] Tables importées dans SurrealDB
- [ ] Fonctions Bunny importées dans SurrealDB
- [ ] `builder_catalogue` créé et peuplé
- [ ] Clé API Bunny configurée (`$bunny_api_key`)
- [ ] Test de connexion réussi (`INFO FOR DB`)
- [ ] Test d'une fonction réussi (`fn::bunny_list_dns_zones`)
- [ ] Test du catalogue réussi (`SELECT * FROM builder_catalogue`)

---

## 📞 Support

### Dépannage rapide

**L'IA ne voit pas les fonctions ?**
```sql
INFO FOR DB;
-- Vérifier que les fonctions sont listées
```

**Erreur d'authentification Bunny ?**
```sql
SELECT VALUE $bunny_api_key;
-- Vérifier la clé API
```

**Logs d'erreurs ?**
```sql
SELECT * FROM infrastructure_log 
WHERE status = 'error' 
ORDER BY timestamp DESC;
```

---

## 🎯 Conclusion

Votre infrastructure Lyxal est **déjà prête** pour être gérée par une IA via MCP !

**Avantages :**
- ✅ Documentation vivante et toujours à jour
- ✅ Auto-découverte complète de l'infrastructure
- ✅ 120+ fonctions Bunny.net immédiatement disponibles
- ✅ Zéro configuration côté IA
- ✅ Sécurité et logs intégrés

**L'IA peut maintenant gérer votre infrastructure Bunny.net de manière autonome.** 🚀

---

**Date de création** : 27 octobre 2025  
**Version** : 1.0.0  
**Projet** : Lyxal Infrastructure  
**Auteur** : Documentation Lyxal Team


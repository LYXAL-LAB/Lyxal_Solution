# 📦 Resource - Seeds de Référence

**Module** : integrations/reference/resource  
**Date** : 2025-10-29  
**Version** : 1.0  
**Statut** : ✅ **COMPLET** - Prêt pour import

---

## 📋 Vue d'Ensemble

Ce module contient **1,091 ressources** extraites depuis n8n et structurées selon les standards Lyxal 100% conformes.

### Qu'est-ce qu'une Resource ?

Une **resource** représente un objet ou une entité sur lequel on peut effectuer des opérations dans le cadre d'un service d'intégration.

**Exemples** :
- Service **Slack** → Ressources: `Channel`, `Message`, `File`, `User`, `Reaction`, `Star`, `User Group`
- Service **Google Sheets** → Ressources: `Sheet`, `Spreadsheet`, `Row`
- Service **GitHub** → Ressources: `Issue`, `Repository`, `Pull Request`, `Comment`

---

## 📊 Statistiques

| Métrique | Valeur |
|----------|--------|
| **Ressources totales** | 1,091 |
| **Services couverts** | 419 |
| **Moyenne ressources/service** | 2.6 |
| **Batches** | 22 |
| **Ressources/batch** | 50 (sauf dernier: 41) |
| **Fichiers .surql** | 66 |
| **Clés i18n** | 3,273 |
| **Traductions** | 16,365 (5 langues) |

---

## 🗂️ Structure des Fichiers

### Batches de Seeds (22 fichiers)

Chaque batch contient **50 ressources** (41 pour le dernier) :

```
resource_batch1_seeds.surql        → Ressources 1-50
resource_batch2_seeds.surql        → Ressources 51-100
resource_batch3_seeds.surql        → Ressources 101-150
...
resource_batch22_seeds.surql       → Ressources 1051-1091
```

**Taille moyenne** : ~69 KB/batch

### Batches i18n_key (22 fichiers)

Clés de traduction pour chaque ressource (3 clés/ressource) :

```
resource_batch1_i18n_keys.surql
resource_batch2_i18n_keys.surql
...
resource_batch22_i18n_keys.surql
```

**Clés générées** :
- `resource_{service}_{resource}_name` : Nom affiché
- `resource_{service}_{resource}_desc` : Description
- `resource_{service}_{resource}_tooltip` : Tooltip

### Batches i18n_translation (22 fichiers)

Traductions dans 5 langues (FR, EN, IT, DE, ES) :

```
resource_batch1_i18n_translations.surql
resource_batch2_i18n_translations.surql
...
resource_batch22_i18n_translations.surql
```

**15 traductions/ressource** (3 clés × 5 langues)

---

## 🎯 Format des Seeds

### Exemple de Resource

```surql
CREATE resource:slack_channel SET
    identity = {
        name: "channel",
        slug: "slack_channel",
        display_name_i18n: i18n_key:resource_slack_channel_name,
        description_i18n: i18n_key:resource_slack_channel_desc,
        aliases: []
    },
    presentation = {
        icon: NONE,
        color: NONE,
        display_order: 123,
        tooltip_i18n: i18n_key:resource_slack_channel_tooltip,
        badge_text: NONE,
        badge_color: NONE
    },
    config = {
        operation_types: {
            supports_create: true,
            supports_read: true,
            supports_update: true,
            supports_delete: false,
            supports_list: true,
            supports_search: true
        },
        capabilities: {
            supports_bulk_operations: false,
            supports_pagination: true,
            supports_filtering: false,
            supports_sorting: false,
            requires_authentication: true,
            is_real_time: false
        },
        api: {
            base_path: NONE,
            id_field: NONE,
            list_endpoint: NONE
        }
    },
    documentation = NONE,
    metadata = {
        common_fields: NONE,
        relationships: [],
        popularity_score: NONE,
        custom_data: NONE
    },
    service_id: service:slack,
    is_active: true;
```

### Champs Clés

#### identity
- **name** : Nom technique (ex: `channel`)
- **slug** : Identifiant unique (ex: `slack_channel`)
- **display_name_i18n** : Clé i18n pour le nom affiché
- **description_i18n** : Clé i18n pour la description
- **aliases** : Liste d'alias pour recherche

#### presentation
- **icon** : Icône (NONE par défaut, à personnaliser)
- **color** : Couleur (NONE par défaut, à personnaliser)
- **display_order** : Ordre d'affichage
- **tooltip_i18n** : Clé i18n pour le tooltip
- **badge_text** / **badge_color** : Badge personnalisable

#### config.operation_types
**CRITIQUE** : Définit les opérations CRUD supportées
- **supports_create** : Peut-on créer cette ressource ?
- **supports_read** : Peut-on lire cette ressource ?
- **supports_update** : Peut-on modifier cette ressource ?
- **supports_delete** : Peut-on supprimer cette ressource ?
- **supports_list** : Peut-on lister les ressources ?
- **supports_search** : Recherche avancée disponible ?

**Utilisation** : L'UI utilise ces flags pour afficher/masquer dynamiquement les actions.

#### config.capabilities
- **supports_bulk_operations** : Opérations par lot
- **supports_pagination** : Pagination des résultats
- **supports_filtering** : Filtrage
- **supports_sorting** : Tri
- **requires_authentication** : Auth requise
- **is_real_time** : Temps réel (websocket, etc.)

#### service_id
**OBLIGATOIRE** : Référence au service parent (ex: `service:slack`)

---

## 🌍 Internationalisation (i18n)

### Langues Supportées

- 🇫🇷 **Français** (fr)
- 🇬🇧 **Anglais** (en)
- 🇮🇹 **Italien** (it)
- 🇩🇪 **Allemand** (de)
- 🇪🇸 **Espagnol** (es)

### Exemples de Traductions

**Ressource** : `Slack → Channel`

| Langue | display_name | description |
|--------|--------------|-------------|
| FR | Canal | Ressource représentant canal |
| EN | Channel | Resource representing channel |
| IT | Canale | Risorsa che rappresenta canale |
| DE | Kanal | Ressource, die Kanal darstellt |
| ES | Canal | Recurso que representa canal |

**Ressource** : `GitHub → Issue`

| Langue | display_name | description |
|--------|--------------|-------------|
| FR | Issue | Ressource Issue |
| EN | Issue | Issue resource |
| IT | Issue | Risorsa Issue |
| DE | Issue-Ressource | Issue-Ressource |
| ES | Issue | Recurso Issue |

*Note* : Beaucoup de termes techniques (Issue, User, Event, etc.) sont universels et gardés tels quels.

---

## 📥 Import des Seeds

### Ordre d'Import (IMPORTANT)

**Dépendances** :
```
1. language (FR, EN, IT, DE, ES)
2. i18n_key
3. i18n_translation (relation)
4. provider
5. service
6. resource ← VOUS ÊTES ICI
```

### Commandes SurrealDB

**Option 1** : Import batch par batch
```bash
# Batch 1
surreal import --conn http://localhost:8000 --user root --pass root --ns lyxal --db main resource_batch1_seeds.surql
surreal import --conn http://localhost:8000 --user root --pass root --ns lyxal --db main resource_batch1_i18n_keys.surql
surreal import --conn http://localhost:8000 --user root --pass root --ns lyxal --db main resource_batch1_i18n_translations.surql

# Batch 2
surreal import --conn http://localhost:8000 --user root --pass root --ns lyxal --db main resource_batch2_seeds.surql
surreal import --conn http://localhost:8000 --user root --pass root --ns lyxal --db main resource_batch2_i18n_keys.surql
surreal import --conn http://localhost:8000 --user root --pass root --ns lyxal --db main resource_batch2_i18n_translations.surql

# ... répéter pour tous les batches
```

**Option 2** : Script PowerShell automatique (recommandé)
```powershell
# import_all_resources.ps1
for ($i = 1; $i -le 22; $i++) {
    Write-Host "Import Batch $i/22..." -ForegroundColor Cyan
    
    surreal import --conn http://localhost:8000 --user root --pass root --ns lyxal --db main "resource_batch${i}_seeds.surql"
    surreal import --conn http://localhost:8000 --user root --pass root --ns lyxal --db main "resource_batch${i}_i18n_keys.surql"
    surreal import --conn http://localhost:8000 --user root --pass root --ns lyxal --db main "resource_batch${i}_i18n_translations.surql"
    
    Write-Host "Batch $i terminé ✅`n" -ForegroundColor Green
}

Write-Host "`nTOUS LES BATCHES IMPORTÉS ✅" -ForegroundColor Green
```

---

## 🔍 Exemples de Requêtes

### 1. Lister toutes les ressources d'un service

```surql
SELECT * FROM resource
WHERE service_id = service:slack AND is_active = true
ORDER BY presentation.display_order ASC;
```

### 2. Trouver les ressources qui supportent la création

```surql
SELECT identity.name, identity.slug, service_id
FROM resource
WHERE config.operation_types.supports_create = true
AND is_active = true;
```

### 3. Ressources avec recherche avancée

```surql
SELECT identity.name, service_id
FROM resource
WHERE config.operation_types.supports_search = true
AND is_active = true;
```

### 4. Ressources d'un service avec traductions

```surql
SELECT
    identity.name,
    identity.slug,
    identity.display_name_i18n->translation[WHERE out = language:fr].text AS display_name_fr,
    identity.display_name_i18n->translation[WHERE out = language:en].text AS display_name_en,
    config.operation_types.*
FROM resource
WHERE service_id = service:slack;
```

### 5. Statistiques par service

```surql
SELECT
    service_id AS service,
    count() AS total_resources,
    math::sum(config.operation_types.supports_create) AS creatable,
    math::sum(config.operation_types.supports_delete) AS deletable
FROM resource
GROUP BY service_id;
```

---

## 🎨 Personnalisation Post-Import

Après l'import, vous pouvez personnaliser :

### 1. Icônes

```surql
UPDATE resource:slack_channel SET
    presentation.icon = icon:channel;
```

### 2. Couleurs

```surql
UPDATE resource:slack_message SET
    presentation.color = "#4A154B";
```

### 3. Badges

```surql
UPDATE resource:github_issue SET
    presentation.badge_text = "Core",
    presentation.badge_color = "#4CAF50";
```

### 4. Configuration API

```surql
UPDATE resource:slack_channel SET
    config.api = {
        base_path: "/conversations",
        id_field: "channel_id",
        list_endpoint: "/conversations.list"
    };
```

---

## 📈 Ressources par Service (Top 10)

| Service | Nombre de Ressources |
|---------|----------------------|
| ClickUp | 22 |
| ActiveCampaign | 18 |
| Salesforce | 15 |
| Microsoft Teams | 12 |
| HubSpot | 12 |
| Trello | 10 |
| ZohoCrm | 10 |
| Asana | 7 |
| ActionNetwork | 7 |
| Slack | 7 |

---

## ✅ Checklist de Conformité

- [x] Structure groupée (identity, presentation, config, documentation, metadata)
- [x] i18n_key pour display_name, description, tooltip
- [x] config.operation_types pour CRUD dynamique
- [x] config.capabilities pour fonctionnalités avancées
- [x] service_id obligatoire (référence vers service)
- [x] is_active pour activation/désactivation
- [x] 5 langues supportées (FR, EN, IT, DE, ES)
- [x] Slug unique par service
- [x] Display_order pour tri
- [x] Format 100% compatible SurrealDB

---

## 🚀 Prochaines Étapes

Après l'import de **resource**, vous pouvez passer à :

1. **tool** : Actions/opérations sur les ressources (Create, Read, Update, Delete, etc.)
2. **parameter** : Paramètres d'entrée/sortie des outils
3. **response_mapping** : Mappage des réponses API
4. **error_mapping** : Gestion des erreurs

---

## 📝 Fichiers Complémentaires

| Fichier | Description |
|---------|-------------|
| `extract_resources.py` | Script d'extraction depuis n8n |
| `generate_batches.py` | Script de génération des seeds |
| `resources_mapping.json` | Mapping ressources par service |
| `resources_flat.json` | Liste plate de toutes les ressources |
| `README.md` | Ce fichier |
| `_LIST.md` | Liste complète des 1,091 ressources |

---

**Version** : 1.0  
**Date de création** : 2025-10-29  
**Statut** : ✅ Prêt pour production


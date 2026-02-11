# 📦 Seeds pour la table `service`

**Module** : integrations > reference > service  
**Version** : 1.0  
**Date** : 2025-10-29  
**Conformité** : 100% avec la table `service` refactorée

---

## 📋 Vue d'Ensemble

Ce dossier contient les seeds (données initiales) pour la table `service`, qui représente les services/produits offerts par les providers (ex: Google Sheets, Slack Messages, GitHub Issues, etc.).

**Source** : n8n (305 services/nodes extraits)  
**Organisation** : Batches de ~20 services  
**Langues i18n** : FR, EN, IT, DE, ES

---

## 📊 Statistiques

| Métrique | Valeur |
|----------|--------|
| **Services totaux** | 419 |
| **Batches créés** | 21 batches |
| **Services par batch** | ~20 |
| **i18n_key par service** | 2 (name, description) |
| **Traductions totales** | 4,190 (838 × 5 langues) |
| **État** | ✅ **TERMINÉ** |

---

## 🏗️ Structure des Fichiers

```
service/
├── README.md                              (Ce fichier)
├── SERVICES_LIST.md                       (Liste complète des 305 services)
│
├── service_batch1_seeds.surql             (Services 1-20)
├── service_batch1_i18n_keys.surql         (Clés i18n pour batch 1)
├── service_batch1_i18n_translations.surql (Traductions FR/EN/IT/DE/ES)
│
├── service_batch2_seeds.surql             (Services 21-40)
├── service_batch2_i18n_keys.surql
├── service_batch2_i18n_translations.surql
│
... (jusqu'au batch 16)
```

---

## 📐 Format des Seeds

### Structure conforme (service refactoré v2.0)

```sql
CREATE service:google_sheets SET
    identity = {
        name: "googleSheets",
        slug: "google-sheets",
        display_name_i18n: i18n_key:service_google_sheets_name,
        description_i18n: i18n_key:service_google_sheets_desc,
        aliases: ["CSV", "Sheet", "Spreadsheet", "GS"]
    },
    presentation = {
        icon: logo_brand:google_sheets,
        color: "#34A853",
        display_order: 10,
        category_slug: "data-storage",
        tooltip_i18n: i18n_key:service_google_sheets_tooltip,
        badge_text: "Popular",
        badge_color: "#4CAF50"
    },
    config = {
        version: {
            current: "4.7",
            is_default_version: true,
            supported_versions: ["4.7", "4.6"]
        },
        capabilities: {
            is_trigger: true,
            is_polling: true,
            is_webhook: false,
            is_action: true,
            supports_batch: true
        },
        api: {
            base_url: "https://sheets.googleapis.com",
            version: "v4",
            protocol: "REST"
        },
        rate_limits: {
            requests_per_minute: 60,
            requests_per_day: 100000
        }
    },
    documentation = {
        main_url: "https://developers.google.com/sheets/api",
        api_reference_url: "https://developers.google.com/sheets/api/reference/rest",
        credential_setup_url: "https://developers.google.com/sheets/api/guides/authorizing",
        video_tutorial_url: NONE,
        changelog_url: "https://developers.google.com/sheets/api/releases"
    },
    metadata = {
        tags: ["spreadsheet", "data", "analytics", "collaboration"],
        popularity_score: 95,
        last_updated_by: NONE,
        custom_data: {
            n8n_version: "4.7",
            extracted_from: "n8n-master"
        }
    },
    provider_id: provider:google,
    category_id: NONE,
    is_active: true;
```

---

## 🌍 Format i18n

### Clés i18n

```sql
CREATE i18n_key:service_google_sheets_name SET
    description = "Nom du service Google Sheets";

CREATE i18n_key:service_google_sheets_desc SET
    description = "Description du service Google Sheets";

CREATE i18n_key:service_google_sheets_tooltip SET
    description = "Tooltip pour Google Sheets";
```

### Traductions (5 langues)

```sql
-- Français
RELATE i18n_key:service_google_sheets_name->translation->language:fr 
    SET text = "Google Sheets";
RELATE i18n_key:service_google_sheets_desc->translation->language:fr 
    SET text = "Créez, modifiez et partagez des feuilles de calcul en ligne";

-- English
RELATE i18n_key:service_google_sheets_name->translation->language:en 
    SET text = "Google Sheets";
RELATE i18n_key:service_google_sheets_desc->translation->language:en 
    SET text = "Create, edit, and share spreadsheets online";

-- Italiano
RELATE i18n_key:service_google_sheets_name->translation->language:it 
    SET text = "Google Sheets";
RELATE i18n_key:service_google_sheets_desc->translation->language:it 
    SET text = "Crea, modifica e condividi fogli di calcolo online";

-- Deutsch
RELATE i18n_key:service_google_sheets_name->translation->language:de 
    SET text = "Google Sheets";
RELATE i18n_key:service_google_sheets_desc->translation->language:de 
    SET text = "Erstellen, bearbeiten und teilen Sie Tabellenkalkulationen online";

-- Español
RELATE i18n_key:service_google_sheets_name->translation->language:es 
    SET text = "Google Sheets";
RELATE i18n_key:service_google_sheets_desc->translation->language:es 
    SET text = "Cree, edite y comparta hojas de cálculo en línea";
```

---

## 🎯 Mapping Provider → Service

### Extraction depuis n8n

Pour chaque service, on extrait :
1. **Nom technique** : Nom du dossier (ex: `GoogleSheets`)
2. **Display name** : Depuis `displayName` dans le fichier `.node.ts`
3. **Description** : Depuis `description` dans le fichier `.node.ts`
4. **Provider** : Déduit du nom ou de la catégorie
5. **Version** : Depuis `version` dans le fichier
6. **Capabilities** : Depuis les propriétés du node (trigger, webhook, etc.)
7. **Catégories** : Depuis les tags/catégories n8n

### Exemples de mapping

| Service n8n | Provider | Service ID | Category |
|-------------|----------|------------|----------|
| GoogleSheets | Google | `service:google_sheets` | data-storage |
| Slack | Slack | `service:slack` | communication |
| GitHubIssues | GitHub | `service:github` | development |
| Airtable | Airtable | `service:airtable` | data-storage |
| Asana | Asana | `service:asana` | project-management |

---

## 📂 Catégories de Services

### Classification des 305 services

1. **Data & Storage** (~60 services)
   - Google Sheets, Airtable, MySQL, PostgreSQL, MongoDB, etc.

2. **Communication** (~50 services)
   - Slack, Discord, Telegram, WhatsApp, Email, etc.

3. **Development** (~40 services)
   - GitHub, GitLab, Bitbucket, CircleCI, Jenkins, etc.

4. **Marketing & CRM** (~45 services)
   - HubSpot, Salesforce, Mailchimp, ActiveCampaign, etc.

5. **Project Management** (~30 services)
   - Asana, Trello, Monday, Jira, ClickUp, etc.

6. **E-commerce** (~25 services)
   - Shopify, WooCommerce, Stripe, PayPal, etc.

7. **Social Media** (~20 services)
   - Twitter, LinkedIn, Facebook, Instagram, etc.

8. **Productivity** (~20 services)
   - Google Calendar, Notion, Todoist, Calendly, etc.

9. **AI & ML** (~15 services)
   - OpenAI, Anthropic, Hugging Face, etc.

---

## 🚀 Processus de Création

### Phase 1 : Extraction des données (En cours)
1. ✅ Lister tous les services n8n (305 services)
2. 🚧 Extraire les métadonnées de chaque service
3. 🚧 Identifier le provider associé
4. 🚧 Déterminer les catégories

### Phase 2 : Génération des seeds
1. Créer les seeds par batches de 20
2. Générer les i18n_key pour chaque service
3. Générer les traductions (FR, EN, IT, DE, ES)
4. Valider la conformité avec la table refactorée

### Phase 3 : Validation
1. Vérifier que tous les `provider_id` existent
2. Tester l'import en base
3. Valider les relations avec `uses_credential`

---

## ⚠️ Prérequis

Avant d'importer ces seeds, assurez-vous que les tables suivantes sont peuplées :

1. ✅ **provider** : Tous les providers nécessaires doivent exister
2. ✅ **logo_brand** : Tous les logos doivent être créés
3. ✅ **i18n_key** & **translation** : Système i18n fonctionnel
4. ✅ **language** : Les 5 langues (FR, EN, IT, DE, ES) doivent exister
5. ⚠️ **category** : Table optionnelle (peut utiliser `category_slug` en string)

---

## 📅 Informations

- **Date de création** : 2025-10-29
- **Date de complétion** : 2025-10-29
- **Conformité** : 100% avec `service.surql` v2.0
- **Source** : n8n-master (419 services)
- **État** : ✅ **TERMINÉ** - 21 batches créés (419 services)
- **Génération** :
  - Batch 1 : Manuelle (qualité optimale, 20 services)
  - Batch 2-21 : Automatique via Python (399 services)
- **Fichiers totaux** : 63 fichiers (21 batches × 3 fichiers)
- **Taille totale** : ~1.05 MB

---

✨ **100% complet et prêt pour import** (après création/import des providers et logos)


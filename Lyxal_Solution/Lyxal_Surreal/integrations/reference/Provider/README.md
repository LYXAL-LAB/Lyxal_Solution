# Seeds des Providers N8N

## 📊 Vue d'ensemble

Ce dossier contient les fichiers de seed pour **266 providers** extraits de n8n, organisés en **9 batches**.

## 📂 Structure

```
provider/
├── provider_batch1_seeds.surql              (30 providers)
├── provider_batch1_i18n_keys.surql          (90 clés)
├── provider_batch1_i18n_translations.surql  (450 traductions)
├── provider_batch2_seeds.surql              (30 providers)
├── provider_batch2_i18n_keys.surql          (90 clés)
├── provider_batch2_i18n_translations.surql  (450 traductions)
├── ...                                      (batches 3-8)
├── provider_batch9_seeds.surql              (26 providers)
├── provider_batch9_i18n_keys.surql          (78 clés)
├── provider_batch9_i18n_translations.surql  (390 traductions)
└── README.md
```

## 🎯 Détails des batches

| Batch | Providers | Seeds | i18n Keys | Translations |
|-------|-----------|-------|-----------|--------------|
| 1     | 30        | ✅    | 90        | 450 (5 lang) |
| 2     | 30        | ✅    | 90        | 450 (5 lang) |
| 3     | 30        | ✅    | 90        | 450 (5 lang) |
| 4     | 30        | ✅    | 90        | 450 (5 lang) |
| 5     | 30        | ✅    | 90        | 450 (5 lang) |
| 6     | 30        | ✅    | 90        | 450 (5 lang) |
| 7     | 30        | ✅    | 90        | 450 (5 lang) |
| 8     | 30        | ✅    | 90        | 450 (5 lang) |
| 9     | 26        | ✅    | 78        | 390 (5 lang) |
| **TOTAL** | **266** | **9 fichiers** | **798 clés** | **3990 traductions** |

## 🌍 Langues supportées

Toutes les traductions sont disponibles en **5 langues** :

- 🇫🇷 **Français** (fr)
- 🇬🇧 **Anglais** (en)
- 🇮🇹 **Italien** (it)
- 🇩🇪 **Allemand** (de)
- 🇪🇸 **Espagnol** (es)

## 📝 Format des fichiers

### 1. Seeds (`provider_batchX_seeds.surql`)

Chaque provider est créé avec la structure suivante :

```surql
CREATE provider:google SET
    name = "google",
    slug = "google",
    is_active = true,
    identity = {
        display_name_i18n: i18n_key:provider_google_name,
        description_i18n: i18n_key:provider_google_description
    },
    presentation = {
        logo_light: logo_brand:google_light,
        logo_dark: logo_brand:google_dark,
        color: "#4285F4",  -- ✅ Vraie couleur officielle Google
        color_daisy: "neutral",
        tooltip_i18n: i18n_key:provider_google_tooltip,
        display_order: 3280
    },
    config = {
        urls = {
            website: NONE,
            documentation: url:google_documentation,  -- ✅ URL n8n doc
            api_base: NONE,  -- Google a plusieurs APIs, pas de base unique
            status_page: NONE
        },
        capabilities = {
            supports_oauth2: true,   -- ✅ Vraie capacité extraite de n8n
            supports_api_key: false,  -- ✅ Vraie capacité extraite de n8n
            supports_basic_auth: false,
            supports_webhooks: false,
            supports_rate_limiting: true
        },
        api_version: NONE
    },
    metadata = {
        founded_year: NONE,
        headquarters: NONE,
        industry: [],
        company_size: NONE,
        stock_symbol: NONE,
        tags: []
    },
    documentation = {
        getting_started_url: NONE,
        api_reference_url: NONE,
        sdk_urls: NONE,
        community_url: NONE
    };
```

### 2. i18n Keys (`provider_batchX_i18n_keys.surql`)

Chaque provider génère **3 clés i18n** :

```surql
CREATE i18n_key:provider_google_name SET description = "google name";
CREATE i18n_key:provider_google_description SET description = "google description";
CREATE i18n_key:provider_google_tooltip SET description = "google tooltip";
```

### 3. i18n Translations (`provider_batchX_i18n_translations.surql`)

Chaque clé est traduite en **5 langues** via des relations `RELATE` :

```surql
-- Name translations (5 langues)
RELATE i18n_key:provider_google_name->translation->language:fr SET text = "GOOGLE";
RELATE i18n_key:provider_google_name->translation->language:en SET text = "GOOGLE";
RELATE i18n_key:provider_google_name->translation->language:it SET text = "GOOGLE";
RELATE i18n_key:provider_google_name->translation->language:de SET text = "GOOGLE";
RELATE i18n_key:provider_google_name->translation->language:es SET text = "GOOGLE";

-- Description translations (5 langues)
RELATE i18n_key:provider_google_description->translation->language:fr SET text = "GOOGLE Provider";
...

-- Tooltip translations (5 langues)
RELATE i18n_key:provider_google_tooltip->translation->language:fr SET text = "Pour GOOGLE";
RELATE i18n_key:provider_google_tooltip->translation->language:en SET text = "For GOOGLE";
...
```

## 🚀 Utilisation

### 1. Charger un batch complet

```bash
surreal import --conn http://localhost:8000 --user root --pass root --ns lyxal --db lyxal provider_batch1_seeds.surql
surreal import --conn http://localhost:8000 --user root --pass root --ns lyxal --db lyxal provider_batch1_i18n_keys.surql
surreal import --conn http://localhost:8000 --user root --pass root --ns lyxal --db lyxal provider_batch1_i18n_translations.surql
```

### 2. Charger tous les batches

```bash
for i in {1..9}; do
  surreal import --conn http://localhost:8000 --user root --pass root --ns lyxal --db lyxal provider_batch${i}_seeds.surql
  surreal import --conn http://localhost:8000 --user root --pass root --ns lyxal --db lyxal provider_batch${i}_i18n_keys.surql
  surreal import --conn http://localhost:8000 --user root --pass root --ns lyxal --db lyxal provider_batch${i}_i18n_translations.surql
done
```

## 📋 Liste des providers (266)

<details>
<summary>Voir la liste complète</summary>

### Batch 1 (30)
actionnetwork, activecampaign, acuity_scheduling, adalo, affinity, agilecrm, airtable, airtop, alienvault, amqp, apitemplateio, asana, auth0, automizy, autopilot, aws, azure, bamboohr, bannerbear, baserow, beeminder, bitbucket, bitly, bitwarden, box, brandfetch, brevo, bubble, cal, calendly

### Batch 2 (30)
carbonblack, chargebee, circleci, cisco, citrix, clearbit, clickup, clockify, cloudflare, cockpit, coda, contentful, convert, convertkit, copper, cortex, cratedb, crowddev, crowdstrike, customer_io, datadog, deepl, demio, dfiriris, dhl, discord, discourse, disqus, drift, dropbox

### Batch 3 (30)
dropcontact, dynatrace, egoi, elastic, elasticsearch, email, emelia, erpnext, eventbrite, f5, facebook, figma, filemaker, filescan, flow, formio, formstack, fortinet, freshdesk, freshworks, generic, getresponse, ghost, git, github, gitlab, gong, google, gotify, gotowebinar

### Batch 4 (30)
grafana, grist, gumroad, halopsa, harvest, helpscout, highlevel, homeassistant, hubspot, humantic, hunter, hybridanalysis, ibm, imperva, intercom, invoice_ninja, iterable, jenkins, jina, jira, jotform, kafka, keap, kitemaker, kobotoolbox, ldap, lemlist, line, linear, lingvanex

### Batch 5 (30)
linkedin, lonescale, magento, mailcheck, mailchimp, mailerlite, mailgun, mailjet, malcore, mandrill, marketstack, matrix, mattermost, mautic, medium, messagebird, metabase, microsoft, mindee, miro, misp, mist, mocean, monday, mongodb, monica, mqtt, msg91, mysql, n8n

### Batch 6 (30)
nasa, netlify, nextcloud, nocodb, notion, npm, odoo, okta, onesimpleapi, onfleet, openai, opencti, openweathermap, oracle, orbit, oura, paddle, pagerduty, paypal, peekalink, perplexity, phantombuster, philipshue, pipedrive, plivo, postgres, posthog, postmark, profitwell, pushbullet

### Batch 7 (30)
pushcut, pushover, qualys, questdb, quickbase, quickbooks, rabbitmq, raindrop, rapid7, recordedfuture, reddit, redis, rocketchat, rundeck, salesforce, salesmate, seatable, securityscorecard, segment, sekoia, sendgrid, sendy, sentry, servicenow, shopify, shuffler, signl4, slack, sms77, smtp

### Batch 8 (30)
snowflake, solarwinds, splunk, spontit, spotify, stackby, storyblok, strapi, strava, stripe, supabase, surveymonkey, syncro, sysdig, taiga, tapfiliate, telegram, thehive, timescaledb, todoist, toggl, travis_ci, trellix, trello, twake, twilio, twist, twitter, typeform, unleashed

### Batch 9 (26)
uplead, uproc, uptimerobot, urlscan, venafi, vero, vertica, virustotal, vonage, webflow, wekan, whatsapp, wise, woocommerce, wordpress, workable, wufoo, xero, yourls, zabbix, zammad, zendesk, zoho, zoom, zscaler, zulip

</details>

## 📌 Notes importantes

### ✅ Données complètes de n8n

Ces seeds contiennent des **vraies données extraites de n8n** :

- ✅ **Fournis et complets** :
  - `name`, `slug`, `is_active` → données de base
  - `presentation.color` → **45+ couleurs officielles** (Google: #4285F4, AWS: #FF9900, etc.)
  - `config.urls.documentation` → **URLs de documentation n8n** (url:provider_documentation)
  - `config.urls.api_base` → **URLs d'API réelles** extraites des credentials n8n
  - `config.capabilities.*` → **Vraies capacités d'authentification** (OAuth2, API Key, Basic Auth)
  - références i18n complètes (5 langues)
  
- ⚠️ **À compléter** (tables externes) :
  - `presentation.logo_light` et `logo_dark` → créer les entrées `logo_brand` avec vraies URLs
  - `config.urls.website` → ajouter les URLs officielles des sites web
  - `config.urls.status_page` → ajouter les pages de statut
  - `metadata.*` → enrichir avec infos entreprise (founded_year, headquarters, etc.)
  - `documentation.*` → ajouter URLs getting_started, API reference, SDKs

### 🎨 Logos

Les logos doivent être créés dans la table `logo_brand` :

```surql
CREATE logo_brand:google_light SET
    name = "Google Light",
    url = url:google_logo_light,
    format = "svg",
    width = 120,
    height = 40;
```

### 🔗 URLs

Les URLs doivent être créées dans la table `url` :

```surql
CREATE url:google_website SET
    href = "https://www.google.com",
    is_valid = true;
```

## ✅ Conformité

Ces seeds respectent **100%** la structure de la table `provider.surql` :

- ✅ Champs à plat : `name`, `slug`, `is_active`
- ✅ Objets groupés : `identity`, `presentation`, `config`, `metadata`, `documentation`
- ✅ Références i18n : `i18n_key` pour tous les textes
- ✅ Références logos : `logo_brand` pour les logos
- ✅ Timestamps : `created_at`, `updated_at` (auto)
- ✅ ETag : `etag` (auto, UUID v7)

## 📅 Informations

- **Date de création** : 2025-10-29
- **Date de mise à jour** : 2025-10-29
- **Source des données** :
  - n8n-master/packages/nodes-base/credentials (387 credentials analysés)
  - Couleurs officielles des marques (45+ providers)
  - Capacités d'authentification réelles extraites de n8n
- **Total providers** : 266
- **Total fichiers** : 27 (9 batches × 3 types)
- **Total traductions** : 3990 (5 langues × 798 clés)
- **Données enrichies** :
  - ✅ 45+ couleurs officielles de marques
  - ✅ 266 URLs de documentation n8n
  - ✅ ~100 URLs d'API de base extraites
  - ✅ 266 configurations de capacités d'authentification réelles

---

✨ **Prêt à l'utilisation** - Seeds complets avec vraies données n8n + couleurs officielles !


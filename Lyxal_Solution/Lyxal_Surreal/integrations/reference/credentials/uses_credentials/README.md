# Seeds des Relations `uses_credential`

## 📊 Vue d'ensemble

Ce dossier contient les fichiers de seed pour la relation **`uses_credential`** qui lie les services aux credential_types.

**Relation** : `service -> uses_credential -> credential_type`

## 🎯 Objectif

Définir quels types de credentials chaque service peut utiliser pour s'authentifier, avec :
- Si le credential est obligatoire ou optionnel
- Lequel est recommandé
- La complexité de configuration
- Le temps estimé de setup

## 📂 Structure

```
uses_credentials/
├── uses_credential_batch1_seeds.surql      (30 relations - Productivité)
├── uses_credential_batch2_seeds.surql      (30 relations - Formulaires, AI, Analytics)
├── uses_credential_batch3_seeds.surql      (30 relations - CMS, ERP, Accounting)
├── uses_credential_batch4_seeds.surql      (30 relations - Divers)
├── uses_credential_batch5_seeds.surql      (30 relations - Divers)
├── uses_credential_batch6_seeds.surql      (30 relations - Divers)
├── uses_credential_batch7_seeds.surql      (30 relations - Divers)
├── uses_credential_batch8_seeds.surql      (30 relations - Divers)
├── uses_credential_batch9_seeds.surql      (30 relations - Divers)
├── uses_credential_batch10_seeds.surql     (30 relations - Divers)
├── uses_credential_batch11_seeds.surql     (30 relations - Divers)
├── uses_credential_batch12_seeds.surql     (30 relations - Divers)
├── uses_credential_batch13_seeds.surql     (30 relations - Divers)
├── uses_credential_batch14_seeds.surql     (29 relations - Divers)
└── README.md
```

## 📊 Statistiques

- **Total credential_types** : 419
- **Services estimés** : ~250
- **Relations totales** : 419
- **Batches créés** : 14 ✅
- **Taille totale** : 112 KB
- **Lignes de code** : 950

## 🎨 Format des Relations

Chaque relation utilise la structure refactorée de `uses_credential` :

```surql
RELATE service:airtable->uses_credential->credential_type:airtable_oauth2_api SET
    is_required = true,
    presentation = {
        display_order: 1,
        is_recommended: true,
        badge_color: "primary"
    },
    config = {
        custom_description_i18n: i18n_key:uses_cred_airtable_oauth2_desc,
        scopes_required: ["data.records:read", "data.records:write"],
        setup_complexity: "easy",
        estimated_setup_time: 5,
        use_case: "standard"
    };
```

### Champs principaux

#### `is_required`
- `true` : L'utilisateur DOIT configurer ce credential
- `false` : Ce credential est optionnel (alternative disponible)

#### `presentation.display_order`
- Plus petit = affiché en premier
- Recommandé: 1, Alternatifs: 2, 3, ...

#### `presentation.is_recommended`
- `true` : Badge "Recommandé" dans l'UI
- `false` : Alternative disponible

#### `presentation.badge_color`
- `primary` : Recommandé
- `neutral` : Standard
- `warning` : Legacy/Déprécié
- `error` : Déconseillé

#### `config.setup_complexity`
- `easy` : Simple, quelques clics
- `medium` : Intermédiaire, configuration requise
- `hard` : Expert, configuration avancée

#### `config.estimated_setup_time`
- Temps en minutes (ex: 2, 5, 10, 30)

#### `config.use_case`
- `standard` : Utilisation normale
- `automation` : Scripts/Automation serveur
- `serverless` : Fonctions serverless
- `development` : Dev/Test uniquement
- `production` : Production uniquement

## 📋 Batch 1 : Services de Productivité (30 relations)

### Services inclus

| Service | Credentials | Recommandé |
|---------|-------------|------------|
| Airtable | 3 (API, OAuth2, Token) | OAuth2 |
| Asana | 2 (API, OAuth2) | OAuth2 |
| ClickUp | 2 (API, OAuth2) | OAuth2 |
| Monday.com | 2 (API, OAuth2) | OAuth2 |
| Notion | 2 (API, OAuth2) | OAuth2 |
| Todoist | 2 (API, OAuth2) | OAuth2 |
| Trello | 1 (API) | API |
| Drift | 2 (API, OAuth2) | OAuth2 |
| Freshdesk | 1 (API) | API |
| HelpScout | 1 (OAuth2) | OAuth2 |
| Intercom | 1 (API) | API |
| Segment | 1 (API) | API |
| Zendesk | 2 (API, OAuth2) | OAuth2 |
| Mailgun | 1 (API) | API |
| Postmark | 1 (API) | API |
| Sendgrid | 1 (API) | API |
| Typeform | 2 (API, OAuth2) | OAuth2 |
| SurveyMonkey | 2 (API, OAuth2) | OAuth2 |
| Jotform | 1 (API) | API |

**Total** : 18 services, 30 relations

## 🚀 Utilisation

### Importer un batch

```bash
surreal import --conn http://localhost:8000 \
  --user root --pass root \
  --ns lyxal --db lyxal \
  uses_credential_batch1_seeds.surql
```

### Importer tous les batches

```bash
for i in {1..14}; do
  surreal import --conn http://localhost:8000 \
    --user root --pass root \
    --ns lyxal --db lyxal \
    uses_credential_batch${i}_seeds.surql
done
```

## 🔍 Requêtes Utiles

### Récupérer tous les credentials d'un service

```surql
SELECT 
    credential_type.*,
    uses_credential.is_required,
    uses_credential.presentation.is_recommended,
    uses_credential.config.setup_complexity
FROM uses_credential
WHERE in = service:airtable
ORDER BY uses_credential.presentation.display_order ASC;
```

### Récupérer uniquement le credential recommandé

```surql
SELECT 
    credential_type.*,
    uses_credential.config.estimated_setup_time
FROM uses_credential
WHERE in = service:airtable
  AND uses_credential.presentation.is_recommended = true
LIMIT 1;
```

### Services avec plusieurs options de credentials

```surql
SELECT 
    in AS service_id,
    count() AS credential_count,
    array::group({
        credential: out,
        is_recommended: presentation.is_recommended
    }) AS credentials
FROM uses_credential
GROUP BY in
HAVING credential_count > 1;
```

## ⚠️ Prérequis

### Tables requises

- ✅ `service` : Services des providers (à créer/refactorer)
- ✅ `credential_type` : Types d'authentification (36 batches créés)
- ✅ `i18n_key` : Clés de traduction (existe)
- ✅ `url` : URLs normalisées (existe)

### Notes importantes

**⚠️ La table `service` n'est pas encore conforme !**

Avant d'importer ces seeds, il faut :
1. Refaire la table `service` (actuellement 20% conforme)
2. Créer les seeds de `service` (Google Sheets, Slack, etc.)
3. Créer les clés i18n nécessaires

## 📅 Informations

- **Date de création** : 2025-10-29
- **Date de complétion** : 2025-10-29
- **Conformité** : 100% avec la structure refactorée de `uses_credential`
- **Source** : 419 credential_types créés dans 36 batches
- **État** : ✅ **TERMINÉ** - 14 batches créés (419 relations)
- **Génération** : 
  - Batch 1-2 : Manuelle (qualité optimale)
  - Batch 3-14 : Automatique (valeurs par défaut intelligentes)
- **i18n** :
  - 20 clés génériques réutilisables
  - 100 traductions (5 langues : FR, EN, IT, DE, ES)
  - Labels : OAuth2, API Key, Token, Basic Auth, Service Account
  - Descriptions : Recommandé, Sécurisé, Dev/Test, Production, Legacy, etc.

---

✨ **100% complet et prêt pour import** (après création de la table `service`)


# Module PARAMETER

## 📋 Vue d'ensemble

Le module **parameter** contient les définitions complètes des paramètres d'entrée/sortie pour tous les outils (tools) extraits depuis n8n. Ces parameters définissent les champs configurables pour chaque action/opération.

## 🎯 Objectif

- Fournir une base de données structurée de tous les parameters des outils n8n
- Permettre une génération dynamique de formulaires UI
- Supporter la validation côté client et serveur
- Faciliter l'internationalisation (i18n) des interfaces
- Permettre aux IA de comprendre et manipuler les configurations

## 📊 Statistiques

- **Total parameters** : 74 466
- **Sources n8n** : 419 services
- **Nombre de batches** : 25
- **Clés i18n** : 297 864
- **Traductions** : 1 489 320 (5 langues)

## 🏗️ Structure

### Fichiers principaux

```
parameter/
├── extract_parameters.py       # Script d'extraction depuis n8n
├── generate_batches.py         # Générateur de seeds
├── parameters_flat.json        # Données JSON intermédiaires
├── README.md                   # Documentation (ce fichier)
├── _LIST.md                    # Liste détaillée des batches
└── parameter_batchX_*.surql    # Seeds (75 fichiers)
```

### Types de fichiers générés

1. **Seeds** (`parameter_batchX_seeds.surql`)
   - Définitions complètes des parameters
   - Relations vers les tools
   - Configuration de validation
   - Métadonnées complètes

2. **Clés i18n** (`parameter_batchX_i18n_keys.surql`)
   - 4 clés par parameter
   - Contexte et catégorie
   - Descriptions

3. **Traductions** (`parameter_batchX_i18n_translations.surql`)
   - 5 langues (FR, EN, IT, DE, ES)
   - 20 traductions par parameter

## 🔑 Clés i18n par parameter

Chaque parameter génère **4 clés i18n** :

| Clé | Description | Exemple |
|-----|-------------|---------|
| `parameter_{slug}_name` | Nom d'affichage | "Job Title" |
| `parameter_{slug}_desc` | Description détaillée | "The job title of the account" |
| `parameter_{slug}_placeholder` | Placeholder du champ | "Enter job title..." |
| `parameter_{slug}_help` | Texte d'aide contextuel | "Help for Job Title" |

## 📝 Schéma SurrealDB

Voir le fichier `../../database/parameter/parameter.surql` pour la définition complète.

### Structure principale

```surql
parameter:{slug}
├── identity
│   ├── name                    (string)
│   ├── display_name_i18n       (record<i18n_key>)
│   ├── description_i18n        (record<i18n_key>)
│   ├── parameter_type          (string)
│   └── sub_type                (option<string>)
├── presentation
│   ├── display_order           (int)
│   ├── placeholder_i18n        (record<i18n_key>)
│   ├── help_text_i18n          (record<i18n_key>)
│   ├── is_sensitive            (bool)
│   └── is_hidden               (bool)
├── validation
│   ├── is_required             (bool)
│   ├── min_value               (option<number>)
│   ├── max_value               (option<number>)
│   ├── min_length              (option<int>)
│   ├── max_length              (option<int>)
│   ├── pattern                 (option<string>)
│   ├── format                  (option<string>)
│   └── allowed_values          (option<array>)
├── config
│   ├── default_value           (option<any>)
│   ├── options                 (option<array>)
│   └── display_conditions      (option<object>)
├── documentation               (option<object>)
├── metadata
│   ├── created_at              (datetime)
│   ├── updated_at              (datetime)
│   ├── version                 (int)
│   ├── etag                    (uuid)
│   └── ...
├── tool_id                     (record<tool>)
└── is_active                   (bool)
```

## 🔗 Relations

### Relations sortantes (FROM parameter)

Aucune relation sortante (les parameters sont des feuilles)

### Relations entrantes (TO parameter)

- `tool` → `parameter` (1:N) : Un outil possède plusieurs parameters

## 📚 Types de parameters

Les types extraits depuis n8n incluent :

| Type | Description | Exemple |
|------|-------------|---------|
| `string` | Texte simple | Nom, description |
| `number` | Valeur numérique | Age, prix |
| `boolean` | Vrai/faux | Actif, visible |
| `options` | Liste de choix (select) | Statut, priorité |
| `multiOptions` | Choix multiples | Tags, catégories |
| `resourceLocator` | Sélecteur de ressource | Channel ID, User ID |
| `json` | Données JSON structurées | Configuration |
| `dateTime` | Date et heure | Date de création |
| `collection` | Collection d'éléments | Liste de tâches |
| `hidden` | Champ caché | Token, secret |

## 🎨 Usage UI

### Génération dynamique de formulaires

Les parameters permettent de générer automatiquement des formulaires :

```typescript
// Exemple pseudo-code
const form = parameters
  .filter(p => p.is_active && !p.presentation.is_hidden)
  .sort((a, b) => a.presentation.display_order - b.presentation.display_order)
  .map(p => ({
    name: p.identity.name,
    label: translate(p.identity.display_name_i18n),
    type: p.identity.parameter_type,
    required: p.validation.is_required,
    placeholder: translate(p.presentation.placeholder_i18n),
    help: translate(p.presentation.help_text_i18n),
    sensitive: p.presentation.is_sensitive,
    validation: {
      min: p.validation.min_value,
      max: p.validation.max_value,
      pattern: p.validation.pattern,
      format: p.validation.format
    },
    default: p.config.default_value,
    options: p.config.options
  }));
```

### Validation côté client

```typescript
function validateParameter(parameter, value) {
  if (parameter.validation.is_required && !value) {
    return `${translate(parameter.identity.display_name_i18n)} est requis`;
  }
  
  if (parameter.validation.min_length && value.length < parameter.validation.min_length) {
    return `Minimum ${parameter.validation.min_length} caractères`;
  }
  
  if (parameter.validation.pattern && !new RegExp(parameter.validation.pattern).test(value)) {
    return `Format invalide`;
  }
  
  // ... autres validations
  
  return null; // Valide
}
```

### Affichage conditionnel

Utiliser `config.display_conditions` pour afficher/masquer des champs dynamiquement :

```typescript
function shouldDisplayParameter(parameter, formValues) {
  const conditions = parameter.config.display_conditions;
  if (!conditions) return true;
  
  // Vérifier les conditions d'affichage
  return Object.entries(conditions).every(([field, value]) => {
    return formValues[field] === value;
  });
}
```

## 🤖 Usage IA

Les IA peuvent utiliser les parameters pour :

1. **Comprendre les capacités d'un outil**
   ```
   Quels sont les parameters de l'outil "Create Channel" de Slack ?
   ```

2. **Valider des configurations**
   ```
   Valider que channelName est bien fourni (is_required: true)
   ```

3. **Générer des exemples**
   ```
   Générer un exemple de configuration avec les valeurs par défaut
   ```

4. **Suggérer des valeurs**
   ```
   Suggérer des valeurs basées sur allowed_values ou options
   ```

## 🔍 Extraction depuis n8n

### Processus d'extraction

1. **Lecture des tools**
   - Charge `tools_flat.json` pour obtenir la liste des outils

2. **Localisation des fichiers Description.ts**
   - Utilise `services_mapping.json` pour trouver les fichiers sources

3. **Parsing TypeScript**
   - Parse les `INodeProperties[]` depuis les fichiers Description
   - Extrait displayName, name, type, description, required, default, etc.

4. **Filtrage par opération**
   - Ne conserve que les parameters pertinents pour chaque operation
   - Exclut les méta-champs (resource, operation)

5. **Génération des seeds**
   - Crée les records SurrealDB avec la structure complète
   - Génère les clés i18n et traductions

### Script d'extraction

Voir `extract_parameters.py` pour les détails d'implémentation.

### Script de génération

Voir `generate_batches.py` pour la génération des seeds.

## 📦 Import

### Import manuel d'un batch

```bash
surreal import --conn http://localhost:8000 --user root --pass root \
  --ns lyxal --db main \
  integrations/reference/parameter/parameter_batch1_seeds.surql

surreal import --conn http://localhost:8000 --user root --pass root \
  --ns lyxal --db main \
  integrations/reference/parameter/parameter_batch1_i18n_keys.surql

surreal import --conn http://localhost:8000 --user root --pass root \
  --ns lyxal --db main \
  integrations/reference/parameter/parameter_batch1_i18n_translations.surql
```

### Import automatique de tous les batches

Voir `../../IMPORT_ALL_SEEDS.ps1` pour l'import de tous les modules.

## 🔄 Régénération

Pour régénérer les seeds :

```bash
# 1. Extraire les parameters depuis n8n
python extract_parameters.py

# 2. Générer les batches
python generate_batches.py
```

## 📖 Exemples de requêtes

### Récupérer tous les parameters d'un outil

```surql
SELECT * FROM parameter 
WHERE tool_id = tool:slack_channel_create
ORDER BY presentation.display_order ASC;
```

### Récupérer les parameters requis

```surql
SELECT * FROM parameter 
WHERE tool_id = tool:slack_channel_create 
  AND validation.is_required = true;
```

### Récupérer les parameters avec options

```surql
SELECT * FROM parameter 
WHERE tool_id = tool:slack_channel_create 
  AND config.options != NONE;
```

### Récupérer les parameters sensibles

```surql
SELECT * FROM parameter 
WHERE presentation.is_sensitive = true;
```

### Recherche par type

```surql
SELECT * FROM parameter 
WHERE identity.parameter_type = 'resourceLocator';
```

## ⚠️ Notes importantes

1. **Extraction 1:1** : Les données sont extraites telles quelles depuis n8n, sans interprétation
2. **Pas de duplication** : Chaque parameter est unique par `{tool_slug}_{parameter_name}`
3. **Relations strictes** : Toutes les relations vers `tool` sont validées
4. **i18n obligatoire** : Tous les textes affichables passent par i18n
5. **Validation côté schéma** : Les `ASSERT` SurrealDB garantissent l'intégrité

## 🚀 Prochaines étapes

Avec le module `parameter` terminé, les prochains modules à implémenter sont :

1. ⏳ `response_mapping` : Mapping des réponses API
2. ⏳ `error_mapping` : Gestion des erreurs
3. ⏳ `webhook_config` : Configuration des webhooks

## 📚 Voir aussi

- [Schema parameter.surql](../../database/parameter/parameter.surql)
- [Liste des batches](./_LIST.md)
- [Module tool](../tool/)
- [Module resource](../resource/)
- [Module service](../service/)


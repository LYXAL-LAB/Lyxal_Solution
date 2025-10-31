# 📊 Analyse de la Table `uses_credential` - Rapport de Conformité

**Date** : 2025-10-29  
**Module** : `integrations > database > credentials`  
**Fichier** : `uses_credential.surql`

---

## 🎯 Vue d'ensemble

La table `uses_credential` est une **relation (edge)** qui lie :
- **`service`** (point de départ `IN`) → ex: `service:google_sheets`
- **`credential_type`** (point d'arrivée `OUT`) → ex: `credential_type:google_sheets_oauth2`

**Architecture n8n** :
```
provider:google 
    ↓
service:google_sheets 
    ↓ (uses_credential)
credential_type:google_sheets_oauth2
    ↓
auth_type:oauth2
```

---

## ✅ Points Forts Actuels

### 1. **Structure de relation claire** ✓
```surql
DEFINE FIELD in ON uses_credential TYPE record<service>;
DEFINE FIELD out ON uses_credential TYPE record<credential_type>;
```
- Direction explicite et logique
- Types strictement définis

### 2. **Champs métier pertinents** ✓
- `is_required` : Gestion des credentials obligatoires vs optionnels
- `is_recommended` : Mise en avant du meilleur choix
- `display_order` : Tri pour l'UI
- `display_conditions` : Affichage conditionnel intelligent

### 3. **Index performants** ✓
```surql
DEFINE INDEX uses_credential_in_idx ON uses_credential FIELDS in;
DEFINE INDEX uses_credential_out_idx ON uses_credential FIELDS out;
DEFINE INDEX uses_credential_unique_idx ON uses_credential FIELDS in, out UNIQUE;
```
- Requêtes bidirectionnelles optimisées
- Prévention des doublons

### 4. **Documentation exemplaire** ✓
- Commentaires détaillés
- Exemples concrets (Google Sheets, Slack, Stripe)
- Requêtes utiles documentées

---

## ⚠️ Non-Conformités Détectées

### 🔴 1. ABSENCE DE SCHEMAFULL STRICT

**Actuel** :
```surql
DEFINE TABLE uses_credential SCHEMAFULL;
```

**Problème** : Manque de contraintes strictes.

**Solution** :
```surql
DEFINE TABLE uses_credential TYPE NORMAL SCHEMAFULL
COMMENT 'Relation entre service et credential_type - Gère les authentifications disponibles par service.'
PERMISSIONS
    FOR SELECT FULL
    FOR CREATE, UPDATE, DELETE WHERE $auth.permissions = 'lyxal_admin';
```

---

### 🔴 2. CHAMPS NON GROUPÉS

**Actuel** : Tous les champs sont à plat.

**Problème** : Manque de structure logique pour l'organisation.

**Solution** : Grouper par cas d'usage :
```surql
-- Champs de base (PLAT)
- in, out, is_required

-- Objet: presentation (Pour l'UI)
presentation {
    display_order,
    custom_label_i18n,        -- ✅ i18n au lieu de string
    tooltip_i18n,              -- ✅ Nouveau champ
    is_recommended,
    badge_color,               -- ✅ Nouveau (ex: "primary", "warning")
    display_conditions
}

-- Objet: config (Configuration technique)
config {
    custom_description_i18n,   -- ✅ i18n au lieu de string
    scopes_required,           -- ✅ Déplacé du metadata
    permissions_needed,        -- ✅ Déplacé du metadata
    setup_complexity           -- ✅ Nouveau ("easy", "medium", "hard")
}

-- Objet: documentation (Ressources d'aide)
documentation {
    setup_instructions_i18n,   -- ✅ i18n
    video_tutorial_url,        -- ✅ Nouveau
    troubleshooting_url        -- ✅ Nouveau
}
```

---

### 🔴 3. ABSENCE D'INTERNATIONALISATION

**Actuel** :
```surql
DEFINE FIELD custom_label ON uses_credential TYPE option<string>;
DEFINE FIELD custom_description ON uses_credential TYPE option<string>;
```

**Problème** : Textes en dur, pas de support multilingue.

**Solution** :
```surql
-- ✅ Avec i18n
DEFINE FIELD presentation.custom_label_i18n ON uses_credential 
    TYPE option<record<i18n_key>>
    REFERENCE ON DELETE REJECT
    COMMENT 'Label personnalisé multilingue pour ce credential dans ce service.';

DEFINE FIELD config.custom_description_i18n ON uses_credential 
    TYPE option<record<i18n_key>>
    REFERENCE ON DELETE REJECT
    COMMENT 'Description personnalisée multilingue.';
```

---

### 🔴 4. METADATA NON STRUCTURÉ

**Actuel** :
```surql
DEFINE FIELD metadata ON uses_credential TYPE option<object>;
```

**Problème** : Fourre-tout non typé, difficile à requêter.

**Solution** : Éclater en champs typés :
```surql
DEFINE FIELD config.scopes_required ON uses_credential 
    TYPE array<string>
    DEFAULT []
    COMMENT 'Scopes OAuth2 requis (ex: ["https://www.googleapis.com/auth/spreadsheets"]).';

DEFINE FIELD config.permissions_needed ON uses_credential 
    TYPE array<string>
    DEFAULT []
    COMMENT 'Permissions nécessaires (ex: ["read:channels", "write:messages"]).';

DEFINE FIELD config.setup_complexity ON uses_credential 
    TYPE string
    ASSERT $value IN ['easy', 'medium', 'hard']
    DEFAULT 'medium'
    COMMENT 'Complexité de configuration pour l\'utilisateur.';
```

---

### 🔴 5. TIMESTAMPS NON CONFORMES

**Actuel** :
```surql
DEFINE FIELD created_at ON uses_credential TYPE datetime DEFAULT time::now();
```

**Problème** : Manque `updated_at` et `READONLY`.

**Solution** :
```surql
DEFINE FIELD created_at ON uses_credential 
    TYPE datetime
    DEFAULT time::now()
    READONLY
    COMMENT 'Date de création de la relation.';

DEFINE FIELD updated_at ON uses_credential 
    TYPE datetime
    READONLY
    DEFAULT ALWAYS time::now()
    COMMENT 'Date de dernière mise à jour (auto-updated).';
```

---

### 🔴 6. ABSENCE D'ETAG (Temps Réel)

**Problème** : Pas de support WebSocket / Live Queries.

**Solution** :
```surql
DEFINE FIELD etag ON uses_credential 
    TYPE string
    DEFAULT rand::uuid::v7()
    COMMENT 'ETag pour détection de changements et synchronisation temps réel.';
```

---

### 🔴 7. DISPLAY_CONDITIONS NON TYPÉ

**Actuel** :
```surql
DEFINE FIELD display_conditions ON uses_credential TYPE option<object>;
```

**Problème** : Structure floue, pas de validation.

**Solution** : Définir la structure attendue avec `ASSERT` :
```surql
DEFINE FIELD presentation.display_conditions ON uses_credential 
    TYPE option<object>
    COMMENT 'Conditions d\'affichage dans l\'interface. Structure: { show: { field: [values] }, hide: { field: [values] } }';

-- Exemple d'utilisation avec validation côté application :
-- {
--   show: { authentication_mode: ["oauth2"], plan: ["pro", "enterprise"] },
--   hide: { region: ["eu"] }
-- }
```

---

### 🔴 8. COMMENTAIRES INSUFFISANTS SUR LES CHAMPS

**Actuel** : Seulement quelques champs ont des `COMMENT`.

**Solution** : **Tous** les champs doivent avoir un `COMMENT` explicite.

---

## 🔄 Cohérence avec l'Écosystème

### ✅ Intégration avec `credential_type`

La relation référence correctement `credential_type` qui a été **complètement refait** selon les standards Lyxal :
- Structure groupée (`identity`, `presentation`, `config`, `documentation`)
- Internationalisation complète (5 langues)
- ETag pour temps réel
- Permissions strictes

**Recommandation** : Aligner `uses_credential` sur le même niveau de qualité.

---

### ⚠️ Problème avec la table `service`

**État actuel** : La table `service` définie dans `integration_schema.surql` (ligne 22) est **très basique** :
```surql
DEFINE TABLE service SCHEMAFULL;
DEFINE FIELD name ON service TYPE string;
DEFINE FIELD display_name ON service TYPE string;
DEFINE FIELD slug ON service TYPE string;
DEFINE FIELD description ON service TYPE option<string>;
DEFINE FIELD icon ON service TYPE option<string>;
DEFINE FIELD provider_id ON service TYPE record<provider>;
-- ... (pas de structure groupée, pas de i18n, pas de ETag)
```

**Problème** :
- ❌ Pas de structure groupée (`identity`, `presentation`, etc.)
- ❌ Pas d'internationalisation (`display_name` en string direct)
- ❌ Pas d'ETag pour temps réel
- ❌ Pas de `PERMISSIONS`
- ❌ Pas de `COMMENT` sur les champs
- ❌ `icon` en string au lieu de `record<logo_brand>`

**Recommandation critique** : Refaire la table `service` avant de finaliser `uses_credential`, car :
1. La qualité de `uses_credential` dépend de la qualité de `service`
2. Les deux tables doivent partager les mêmes standards
3. L'UI va requêter les deux ensemble (JOIN)

---

## 🎯 Architecture Cible

### Hiérarchie complète
```
provider (✅ FAIT - 100% conforme)
    ↓ (has_service)
service (⚠️ À REFAIRE)
    ↓ (uses_credential)
credential_type (✅ FAIT - 100% conforme)
    ↓ (has_auth_type)
auth_type (✅ FAIT - 100% conforme)
```

### Tables de support
- `logo_brand` (✅ Existe)
- `icon` (✅ Existe)
- `i18n_key` (✅ Existe)
- `language` (✅ Existe)
- `translation` (✅ Relation)
- `url` (⚠️ À vérifier)

---

## 📋 Plan de Refactoring Recommandé

### 🔥 Phase 1 : Refaire la table `service`
**Priorité** : CRITIQUE
- Implémenter structure groupée
- Ajouter internationalisation (i18n_key)
- Ajouter ETag pour temps réel
- Ajouter PERMISSIONS
- Remplacer `icon` par `logo_brand`
- Ajouter COMMENT sur tous les champs

### 🔧 Phase 2 : Refactor `uses_credential`
**Priorité** : HAUTE
- Grouper les champs (`presentation`, `config`, `documentation`)
- Remplacer strings par `i18n_key`
- Ajouter ETag
- Ajouter `updated_at`
- Ajouter PERMISSIONS
- Typer le `metadata` (éclater en champs dédiés)

### 📝 Phase 3 : Seeds et tests
- Générer les seeds pour `service` (Google Sheets, Slack, etc.)
- Générer les seeds pour `uses_credential`
- Créer les clés i18n nécessaires
- Tests de requêtes

---

## 💡 Proposition de Nouvelle Structure

### Version refactorée de `uses_credential` :

```surql
-- ========================================================================
-- TABLE: uses_credential
-- Relation entre service et credential_type
-- ========================================================================

DEFINE TABLE uses_credential TYPE NORMAL SCHEMAFULL
COMMENT 'Relation entre service et credential_type - Gère les authentifications disponibles par service.'
PERMISSIONS
    FOR SELECT FULL
    FOR CREATE, UPDATE, DELETE WHERE $auth.permissions = 'lyxal_admin';

-- =====================================================
-- CHAMPS DE RELATION (PLAT)
-- =====================================================

DEFINE FIELD in ON uses_credential 
    TYPE record<service>
    ASSERT $value != NONE
    COMMENT 'Service source (ex: service:google_sheets).';

DEFINE FIELD out ON uses_credential 
    TYPE record<credential_type>
    ASSERT $value != NONE
    COMMENT 'Type de credential cible (ex: credential_type:google_sheets_oauth2).';

DEFINE FIELD is_required ON uses_credential 
    TYPE bool
    DEFAULT true
    COMMENT 'Indique si ce credential est obligatoire pour utiliser le service.';

-- =====================================================
-- OBJET: presentation (Pour l'UI)
-- =====================================================

DEFINE FIELD presentation ON uses_credential 
    TYPE object
    COMMENT 'Éléments de présentation pour l\'interface utilisateur.';

DEFINE FIELD presentation.display_order ON uses_credential 
    TYPE int
    DEFAULT 0
    COMMENT 'Ordre d\'affichage (plus petit = plus haut).';

DEFINE FIELD presentation.custom_label_i18n ON uses_credential 
    TYPE option<record<i18n_key>>
    REFERENCE ON DELETE REJECT
    COMMENT 'Label personnalisé multilingue (override du display_name du credential_type).';

DEFINE FIELD presentation.tooltip_i18n ON uses_credential 
    TYPE option<record<i18n_key>>
    REFERENCE ON DELETE REJECT
    COMMENT 'Tooltip explicatif pour ce credential dans ce contexte.';

DEFINE FIELD presentation.is_recommended ON uses_credential 
    TYPE bool
    DEFAULT false
    COMMENT 'Indique si ce credential est recommandé pour ce service.';

DEFINE FIELD presentation.badge_color ON uses_credential 
    TYPE string
    ASSERT $value IN ['primary', 'secondary', 'accent', 'neutral', 'info', 'success', 'warning', 'error']
    DEFAULT 'neutral'
    COMMENT 'Couleur du badge DaisyUI pour l\'UI.';

DEFINE FIELD presentation.display_conditions ON uses_credential 
    TYPE option<object>
    COMMENT 'Conditions d\'affichage dynamiques. Format: { show: { field: [values] }, hide: { field: [values] } }';

-- =====================================================
-- OBJET: config (Configuration technique)
-- =====================================================

DEFINE FIELD config ON uses_credential 
    TYPE object
    COMMENT 'Configuration technique et exigences.';

DEFINE FIELD config.custom_description_i18n ON uses_credential 
    TYPE option<record<i18n_key>>
    REFERENCE ON DELETE REJECT
    COMMENT 'Description personnalisée multilingue pour ce contexte.';

DEFINE FIELD config.scopes_required ON uses_credential 
    TYPE array<string>
    DEFAULT []
    COMMENT 'Scopes OAuth2 spécifiques requis (ex: ["https://www.googleapis.com/auth/spreadsheets"]).';

DEFINE FIELD config.permissions_needed ON uses_credential 
    TYPE array<string>
    DEFAULT []
    COMMENT 'Permissions nécessaires (ex: ["read:channels", "write:messages"]).';

DEFINE FIELD config.setup_complexity ON uses_credential 
    TYPE string
    ASSERT $value IN ['easy', 'medium', 'hard']
    DEFAULT 'medium'
    COMMENT 'Complexité de configuration (easy, medium, hard).';

DEFINE FIELD config.estimated_setup_time ON uses_credential 
    TYPE option<int>
    COMMENT 'Temps estimé de configuration en minutes.';

-- =====================================================
-- OBJET: documentation (Ressources d'aide)
-- =====================================================

DEFINE FIELD documentation ON uses_credential 
    TYPE object
    COMMENT 'Ressources de documentation spécifiques à ce contexte.';

DEFINE FIELD documentation.setup_instructions_i18n ON uses_credential 
    TYPE option<record<i18n_key>>
    REFERENCE ON DELETE REJECT
    COMMENT 'Instructions de configuration détaillées.';

DEFINE FIELD documentation.video_tutorial_url ON uses_credential 
    TYPE option<record<url>>
    REFERENCE ON DELETE REJECT
    COMMENT 'URL d\'une vidéo tutoriel.';

DEFINE FIELD documentation.troubleshooting_url ON uses_credential 
    TYPE option<record<url>>
    REFERENCE ON DELETE REJECT
    COMMENT 'URL de la page de dépannage.';

-- =====================================================
-- CHAMPS SYSTÈME
-- =====================================================

DEFINE FIELD etag ON uses_credential 
    TYPE string
    DEFAULT rand::uuid::v7()
    COMMENT 'ETag pour détection de changements et synchronisation temps réel.';

DEFINE FIELD created_at ON uses_credential 
    TYPE datetime
    DEFAULT time::now()
    READONLY
    COMMENT 'Date de création de la relation.';

DEFINE FIELD updated_at ON uses_credential 
    TYPE datetime
    READONLY
    DEFAULT ALWAYS time::now()
    COMMENT 'Date de dernière mise à jour (auto-updated).';

-- =====================================================
-- INDEX
-- =====================================================

DEFINE INDEX uses_credential_in_idx ON uses_credential FIELDS in
    COMMENT 'Récupération rapide des credentials d\'un service.';

DEFINE INDEX uses_credential_out_idx ON uses_credential FIELDS out
    COMMENT 'Récupération des services utilisant un credential_type.';

DEFINE INDEX uses_credential_unique_idx ON uses_credential FIELDS in, out UNIQUE
    COMMENT 'Prévention des doublons.';

DEFINE INDEX uses_credential_required_idx ON uses_credential FIELDS is_required
    COMMENT 'Filtrage des credentials obligatoires.';

DEFINE INDEX uses_credential_recommended_idx ON uses_credential FIELDS presentation.is_recommended
    COMMENT 'Filtrage des credentials recommandés.';
```

---

## ✅ Conformité Finale

### Checklist de conformité Lyxal

- ✅ **SCHEMAFULL strict** avec `TYPE NORMAL`
- ✅ **COMMENT** sur tous les champs
- ✅ **Structure groupée** (`presentation`, `config`, `documentation`)
- ✅ **Internationalisation** (i18n_key pour tous les textes)
- ✅ **ETag** pour temps réel
- ✅ **Timestamps** (`created_at` READONLY, `updated_at` avec ALWAYS)
- ✅ **PERMISSIONS** explicites
- ✅ **Index** performants et documentés
- ✅ **ASSERT** pour validation des données
- ✅ **REFERENCE ON DELETE REJECT** pour intégrité

---

## 🎯 Conclusion

### État actuel : ⚠️ **60% conforme**

**Points forts** :
- ✅ Architecture relationnelle claire
- ✅ Logique métier solide
- ✅ Documentation exemplaire

**Points à améliorer** :
- ❌ Absence de structure groupée
- ❌ Pas d'internationalisation
- ❌ Metadata non structuré
- ❌ Timestamps incomplets
- ❌ Pas d'ETag

### Prochaine étape recommandée

**PRIORITÉ 1** : Refaire la table `service` (elle est référencée mais non conforme)  
**PRIORITÉ 2** : Refactorer `uses_credential` selon la structure proposée

---

✨ **Document prêt pour validation et implémentation !**


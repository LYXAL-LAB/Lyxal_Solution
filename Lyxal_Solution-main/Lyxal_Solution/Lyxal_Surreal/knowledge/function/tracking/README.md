-- ============================================================================
-- Fichier : knowledge/function/tracking/README.md
-- Module : knowledge
-- Description : Documentation des fonctions de tracking et analytics
-- ============================================================================

# 📊 Fonctions de Tracking et Analytics – Knowledge System

Ce dossier contient les **fonctions SurrealDB** pour automatiser le tracking des métriques d'usage des contenus de connaissance.

## 🎯 Objectif

Fournir des fonctions réutilisables pour :
- ✅ Incrémenter automatiquement les compteurs de vues
- ✅ Tracker l'utilisation spécifique par IA
- ✅ Mettre à jour les dates de dernière consultation
- ✅ Récupérer les métriques analytics d'un contenu
- ✅ Séparation des responsabilités : fonctions de tracking isolées

## 📋 Fonctions Disponibles

### 1. `fn::knowledge_track_content_view()`

Incrémente le compteur de vues générales pour un contenu.

**Paramètres** :
- `$content_id` : ID du contenu (ex: `knowledge_content:content_slug`)

**Retourne** :
```json
{
  "success": true,
  "content_id": "knowledge_content:content_slug",
  "analytics": {
    "view_count": 42,
    "last_viewed": "2025-01-15T10:30:00Z"
  }
}
```

**Exemple** :
```sql
SELECT * FROM fn::knowledge_track_content_view(knowledge_content:define-field-basic-syntax);
```

**Utilisation** :
- À appeler lors d'une consultation générale (humain ou vue simple)
- Incrémente uniquement `view_count` et met à jour `last_viewed`

---

### 2. `fn::knowledge_track_ai_usage()`

Incrémente le compteur d'utilisation spécifique par IA pour un contenu.

**Paramètres** :
- `$content_id` : ID du contenu (ex: `knowledge_content:content_slug`)

**Retourne** :
```json
{
  "success": true,
  "content_id": "knowledge_content:content_slug",
  "analytics": {
    "view_count": 43,
    "ai_usage_count": 15,
    "last_viewed": "2025-01-15T10:30:00Z"
  }
}
```

**Exemple** :
```sql
SELECT * FROM fn::knowledge_track_ai_usage(knowledge_content:define-field-basic-syntax);
```

**Utilisation** :
- À appeler lors d'une utilisation spécifique par une IA/agent IA
- Incrémente `ai_usage_count` ET `view_count`, et met à jour `last_viewed`
- Permet de distinguer l'usage IA de l'usage humain

---

### 3. `fn::knowledge_track_content_access()`

Fonction combinée pour tracker l'accès à un contenu (vue générale ou utilisation IA).

**Paramètres** :
- `$content_id` : ID du contenu (ex: `knowledge_content:content_slug`)
- `$is_ai_usage` : `bool` - `true` si utilisation par IA, `false` si vue générale

**Retourne** :
```json
{
  "success": true,
  "content_id": "knowledge_content:content_slug",
  "is_ai_usage": true,
  "analytics": {
    "view_count": 43,
    "ai_usage_count": 15,
    "last_viewed": "2025-01-15T10:30:00Z"
  }
}
```

**Exemple** :
```sql
-- Utilisation par IA
SELECT * FROM fn::knowledge_track_content_access(
    knowledge_content:define-field-basic-syntax,
    true
);

-- Vue générale (humain)
SELECT * FROM fn::knowledge_track_content_access(
    knowledge_content:define-field-basic-syntax,
    false
);
```

**Utilisation** :
- Fonction unifiée pour simplifier le tracking selon le contexte
- Si `$is_ai_usage = true` : même comportement que `ai_usage()`
- Si `$is_ai_usage = false` : même comportement que `content_view()`

---

### 4. `fn::knowledge_track_get_analytics()`

Récupère les métriques analytics complètes pour un contenu.

**Paramètres** :
- `$content_id` : ID du contenu (ex: `knowledge_content:content_slug`)

**Retourne** :
```json
{
  "success": true,
  "content_id": "knowledge_content:content_slug",
  "slug": "define-field-basic-syntax",
  "analytics": {
    "view_count": 42,
    "ai_usage_count": 15,
    "last_viewed": "2025-01-15T10:30:00Z",
    "ai_usage_ratio": 35.71
  },
  "metadata": {
    "quality_score": 0.9,
    "is_active": true
  }
}
```

**Exemple** :
```sql
SELECT * FROM fn::knowledge_track_get_analytics(knowledge_content:define-field-basic-syntax);
```

**Utilisation** :
- Récupérer les métriques sans les modifier
- Calcule automatiquement le ratio d'utilisation IA (`ai_usage_ratio`)
- Inclut aussi les métadonnées de qualité et statut actif

---

## 🔄 Intégration avec les Fonctions IA

Ces fonctions peuvent être appelées dans les autres fonctions IA si nécessaire (mais pour le moment, elles ne sont **PAS** implémentées automatiquement) :

```sql
-- Exemple d'intégration future dans fn::knowledge_get_topic_bundle_for_ai()
DEFINE FUNCTION fn::knowledge_get_topic_bundle_for_ai(...) {
    -- ... récupération du bundle ...
    
    -- Optionnel : tracker l'utilisation IA
    FOR $content IN $contents {
        fn::knowledge_track_ai_usage($content.id);
    };
    
    RETURN { ... };
};
```

**Note** : Pour le moment, le tracking doit être fait manuellement ou via appel explicite de ces fonctions.

---

## 📊 Cas d'Usage

### Tracking manuel depuis une application

```sql
-- L'utilisateur consulte un contenu
SELECT * FROM fn::knowledge_track_content_view(knowledge_content:define-field-basic-syntax);

-- Une IA utilise un contenu
SELECT * FROM fn::knowledge_track_ai_usage(knowledge_content:define-field-basic-syntax);
```

### Récupération des métriques pour analytics

```sql
-- Obtenir les analytics d'un contenu
SELECT * FROM fn::knowledge_track_get_analytics(knowledge_content:define-field-basic-syntax);

-- Requête manuelle pour tops contenus
SELECT 
    identity.slug,
    metadata.analytics.view_count,
    metadata.analytics.ai_usage_count,
    metadata.analytics.last_viewed
FROM knowledge_content
WHERE metadata.is_active = true
ORDER BY metadata.analytics.view_count DESC
LIMIT 10;
```

### Tracking dans un batch/script

```sql
-- Tracker plusieurs contenus en une fois
FOR $content_id IN [
    knowledge_content:content_1,
    knowledge_content:content_2,
    knowledge_content:content_3
] {
    SELECT * FROM fn::knowledge_track_content_access($content_id, false);
};
```

---

## 🎯 Avantages

1. **Séparation des responsabilités** : Fonctions de tracking isolées, réutilisables
2. **Consistance** : Garantit que le tracking est fait de manière uniforme
3. **Flexibilité** : Peut être appelé depuis n'importe où (fonctions IA, applications, scripts)
4. **Extensibilité** : Facile d'ajouter des métriques supplémentaires plus tard
5. **Non-intrusif** : Les fonctions IA existantes ne sont pas modifiées pour le moment

---

## 📚 Références

- **Champs analytics** : Voir `knowledge/documentation/06_Knowledge_Content.md` (section `metadata.analytics`)
- **Fonctions IA** : Voir `knowledge/function/README.md`
- **Schéma complet** : Voir `knowledge/documentation/SCHEMA_Knowledge_System.md`

---

**Dernière mise à jour** : 2025


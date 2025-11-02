# 📘 Table : `knowledge_content`

## 🎯 Objectif

La table `knowledge_content` stocke chaque **unité de connaissance** liée à un topic.  
Il s’agit du cœur du système : chaque enregistrement représente un morceau de savoir exploitable par un humain et par une IA.

Un topic = plusieurs contenus de nature différente (exemples, explications, code, règles, patterns…).

---

## 🧱 Structure

| Bloc | Description |
|-------|----------------|
| `topic` | Référence vers le topic parent |
| `identity` | Informations permettant d’identifier et décrire le contenu |
| `content` | Le savoir lui-même (texte, code, explications, règles, etc.) |
| `metadata` | Informations de gestion, IA, affichage et statut |

---

### 🔗 Relation

| Table liée | Type | Description |
|-------------|----------|----------------|
| `knowledge_topic` | 1 → N | Un topic possède plusieurs contenus |


---

## 🧩 Champs principaux

### 🧠 `identity`

| Field | Description |
|--------|----------------|
| `slug` | Identifiant unique lisible, utilisé dans les URLs et pour IA |
| `label_key` | Clé i18n du titre du contenu |
| `description_key` | Clé i18n d’une description courte |

---

### 📚 `content`

Contient l’information destinée à l’apprentissage :

| Field | Description |
|--------|----------------|
| `surql_code` | Exemple de code SurrealQL (si applicable) |
| `explanation_key` | Clé i18n expliquant le contenu |
| `why_incorrect_key` | Clé i18n expliquant l’erreur (optionnel) |
| `when_to_use_key` | Clé i18n indiquant quand l’utiliser (optionnel) |
| `url` | Référence vers ressource externe (documentation, vidéo, article) |

> Tous ces champs sont optionnels, car un contenu peut être purement explicatif, ou au contraire uniquement un snippet de code.

---

### 🧬 `metadata`

| Field | Description |
|--------|----------------|
| `content_type` | record<knowledge_content_type> |
| `is_active` | Permet d’activer/désactiver un contenu |
| `display_order` | Ordre d’affichage parmi les contenus du topic |
| `tags` | Tags structurés (record<tag>) |
| `quality_score` | Score de qualité pour IA & UX |
| `version_label` | Version fonctionnelle du contenu |

---

## 🤖 Bénéfices pour l’IA

Cette structure optimise :

✅ RAG interne (Recherche + Assembly du contexte optimal)  
✅ Génération de code (pattern + syntax + rule + tips)  
✅ Apprentissage automatique du raisonnement correct  
✅ Détection automatique des erreurs via `why_incorrect`  
✅ Amélioration de la réponse selon `quality_score`  

---

## 🧪 Exemples d’utilisation

### 🔍 Obtenir tous les contenus d’un topic

```sql
SELECT ->knowledge_content.* 
FROM knowledge_topic:DEFINE_FIELD;

🧠 Préparer un bundle pour IA

SELECT {
    type: metadata.content_type->identity.code,
    title: identity.label_key->fr,
    code: content.surql_code,
    explanation: content.explanation_key->fr,
    tags: metadata.tags
}
FROM knowledge_content
WHERE topic = knowledge_topic:DEFINE_FIELD
  AND metadata.is_active = true
ORDER BY metadata.display_order;

✅ Ajouter un contenu

CREATE knowledge_content SET
    topic = knowledge_topic:DEFINE_FIELD,
    identity.slug = "define_field_assert_not_empty",
    metadata.content_type = knowledge_content_type:EXAMPLE_CORRECT,
    content.surql_code = "DEFINE FIELD name ON TABLE user TYPE string ASSERT $value != NONE;",
    metadata.tags = [tag:validation]
;

🧵 Résumé

La table knowledge_content :

Représente chaque pièce de connaissance exploitable

Relie un contenu à un topic et à un type

Est pensée pour l’IA et l’humain

Supporte multi-langue et multi-support (text, code, vidéo…)

Elle constitue le centre de gravité de tout le système de connaissance.
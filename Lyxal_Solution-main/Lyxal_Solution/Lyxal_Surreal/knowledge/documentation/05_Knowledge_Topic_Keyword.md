# 🔍 Table : `knowledge_topic_keyword`

## 🎯 Objectif

La table `knowledge_topic_keyword` permet d’associer **des mots-clés libres** à un topic afin d’améliorer :

- La recherche full-text (BM25 + Highlight)
- Le référencement interne
- Le repérage rapide par l’IA et l’utilisateur
- La navigation intelligente dans la base de connaissance

Ce modèle évite de stocker des mots-clés en array dans `knowledge_topic`, permettant une recherche plus performante, des statistiques, et une meilleure normalisation.

---

## 🧱 Structure

| Bloc | Description |
|-------|----------------|
| `in` | Référence du topic associé |
| `out` | Mot-clé libre |
| Index full-text | Recherche avancée par mot(s)-clé(s) |
| Index unique | Empêche les doublons |

- Chaque combinaison **(topic, mot-clé)** est unique.
- Les mots-clés sont stockés et comparés en **lowercase**, pour cohérence.

---

## 🔗 Relations

| Table liée | Type | Description |
|-------------|----------|----------------|
| `knowledge_topic` | N → N | Un topic peut avoir plusieurs mots-clés |
| - | - | Un mot-clé peut se retrouver sur plusieurs topics |

---

## 🔥 Points forts

✅ Recherche très rapide grâce au FULLTEXT BM25  
✅ Compatible IA (meilleur matching contextuel)  
✅ Scalable même avec des milliers de mots-clés  
✅ Permet de filtrer, agréger, analyser la pertinence des termes utilisés  

---

## 🧠 Utilité IA

Cette table optimise fortement :
- Le RAG interne
- Le mapping intention utilisateur → topic
- Le scoring de proximité sémantique
- Les suggestions contextuelles par l’IA

Elle sert de **pont lexical** entre le langage humain naturel et la structure interne de la connaissance.

---

## 🧪 Exemples d’utilisation

### ➕ Ajouter des mots-clés à un topic

```sql
RELATE knowledge_topic:DEFINE_FIELD
    -> knowledge_topic_keyword
    -> "field"
;

RELATE knowledge_topic:DEFINE_FIELD
    -> knowledge_topic_keyword
    -> "schema"
;
🔍 Recherche : trouver les topics liés au mot “index”

SELECT in AS topic
FROM knowledge_topic_keyword
WHERE out @@ "index";

📊 Lister les mots-clés par topic
SELECT in AS topic, array::agg(out) AS keywords
FROM knowledge_topic_keyword
GROUP BY in;

✅ Résumé

La table knowledge_topic_keyword :

Normalise et indexe les mots-clés liés aux topics

Améliore fortement le référencement et la recherche

Facilite l’exploitation IA (précision, matching et ranking)

Évite les doublons et la divergence des mots-clés

Elle constitue un levier essentiel pour l’exploration intelligente du savoir et les futures fonctionnalités d’auto-apprentissage.


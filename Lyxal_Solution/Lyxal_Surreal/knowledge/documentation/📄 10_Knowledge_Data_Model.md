# 🧬 Modèle de Données – Knowledge System

## 🎯 Objectif

Ce document présente **la vision globale du modèle de données** du système de connaissance Lyxal.  
Il illustre comment les différentes tables interagissent pour former une base de connaissance structurée, intelligente, et exploitable par l’IA et l’humain.

---

## 🧱 Les 6 Composants du Knowledge System

Le système repose sur 6 tables principales :

| Composant | Table | Rôle |
|------------|---------|--------|
| Domaine | `knowledge_domain` | Grande catégorie de connaissance |
| Mot-clé global | `knowledge_keyword` | Référentiel centralisé des mots-clés |
| Topic | `knowledge_topic` | Sujet de connaissance (ex: DEFINE FIELD) |
| Type de contenu | `knowledge_content_type` | Catégorisation dynamique du contenu |
| Contenu | `knowledge_content` | Unité de connaissance |
| Relations mots-clés | `knowledge_domain_keyword`, `knowledge_topic_keyword` | Liens entre entités & mots-clés |

---

## 🌐 Vue Graphique du Modèle

```plaintext
 ┌────────────────────┐
 │  knowledge_domain   │
 └────────┬────────────┘
          │1─∞
          │
          ▼
 ┌────────────────────┐
 │  knowledge_topic    │
 └───────┬────┬────────┘
         │    │
         │    └───────────────┐ optional
         │1─∞                  │
         ▼                     ▼
 ┌────────────────────┐   ┌────────────────────┐
 │ knowledge_content   │   │knowledge_content_type│
 └────────────────────┘   └────────────────────┘


        Mots-Clés (Keywords)
        ┌─────────────────────────────────────────┐
        │             knowledge_keyword            │
        └─────────────────────────────────────────┘

Relations
------------

knowledge_domain_keyword   (∞─∞ Domain ↔ Keyword)
knowledge_topic_keyword    (∞─∞ Topic ↔ Keyword)

🧠 Logique Conceptuelle
Niveau	Élément	Question à laquelle il répond
1	Domaine	“Dans quel univers de connaissance sommes-nous ?”
2	Topic	“De quoi parle-t-on précisément ?”
3	Contenu	“Quelle information utile associons-nous à ce sujet ?”
Meta	Type	“De quelle nature est ce contenu ?"
Sémantique	Keywords	“Comment l’IA et l’utilisateur doivent trouver/relier cette info ?”
🧩 Exemple Concret

Cas d’usage : un agent IA doit aider à écrire un DEFINE FIELD.

Table	Exemple
Domain	SURREAL_DB
Topic	DEFINE_FIELD
Content Types	SYNTAX, RULE, EXAMPLE_CORRECT, EXAMPLE_INCORRECT, TIP
Keywords	FIELD, ASSERT, PERMISSIONS, TYPE

Processus IA :

Cherche le domaine → SURREAL_DB

Trouve le topic → DEFINE_FIELD

Récupère les contenus associés

Filtre par type selon le besoin (ex: examples only)

Utilise les keywords pour contextualisation / RAG

📊 Pourquoi ce modèle est optimal ?
Critère	Résultat
Évolutivité	Ajout de sujets sans changer le schéma
IA Ready	Données structurées + sémantique + scoring
RAG efficace	Indexation par mots-clés + types + structure
UX-Friendly	Multi-niveaux lisibles pour l’humain
White Label	Extensible à d’autres connaissances que SurrealDB
🚀 Scalabilité prévue

Cette architecture supporte nativement l’extension future :

ajout d’historiques et versionning natif SurrealDB,

ajout d’un niveau “module” ou “collection” si besoin,

ajout d’un graphe IA (embeddings & similarity search) si activé.

🧵 Résumé

Le Knowledge System repose sur un modèle :

structuré (Domain → Topic → Content)

sémantique (Keywords + Types)

IA-optimisé (Scoring, Priorités, Use Cases IA)

multi-domaines et multi-niveaux

Ce modèle transforme la base de connaissance Lyxal en un véritable cortex de savoir, utilisable par des humains, des IAs internes ou externes, et tous les modules de la suite.
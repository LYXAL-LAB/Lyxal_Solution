# 🤖 Utilisation du Knowledge System par l’IA

## 🎯 Objectif

Ce document explique comment une IA doit exploiter le Knowledge System pour :

- apprendre un domaine,
- générer du contenu fiable,
- corriger des erreurs,
- assister les utilisateurs,
- s’auto-améliorer.

Il sert de **guide d’intégration** pour agents IA Lyxal, copilots, assistants, RAG, automatisations ou LLM externes.

---

## 🧠 1. Approche Générale de l’IA

L’IA doit toujours interroger la base selon la hiérarchie suivante :

1. Identifier le **domaine**
2. Trouver le **topic compatible**
3. Récupérer les **contenus associés**
4. Filtrer par **type de contenu**
5. Utiliser les **keywords** pour renforcer la pertinence

Cette structure garantit une réponse :

✅ contextualisée  
✅ exacte  
✅ conforme aux règles Lyxal  

---

## 🧬 2. Navigation recommandée pour l’IA

### 🔍 Trouver le bon domaine

L’IA commence par déterminer le domaine principal du besoin utilisateur.

Exemple de requête :

```sql
SELECT * FROM knowledge_domain
WHERE identity.code = "SURREAL_DB";

🎯 Trouver le bon topic

SELECT * FROM knowledge_topic
WHERE domain = knowledge_domain:SURREAL_DB
    AND identity.code = "DEFINE_FIELD";

📚 Récupérer les contenus associés

SELECT * FROM knowledge_content
WHERE topic = knowledge_topic:DEFINE_FIELD
ORDER BY metadata.display_order;

🧩 3. Comment choisir les bons contenus

L’IA doit sélectionner les contenus selon le contexte d’usage.

Besoin IA	Types à privilégier
Expliquer	EXPLANATION, RULE, TIP
Enseigner	EXAMPLE_CORRECT, EXAMPLE_INCORRECT
Générer	SYNTAX, PATTERN
Valider	RULE, PATTERN, EXAMPLE_INCORRECT
Correction	EXAMPLE_INCORRECT + RULE
🧠 4. Utilisation des metadata IA

Chaque type de contenu contient des métadonnées IA permettant de :

Métadonnée	Effet sur IA
priority	Choisir un type plutôt qu’un autre
weight	Pondérer sa valeur dans la réponse
level	Adapter la complexité
min_quality_score	Ignorer les contenus insuffisants
use_cases	Orienter selon le contexte (teach, generate…)

L’IA doit pondérer ses réponses selon ces paramètres.

🔧 5. Utilisation des Keywords

Les relations mots-clés permettent :

recherche sémantique ciblée

augmentation de contexte

alignement conceptuel entre contenus

Exemple : trouver les contenus liés au keyword ASSERT

SELECT * FROM knowledge_content
WHERE topic IN (
    SELECT in FROM knowledge_topic_keyword
    WHERE out = knowledge_keyword:ASSERT
);

🧠 6. RAG : Règles d’Usage pour IA

Lorsqu’un agent IA prépare un contexte RAG, il doit :

✅ Inclure :

1 domaine

1 topic principal

3–6 contenus max

3–8 keywords pertinents

❌ Ne pas inclure :

contenus inactifs (metadata.is_active = false)

contenus en dessous du min_quality_score

autres topics non liés au besoin

🎯 Objectif RAG

Créer un contexte court, ciblé, utile, plutôt qu’un long dump de données.

🔁 7. Feedback & Auto-Amélioration

Les IA doivent remonter un score d’utilisation pour alimenter le futur module de qualité.

Le score envoyé doit comporter :

Donnée	Exemple
content_id	knowledge_content:DEFINE_FIELD_RULE_01
score	0.8
type	TEACHING_SUCCESS
🚀 Résultat attendu

Grâce à ce guide, toutes les IA Lyxal utiliseront le Knowledge System de manière :

optimisée

intelligente

normée

auto-améliorée

Ce document sert de contrat de comportement IA pour l’exploitation du savoir Lyxal.
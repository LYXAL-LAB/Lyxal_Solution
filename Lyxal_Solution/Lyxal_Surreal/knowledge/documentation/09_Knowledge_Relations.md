# 🔗 Relations du Système de Connaissance

## 🎯 Objectif

Ce fichier documente les **tables relationnelles** qui assurent les liens entre :

- les **domaines** (`knowledge_domain`)
- les **topics** (`knowledge_topic`)
- les **contenus** (`knowledge_content`)
- les **mots-clés** (`knowledge_keyword`)

Ces relations permettent :

✅ une navigation hiérarchique  
✅ une recherche intelligente et précise  
✅ un graphe de connaissance exploitable par l’IA  

---

## 🧱 Vue globale du modèle relationnel

```plaintext
knowledge_domain
     │ 1─∞
     ▼
knowledge_topic
     │ 1─∞
     ▼
knowledge_content


Mots-clés (Keywords)
     ∞─∞ via relations

Relations via 3 tables :

Table relationnelle	Rôle
knowledge_domain_keyword	Mots-clés liés à un domaine
knowledge_topic_keyword	Mots-clés liés à un topic
(optionnel futur) knowledge_content_keyword	Mots-clés liés au contenu

📌 1. knowledge_domain_keyword
Rôle

Associe des mots-clés globaux à un domaine.

Exemples :

Domaine SURREAL_DB → keywords : PERMISSIONS, RELATION, ASSERT

Domaine BUSINESS → keywords : CRM, LEADS, PIPELINE

Exemple de liaison

RELATE knowledge_domain:SURREAL_DB
    ->knowledge_domain_keyword->knowledge_keyword:ASSERT;

Requête : récupérer les mots-clés d’un domaine

SELECT ->knowledge_domain_keyword->identity.code AS keywords
FROM knowledge_domain:BUSINESS;

📍 2. knowledge_topic_keyword

Rôle

Associe des mots-clés à un topic.
Permet un filtrage précis par besoin.

Exemples :

Topic DEFINE_FIELD → keywords : ASSERT, TYPE, CONSTRAINT

Topic SELECT_FULLTEXT → keywords : FULLTEXT, SEARCH, BM25

Exemple de liaison

RELATE knowledge_topic:DEFINE_FIELD
    ->knowledge_topic_keyword->knowledge_keyword:TYPE;

Requête : trouver les topics proches d’un mot-clé

SELECT in AS topic
FROM knowledge_topic_keyword
WHERE out = knowledge_keyword:ASSERT;

📎 3. (Optionnel futur) knowledge_content_keyword

Non implémentée volontairement à cette phase.
Peut être ajoutée lorsque l’on souhaitera des mots-clés au niveau du contenu pour augmenter la granularité IA.

Usage futur :

suggérer le bon contenu selon un mot-clé

entraînement IA fin

🧠 Comment l’IA exploite ces relations

Ces relations créent un mini-graphe sémantique :

IA Task	Utilisation
Générer du code SurrealDB	Cherche les contenus du topic + keywords associés
Corriger un code	Mappe les erreurs aux keywords + topics concernés
Apprendre	Explore par niveau : Domain → Topics → Contents
RAG interne	Filtre par keywords pour augmenter la qualité du contexte
🧵 Résumé

Les relations permettent :

une structuration fine du savoir,

une recherche sémantique multi-niveaux,

une montée en puissance IA.

Niveau	Table	Description
Domaine	knowledge_domain_keyword	Mots-clés globalisés
Topic	knowledge_topic_keyword	Mots-clés contextuels
Contenu	(futur) knowledge_content_keyword	Mots-clés granulaire IA

Elles transforment votre base de connaissance en un graphe intelligent, navigable par humain et IA.
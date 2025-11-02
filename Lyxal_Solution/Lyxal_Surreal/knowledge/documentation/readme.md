# 📚 Knowledge System – Master Documentation  
*(Module : `knowledge` – SurrealDB Knowledge & AI Learning System)*

Ce document décrit les tables qui composent le **Knowledge System**.  
Ce système permet de **structurer, stocker, organiser et exploiter** les connaissances de manière exploitable par les humains **et par les IA**.

Il a été conçu pour :

- Centraliser la connaissance (SurrealDB, Business, IA, Lyxal Standards, etc.)
- Fournir un moteur d’apprentissage pour IA (auto-amélioration, génération fiable)
- Servir de base à la gouvernance technique et documentaire de Lyxal

---

## 🧠 Vision du Knowledge System

L’objectif est de créer une **base de connaissance vivante**, capable de :

✅ Fournir des blocs de connaissance réutilisables  
✅ Guider et corriger l’IA dans ses productions  
✅ Éviter les incohérences documentaires entre développeurs et IA  
✅ Servir de “vérité unique” (Single Source of Truth)  
✅ S’adapter à tous les domaines (SurrealDB, Business, IA, UI, Lyxal Standards, etc.)

Le module s’organise en **6 tables principales**, chacune ayant un rôle clair.

---

## 🧩 Architecture des Tables

knowledge_domain
└── knowledge_topic
└── knowledge_content (avec type = knowledge_content_type)

knowledge_domain_keyword (mots-clés du domaine)
knowledge_topic_keyword (mots-clés du topic)

knowledge_content_type (référentiel des types de contenus)


---

## 🏛️ Table : `knowledge_domain`

### 🎯 Rôle
Représente un **domaine de connaissance**.  
Exemple : SurrealDB, Business, IA, UI, Lyxal Standards…

C’est le niveau le plus haut de classification.

### 📍 Pourquoi elle existe ?

- Séparer les connaissances par “univers”
- Permettre de charger seulement les domaines utiles (ex: une instance peut importer uniquement Business ou SurrealDB)
- Permettre à l’IA de comprendre le contexte d’un sujet

### 🧱 Champs clés

| Field | Description |
|--------|----------------|
| `identity.code` | Code du domaine (UPPER_SNAKE_CASE) |
| `identity.label_key` | Nom i18n du domaine |
| `identity.description_key` | Description i18n |
| `tags` | Tags structurés du domaine |
| (relation) `knowledge_domain_keyword` | Mots-clés libres pour recherche full-text |
| `metadata.display_order` | Ordre d’affichage |
| `metadata.is_active` | Actif/inactif |

---

## 🧠 Table : `knowledge_domain_keyword` *(TYPE RELATION)*

### 🎯 Rôle
Stocke les **mots-clés libres** associés à un domaine pour permettre la **recherche full-text IA/humain**.

### Pourquoi séparé du domain ?
- Permet une indexation full-text BM25
- Évite d’alourdir la table principale
- Permet une recherche plus intelligente

---

## 🧩 Table : `knowledge_topic`

### 🎯 Rôle
Un **topic** est un **sujet précis** à l’intérieur d’un domaine.

Exemples (dans le domain SurrealDB) :

- DEFINE_FIELD
- SELECT
- RELATE
- SCHEMAFULL vs SCHEMALESS

Exemples (dans le domain Lyxal Standards) :

- ID_CONVENTIONS
- NAMING_RULES
- UI_NO_INLINE_CSS

### 📍 Pourquoi elle existe ?

- Décomposer la connaissance en unités logiques
- Permettre à l’IA d’apprendre sujet par sujet
- Organiser le contenu pour la UI (filtrage, classement, tags)

### 🧱 Champs clés

| Field | Description |
|--------|----------------|
| `domain` | Domaine parent |
| `category` | Catégorie du topic |
| `sub_category` | Sous-catégorie (optionnelle) |
| `tags` | Tags structurés |
| (relation) `knowledge_topic_keyword` | Mots-clés pour recherche IA |
| `identity.code` | Nom constant du topic |
| `identity.label_key` | Nom i18n |
| `identity.description_key` | Description i18n |
| `metadata.display_order` | Ordre |
| `metadata.is_active` | Actif |

---

## 🔍 Table : `knowledge_topic_keyword` *(TYPE RELATION)*

### 🎯 Rôle
Associe des mots-clés libres à un topic.  
Optimisé IA grâce à la recherche full-text BM25.

Utilisé par :
- UI : auto-suggestion
- IA : compréhension contextuelle
- Recherche : “trouve tous les topics liés à permissions + assertions”

---

## 📦 Table : `knowledge_content_type`

### 🎯 Rôle
Référentiel des **types de contenus**.

Exemples de types :
- SYNTAX
- RULE
- EXAMPLE_CORRECT
- EXAMPLE_INCORRECT
- TIP
- PATTERN
- EXPLANATION
- REFERENCE

### 📍 Pourquoi elle existe ?

- Séparer la forme du contenu de son usage
- Permettre à l’IA de choisir le bon type selon l’objectif
- Permettre un standard universel d’organisation du savoir

### 🧠 IA Fields (Intelligence intégrée)

Cette table contient un bloc `metadata.ai` permettant de guider l’IA :

- Priorité & poids d’importance
- Niveau de complexité
- Taille optimale du contenu pour LLM
- Liste des use-cases IA recommandés

---

## 📑 Table : `knowledge_content`

### 🎯 Rôle
Contient l’unité de connaissance elle-même.  
Un **topic** peut avoir plusieurs contenus, chacun d’un type différent.

Exemple pour `DEFINE_FIELD` :
- 1 syntaxe
- 3 règles
- 2 exemples corrects
- 2 mauvais exemples
- 1 pattern réutilisable
- 1 explication détaillée

### 🧱 Champs clés

| Field | Description |
|--------|----------------|
| `topic` | Le topic auquel appartient ce contenu |
| `content_type` | Référence vers `knowledge_content_type` |
| `identity.title` | Titre |
| `identity.description` | Description courte |
| `content.surql_code` | Code SurrealQL d’exemple |
| `content.explanation` | Explication |
| `content.why_incorrect` | (si mauvais exemple) |
| `content.when_to_use` | Quand l’utiliser |
| `metadata.priority` | Ordre |
| `metadata.tags` | Filtres texte |
| `metadata.is_active` | Actif |

---

## 🚀 Comment une IA utilise ce système

1. Elle identifie le domaine → filtre les topics
2. Elle récupère le topic → charge tous les contenus liés
3. Elle lit le type de contenu pour savoir **comment l’utiliser**
4. Elle choisit le type en fonction de l’objectif (ex: générer code, enseigner, corriger)
5. Elle combine les contenus (syntax + rule + patterns + examples) pour produire un résultat fiable

---

## 📍 Conclusion

Ce module `knowledge` permet :

✅ D’organiser la connaissance comme un **système structuré et évolutif**  
✅ D’enseigner aux IA *comment travailler comme Lyxal*  
✅ De réduire les erreurs et d’augmenter la cohérence  
✅ De servir de base pour un futur **auto-learning Lyxal AI**  

---

Souhaites-tu que je génère maintenant :  

A. Le schéma graphique (.png) pour visualiser les relations  
B. Un 2e fichier `.md` **“How to contribute knowledge”** (process d’ajout de contenu)  
C. Les prompts IA pour utiliser ce Knowledge System correctement  

Répond : **A**, **B**, **C**, ou **ALL**.

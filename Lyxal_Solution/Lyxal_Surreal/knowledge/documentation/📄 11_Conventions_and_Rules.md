# ✅ Conventions & Règles – Lyxal Knowledge System

Ce document définit les **standards officiels Lyxal** pour structurer, nommer, rédiger et maintenir la connaissance.  
Il garantit une cohérence maximale entre humain, UI, API et IA.

---

## 🧱 1. Principes Fondateurs

| Principe | Description |
|----------|--------------|
| **Clarté** | Chaque élément doit être compréhensible immédiatement |
| **Modularité** | Le système doit rester extensible sans casse |
| **IA-Friendly** | Optimisé pour compréhension et génération par IA |
| **I18N Ready** | Tous les contenus sont internationalisables |
| **Neutralité** | Le Knowledge n’est pas lié à un client ou projet, mais à la connaissance elle-même |

---

## 🏗️ 2. Nommage (Naming Rules)

### Tables

| Élément | Format | Exemple |
|---------|---------|----------|
| Table principale | `snake_case` | `knowledge_domain` |
| Table relationnelle | `snake_case` + `_keyword` | `knowledge_topic_keyword` |

### Fields

| Type | Format | Exemple |
|--------|---------|----------|
| Bloc | `lowercase` | `identity`, `metadata`, `ai` |
| Champs internes | `lowercase` ou `snake_case` | `display_order`, `is_active` |
| Enum code | `UPPER_SNAKE_CASE` | `EXAMPLE_CORRECT` |

### Identifiants (id)

- Toujours en **lowercase** sauf décision explicite contraire  
- Recommandation Lyxal : lowercase  
- Exemple : `knowledge_content_type:example_correct`

---

## 🌍 3. Internationalisation (i18n)

| Élément | Règle |
|--------|--------|
| Tout texte affichable doit pointer vers un `i18n_key` |
| Aucun texte figé ne doit rester dans les records |
| 1 label court + 1 description longue minimum |
| Optionnel : `ai_context_key` pour guider les LLM |

🔧 **Structure standard :**

```text
identity.label_key → pour UI & listes
identity.description_key → pour hovering, détails
identity.ai_context_key → pour optimiser l’usage IA

🧠 4. Structuration de la Connaissance
Niveau	Élément	Rôle
1	Domaine	Grande catégorie (ex : SurrealDB, IA, Business)
2	Topic	Sujet précis (ex : DEFINE FIELD)
3	Content Type	Format du contenu (ex : SYNTAX, EXAMPLE_CORRECT)
4	Content	La connaissance elle-même
Règle d’or

Un Content = 1 idée claire, utilisable immédiatement, avec exemple si possible

🏷️ 5. Tags & Keywords
Tags

Rattachés aux Domaines & Topics

Doivent provenir de la table tag (référentiel)

Objectif : organisation & filtres UI

Keywords (libres)

Utilisés pour recherche, IA & SEO interne

Stockés via tables relationnelles :

knowledge_domain_keyword

knowledge_topic_keyword

Normalisés en lowercase

🤖 6. Règles Spéciales IA
Règle	Description
Ne jamais mélanger plusieurs contenus dans un même record	
Chaque content doit être exploitable indépendamment	
Ajouter ai_context_key quand la compréhension peut varier	
Utiliser le metadata.ai pour guider la génération automatique	
🧪 7. Qualité & Validation
Checklist de validation pour chaque nouveau contenu
✅ Critère
Correct techniquement
Compréhensible par un débutant
Vérifié par un humain
Compatible IA (structure claire)
A un exemple si applicable
Ne duplique pas un contenu existant
⚠️ 8. Ce Qui Est Interdit
❌ Interdit
Mettre plusieurs idées dans un contenu
Texte direct non i18n
Références à un utilisateur ou client
Mentions de versions de code hors metadata
Lier un contenu à un cas d’usage trop spécifique
🔄 9. Versioning Interne

metadata.version_label = version fonctionnelle

Version natif SurrealDB (VERSION clause) peut être utilisée plus tard pour rollback/undo

🎯 Objectif final

Ces conventions garantissent :

Cohérence du système de connaissance

Exploitation optimale par humains & IA

Base solide pour futur Auto-Learning & IA Knowledge Graph

Une violation des règles doit être corrigée avant merge.
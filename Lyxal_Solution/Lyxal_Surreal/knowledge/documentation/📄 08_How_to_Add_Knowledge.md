# 🧩 Comment Ajouter une Nouvelle Connaissance – Guide Pratique

Ce guide explique étape par étape comment ajouter un nouvel élément dans le **Knowledge System Lyxal**.  
Il s’adresse aussi bien aux humains qu’aux IA contribuant au système.

---

## ✅ 1. Ajouter un Domaine (si nécessaire)

Un domaine représente un grand pilier de connaissance (ex : SurrealDB, Business, IA).

À faire uniquement si le sujet n’existe pas.

1. Créer un `knowledge_domain`
2. Ajouter les tags pertinents
3. Ajouter les mots-clés (via `knowledge_domain_keyword`)
4. Créer les clés i18n associées

---

## 🗂️ 2. Ajouter un Topic

Un topic est un **sujet précis** dans un domaine (ex : DEFINE FIELD, RELATE, Business Model Canvas).

Étapes :

1. Créer un record `knowledge_topic`
2. Le lier à un `knowledge_domain`
3. (Optionnel) Ajouter une catégorie et sous-catégorie
4. Ajouter les tags
5. Ajouter les mots-clés (via `knowledge_topic_keyword`)
6. Créer les i18n keys

> Un topic doit rester **concis et universel**.  
> Si trop large, le découper en plusieurs topics.

---

## 📘 3. Choisir le Type de Contenu

Chaque contenu doit utiliser un type issu de `knowledge_content_type`.

Exemples typiques :

| Type | Usage |
|-------|--------|
| SYNTAX_SURREAL | Montre la syntaxe correcte |
| EXAMPLE_CORRECT_SURREAL | Exemple valide |
| EXAMPLE_INCORRECT_SURREAL | Mauvais exemple + explication |
| RULE | Règle à suivre |
| TIP | Conseil rapide |
| PATTERN | Modèle réutilisable |

---

## ✍️ 4. Ajouter un Contenu

Un contenu est une **unité de connaissance** liée à un topic.

Étapes :

1. Créer un record `knowledge_content`
2. Spécifier :
   - Le topic
   - Le type de contenu
   - Le titre (facultatif)
   - Le contenu (code, explications, etc.)
3. Ajouter les i18n keys si nécessaire

> Un topic doit contenir **plusieurs contenus variés** pour être utile.

---

## 🏷️ 5. Ajouter des Tags

Les tags servent au classement avancé.

Règles :

- Toujours vérifier si un tag existe avant d’en créer un
- Utiliser le **référentiel tag global** (pas de duplication)
- Maximum recommandé : **5 tags par item**

---

## 🔍 6. Ajouter des Mots-Clés (Keywords)

Les mots-clés améliorent la recherche IA + Full-text.

Ils se créent via **RELATE** :

```sql
RELATE knowledge_topic:DEFINE_FIELD -> knowledge_topic_keyword -> "validation";

Recommandations :

3 à 8 mots-clés maximum

Toujours en lowercase

Simples et universels

🤖 7. Checklist de Qualité avant Validation
Critère	OK ?
Le domaine existe et est pertinent	☐
Le topic est clair et unique	☐
Le type de contenu est adapté	☐
Le contenu est utile pour humain & IA	☐
Tags pertinents ajoutés	☐
3+ mots-clés ajoutés	☐
I18n keys créées	☐
Pas de redondance avec un contenu existant	☐
🧠 Principe Fondamental Lyxal

Chaque ajout doit augmenter la valeur collective de la connaissance, et être exploitable par les IA Lyxal pour générer, enseigner, corriger et améliorer.

🚀 Exemple Minimal d’Ajout

Créer un topic : DEFINE FIELD

Ajouter 1 syntaxe, 1 bon exemple, 1 mauvais, 1 règle, 1 tip

Ajouter keywords : "field", "define", "surreal", "schema", "assert"

Ajouter tags : ["surreal", "schema"]

Ce fichier garantit que toute nouvelle connaissance ajoutée suit un standard homogène, évolutif et exploitable par IA.
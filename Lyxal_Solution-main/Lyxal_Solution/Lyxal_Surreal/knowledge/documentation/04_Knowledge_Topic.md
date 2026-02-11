# 📘 Table : `knowledge_topic`

## 🎯 Objectif
La table `knowledge_topic` représente les **sujets de connaissance** liés à un domaine spécifique.  
Chaque topic regroupe un concept clé (ex : *DEFINE FIELD*, *PERMISSIONS*, *INDEX*) et sert de point d’entrée pour le contenu associé (exemples, règles, syntaxe, bonnes pratiques).

Elle est utilisée à la fois pour :
- Structurer la documentation humaine
- Guider l’IA afin de répondre avec précision et cohérence
- Catégoriser les connaissances pour navigation, formation et génération de code

---

## 🧱 Structure du Topic

| Bloc | Description |
|-------|----------------|
| `domain` | Domaine auquel le topic appartient (ex : SurrealDB, IA, Business) |
| `category` / `sub_category` | Organisation thématique des topics |
| `tags` | Tags structurés pour filtrage et navigation |
| `identity.*` | Code + libellés i18n (nom et description) |
| `metadata.*` | Données techniques et de gestion d’affichage |

---

### 📎 Champs principaux

#### 🔹 Domaine
- Un topic appartient **obligatoirement** à un domaine (`knowledge_domain`)
- Permet une séparation claire entre les connaissances SurrealDB, Business, IA, etc.

#### 🧩 Catégorisation
- `category` : catégorie principale (obligatoire)
- `sub_category` : sous-catégorie (optionnelle)
- `tags` : liste de tags liés à une table de tags externe

Cette structure permet :
- Une navigation hiérarchique claire
- Des filtres multi-dimensionnels pour UI et IA

#### 🆔 Identité
- `identity.code` : identifiant unique du topic (`UPPER_SNAKE_CASE`)
- `identity.label_key` : clé i18n du nom
- `identity.description_key` : clé i18n de description
- `identity.ai_context_key` : clé i18n destinée à l'IA pour améliorer la compréhension du sujet

#### ⚙️ Métadonnées
| Champ | Rôle |
|--------|--------|
| `version_label` | Version fonctionnelle du topic |
| `display_order` | Permet de classer l’affichage |
| `is_active` | Activation/désactivation du topic |

---

## 🧠 Impact IA

Un `knowledge_topic` est un **pivot** pour l’IA, car il définit le cadre conceptuel d’un sujet.  
Il permet :

✅ Compréhension claire d’un concept avant d’utiliser le contenu associé  
✅ Contextualisation des réponses  
✅ Réutilisation dans des agents IA, assistants de formation, ou génération automatisée de code  

Seule la liste de contenus (`knowledge_content`) doit évoluer, non les topics.  
Le topic est donc **stable**, servant d’ancrage conceptuel.

---

## 🔗 Relations clés

| Table liée | Type de relation | Description |
|-------------|--------------------|----------------|
| `knowledge_domain` | 1 → N | Un domaine peut contenir plusieurs topics |
| `knowledge_category` | 1 → N | Catégorie principale du topic |
| `knowledge_sub_category` | 1 → N (optionnel) | Sous-catégorie |
| `knowledge_topic_keyword` | N ↔ N | Mots-clés libres pour recherche avancée |
| `knowledge_content` | 1 → N | Contenus de connaissance associés au topic |

---

## 📂 Exemple d’usage

**Créer un Topic “DEFINE FIELD”**

```sql
CREATE knowledge_topic SET
    domain = knowledge_domain:SURREAL_DB,
    category = knowledge_category:DATA_DEFINITION,
    identity.code = "DEFINE_FIELD",
    identity.label_key = i18n_key:kt_define_field_label,
    identity.description_key = i18n_key:kt_define_field_description,
    metadata.display_order = 1;

✅ Résumé

La table knowledge_topic sert à :

Définir un concept de connaissance structuré

Classer l'information par domaine, catégorie, tags et mots-clés

Être la source d’ancrage pour la documentation UI et IA

Éviter la duplication d’informations entre contenu, règles, exemples, etc.

Elle constitue l’ossature centrale de la base de connaissance universelle
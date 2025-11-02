# 📚 knowledge_domain – Documentation

La table `knowledge_domain` représente le **niveau le plus haut de la connaissance**.  
Chaque domaine couvre un univers conceptuel (ex: SurrealDB, IA, Business, Lyxal_Solution…).

---

## 🎯 Rôle de la table

| Objectif | Description |
|------------|-----------------------|
| Structurer la connaissance | Classe les topics par grands domaines |
| Clarté pour humains & IA | Permet un contexte d’apprentissage et de génération |
| Multi-lingue | Utilise des clés i18n pour UI + IA |
| Extensible | Ajout de domaines sans modification du code |

Exemples de domaines :

- `SURREAL_DB`
- `LYXAL_SOLUTION`
- `AI_ML`
- `BUSINESS`

---

## 🧱 Structure de la table

| Bloc | Description |
|--------|----------------------------|
| identity | Code + i18n (nom + description + contexte IA) |
| tags | Références vers table `tag` |
| keywords | Stockés dans la table relationnelle `knowledge_domain_keyword` |
| metadata | Statut, affichage, version |

---

## 🧠 Champs IA utiles

- `identity.ai_context_key` : Donne une **vision IA du domaine** (utilisé comme prompt-context)
- Mots-clés dans `knowledge_domain_keyword` améliorent la **pertinence IA** (recherche + ranking)

---

## 🔗 Table associée : knowledge_domain_keyword

Cette table RELATION permet :

| Fonction | Pourquoi |
|------------|-----------------------------|
| Full-text BM25 | Recherche IA performante |
| Mots-clés illimités | Pas de limite de taille ni de structure |
| Unicité | Empêche les doublons par domaine |

Pratique pour les requêtes :

```sql
SELECT ->knowledge_domain_keyword->out AS keywords
FROM knowledge_domain
WHERE id = knowledge_domain:SURREAL_DB;

✅ Ce que permet ce modèle
✔ Pour l’humain

Navigation claire (domaines → topics)

UI traduite

Organisation stable et lisible

🤖 Pour l’IA

Contextualiser ses réponses

Filtrer par domaine

Comprendre la sémantique du domaine

Améliorer la précision et cohérence

📌 Exemple d’usage

CREATE knowledge_domain:SURREAL_DB SET
    identity.code = "SURREAL_DB",
    identity.label_key = i18n_key:surreal_db_label,
    identity.description_key = i18n_key:surreal_db_description,
    metadata.display_order = 1;

Ajout d’un mot-clé :

RELATE knowledge_domain:SURREAL_DB -> knowledge_domain_keyword -> "database";

🔥 Importance stratégique
Raison	Impact Lyxal
Normalise la connaissance	Unifie l’écosystème
IA-Ready	Fondations du futur Lyxal Knowledge Graph
Multi-tenant compatible	Chaque instance peut avoir ses propres domaines

En résumé :
knowledge_domain définit de quoi on parle,
knowledge_topic définira ce que l’on doit savoir,
knowledge_content expliquera comment l’utiliser.


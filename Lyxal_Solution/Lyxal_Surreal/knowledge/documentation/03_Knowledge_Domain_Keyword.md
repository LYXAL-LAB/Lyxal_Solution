# 🔎 knowledge_domain_keyword – Documentation

`knowledge_domain_keyword` est une **table relationnelle** (TYPE RELATION) qui associe des **mots-clés libres** à un domaine (`knowledge_domain`).  
Elle est optimisée pour la **recherche full-text** (BM25 + highlights) et l’**exploitation par les IA**.

---

## 🎯 Rôle

- Enrichir un domaine avec des **termes libres** (synonymes, alias, abréviations, concepts).
- Permettre une **recherche sémantique** rapide (full-text indexé).
- Rester **légère** et extensible sans alourdir `knowledge_domain`.

---

## 🧱 Structure (rappel)

| Champ | Type | Description |
|---|---|---|
| `in` | `record<knowledge_domain>` | Domaine propriétaire du mot-clé. |
| `out` | `string` | Mot-clé (normalisé en lowercase côté usage). |
| **Indexes** |  | `FULLTEXT` sur `out`, index sur `in`, **UNIQUE** sur `(in, out)`. |

> Permissions : `SELECT FULL`, créations/updates via seeds/outillage (pas en écriture libre).

---

## ✅ Bonnes pratiques

- **Singulier / simple** : préférer `permissions` à `user permissions`.  
  Les expressions multi-mots restent possibles pour la recherche.
- **Lowercase côté data** (usage) pour homogénéité des tokens.
- **Éviter les doublons** : l’index `(in, out) UNIQUE` protège déjà.
- **Granularité** : mieux vaut 5 mots-clés ciblés que 30 vagues.

---

## ✍️ Exemples de seeds

```sql
-- Mots-clés pour le domaine SurrealDB
RELATE knowledge_domain:SURREAL_DB -> knowledge_domain_keyword -> "database";
RELATE knowledge_domain:SURREAL_DB -> knowledge_domain_keyword -> "surql";
RELATE knowledge_domain:SURREAL_DB -> knowledge_domain_keyword -> "index";
RELATE knowledge_domain:SURREAL_DB -> knowledge_domain_keyword -> "permissions";
RELATE knowledge_domain:SURREAL_DB -> knowledge_domain_keyword -> "schemafull";
RELATE knowledge_domain:SURREAL_DB -> knowledge_domain_keyword -> "schemaless";

-- Mots-clés pour le domaine Lyxal Solution
RELATE knowledge_domain:LYXAL_SOLUTION -> knowledge_domain_keyword -> "standards";
RELATE knowledge_domain:LYXAL_SOLUTION -> knowledge_domain_keyword -> "naming";
RELATE knowledge_domain:LYXAL_SOLUTION -> knowledge_domain_keyword -> "architecture";
RELATE knowledge_domain:LYXAL_SOLUTION -> knowledge_domain_keyword -> "surreal";
RELATE knowledge_domain:LYXAL_SOLUTION -> knowledge_domain_keyword -> "ui_rules";

🔍 Requêtes utiles
1) Récupérer tous les mots-clés d’un domaine
SELECT array::distinct(->knowledge_domain_keyword->out) AS keywords
FROM ONLY knowledge_domain:SURREAL_DB;

2) Rechercher les domaines par mot-clé (full-text)
SELECT d.*, search::score() AS score
FROM knowledge_domain_keyword
LET d = in
WHERE out @@ "permissions"
ORDER BY score DESC;

3) Recherche multi-termes + ranking
SELECT in AS domain, array::agg(out) AS matched, count() AS hits
FROM knowledge_domain_keyword
WHERE out @@ "schema index"
GROUP BY in
ORDER BY hits DESC;

🧠 Usage IA

Index sémantique de premier niveau : l’IA peut prioriser les domaines selon matching BM25 sur out.

Sert de filtre rapide avant d’aller chercher les topics et contents.

Couplé à des tags (knowledge_domain.tags) pour facettes UI + IA.

🧩 Intégration UI

Auto-suggestion de recherche : proposer les out les plus fréquents/matchés.

Afficher highlights (si exposés par la couche API) pour contextualiser le résultat.

Filtrer/ordonner les domaines par score lors d’une recherche texte.

🚧 Roadmap courte

(Optionnel) Poids par mot-clé (ex: weight: number) → affiner le ranking.

(Optionnel) Source (manual, import, auto) pour gouvernance.

(Optionnel) Audit (qui a ajouté quoi, quand) si édition ouverte un jour.

Résumé : knowledge_domain_keyword donne au domaine un vocabulaire vivant et recherchable — essentiel pour la découverte, la pertinence IA et la navigation.
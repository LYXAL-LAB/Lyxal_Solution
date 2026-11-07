# Feuille de route — `lyxal_core`

Évolutions prévues de la bibliothèque standard SurrealQL. L'état actuel (primitives
`validation`, `sanitize`, `security`, `utils`, moteur unique de pipelines et de schémas d'objet,
catalogues de règles, suite de tests) est décrit dans le [`Readme.md`](Readme.md). Toute
extension du Core suit `.agents/AGENTS.md` §5.7.7 : aucun équivalent existant, besoin
transversal, aucune logique métier, validation explicite du CTO. Aucune étape ne démarre sans
ordre du CTO et `implementation_plan.md` validé (`.agents/AGENTS.md` §3).

| Étape | Thème | Dépendances |
| :--- | :--- | :--- |
| 1 | Remplacement et suppression de caractères | — |

---

## 1. Remplacement et suppression de caractères

Aucune règle `sanitize` ne remplace ni ne supprime une liste de caractères donnée. Le pipeline
d'ingestion calcule la clé de ses unités (« m.l. » → « ML ») avec `string::replace` natif
(`crates/lyxal_pipeline_ingestion/functions/rule/ingestion_resolve_units.surql`), hors du moteur.

Critères d'acceptation :

- [ ] règle `sanitize` paramétrée (caractères à retirer, ou couples à remplacer), disponible au
      catalogue `fn::sanitize_step_catalog()` et donc dans les pipelines et schémas d'objet ;
- [ ] options contrôlées (`CORE_INVALID_ARGUMENT` pour une option mal formée) ;
- [ ] tests de la règle seule et dans un pipeline ;
- [ ] l'ingestion utilise la règle et ne contient plus d'appel `string::replace`.

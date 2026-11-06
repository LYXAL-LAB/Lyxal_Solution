# Feuille de route — `lyxal_base`

Évolutions prévues des référentiels de base. L'état actuel (types d'unités et unités, socle de
11 types et 30 unités, protection des unités utilisées, banc de tests) est décrit dans le
[`README.md`](README.md). Aucune étape ne démarre sans ordre du CTO et `implementation_plan.md`
validé (`.agents/AGENTS.md` §3).

| Étape | Thème | Dépendances |
| :--- | :--- | :--- |
| 1 | Codes d'échange normalisés des unités | étape 1 de la [feuille de route de l'ingestion](../lyxal_pipeline_ingestion/ROADMAP.md) |
| 2 | Conversions entre unités d'un même type | — |
| 3 | Libellés traduits | — |

---

## 1. Codes d'échange normalisés des unités

L'ingestion résout encore les unités fournisseurs par une table statique en Rust
(`normalization/units.rs`), qui contient notamment les codes UN/CEFACT (Rec. 20 : `MTK`, `KGM`,
`C62`…). Rattacher ces codes aux unités du référentiel permet de supprimer cette table (étape 1
de l'ingestion) et sert aux futurs connecteurs EDI.

Critères d'acceptation :

- [ ] code d'échange porté par l'unité (champ ou table de correspondance), unique par norme ;
- [ ] lecture par une fonction publique `fn::base_*`, utilisée par l'ingestion ;
- [ ] seeds complétés pour les 30 unités du socle.

## 2. Conversions entre unités d'un même type

Les métrés et les devis convertissent des quantités (`CM` → `M`, `KG` → `T`, `M3H` selon
l'unité de débit). Chaque type désigne une unité de base ; chaque unité porte son facteur vers
cette unité.

Critères d'acceptation :

- [ ] facteur de conversion décimal, positif, défini pour toute unité convertible ;
- [ ] fonction publique de conversion, refus entre deux types différents ;
- [ ] unités non convertibles (`FORFAIT`, `ENS`, conditionnements) déclarées comme telles.

## 3. Libellés traduits

Les libellés sont aujourd'hui en français. Les documents envoyés aux clients et la console
doivent pouvoir les afficher dans la langue de l'utilisateur, comme les messages d'erreur de
`lyxal_error`.

Critères d'acceptation :

- [ ] libellé par langue (au moins `fr`, `en`), le français restant la valeur par défaut ;
- [ ] `fn::base_unite_get` et `fn::base_unite_list` renvoient le libellé de la langue demandée.

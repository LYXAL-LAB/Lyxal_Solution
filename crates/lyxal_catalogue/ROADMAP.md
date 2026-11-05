# Feuille de route — `lyxal_catalogue`

Évolutions prévues du référentiel des articles. L'état actuel (13 tables, articles maîtres et
privés, catégories, attributs, variantes, compositions, relations, banc de tests) est décrit dans
le [`README.md`](README.md). Aucune étape ne démarre sans ordre du CTO et `implementation_plan.md`
validé (`.agents/AGENTS.md` §3). Ordre prévu : substitutions, recherche, historisation, catalogue
intelligent.

| Étape | Thème | Dépendances |
| :--- | :--- | :--- |
| 1 | Substitutions et équivalences contextualisées | regroupement technique de `lyxal_pipeline_ingestion` (étape 2 de sa [feuille de route](../lyxal_pipeline_ingestion/ROADMAP.md)) |
| 2 | Recherche avancée et qualité des références | étape 1 ; index composites et plein texte |
| 3 | Historisation et cycle de vie | étape 2 |
| 4 | Catalogue intelligent (agents IA) | étape 3 ; bus `lyxal_event` ; validation humaine obligatoire |

---

## 1. Substitutions et équivalences contextualisées

Objectifs :

1. Définir une substitution selon un contexte précis (système constructif, ex. DTU 25.41 ;
   exposition, ex. pièces humides H1 ; exigences acoustiques ; résistance au feu EI30 / EI60 ;
   pose intérieure ou extérieure), jamais de façon globale.
2. Distinguer quatre niveaux : similarité commerciale, équivalence fonctionnelle, compatibilité
   d'assemblage, substitution autorisée pour un ouvrage donné.
3. Interdire toute équivalence générique « marque A = marque B » hors d'un système qualifié.
4. Rendre les règles révocables et traçables (justification, date d'effet, auteur).
5. Réutiliser les règles `ingestion_substitution_rule` de `lyxal_pipeline_ingestion`, sans
   doublon avec `catalogue_relation` (accessoires et compléments).

Étude : table dédiée `catalogue_substitution` (contexte `system_scope`, `certification_ref`,
`valid_until`, révocation `is_revoked` / `revocation_reason`). Toute table `TYPE RELATION` est
soumise à validation du CTO (`docs/01-architecture/AUDIT_SURREALDB_RELATION_TABLES.md`).

Critères d'acceptation :

- [ ] contexte d'application dans le modèle (`contexte`, `domaine`, `contraintes`) ;
- [ ] `fn::catalogue_substitution_resolve($params: object)` : substituts valides pour un contexte ;
- [ ] substitutions non documentées ou révoquées refusées ;
- [ ] piste d'audit des approbations et révocations.

---

## 2. Recherche avancée et qualité des références

Objectifs :

1. Recherche combinée : fabricant, marque, gamme, famille technique, caractéristiques, unité,
   usages normatifs.
2. Navigation par facettes : valeurs d'attributs disponibles dans la sélection courante.
3. Détection des doublons et des références proches : GTIN, références fabricant normalisées,
   distance de Levenshtein ou trigrammes sur les libellés.
4. Rapprochement de références sans fusion destructive.
5. Contrats de recherche stables (`CatalogueSearchQuery`, `CatalogueSearchResult`) pour la
   console et les agents.

Critères d'acceptation :

- [ ] `fn::catalogue_item_search($params: object)` avec pagination par curseur ;
- [ ] index plein texte et composites sur les libellés et attributs clés ;
- [ ] `fn::catalogue_item_detect_duplicates($params: object)` ;
- [ ] réponse en moins de 50 ms sur plus de 100 000 articles (environnement de recette).

---

## 3. Historisation et cycle de vie

Objectifs :

1. Journal immuable des variations d'attributs, de conditionnements et de documents techniques.
2. Millésimes des catalogues fabricants, sans écraser les définitions utilisées par d'anciens
   chantiers.
3. Cycle de vie de référence avec transitions contrôlées, à construire à partir du
   `statut_commercial` actuel (`ACTIF`, `FIN_DE_SERIE`, `OBSOLETE`, `REMPLACE`) : lien vers le
   successeur, retrait du marché, conservation pour le SAV.
4. Aucune suppression d'un article référencé dans un devis, une facture ou une composition
   scellée.

Critères d'acceptation :

- [ ] table `catalogue_item_history` alimentée par les fonctions de mutation ou un `DEFINE EVENT` ;
- [ ] transitions de statut validées ;
- [ ] lecture d'une composition à une date passée (`as_of_date`).

---

## 4. Catalogue intelligent

Étude préalable, sous arbitrage du CTO : passage éventuel de `catalogue_relation` en
`TYPE RELATION`, avec comparaison des performances (traversée de graphe contre requêtes
indexées actuelles) et analyse des impacts sur les permissions et sur
`evt_catalogue_relation_guard`.

Objectifs :

1. Lecture et raisonnement sur le catalogue par les agents métier (devis BTP, chiffrage gros et
   second œuvre), dans le respect des permissions.
2. Questions en langage technique (ex. « quel doublage pour atteindre 45 dB avec une cloison de
   72 mm ? »).
3. Recommandations justifiées : norme DTU, avis technique, fiche FDES.
4. Raccordement à LYXAL HABITAT et LYXAL FORMATION.
5. Aucune modification du catalogue maître par un modèle sans validation humaine.

Critères d'acceptation :

- [ ] indexation sémantique découplée par `lyxal_event` ;
- [ ] recommandations sous la forme (produit, justification, norme) ;
- [ ] sas d'approbation dans la console pour tout enrichissement proposé par l'IA.

# Feuille de route — `lyxal_pipeline_ingestion`

Évolutions prévues du pipeline d'ingestion. L'état actuel (11 tables, 25 fonctions, worker par
blocs, quarantaine, manifestes scellés, publication réelle vers le catalogue sous
`catalogue_sync_agent`, banc de tests) est décrit dans le [`README.md`](README.md). Aucune étape
ne démarre sans ordre du CTO et `implementation_plan.md` validé (`.agents/AGENTS.md` §3). Les 11
tables restent en `TYPE NORMAL` ; toute table `TYPE RELATION` est soumise à validation du CTO
([`docs/01-architecture/AUDIT_SURREALDB_RELATION_TABLES.md`](../../docs/01-architecture/AUDIT_SURREALDB_RELATION_TABLES.md)).

| Étape | Thème | Dépendances |
| :--- | :--- | :--- |
| 1 | Normalisation sur les référentiels en base | codes d'échange des unités (étape 1 de la [feuille de route de `lyxal_base`](../lyxal_base/ROADMAP.md)) |
| 2 | Regroupement technique en SurrealQL | étape 1 |
| 3 | Connecteurs fabricants et preuves documentaires | services de fichiers et de secrets de Lyxal OS |
| 4 | Synchronisation incrémentale et retraits | étape 3 ; `lyxal_catalogue` |
| 5 | Résolution des conflits multisources | étape 4 |
| 6 | Ingestion assistée par agents IA | étape 5 ; bus `lyxal_event` ; validation humaine obligatoire |

---

## 1. Normalisation sur les référentiels en base

La normalisation Rust du worker résout encore unités et fabricants par des tables statiques
(`normalization/units.rs`, `normalization/manufacturer.rs`), alors que les référentiels
administrés par le Data Steward sont en base (`ingestion_unit_alias`,
`ingestion_manufacturer_alias`, unités de `lyxal_base` lues par `fn::base_unite_get`) avec
`fn::ingestion_resolve_unit` et `fn::ingestion_resolve_manufacturer`.

Critères d'acceptation :

- [ ] résolution par les fonctions SurrealQL (par bloc, sans aller-retour par ligne) ; tables
  statiques Rust supprimées ;
- [ ] unité inconnue : article `TO_CONFIRM` ou anomalie en quarantaine, selon la décision du CTO ;
- [ ] débit du banc Rust maintenu (seuil actuel : 50 articles/s).

## 2. Regroupement technique en SurrealQL

Rapprocher les articles du staging sur quatre niveaux (famille, spécification patronne,
équivalence fonctionnelle, substitution autorisée) à partir des référentiels en base
(`ingestion_family_rule`, `ingestion_specification`, `ingestion_substitution_rule`,
`fn::ingestion_rules_load`), raccordé à la qualification. Une équivalence technique ne confère
jamais à elle seule le statut `VERIFIED`.

Critères d'acceptation :

- [ ] fonctions `fn::ingestion_grouping_*($params: object)` ; décision et niveau atteint
  enregistrés sur l'article ;
- [ ] substitutions contextualisées (périmètre, certification, validité) et révocables ;
- [ ] réutilisables par l'étape « substitutions » de `lyxal_catalogue`
  ([`ROADMAP`](../lyxal_catalogue/ROADMAP.md)).

## 3. Connecteurs fabricants et preuves documentaires

1. Collecte automatisée (SFTP, API partenaires, EDI, stockage objet), sous worker supervisé.
2. Authentification des flux (OAuth2 M2M, mTLS, clés API) par le gestionnaire de secrets de
   Lyxal OS.
3. Archivage haché (BLAKE3) des pièces justificatives (fiches techniques, DoP, FDES, attestations
   CE / NF) et rattachement à la preuve commerciale de l'article.
4. Vérification positive de provenance (signature fournisseur ou tiers de confiance) en
   remplacement du refus des preuves pilotes ou synthétiques par motif de référence.

Critères d'acceptation :

- [ ] connecteurs asynchrones sans blocage des workers ;
- [ ] preuve rattachée à un document haché, consultable par le steward avant requalification
  (`fn::ingestion_staged_requalify`).

## 4. Synchronisation incrémentale et retraits

1. Comparaison avec la dernière version publiée : articles nouveaux, modifiés, retirés.
2. Pas de requalification d'un article dont l'empreinte canonique est inchangée
   (`publication_action = UNCHANGED`).
3. Retrait d'un produit par le fabricant : article maître jamais supprimé, statut commercial
   déprécié au catalogue (`publication_action = DEPRECATE`, aujourd'hui refusée par la
   publication).

Critères d'acceptation :

- [ ] suivi différentiel par lot ; reprise sans doublon ;
- [ ] calcul différentiel inférieur à 1 s pour 10 000 références ;
- [ ] aucune suppression dans `catalogue_item`.

## 5. Résolution des conflits multisources

1. Rapprochement d'un même article distribué par plusieurs sources.
2. Détection des divergences (libellés, conditionnements, cotes, unités) et indice de confiance
   par source.
3. Arbitrage par le steward en quarantaine, décision tracée ; pas de manifeste approuvé tant
   qu'un conflit structurant reste ouvert.

Critères d'acceptation :

- [ ] matrice de priorité des sources ;
- [ ] arbitrage enregistré par `fn::ingestion_quarantine_resolve`.

## 6. Ingestion assistée par agents IA

1. Découverte de nouveaux catalogues et tarifs.
2. Extraction de données techniques depuis des formats non structurés (PDF, pages web).
3. Détection d'anomalies sémantiques et propositions de rapprochement argumentées.
4. Aucune validation ni publication autonome : le steward contresigne chaque proposition.

Critères d'acceptation :

- [ ] propositions avec score de confiance, inspectables par le steward ;
- [ ] empreinte du modèle et paramètres d'inférence journalisés ;
- [ ] publication impossible sans session humaine.

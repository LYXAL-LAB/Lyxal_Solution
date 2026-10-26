# 🗺️ Feuille de Route Officielle — Module `lyxal_catalogue`

> **Référentiel universel des produits, services, ouvrages, ressources et ensembles de LYXAL OS.**  
> **Référence d'architecture :** [`.agents/AGENTS.md`](file:///c:/Users/HP/Desktop/Lyxal_OS/.agents/AGENTS.md) & [`LYXAL_ARCHITECTURE.md`](file:///c:/Users/HP/Desktop/Lyxal_OS/LYXAL_ARCHITECTURE.md).  
> **Gouvernance :** Toute évolution ultérieure requiert un plan d'implémentation préalable et une validation formelle du CTO.

---

## 📊 Matrice d'Avancement & Statuts des Versions

| Version | Thématique Principale | Statut Officiel | Condition / Dépendance |
| :---: | :--- | :---: | :--- |
| **V1.1** | **Master Catalogue Fondamental & BTP** | **`DONE` ✅** | **Fonctionnellement terminée et gelée** (SurrealDB 3.2.0, 12 tables, 22 fonctions, 64 articles BTP) |
| **V1.2** | **Substitutions & Équivalences Contextualisées** | **`PLANNED` 📋** | En attente d'ordre CTO de lancement — Dépend de `lyxal_pipeline_ingestion` |
| **V1.3** | **Recherche Avancée & Qualité des Références** | **`PLANNED` 📋** | En attente de V1.2 — Index composites et Full-Text SurrealDB |
| **V1.4** | **Historisation & Cycle de Vie du Catalogue** | **`PLANNED` 📋** | En attente de V1.3 — Modèle d'immuabilité temporelle |
| **V2.0** | **Catalogue Intelligent LYXAL OS (Agents IA)** | **`PLANNED` 📋** | En attente de V1.4 et bus `lyxal_event` — Validation humaine obligatoire |

---

## 🟢 V1.1 — Master Catalogue Fondamental & Référentiel BTP (`DONE` ✅)

**Statut :** **Fonctionnellement terminée, validée et gelée.**  
**Rôle :** Fondation universelle des données produits, articles marchands, prestations immatérielles et nomenclatures d'ouvrages BTP.  
**Directive d'Architecture SurrealDB :**  
- **Conserver les 13 tables existantes en `TYPE NORMAL`** (conforme aux conclusions de l'[`audit d'architecture`](file:///c:/Users/HP/Desktop/Lyxal_OS/docs/architecture/AUDIT_SURREALDB_RELATION_TABLES.md)).  
- **Aucune migration autorisée** sur le socle V1.1 scellé.

### Capacités Déjà Implémentées & Disponibles
- ✅ **13 Tables SCHEMAFULL Déclaratives** ([`schema/`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/schema/)) : `catalogue_session`, `catalogue_type`, `catalogue_item`, `catalogue_categorie`, `catalogue_item_categorie`, `catalogue_attribut`, `catalogue_attribut_valeur`, `catalogue_variante`, `catalogue_variante_attribut`, `catalogue_composition`, `catalogue_composition_ligne`, `catalogue_relation_type`, `catalogue_relation`.
- ✅ **22 Fonctions Métier SurrealQL** ([`functions/`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/functions/)) : Typage universel, gestion arborescente des catégories, gestion des attributs statiques et différentiateurs, variantes avec empreintes déterministes, gestion des nomenclatures et liaisons directes.
- ✅ **45 Codes d'Erreurs Master Data Canoniques** ([`error/`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/error/)) : Référentiel 100% `CREATE` préfixé `CATALOGUE_*`.
- ✅ **Verrous Moteur & Algorithmes d'Intégrité** :
  - Détection récursive des cycles de nomenclature (BFS jusqu'à 200 niveaux avec levée d'erreur stricte `CATALOGUE_COMPOSITION_CYCLE_DEPTH_EXCEEDED`).
  - Recalcul bi-directionnel transactionnel des empreintes SHA-256 de variantes (`evt_cva_recalc_fingerprint`).
  - Scellement immuable des nomenclatures publiées (`PUBLISHED`).
- ✅ **Référentiel Pilote BTP Réel (Lot 1 Cloisons / Second Œuvre)** : 64 articles vérifiés (Placo, Knauf, Siniat, Isover, Rockwool, Legrand, Schneider + 4 génériques normatifs DTU 25.41).

---

## 📋 V1.2 — Substitutions et Équivalences Contextualisées (`PLANNED` 📋)

> **Directive CTO :** Développement non autorisé sans ordre de démarrage spécifique.

### Objectifs Stratégiques
1. **Contextualisation Métier Stricte :** Définir les substitutions non plus de façon globale et statique, mais selon le contexte métier précis, le domaine d'utilisation et les contraintes techniques réelles (ex: système constructif DTU 25.41, exposition pièces humides H1, exigences acoustiques, résistance au feu EI30/EI60, pose intérieure vs extérieure).
2. **Étude d'une Table Dédiée en Graphe Natif (`catalogue_substitution`) :**
   - Étudier l'introduction d'une nouvelle arête native SurrealDB 3.2.0 :
     `DEFINE TABLE catalogue_substitution TYPE RELATION IN catalogue_item OUT catalogue_item SCHEMAFULL;`
   - Prévoir les règles de contexte d'application (`system_scope: string`), de certification officielle (`certification_ref: string`), de validité temporelle (`valid_until: datetime`) et de révocation traçable (`is_revoked: bool`, `revocation_reason: option<string>`).
   - Vérifier l'absence absolue de duplication fonctionnelle avec `catalogue_relation` (qui conserve les liaisons d'accessoires et de compléments) et avec `ingestion_substitution_rule` (qui gère les règles brutes d'ingestion au niveau fabricant).
   - **Gouvernance :** La création effective de cette table reste strictement soumise à la validation formelle préalable du CTO.
3. **Taxonomie Rigoureuse des 4 Niveaux Relationnels :**
   - *Similarité commerciale :* Produits de même famille ou gamme comparable.
   - *Équivalence fonctionnelle :* Produits respectant les mêmes spécifications techniques et tolérances normatives sans être de la même marque.
   - *Compatibilité physique / d'assemblage :* Composants conçus pour s'assembler sans altération technique.
   - *Substitution autorisée :* Remplacement validé pour un contexte d'ouvrage spécifique, sans rupture de conformité normative.
4. **Interdiction des Équivalences Globales Abusives :** Empêcher formellement toute affirmation générique du type « Marque A = Marque B » en dehors d'un système constructif qualifié.
5. **Révocabilité & Traçabilité :** Prise en charge des règles de substitution révocables et historisées avec justification technique et date d'effet.
6. **Synergie avec le Pipeline d'Ingestion :** Exploiter et réutiliser les règles contextualisées `ingestion_substitution_rule` issues de [`lyxal_pipeline_ingestion`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_pipeline_ingestion).

### Critères d'Acceptation
- [ ] Extension du modèle de relations pour intégrer le contexte d'application (`contexte: object`, `domaine: string`, `contraintes: array<string>`).
- [ ] Fonction SurrealQL dédiée `fn::catalogue_substitution_resolve($params: object)` retournant les substituts valides pour un contexte donné.
- [ ] Verrou interdisant les substitutions non documentées ou révoquées.
- [ ] Piste d'audit documentant qui a approuvé ou révoqué la règle de substitution.

---

## 📋 V1.3 — Recherche Avancée et Qualité des Références (`PLANNED` 📋)

> **Directive CTO :** Développement non autorisé sans ordre de démarrage spécifique.

### Objectifs Stratégiques
1. **Moteur de Recherche Multicritère :** Consultation fluide et combinée par fabricant, marque, gamme, famille technique, caractéristiques physiques, unité et usages normatifs.
2. **Filtres Dynamiques & Navigation Facettée :** Agrégation temps réel des valeurs d'attributs disponibles selon le sous-ensemble sélectionné, sans saturation mémoire de SurrealDB.
3. **Détection des Doublons & Références Proches :** Algorithmes de rapprochement automatique basés sur les clés GTIN-13, références d'usines normalisées et distances de Levenshtein/Trigrammes sur les désignations commerciales.
4. **Rapprochement Contrôlé :** Interface et fonctions permettant au gestionnaire de catalogue d'associer des références sans fusion destructive.
5. **Contrats de Recherche pour LYXAL SPACE & Agents IA :** Fourniture de contrats JSON normalisés stables (`CatalogueSearchQuery`, `CatalogueSearchResult`) exploitables par l'interface utilisateur et les automates.

### Critères d'Acceptation
- [ ] Fonction SurrealQL publique `fn::catalogue_item_search($params: object)` avec pagination déterministe par curseur.
- [ ] Indexation Full-Text et composites optimisés sur les libellés et attributs clés.
- [ ] Fonction d'analyse de doublons `fn::catalogue_item_detect_duplicates($params: object)`.
- [ ] Tps de réponse < 50ms sur un catalogue de plus de 100 000 articles en environnement Staging.

---

## 📋 V1.4 — Historisation et Cycle de Vie du Catalogue (`PLANNED` 📋)

> **Directive CTO :** Développement non autorisé sans ordre de démarrage spécifique.

### Objectifs Stratégiques
1. **Traçabilité Temporelle des Modifications :** Journalisation immuable des variations d'attributs, de tarifs de référence, de conditionnements et de documents techniques.
2. **Gestion des Millésimes Fabricants :** Capacité à conserver les versions annuelles ou semestrielles des catalogues fournisseurs sans écraser les définitions historiques nécessaires aux anciens chantiers.
3. **Machine à États de Cycle de Vie de Référence :**
   - `ACTIVE` : Référence commercialisée et tenue en stock ou commande.
   - `SUPERSEDED` : Référence remplacée par un nouveau modèle (avec lien vers le successeur).
   - `WITHDRAWN` : Référence retirée du marché par le fabricant.
   - `OBSOLETE` : Référence abandonnée (conservation pour mémoire et SAV).
4. **Non-Destruction des Liens Historiques :** Interdiction absolue de suppression en cascade des articles référencés dans des devis, factures ou nomenclatures scellées.

### Critères d'Acceptation
- [ ] Table d'historique `catalogue_item_history` alimentée par `DEFINE EVENT` ou fonction de mutation.
- [ ] Statut de cycle de vie contrôlé avec validation des transitions d'état.
- [ ] Requêtage temporel d'une nomenclature à date passée (`as_of_date`).

---

## 📋 V2.0 — Catalogue Intelligent LYXAL OS & Évolution Graphe (`PLANNED` 📋 / À ÉTUDIER)

> **Directive CTO :** Développement non autorisé sans ordre de démarrage spécifique.

### Étude d'Architecture Graphe SurrealDB (Sous réserve d'arbitrage CTO)
- **Évaluer une éventuelle migration de `catalogue_relation` vers `TYPE RELATION` :**
  - Exiger une étude comparative formelle des performances d'exécution (traversées natives de graphe vs requêtes `SELECT` indexées actuelles).
  - Analyser en profondeur les impacts sur les règles Row-Level Security (RLS) et les événements moteurs de validation ([`evt_catalogue_relation_guard`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/schema/12_catalogue_relation.surql#L99)).
  - Vérifier la compatibilité ascendante et le plan de dépréciation ordonné des fonctions existantes ([`fn::catalogue_relation_create`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/functions/relation/catalogue_relation_create.surql), [`fn::catalogue_relation_check_cycle`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/functions/relation/catalogue_relation_check_cycle.surql), etc.).
  - **Gouvernance :** Ne pas considérer cette migration comme automatiquement approuvée ; elle fera l'objet d'un arbitrage technique dédié et explicite du CTO.

### Objectifs Stratégiques IA
1. **Exploitation Native par les Agents IA :** Accès sécurisé au catalogue en lecture et en raisonnement pour les agents métier Lyxal OS (Assistant Devis BTP, Chiffreur Gros Œuvre / Second Œuvre).
2. **Recherche Sémantique & Inférence Constructive :** Capacité à interroger le catalogue en langage naturel technique (ex: *« Quel doublage acoustique pour atteindre 45 dB avec une cloison de 72 mm ? »*).
3. **Recommandations Contextualisées & Explicables :** Toute proposition d'accessoire, de substitut ou de dimensionnement doit fournir la justification technique complète (norme DTU associée, avis technique, fiche FDES).
4. **Intégration Transversale :** Raccordement avec LYXAL HABITAT (conception technique de chantiers) et LYXAL FORMATION (apprentissage des règles constructives).
5. **Gouvernance & Sécurité Inviolable :**
   - Aucune modification du Master Catalogue ne peut être opérée directement par un modèle IA sans validation humaine formelle.
   - Respect absolu des rôles et permissions RLS définis dans la plateforme.

### Critères d'Acceptation
- [ ] Pipeline de vectorisation ou d'indexation sémantique découplé via `lyxal_event`.
- [ ] Agent de recommandation fournissant systématiquement le triptyque `(produit, justification, norme)`.
- [ ] Sas d'approbation obligatoire dans LYXAL SPACE pour tout enrichissement suggéré par l'IA.

---

## 🔗 Liens & Documents Associés
- Audit architectural des tables relationnelles SurrealDB : [`docs/architecture/AUDIT_SURREALDB_RELATION_TABLES.md`](file:///c:/Users/HP/Desktop/Lyxal_OS/docs/architecture/AUDIT_SURREALDB_RELATION_TABLES.md)
- Documentation officielle du module : [`README.md`](file:///c:/Users/HP/Desktop/Lyxal_OS/crates/lyxal_catalogue/README.md)
- Charte d'architecture du workspace : [`.agents/AGENTS.md`](file:///c:/Users/HP/Desktop/Lyxal_OS/.agents/AGENTS.md)
- Roadmap transversale d'intégration : [`docs/14-roadmap/ROADMAP_LYXAL_SPACE.md`](file:///c:/Users/HP/Desktop/Lyxal_OS/docs/14-roadmap/ROADMAP_LYXAL_SPACE.md)

# `lyxal_base` — Référentiels de base

Référentiel transversal des unités de mesure, de leurs types (longueur, surface, conditionnement,
énergie…), de leurs codes d'échange normalisés et de leurs conversions, utilisé par les modules métiers. Module **SurrealQL seul** : tables, fonctions, erreurs
et seeds, sans crate Rust.

| | |
| :--- | :--- |
| Identifiant | `lyxal_base` (version `0.1.0`) |
| Dépendances (`manifest.toml`) | `lyxal_core`, `lyxal_error`, `lyxal_i18n` (libellés ; donc `lyxal_auth` et `lyxal_event`) |
| Hébergement | `apps/lyxal-server` (`ManifestModule`, installé depuis le manifeste) |
| Consommateurs | `lyxal_catalogue`, `lyxal_pipeline_ingestion` |
| Évolutions prévues | [`ROADMAP.md`](ROADMAP.md) |

---

## 1. Contrat public

* **Fonctions** `fn::base_*($params: object)` (§3), au contrat `fn::result_ok` /
  `fn::error_result`. Un module consommateur lit les unités **uniquement** par
  `fn::base_unite_get`, jamais par les tables (`.agents/AGENTS.md` §1).
* **Identifiants** : `base_unite:<CODE>` et `base_unite_type:<CODE>`, où `<CODE>` est le code
  alphanumérique en majuscules. Un module consommateur les stocke dans des champs
  `record<base_unite>` déclarés `REFERENCE ON DELETE REJECT` : une unité utilisée ne peut pas être
  supprimée.
* **Libellés** : le libellé d'une unité ou d'un type n'est pas un champ de sa table. C'est le
  texte d'une clé de `lyxal_i18n` (espace de noms `base`, texte source en français, syntaxe
  `plain`) : `base.unite_<code>` et `base.unite_type_<code>`, code en minuscules
  (`base.unite_m2`, `base.unite_type_longueur`). Les fonctions de lecture le rendent dans la
  langue demandée ; une traduction s'écrit par `lyxal_i18n` (`fn::i18n_translation_set`,
  import de fichier) et une organisation peut le surcharger. L'abréviation (`m`, `kg`) n'est
  pas traduite.
* **Unité utilisable** (`usable` dans `fn::base_unite_get`) : unité **et** type actifs. C'est la
  seule règle d'emploi d'une unité dans un nouveau document ; les consommateurs ne la recopient
  pas.
* **Conversions** : chaque type désigne son **unité de base** (`base_unit`, `M` pour les
  longueurs) ; chaque unité porte son **facteur** vers cette unité (`factor`, décimal strictement
  positif : `CM` vaut 0,01). Une unité sans facteur, ou d'un type sans unité de base, n'est
  **pas convertible** (`convertible: false` dans `fn::base_unite_get`). Un module convertit une
  quantité **uniquement** par `fn::base_unite_convert` ; il ne recopie ni les facteurs ni le
  calcul. Conversions par simple facteur seulement : aucune unité à décalage (°C / °F) n'est au
  référentiel.

---

## 2. Tables (`schema/`)

3 tables `TYPE NORMAL SCHEMAFULL`, lisibles par toute identité, écrites seulement par une session
d'administration (root ou système de l'hôte).

| Table | Champs | Contraintes |
| :--- | :--- | :--- |
| `base_unite_type` | `code`, `enabled`, `is_system`, `base_unit` (`option<record<base_unite>>`, `REFERENCE ON DELETE REJECT`), `created_at`, `updated_at` | `code` unique, alphanumérique en majuscules (1 à 32) ; `is_system` et `created_at` immuables ; l'unité de base d'un type ne se supprime pas |
| `base_unite` | `code`, `enabled`, `is_system`, `created_at`, `updated_at`, plus `abreviation` (1 à 10), `type` (`record<base_unite_type>`, `REFERENCE ON DELETE REJECT`) et `factor` (`option<decimal>`) | mêmes contraintes ; un type portant des unités ne se supprime pas ; `factor` strictement positif (`ASSERT`) |
| `base_unite_code` | `norme` (`UNECE_REC20` : unités de mesure ; `UNECE_REC21` : types d'emballage), `code`, `unite` (`record<base_unite>`, `REFERENCE ON DELETE REJECT`), `created_at` | identifiant `base_unite_code:[<NORME>, <CODE>]` ; (`norme`, `code`) unique ; plusieurs codes par unité |

Les abréviations sont conservées telles que saisies (« m² ») ; le nettoyage est fait par les
fonctions, le schéma vérifie le résultat (`ASSERT`).

---

## 3. Fonctions (`functions/`)

12 fonctions. Entrées validées puis nettoyées par le moteur de `lyxal_core`
(`fn::validation_object_execute`, `fn::sanitize_object_execute`, `unknown_keys: "reject"`) ;
donnée invalide : `BASE_INVALID_PARAMETERS` avec le détail par champ (`details.fields`).
Identifiants transmis en texte et contrôlés par table (règle `record`) : un identifiant d'une
autre table est refusé. Chaque écriture est vérifiée : `BASE_WRITE_FORBIDDEN` si les permissions
la filtrent. Paramètre commun : `language` (`fr` par défaut), langue des messages d'erreur.
Les lectures (`_get`, `_list`) acceptent `locale` (étiquette BCP 47, par défaut la valeur de
`language`) : le champ `libelle` du résultat est rendu dans cette langue, avec le repli de
`lyxal_i18n` (langue parente, langue par défaut de l'installation, texte source).

| Fonction | Paramètres | Règles |
| :--- | :--- | :--- |
| `fn::base_unite_type_create` | `code`, `libelle` | code unique (`BASE_UNITE_TYPE_ALREADY_EXISTS`) ; type créé actif, non système ; `libelle` (1 à 128) devient le texte source de sa clé ; si la clé ne peut pas être écrite, rien n'est créé (`BASE_LIBELLE_WRITE_FAILED`) |
| `fn::base_unite_type_get` | `id` ou `code`, `locale` | `BASE_UNITE_TYPE_NOT_FOUND` |
| `fn::base_unite_type_list` | `enabled`, `locale`, `limit` (1 à 200, défaut 50), `start` | tri par code |
| `fn::base_unite_type_update` | `id`, `libelle`, `enabled`, `base_unit`, `clear_base_unit` | au moins un champ (`BASE_NO_UPDATABLE_FIELDS_PROVIDED`) ; la désactivation ne modifie pas les unités rattachées ; `libelle` remplace le texte source (ses traductions deviennent obsolètes) ; `base_unit` : unité de ce type, de facteur 1 (`BASE_UNITE_BASE_INVALID`, détail `reason` : `not_found`, `other_type`, `factor_not_one`) ; `clear_base_unit: true` la retire (les unités du type ne sont plus convertibles) |
| `fn::base_unite_type_delete` | `id` | refus si système (`BASE_UNITE_TYPE_IS_SYSTEM`) ou référencé (`BASE_UNITE_TYPE_IN_USE`, nombre de références) ; la clé du libellé et ses traductions sont supprimées avec lui |
| `fn::base_unite_create` | `code`, `libelle`, `abreviation`, `type`, `factor` | type existant (`BASE_UNITE_TYPE_INVALID`) et actif (`BASE_UNITE_TYPE_DISABLED`) ; code unique (`BASE_UNITE_ALREADY_EXISTS`) ; libellé comme pour un type ; `factor` facultatif (nombre de 0,000001 à 1 000 000, enregistré en décimal) |
| `fn::base_unite_get` | `id` ou `code`, `fetch_type`, `locale` | renvoie l'unité (dont `factor` s'il est défini), `usable`, `convertible`, ses codes d'échange (`codes` : `[{ norme, code }]`) et, si `fetch_type`, le type (`type_detail`) ; `BASE_UNITE_NOT_FOUND` |
| `fn::base_unite_resolve` | `codes` (tableau de chaînes, 500 au plus) | résolution d'un bloc en une requête : code Lyxal, puis code d'échange (`UNECE_REC20` avant `UNECE_REC21`), recherche en majuscules ; renvoie `{ <brut sans espaces périphériques>: { code, usable } }`, sans entrée pour un code inconnu |
| `fn::base_unite_list` | `type`, `enabled`, `for_new_documents`, `locale`, `limit`, `start` | `for_new_documents` : unités utilisables seulement |
| `fn::base_unite_update` | `id`, `libelle`, `abreviation`, `type`, `factor`, `clear_factor`, `enabled` | jamais rattachée à un type inactif ni réactivée sur un type inactif (`BASE_UNITE_TYPE_DISABLED`) ; `libelle` comme pour un type ; `clear_factor: true` retire le facteur ; un changement de type retire le facteur s'il n'est pas fourni dans le même appel (il se rapportait à l'unité de base de l'ancien type) ; l'unité de base d'un type garde ce type et le facteur 1 (`BASE_UNITE_BASE_INVALID`, `reason` : `base_unit_type`, `base_unit_factor`) |
| `fn::base_unite_delete` | `id` | refus si système (`BASE_UNITE_IS_SYSTEM`) ou référencée par une autre table (`BASE_UNITE_IN_USE`), dont l'unité de base que son type désigne encore ; ses codes d'échange, la clé de son libellé et ses traductions sont supprimés avec elle |
| `fn::base_unite_convert` | `quantity` (nombre de 0 à 10^15), `from`, `to` (codes d'unité) | renvoie `{ quantity, from, to }` : quantité × facteur de `from` ÷ facteur de `to`, en `decimal` (pas d'erreur d'arrondi binaire), **sans arrondi** (l'appelant arrondit selon son usage) ; unité inconnue : `BASE_UNITE_NOT_FOUND` ; types différents : `BASE_UNITE_TYPE_MISMATCH` ; unité non convertible : `BASE_UNITE_NOT_CONVERTIBLE`, détail `reason` : `disabled` (unité ou type inactif), `no_base_unit` (type sans unité de base), `no_factor` ; lecture ouverte, comme le référentiel |

Fonctions internes (`functions/libelle/`) : `fn::base_libelle_name`, `_attach`, `_create`,
`_update`, `_delete` appellent les seules fonctions publiques de `lyxal_i18n`
(`fn::i18n_resolve_many`, `fn::i18n_key_create`, `fn::i18n_translation_set`,
`fn::i18n_key_delete`).

Les références entrantes sont comptées de façon générique (`SELECT VALUE <~? FROM ONLY $id`) :
`lyxal_base` ne connaît pas les tables qui le référencent. Seuls les champs de premier niveau
déclarés `REFERENCE` sont suivis par SurrealDB 3.3.4 ; un consommateur ne range donc pas une
unité dans un objet imbriqué.

---

## 4. Erreurs (`error/`)

18 définitions `BASE_*`, créées seulement si elles n'existent pas.

| Thème | Codes |
| :--- | :--- |
| `parametres` | `BASE_INVALID_PARAMETERS`, `BASE_NO_UPDATABLE_FIELDS_PROVIDED` |
| `permissions` | `BASE_WRITE_FORBIDDEN` |
| `unite_type` | `BASE_UNITE_TYPE_NOT_FOUND`, `BASE_UNITE_TYPE_ALREADY_EXISTS`, `BASE_UNITE_TYPE_IS_SYSTEM`, `BASE_UNITE_TYPE_IN_USE` |
| `unite` | `BASE_UNITE_NOT_FOUND`, `BASE_UNITE_ALREADY_EXISTS`, `BASE_UNITE_IS_SYSTEM`, `BASE_UNITE_IN_USE`, `BASE_UNITE_TYPE_INVALID`, `BASE_UNITE_TYPE_DISABLED`, `BASE_LIBELLE_WRITE_FAILED`, `BASE_LIBELLE_READ_FAILED` (détail `cause` : code `I18N_*` reçu), `BASE_UNITE_TYPE_MISMATCH`, `BASE_UNITE_NOT_CONVERTIBLE`, `BASE_UNITE_BASE_INVALID` |

---

## 5. Seeds (`seeds/`)

Socle système (`is_system: true`), rejouable (`IF !record::exists(...) THEN ( CREATE ... ) END`) :
11 types et 30 unités. Un élément système se désactive mais ne se supprime pas.
`libelle_initial.surql` crée l'espace de noms `base` et, pour chaque type et chaque unité, sa clé
avec le texte français (source) et la traduction anglaise ; un texte existant n'est pas modifié
au rejeu.

| Type | Unité de base | Unités (facteur vers l'unité de base ; « — » : non convertible) |
| :--- | :--- | :--- |
| `LONGUEUR` | `M` | `KM` (1000), `M` (1), `ML` (1), `CM` (0,01), `MM` (0,001) |
| `SURFACE` | `M2` | `HA` (10000), `M2` (1) |
| `VOLUME` | `M3` | `M3` (1), `LTR` (0,001) |
| `MASSE` | `KG` | `T` (1000), `KG` (1), `G` (0,001) |
| `DUREE` | `H` | `MOIS` (—), `SEM` (—), `J` (—), `H` (1) |
| `QUANTITE` | — | `U`, `PCE`, `ENS`, `PAIRE`, `FORFAIT` (—) |
| `CONDITIONNEMENT` | — | `ROUL`, `SAC`, `PAL`, `BTE`, `CART` (—) |
| `ENERGIE` | `KWH` | `KWH` (1) |
| `PUISSANCE` | `W` | `W` (1) |
| `PRESSION` | `BAR` | `BAR` (1) |
| `DEBIT` | `M3H` | `M3H` (1) |

17 unités convertibles, 13 non convertibles :

* le mètre linéaire (`ML`) est une longueur d'un mètre : il se convertit comme `M` ;
* le jour (`J`), la semaine (`SEM`) et le mois (`MOIS`) n'ont **pas de facteur** : sur un devis
  ou un planning ce sont des temps de travail, et une journée ou une semaine de chantier (7 h,
  8 h, 35 h…) dépend de l'entreprise ; la conversion appartient à l'application métier, réglée
  par organisation (une conversion calendaire, 24 h par jour, donnerait un résultat faux sans
  erreur visible) ;
* les quantités (`U`, `PCE`, `ENS`, `PAIRE`, `FORFAIT`) et les conditionnements n'ont ni facteur
  ni unité de base : le contenu d'un sac ou d'une palette dépend de l'article ;
* un type à une seule unité a cette unité pour base, pour qu'une unité ajoutée ensuite (`MWH`,
  `KW`…) s'y rapporte.

`unite_type_initial.surql` est installé avant `unite_initial.surql` (ordre du manifeste) et
désigne déjà l'unité de base de chaque type : SurrealDB accepte une référence vers un
enregistrement créé ensuite, et les deux seeds restent des `CREATE` protégés, sans mise à jour au
rejeu (une unité de base ou un facteur modifié après installation est conservé).

Les codes sont ceux que produit la normalisation de `lyxal_pipeline_ingestion`, sans alias : un
banc de l'ingestion vérifie que chacun de ses alias d'unités pointe vers une unité utilisable.

Codes d'échange (31) : Rec. 20 pour les grandeurs (`KMT`, `MTR`, `LM`, `CMT`, `MMT`, `HAR`, `MTK`,
`MTQ`, `LTR`, `TNE`, `KGM`, `GRM`, `MON`, `WEE`, `DAY`, `HUR`, `C62` → `U`, `H87` et `EA` → `PCE`,
`SET`, `PR`, `LS` → `FORFAIT`, `KWH`, `WTT`, `BAR`, `MQH`) ; Rec. 21 pour les conditionnements
(`RO` → `ROUL`, `BG` → `SAC`, `PX` → `PAL`, `BX` → `BTE`, `CT` → `CART`).

---

## 6. Vérification

* Banc SurrealQL (`scripts/ci/test_lyxal_modules.py`, module installé depuis son manifeste dans
  une base neuve, identités simulées) : `parametres`, `permissions`, `referentiel`, `integrite`,
  `types`, `unites`, `codes`, `libelles` (langue demandée, repli, création, modification,
  suppression, écriture refusée), `conversions` (facteurs du socle, conversions, refus, gardes de
  l'unité de base, écriture refusée) ; chaque fonction est appelée.
* `apps/lyxal-server` : installation et rejeu sans doublon (11 types).
* `scripts/ci/ci_local.sh` rejoue la CI complète.

# `lyxal_catalogue` — Référentiel universel des articles

Référentiel des produits, services, ouvrages, ressources et ensembles de Lyxal OS : articles
maîtres partagés et articles privés de chaque locataire, catégories, attributs typés, variantes,
compositions versionnées et relations entre articles.

Version `0.1.0` (régime pré-production, `.agents/AGENTS.md` §0). Module **SurrealQL seul**, sans
crate Rust, hébergé par `lyxal-server` (`ManifestModule`). Cible : SurrealDB 3.3.4. Dépend de
`lyxal_core` (validation et nettoyage des entrées, règle `gtin`), `lyxal_error` (contrat de
résultat, définitions d'erreurs) et `lyxal_base` (unités de mesure).

---

## 1. Tables (`schema/`)

Toutes en `TYPE NORMAL SCHEMAFULL`, avec permissions explicites.

| Table | Rôle | Lecture | Écriture |
| :--- | :--- | :--- | :--- |
| `catalogue_session` | Sessions des utilisateurs d'enregistrement (`role`, `tenant_id`, `scope`) | sa propre session | aucune (hôte) |
| `catalogue_type` | Types : `PRODUIT`, `SERVICE`, `OUVRAGE`, `RESSOURCE`, `ENSEMBLE` | tous | administration |
| `catalogue_item` | Articles maîtres (`is_custom = false`) et privés (`is_custom = true`, `tenant_id`) | voir §3 | voir §3 |
| `catalogue_categorie` | Catégories arborescentes | tous | administration |
| `catalogue_item_categorie` | Rattachement article ↔ catégorie | selon l'article | selon l'article |
| `catalogue_attribut` | Attributs typés (`STRING`, `NUMBER`, `BOOLEAN`, `DATE`, `COLOR`), pilotes de déclinaison ou non | tous | administration |
| `catalogue_attribut_valeur` | Valeurs autorisées d'un attribut | tous | administration |
| `catalogue_variante` | Variantes d'un article, empreinte de combinaison unique par article | selon l'article | selon l'article |
| `catalogue_variante_attribut` | Attributs statiques d'un article (`variante = NONE`) et combinaisons des variantes | selon l'article | selon l'article |
| `catalogue_composition` | Versions de nomenclature (`DRAFT`, `PUBLISHED`, `ARCHIVED`) | selon l'article parent | selon l'article parent |
| `catalogue_composition_ligne` | Composants, quantités, coefficient de perte | selon l'article parent | selon l'article parent |
| `catalogue_relation_type` | Types de relation (`ACCESSOIRE`, `SUBSTITUT`, `SIMILAIRE`, `COMPATIBLE`, `OBLIGATOIRE`, `COMMERCIAL_SPECIFICATION`, `REMPLACEMENT`) | tous | administration |
| `catalogue_relation` | Relations dirigées entre articles (réciproque créée pour les types bidirectionnels) | selon les deux articles | selon les deux articles |

« Administration » : session root ou système (hôte, installation). « Selon l'article » : mêmes
règles que l'article concerné (§3).

Gardes d'intégrité (`DEFINE EVENT`, `THROW "<CODE>: …"` qui annule l'écriture) :

* `evt_catalogue_item_guard` : règles de §3 appliquées aussi aux écritures directes ;
* `evt_cva_recalc_fingerprint` / `evt_variante_protect_fingerprint` : l'empreinte d'une variante
  est recalculée à chaque écriture de sa combinaison et ne se modifie jamais directement ;
* `evt_composition_protect`, `evt_composition_no_del`, `evt_comp_ligne_guard` : une composition
  publiée (scellée) et ses lignes sont immuables ; seul l'archivage est permis ;
* `evt_catalogue_relation_guard` : une relation ne touche que des articles accessibles à
  l'appelant ; un locataire ne relie pas deux articles maîtres, l'agent de synchronisation ne
  touche pas aux articles privés.

---

## 2. Fonctions (`functions/`)

Fonctions publiques : un objet unique `$params`, retour `{ ok, data, error }`
(`fn::result_ok` / `fn::error_result`). Les entrées sont validées par
`fn::validation_object_execute` puis nettoyées par `fn::sanitize_object_execute` de `lyxal_core`.
Les champs inconnus sont refusés. Une entrée invalide renvoie `CATALOGUE_INVALID_PARAMETERS`
avec le détail par champ dans `error.details.fields`. Le champ `language` (défaut `fr`) choisit
la langue du message.

Conventions d'entrée :

* identifiants en chaîne : `"table:id"` ou `"id"` (un Record ID natif est refusé) ;
* nombres en entier, flottant ou décimal (convertis en `decimal` quand le schéma l'exige) ;
* texte facultatif vide = absent ; codes mis en majuscules ;
* une écriture refusée par les permissions renvoie `CATALOGUE_WRITE_FORBIDDEN` (403) : rien
  n'est écrit.

| Domaine | Fonctions |
| :--- | :--- |
| Types | `fn::catalogue_type_list` (`enabled`) |
| Catégories | `fn::catalogue_categorie_create` (`code`, `libelle`, `parent`, `ordre`), `_tree` (`enabled`), `_update` (`id`, `libelle`, `parent` — `null` pour devenir racine —, `ordre`, `enabled`), `_delete` (`id` ; refus si enfants ou articles rattachés) |
| Articles | `fn::catalogue_item_create`, `_update`, `_get` (`id` ou `code`), `_list` (`type`, `categorie`, `enabled`, `search`, `limit` 1–200, `start`), `_delete` (`id` ; articles privés seulement, refus si composant d'une composition) |
| Attributs | `fn::catalogue_attribut_create` (`code`, `libelle`, `type_donnee`, `unite`, `is_variant_driver`), `fn::catalogue_attribut_valeur_create` (`attribut`, `code`, `valeur_texte` / `valeur_nombre` / `valeur_booleen` / `valeur_date` selon le type, `libelle_affichage`, `ordre`), `fn::catalogue_attribut_set_static` (`item_id`, `attribut_id`, `valeur_id`) |
| Variantes | `fn::catalogue_variante_create` (`item_id`, `code`, `libelle`, `reference_fabricant`, `code_barre`, `is_default`), `fn::catalogue_variante_set_attributs` (`variante_id`, `item_id`, `attributs: [{ attribut, valeur }]` ; attributs pilotes seulement ; combinaison unique par article) |
| Compositions | `fn::catalogue_composition_create` (`parent_item`, `libelle`), `_add_line` (`composition_id`, `composant_item`, `composant_variante` — obligatoire si le composant a des variantes —, `quantite` > 0, `unite`, `coefficient_perte` ≥ 1, `ordre`, `commentaire`), `_publish` (`composition_id` ; non vide ; archive la version publiée précédente), `_clone_version` (`source_composition_id` ; nouveau brouillon avec les lignes) |
| Relations | `fn::catalogue_relation_create` (`source`, `cible`, `relation_type`, `ordre`, `commentaire`), `_delete` (`id` ; supprime aussi la réciproque) |

Fonctions internes, appelées par le module avec des valeurs déjà validées :
`fn::catalogue_composition_check_cycle` et `fn::catalogue_relation_check_cycle` (gardes
anti-cycle récursives ; au-delà de 200 niveaux de nomenclature ou de 50 remplacements, erreur
explicite `CATALOGUE_*_CYCLE_DEPTH_EXCEEDED`, jamais un faux « sans cycle »), `fn::catalogue_variante_fingerprint` (seul
calcul de l'empreinte : SHA-256 des paires `attribut:valeur` triées).

### Contrat de `fn::catalogue_item_create`

Référence pour les appelants (dont la publication de `lyxal_pipeline_ingestion`).

| Champ | Type | Règle |
| :--- | :--- | :--- |
| `code` | texte ≤ 64 | **requis**, unique, mis en majuscules |
| `type` | `"catalogue_type:<CODE>"` | **requis**, type actif |
| `libelle` | texte ≤ 255 | **requis** |
| `unite_reference` | `"base_unite:<CODE>"` | **requis**, unité active de `lyxal_base` |
| `description` | texte ≤ 4000 | |
| `nature_reference` | `GENERIQUE` (défaut) ou `COMMERCIALE` | un générique n'a ni fabricant, ni marque, ni référence, ni code-barres ; un commercial a un fabricant ou une marque |
| `fabricant`, `marque` | texte ≤ 128 | mis en majuscules |
| `reference_fabricant` | texte ≤ 64 | couple (`fabricant`, `reference_fabricant`) unique |
| `code_barre` | GTIN-8/12/13/14 | règle `gtin` de `lyxal_core` (clé GS1), enregistré sous forme normalisée, unique |
| `statut_commercial` | `ACTIF` (défaut), `FIN_DE_SERIE`, `OBSOLETE`, `REMPLACE` | |
| `documents` | liste d'objets `{ type, titre, url, date, version }` | |
| `conditionnement` | objet `{ type_unite, quantite, poids_kg, volume_m3, dimensions }` | |
| `has_variants` | booléen (défaut `false`) | |
| `categories` | liste d'identifiants ou de `{ id, is_primary }` | erreurs signalées par position |
| `master_id` | texte ≤ 128 | article maître seulement, unique |
| `is_custom` | booléen | défaut : `false` si `master_id` est fourni, sinon `true` |
| `code_interne_client`, `libelle_personnalise` | texte | personnalisation locale |
| `tenant_id` | texte | facultatif ; s'il est fourni, il doit être celui du jeton |

`fn::catalogue_item_update` accepte les mêmes champs (sauf `categories`, `has_variants`) et `id` ;
`code`, `type`, `nature_reference`, `tenant_id`, `master_id` et le passage privé ↔ maître sont
immuables (erreur s'ils diffèrent de la valeur enregistrée).

---

## 3. Identités et articles

Les permissions et les fonctions lisent l'identité de la session : claims du jeton (`$token`) ou,
sans jeton, champs de la session d'enregistrement (`$auth`, table `catalogue_session`). Le module
ne définit pas l'accès (`DEFINE ACCESS`) : l'hôte (ou `lyxal_auth`) le configure et signe les
jetons.

| Claim | Valeur |
| :--- | :--- |
| `aud` | `lyxal-catalogue` (sinon aucun article n'est visible) |
| `iss` | `lyxal-os`, exigé pour l'agent de synchronisation (fonctions d'articles, gardes des articles et des relations) |
| `role` | `catalogue_sync_agent` ou `tenant_user` |
| `scope` | `["catalogue:sync:write"]` pour l'agent de synchronisation |
| `tenant_id` | locataire de l'utilisateur (`tenant_user`) |
| `id` | session d'enregistrement (`catalogue_session:<sujet>`) : les permissions de table s'appliquent |

| Identité | Articles maîtres | Articles privés |
| :--- | :--- | :--- |
| `catalogue_sync_agent` + `catalogue:sync:write` + `iss = lyxal-os` | crée, modifie les champs maîtres ; ne réactive pas un article désactivé localement, n'écrase pas une personnalisation locale | ne voit rien |
| `tenant_user` avec `tenant_id` | lit ; personnalise `libelle_personnalise`, `code_interne_client`, `enabled` ; ne modifie pas les champs maîtres | crée, lit, modifie, supprime les siens seulement |
| autre rôle, sans `tenant_id`, autre audience | lit au plus | rien |

Un article maître ne se supprime pas (désactivation par `enabled = false`).

---

## 4. Erreurs (`error/`) et seeds

65 définitions `CATALOGUE_*` (`error/<thème>/*.surql`), protégées par `record::exists` donc
rejouables : articles, catégories, attributs, variantes, compositions, relations, paramètres
(`CATALOGUE_INVALID_PARAMETERS`), permissions (`CATALOGUE_WRITE_FORBIDDEN`). Un test du serveur
vérifie que chaque code émis par une fonction est défini.

Seeds de référence, rejouables : `seeds/catalogue_type_initial.surql`,
`seeds/catalogue_relation_type_initial.surql`. `tests/fixtures/` contient deux jeux de
démonstration (`btp_lot1_commercial.surql`, `pilote_btp_habitat.surql`), jamais installés.

---

## 5. Vérification

```bash
python3 -I scripts/ci/test_lyxal_modules.py
```

Le banc installe le module et ses dépendances depuis leurs manifestes dans une base SurrealDB
3.3.4 neuve, puis exécute `tests/*.test.surql` sous des identités JWT simulées (format en tête
du script). Fichiers : `articles` (rôles, isolation entre locataires, champs maîtres),
`categories`, `attributs_variantes` (empreintes), `compositions` (versions, verrouillage, cycles
sur 8 niveaux), `relations`, `parametres`. Toute fonction publique doit être appelée par un
test. `scripts/ci/ci_local.sh` rejoue la CI complète, dont l'installation et le rejeu du module
par `lyxal-server`.

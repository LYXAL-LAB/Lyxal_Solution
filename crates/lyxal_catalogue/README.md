# `lyxal_catalogue` — Référentiel universel des articles

Référentiel des produits, services, ouvrages, ressources et ensembles de Lyxal OS : articles
maîtres partagés et articles privés de chaque locataire, catégories, attributs typés, variantes,
compositions versionnées et relations entre articles.

Version `0.1.0` (régime pré-production, `.agents/AGENTS.md` §0). Module **SurrealQL seul**, sans
crate Rust, hébergé par `lyxal-server` (`ManifestModule`). Cible : SurrealDB 3.3.4. Dépend de
`lyxal_core` (validation et nettoyage des entrées, règle `gtin`), `lyxal_error` (contrat de
résultat, définitions d'erreurs), `lyxal_base` (unités de mesure) et `lyxal_auth` (sessions,
organisations, permissions).

Évolutions prévues : [`ROADMAP.md`](ROADMAP.md).

---

## 1. Tables (`schema/`)

Toutes en `TYPE NORMAL SCHEMAFULL`, avec permissions explicites.

| Table | Rôle | Lecture | Écriture |
| :--- | :--- | :--- | :--- |
| `catalogue_type` | Types : `PRODUIT`, `SERVICE`, `OUVRAGE`, `RESSOURCE`, `ENSEMBLE` | tous | administration |
| `catalogue_item` | Articles maîtres (`is_custom = false`) et privés (`is_custom = true`, `tenant` : organisation `lyxal_auth`) | voir §3 | voir §3 |
| `catalogue_item_personnalisation` | Personnalisation d'un article maître par un locataire : `libelle_personnalise`, `code_interne_client`, `enabled` ; une ligne par couple (`item`, `tenant`) | son organisation (`catalogue.item.read`) | son organisation (`catalogue.item.manage`) |
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
* `evt_personnalisation_guard` : seul un article maître se personnalise ;
* `evt_cva_recalc_fingerprint` / `evt_variante_protect_fingerprint` : l'empreinte d'une variante
  est recalculée à chaque écriture de sa combinaison et ne se modifie jamais directement ;
* `evt_composition_protect`, `evt_composition_no_del`, `evt_comp_ligne_guard` : une composition
  publiée (scellée) et ses lignes sont immuables ; seul l'archivage est permis ;
* `evt_catalogue_relation_guard` : une relation ne touche que des articles accessibles à
  l'appelant ; un locataire ne relie pas deux articles maîtres, le compte de synchronisation
  ne touche pas aux articles privés.

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
| Articles | `fn::catalogue_item_create`, `_update`, `_get` (`id` ou `code`), `_list` (`type`, `categorie`, `enabled` — disponibilité pour le organisation active de la session —, `search`, `limit` 1–200, `start`), `_delete` (`id` ; articles privés seulement, refus si composant d'une composition). `_get` et chaque élément de `_list` portent `personnalisation` (celle du organisation active de la session, ou `NONE`) et `disponible` (article actif et non désactivé par cette organisation) |
| Personnalisations | `fn::catalogue_item_personnaliser` (`item_id` d'un article maître, puis `libelle_personnalise`, `code_interne_client`, `enabled`, au moins un ; crée ou met à jour la personnalisation du organisation active de la session), `fn::catalogue_item_personnalisation_supprimer` (`item_id` ; retour au référentiel) |
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
| `unite_reference` | `"base_unite:<CODE>"` | **requis**, unité utilisable selon `fn::base_unite_get` (unité et type actifs) |
| `description` | texte ≤ 4000 | |
| `nature_reference` | `GENERIQUE` (défaut) ou `COMMERCIALE` | un générique n'a ni fabricant, ni marque, ni référence, ni code-barres ; un commercial a un fabricant ou une marque |
| `fabricant`, `marque` | texte ≤ 128 | mis en majuscules |
| `reference_fabricant` | texte ≤ 64 | couple (`fabricant`, `reference_fabricant`) unique |
| `code_barre` | GTIN-8/12/13/14 | règle `gtin` de `lyxal_core` (clé GS1), enregistré sous forme normalisée, unique |
| `statut_commercial` | `ACTIF` (défaut), `FIN_DE_SERIE`, `OBSOLETE`, `REMPLACE` | |
| `documents` | liste d'objets `{ type, titre, url, date, version }` | |
| `conditionnement` | objet `{ quantite, poids_kg, volume_m3, dimensions }` | |
| `unite_conditionnement` | `"base_unite:<CODE>"` | unité utilisable selon `fn::base_unite_get` ; champ de premier niveau, car SurrealDB 3.3.4 ne suit pas `REFERENCE` sur un champ imbriqué |
| `has_variants` | booléen (défaut `false`) | |
| `categories` | liste d'identifiants ou de `{ id, is_primary }` | erreurs signalées par position |
| `master_id` | texte ≤ 128 | article maître seulement, unique |
| `is_custom` | booléen | défaut : `false` si `master_id` est fourni, sinon `true` |

Les quatre champs qui pointent vers `lyxal_base` (`catalogue_item.unite_reference`,
`catalogue_item.unite_conditionnement`, `catalogue_composition_ligne.unite`,
`catalogue_attribut.unite`) sont déclarés `REFERENCE ON DELETE REJECT` : une unité utilisée par
le catalogue ne peut pas être supprimée (`fn::base_unite_delete` renvoie `BASE_UNITE_IN_USE`, la
base refuse une suppression directe).

`fn::catalogue_item_update` accepte les mêmes champs (sauf `categories`, `has_variants`) et `id` ;
`code`, `type`, `nature_reference`, `master_id` et le passage privé ↔ maître sont immuables
(erreur s'ils diffèrent de la valeur enregistrée). L'organisation propriétaire d'un article privé
est l'organisation active de la session à la création ; elle n'est pas un paramètre et ne change
jamais (champ `READONLY`).

---

## 3. Sessions, permissions et articles

Les permissions de table, les gardes et les fonctions lisent la session `lyxal_auth` de
l'appelant par `fn::catalogue_caller` (`functions/access/`) : validité de la session
(`fn::auth_session_valid`), organisation active, et permissions détenues
(`fn::auth_has_permission`). `fn::catalogue_access({ is_custom, tenant, action })` en déduit le
droit de lire ou d'écrire un article ; les tables dépendantes (catégories d'article, variantes,
compositions, relations, personnalisations) l'appliquent à leur article. La session système
(root, hôte) passe tous les contrôles.

Permissions déclarées par `seeds/catalogue_auth.surql` :

| Permission | Portée | Droit | Rôles par défaut |
| :--- | :--- | :--- | :--- |
| `catalogue.item.read` | organisation | lire le catalogue partagé et les articles privés de son organisation | `organization_member`, `organization_admin` |
| `catalogue.item.manage` | organisation | créer, modifier, supprimer les articles privés de son organisation et ses personnalisations | `organization_admin` |
| `catalogue.master.write` | installation | lire et écrire les articles maîtres, sans organisation active ; aucun accès aux articles privés | `catalogue_sync` (rôle d'installation créé par ce seed) |

`catalogue.master.write` n'est accordée qu'au compte de synchronisation : elle exclut les
articles privés, et les articles maîtres ne viennent que de la publication du pipeline. Le rôle
`catalogue_sync` est porté par le compte de service de synchronisation
(`lyxal-catalogue-sync`, créé par `lyxal_pipeline_ingestion`), dont l'hôte ouvre les sessions.

| Session | Articles maîtres | Articles privés |
| :--- | :--- | :--- |
| `catalogue.master.write` | crée, modifie les champs maîtres, retire ou rétablit un article pour tous (`enabled`) ; n'accède à aucune personnalisation | ne voit rien |
| `catalogue.item.manage` dans l'organisation active | lit ; ne modifie aucun champ, disponibilité comprise ; personnalise et désactive pour son organisation (`fn::catalogue_item_personnaliser`) | crée, lit, modifie, supprime ceux de son organisation |
| `catalogue.item.read` dans l'organisation active | lit | lit ceux de son organisation |
| sans permission, sans organisation active, session révoquée ou expirée | rien | rien |

Un article maître ne se supprime pas : la synchronisation le retire pour tous (`enabled = false`).
La personnalisation d'un locataire ne touche jamais l'article maître partagé : un autre locataire
lit toujours le libellé et la disponibilité du référentiel.


Une organisation purgée par `lyxal_auth` (après sa durée de conservation) emporte ses articles
privés et ses personnalisations (`REFERENCE ON DELETE CASCADE` sur `tenant`) ; les catégories,
variantes, attributs, compositions (même scellées), lignes et relations d'un article supprimé
partent avec lui. Une composition scellée ne se supprime jamais à la main.

---

## 4. Erreurs (`error/`) et seeds

71 définitions `CATALOGUE_*` (`error/<thème>/*.surql`), protégées par `record::exists` donc
rejouables : articles, catégories, attributs, variantes, compositions, relations, paramètres
(`CATALOGUE_INVALID_PARAMETERS`), permissions (`CATALOGUE_WRITE_FORBIDDEN`). Un test du serveur
vérifie que chaque code émis par une fonction est défini.

Seeds rejouables : `seeds/catalogue_type_initial.surql`,
`seeds/catalogue_relation_type_initial.surql`, `seeds/catalogue_auth.surql` (permissions, rôle
`catalogue_sync`, attributions). `tests/fixtures/` contient deux jeux de
démonstration (`btp_lot1_commercial.surql`, `pilote_btp_habitat.surql`), jamais installés.

---

## 5. Vérification

```bash
python3 -I scripts/ci/test_lyxal_modules.py
```

Le banc installe le module et ses dépendances depuis leurs manifestes dans une base SurrealDB
3.3.4 neuve, puis exécute `tests/*.test.surql` sous des sessions `lyxal_auth` simulées (format en
tête du script). Fichiers : `articles` (permissions, isolation entre organisations, champs
maîtres),
`categories`, `attributs_variantes` (empreintes), `compositions` (versions, verrouillage, cycles
sur 8 niveaux), `relations`, `parametres`. Toute fonction publique doit être appelée par un
test. `scripts/ci/ci_local.sh` rejoue la CI complète, dont l'installation et le rejeu du module
par `lyxal-server`.

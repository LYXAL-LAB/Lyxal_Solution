# Plan d'implémentation — `lyxal_auth`, lot 5 (bascule du catalogue et de l'ingestion)

Plan détaillé du lot 5 du programme `lyxal_auth` V1 (`implementation_plan.md` à la racine, §6) :
`lyxal_catalogue` et `lyxal_pipeline_ingestion` abandonnent leurs sessions propres
(`catalogue_session`, `ingestion_session`, rôles portés par le jeton, accès JWT
`lyxal_catalogue_sync`) et passent sur les sessions, permissions et comptes de service de
`lyxal_auth`. **Rupture coordonnée** (`.agents/AGENTS.md` §0.3) : schémas, fonctions, tests,
publication et hôte mis à jour dans le même changement. Aucun code avant validation de ce plan
par le CTO (`.agents/AGENTS.md` §3).

Suite : lot 6 (clôture du module).

## 0. État actuel

| Module | Aujourd'hui |
| :--- | :--- |
| `lyxal_catalogue` | Table `catalogue_session` (`role`, `tenant_id`, `scope`). Les `PERMISSIONS` de 8 tables et les fonctions `catalogue_item_create` / `_update` / `_delete` / `_personnaliser` lisent `$token.role` (`tenant_user`, `catalogue_sync_agent`), `$token.aud = "lyxal-catalogue"`, `$token.scope` et `$token.tenant_id` (texte libre), ou leurs équivalents sur `$auth`. Les référentiels (types, catégories, attributs, types de relation) sont lisibles par tous et écrits par la seule session système |
| `lyxal_pipeline_ingestion` | Table `ingestion_session` (`role` ∈ `ingestion_agent`, `qualification_agent`, `steward_admin`, `catalogue_sync_agent` ; `scope`). Les `PERMISSIONS` de 10 tables lisent ces rôles et périmètres ; `fn::ingestion_session_identity` donne l'opérateur et son rôle, enregistrés dans les manifestes (`approved_by`, `approver_role`, `triggered_by`) |
| Publication | Le pipeline publie vers le catalogue avec un jeton `catalogue_sync_agent` signé par l'hôte (clé `catalogue_sync.signing_key`, accès JWT `lyxal_catalogue_sync`) |

## 1. Cible

* Une seule identité pour tout Lyxal : la session `lyxal_auth` (`$auth` = `auth_session`),
  contrôlée par `fn::auth_has_permission` (révocation, version des droits, niveau d'assurance,
  organisation active).
* Les modules **déclarent leurs permissions** et des **rôles par défaut** dans leurs seeds
  (`auth_permission`, `auth_role`, `auth_role_grants`) ; `lyxal_auth` n'en connaît pas le sens.
* Locataire : l'**organisation `lyxal_auth`** (Q1), au lieu d'un texte libre.
* Agent de synchronisation : **compte de service `lyxal_auth`** (application machine
  installée par l'hôte, rôle `catalogue_sync`) au lieu d'un jeton signé par une clé partagée (Q2).

## 2. Permissions et rôles déclarés (Q3)

| Permission | Portée | Effet | Rôles par défaut |
| :--- | :--- | :--- | :--- |
| `catalogue.item.read` | organisation | lire le catalogue partagé (articles maîtres et leurs variantes, compositions, relations, catégories d'article) et les articles privés de son organisation | `organization_member`, `organization_admin` |
| `catalogue.item.manage` | organisation | créer, modifier, supprimer les articles privés de son organisation et ses personnalisations des articles maîtres | `organization_admin` |
| `catalogue.master.write` | installation | lire et écrire les articles maîtres et leurs données dépendantes (publication : relecture avant mise à jour, reprise d'une insertion), sans organisation active ; aucun accès aux articles privés | `catalogue_sync` (nouveau rôle d'installation, compte de service) |
| `ingestion.read` | installation | consulter lots, éléments, quarantaine, manifestes, référentiels, tableau de bord | `ingestion_operator`, `ingestion_qualifier`, `ingestion_steward`, `catalogue_sync` |
| `ingestion.batch.write` | installation | créer et faire avancer les lots, enregistrer les éléments bruts | `ingestion_operator` |
| `ingestion.staged.qualify` | installation | qualifier, requalifier, mettre en quarantaine et résoudre | `ingestion_qualifier` |
| `ingestion.rule.manage` | installation | gérer les référentiels (familles, spécifications, alias, substitutions) | `ingestion_steward` |
| `ingestion.manifest.approve` | installation, **AAL2** (Q5) | préparer et approuver les manifestes de publication | `ingestion_steward` |
| `ingestion.manifest.execute` | installation | enregistrer l'exécution d'un manifeste (publication) | `catalogue_sync` |

`platform_admin` reçoit toutes les permissions d'installation ci-dessus. Les rôles par défaut
sont des rôles d'installation `system: true` de `lyxal_auth`, créés par les seeds des modules
(création seule, rejouable).

## 3. `lyxal_catalogue`

* Manifeste : dépendance `lyxal_auth` (`>=0.1.0`).
* Suppression : `schema/00_catalogue_session.surql`, toute lecture de `$token.role`,
  `$token.aud`, `$token.scope`, `$token.tenant_id`, `$auth.role`, `$auth.tenant_id`.
* `tenant_id: string` remplacé par `tenant: option<record<auth_organization>>` sur
  `catalogue_item` et `catalogue_item_personnalisation` (Q1) ; index et contrôles réécrits.
* `PERMISSIONS` des 8 tables, sur le modèle de `lyxal_auth` :
  * lecture d'un article maître : `catalogue.item.read` dans l'organisation active, **ou**
    `catalogue.master.write` (portée installation : le compte de service n'a pas
    d'organisation active et relit les articles qu'il publie) ;
  * lecture d'un article privé : `tenant` = organisation active et `catalogue.item.read` ;
  * écriture d'un article maître : `catalogue.master.write` ;
  * écriture d'un article privé ou d'une personnalisation :
    `catalogue.item.manage` avec `tenant` = organisation active ;
  * tables dépendantes (catégories d'article, variantes, attributs de variante, compositions,
    relations) : droits de l'article parent, comme aujourd'hui.
* Fonctions `catalogue_item_create` / `_update` / `_delete` / `_get` / `_list`,
  `catalogue_item_personnaliser` / `_personnalisation_supprimer` : le locataire vient de
  `fn::auth_context` (organisation active), jamais d'un paramètre ; contrôles par
  `fn::auth_has_permission`. Le paramètre `tenant_id` disparaît (un article privé appartient
  toujours à l'organisation active de l'appelant).
* Seeds : permissions `catalogue.*`, rôle `catalogue_sync`, attributions aux rôles par défaut.
* Erreurs : codes de droits réécrits (`CATALOGUE_PERMISSION_DENIED`, `CATALOGUE_TENANT_REQUIRED`) ;
  codes devenus sans objet supprimés.

## 4. `lyxal_pipeline_ingestion`

* Manifeste : dépendance `lyxal_auth`.
* Suppression : `schema/00_ingestion_session.surql`, `functions/session/ingestion_session_identity.surql`,
  toute lecture de `$token.role` / `$token.scope` / `$auth.role`.
* `PERMISSIONS` des 10 tables par `fn::auth_has_permission` (permissions `ingestion.*`, §2).
* Opérateur enregistré : identité **ou** application de la session (`fn::auth_context`), en
  texte `auth_identity:<clé>` / `auth_application:<clé>` ; `approver_role` disparaît
  (l'autorisation est vérifiée par la permission au moment de l'approbation ; le rôle n'a plus
  de sens stable) ; session système = `system`.
* Garde d'approbation (`DEFINE EVENT`) : `ingestion.manifest.approve` exigée et approbateur =
  opérateur de la session, au lieu des rôles `steward_admin` / `system`.
* Seeds : permissions `ingestion.*`, rôles `ingestion_operator`, `ingestion_qualifier`,
  `ingestion_steward`, attributions (`catalogue_sync` reçoit `ingestion.read` et
  `ingestion.manifest.execute`).

## 5. Publication et hôte

* `lyxal_auth` : `fn::auth_service_session_open` (session système seulement) ouvre une session
  de compte de service pour une application **sans secret** — l'hôte, déjà maître de la base,
  n'a pas à se présenter un secret à lui-même (Q2). `AccessService::internal_service_token(client_id)`
  émet le jeton d'accès correspondant (durée de la politique, aucun renouvellement).
* Hôte (`apps/lyxal-server/src/modules/ingestion.rs`) :
  * au démarrage, installe l'application machine `lyxal-catalogue-sync` (création seule) et
    lui attribue le rôle `catalogue_sync` ;
  * fournit au publieur un `CatalogueTokenIssuer` qui demande un jeton frais à `lyxal_auth`
    pour chaque publication ;
  * abonne la publication à `ingestion.manifest.approved` dès que le service de connexion est
    actif (clé applicative et `auth.public_url`), la suspend sinon.
* Supprimés : configuration `catalogue_sync.signing_key` (`LYXAL__CATALOGUE_SYNC__SIGNING_KEY`),
  accès JWT `lyxal_catalogue_sync`, `HmacCatalogueTokenIssuer`, `CatalogueSyncKey`, constantes
  de rôle et de périmètre du jeton.
* Le publieur se connecte avec le jeton du compte de service (accès `lyxal_auth_a|b`) : les
  `PERMISSIONS` du catalogue s'appliquent comme à tout appelant.

## 6. Contrats modifiés (rupture coordonnée)

| Contrat | Avant | Après |
| :--- | :--- | :--- |
| `catalogue_item.tenant_id`, `catalogue_item_personnalisation.tenant_id` | texte | `tenant: record<auth_organization>` |
| `fn::catalogue_item_create` (et fonctions d'articles privés) | paramètre `tenant_id` | locataire = organisation active |
| `ingestion_publication_manifest.approver_role` | rôle texte | supprimé |
| `approved_by`, `triggered_by` | sujet du jeton ou `auth.id` | identité ou application `lyxal_auth`, ou `system` |
| `fn::ingestion_session_identity` | interne | supprimée (remplacée par `fn::auth_context`) |
| Publication (Rust) | `HmacCatalogueTokenIssuer` | `CatalogueTokenIssuer` fourni par l'hôte, adossé à `lyxal_auth` |
| Configuration de l'hôte | `catalogue_sync.signing_key` | supprimée |

## 7. Fonctions Core réutilisées et besoins signalés

Inchangé : les entrées restent validées par `fn::validation_object_execute` et
`fn::sanitize_object_execute`. Le paramètre `tenant_id` disparaissant, aucune règle nouvelle.
Aucune fonction Core manquante. Aucune cryptographie nouvelle (la clé `catalogue_sync` et sa
signature HMAC disparaissent).

## 8. Tests

* **Bancs SurrealQL** des deux modules réécrits sur des sessions `lyxal_auth` (sessions et
  claims `permissions` simulés, comme les bancs de `lyxal_auth`) :
  * mêmes scénarios qu'aujourd'hui : cloisonnement entre organisations, article maître
    réservé au compte de service, personnalisations, rôles du pipeline, approbation et sa
    garde ;
  * cas nouveaux : session révoquée sans droit, organisation active différente, approbation
    refusée à une session AAL1, permission retirée d'un rôle → droits perdus après
    renouvellement.
* **Rust** : publication de bout en bout avec le compte de service `lyxal_auth` (jeton émis par
  l'hôte, accepté par la base) : insertion, **mise à jour** d'un article publié (relecture
  préalable) et **reprise** d'une insertion déjà faite ; aucun article privé visible du compte de
  service ; refus sans le rôle `catalogue_sync`.
* **Serveur** : démarrage installant l'application et son rôle ; publication par le moteur
  d'événements ; sans service de connexion, abonnement suspendu.
* **Serveur réel** (`scripts/ci/test_all.sh`) : les tests de recette du pipeline passent par
  `lyxal_auth`.
* `scripts/ci/ci_local.sh` complet.

## 9. Fichiers

* `crates/lyxal_catalogue/` : `schema/` (8 tables, session supprimée), `functions/item/`,
  `functions/personnalisation/`, `seeds/`, `error/`, `tests/`, `manifest.toml`, `README.md`,
  `ROADMAP.md`.
* `crates/lyxal_pipeline_ingestion/` : `schema/` (10 tables, session supprimée),
  `functions/` (manifestes, qualification, quarantaine ; `session/` supprimé), `events/`,
  `seeds/`, `src/publisher/` (`token.rs` réduit au trait), `tests/`, `manifest.toml`,
  `README.md`, `ROADMAP.md`.
* `crates/lyxal_auth/` : `fn::auth_service_session_open`, `AccessService::internal_service_token`,
  tests, `README.md`, `ROADMAP.md`.
* `apps/lyxal-server/` : `src/modules/ingestion.rs`, `src/config.rs`, tests, `README.md`.
* Racine : plan du programme (lot 5 réalisé), `.agents/AGENTS.md` si besoin. Ce plan est
  supprimé une fois exécuté.

## 10. Questions au CTO

| # | Question | Recommandation |
| :- | :--- | :--- |
| Q1 | Le locataire des articles privés et des personnalisations devient une **référence à l'organisation `lyxal_auth`** (`tenant: record<auth_organization>`) au lieu d'un texte libre | Oui : une seule notion d'organisation dans Lyxal, contrôlée par `fn::auth_has_permission` (organisation active) ; plus de texte libre à faire correspondre |
| Q2 | L'agent de synchronisation devient un **compte de service `lyxal_auth` installé par l'hôte**, dont les sessions sont ouvertes par la session système **sans secret** ; la clé `catalogue_sync.signing_key` disparaît | Oui : un secret de moins à configurer et à faire tourner ; les sessions de ce compte sont révocables et ses droits passent par un rôle, comme tout compte de service |
| Q3 | Permissions et rôles par défaut du §2 | Valider |
| Q4 | La lecture du catalogue partagé exige `catalogue.item.read` (accordée aux membres de toute organisation), au lieu de tout jeton de rôle `tenant_user` | Oui : même règle pour tous, retirable par organisation en modifiant ses rôles |
| Q5 | L'approbation d'un manifeste de publication exige une session **AAL2** (`min_aal: 2`) | Oui : publier dans le catalogue partagé par tous les clients est l'action la plus sensible du pipeline |

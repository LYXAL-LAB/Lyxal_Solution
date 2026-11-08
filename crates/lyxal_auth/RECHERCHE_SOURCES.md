# `lyxal_auth` — recherche de sources open source

Document de travail préalable au plan d'implémentation de `lyxal_auth` (crate du Noyau Technique,
rang 1 de [`docs/14-roadmap/ROADMAP_NOYAU.md`](../../docs/14-roadmap/ROADMAP_NOYAU.md)). Le crate
n'existe pas encore : ce dossier ne contient que ce document. Aucun code ne sera écrit avant un
`implementation_plan.md` validé par le CTO (`.agents/AGENTS.md` §3). Ce document est retiré, ou
réduit aux sources retenues, quand le crate est créé.

Recherche du 8 novembre 2026, objectif **version de production**. Les licences et versions citées
viennent en partie de sources secondaires (miroirs, comparatifs) quand c'est indiqué ; elles sont
revérifiées sur les dépôts officiels (fichier `LICENSE`) au moment du plan.

## 1. Besoin

Aujourd'hui, chaque module porte sa propre identité :

* `lyxal_catalogue` : table `catalogue_session`, rôles et `tenant_id` propres ;
* `lyxal_pipeline_ingestion` : table `ingestion_session`, rôles propres ;
* `lyxal-server` : accès JWT `lyxal_catalogue_sync` défini en dur dans
  `apps/lyxal-server/src/modules/ingestion.rs`.

Chaque nouveau module ajouterait une copie de plus (`.agents/AGENTS.md` §5.1). `lyxal_auth` doit
porter, une seule fois :

| Besoin | Détail |
| :--- | :--- |
| Identités | utilisateurs, comptes de service (workers, intégrations), cycle de vie (invitation, suspension, suppression) |
| Organisations et locataires | multi-entreprise : chaque donnée appartient à un locataire (`tenant_id`), un utilisateur peut appartenir à plusieurs organisations |
| Authentification | mot de passe (Argon2id par `lyxal_crypto`), clés d'accès sans mot de passe (passkeys / WebAuthn), double facteur, connexion par un fournisseur externe (OpenID Connect : Microsoft, Google, Keycloak d'un client…) |
| Sessions et jetons | jetons courts signés, renouvellement, révocation, comptes de service par jeton |
| Droits | rôles et permissions par organisation (RBAC), règles plus fines par objet si besoin |
| Application des droits | dans SurrealDB même : `DEFINE ACCESS` (jetons), `$auth` / `$token` dans les `PERMISSIONS` des tables de tous les modules |
| Traçabilité | journal des connexions et des changements de droits |
| Interface | écrans d'administration dans la console (`surrealist`, charte §15) |

## 2. Trois façons de faire

| Option | Principe | Avantages | Limites |
| :--- | :--- | :--- | :--- |
| **A. Produit complet externe** | Déployer Logto, Keycloak, Kanidm… à côté de Lyxal ; `lyxal_auth` se réduit à vérifier leurs jetons | Maturité, interface complète, fonctions avancées tout de suite | Un service de plus à opérer ; utilisateurs et rôles hors de SurrealDB (deux sources de vérité) ; les droits par ligne de SurrealDB dépendent d'un système extérieur |
| **B. Tout reconstruire** | Tout écrire en Rust et SurrealDB | Une seule source de vérité | Long ; code de sécurité critique entièrement à notre charge |
| **C. Cœur natif + briques éprouvées + fédération** | Identités, organisations, rôles et sessions dans SurrealDB (`lyxal_auth`) ; primitives de sécurité prises dans des bibliothèques Rust auditées ; modèle et écrans transcrits des produits mûrs ; connexion par un fournisseur externe possible (OpenID Connect) | Une seule source de vérité, droits appliqués nativement par SurrealDB, pas de cryptographie maison, un client peut garder son propre fournisseur d'identité | Plus de travail que A ; demande une revue de sécurité avant la production |

**Décision du CTO : option C, avec reprise du modèle des projets mûrs.** Les produits complets
ne sont pas déployés à côté de Lyxal : leur modèle de données et leurs fonctionnalités sont repris
et transcrits en SurrealDB et Rust. La correspondance table par table est dans
[`MODELE_SOURCES.md`](MODELE_SOURCES.md), les analyses détaillées dans [`sources/`](sources/).
Un client qui a déjà Keycloak ou Microsoft Entra peut s'y connecter par OpenID Connect
(fédération), sans que Lyxal en dépende.

## 3. Produits complets (modèles à étudier)

| Produit | Langage | Licence | Points forts | Usage proposé |
| :--- | :--- | :--- | :--- | :--- |
| [Logto](https://github.com/Celibioux/logto) | TypeScript | MPL-2.0 (miroirs ; à vérifier) | Organisations, RBAC par organisation, invitations, SSO, double facteur, journal d'audit, console très aboutie | **Modèle principal** : modèle de données (organisations, rôles, permissions, invitations) et écrans de la console. MPL-2.0 : copyleft par fichier, on s'inspire de la conception sans traduire le code ligne à ligne |
| [Keycloak](https://www.cncf.io/projects/keycloak) | Java | Apache-2.0 (à vérifier sur le dépôt) | Projet CNCF depuis 2023, quatre versions par an (26.7 en 2026), standard du marché | **Référence** des flux OpenID Connect et de l'administration ; **fournisseur externe** fédéré pour les clients qui l'utilisent |
| [Kanidm](https://git.ox.compsoc.net/CompSoc/kanidm) | **Rust** | MPL-2.0 (paquet AUR, mai 2026) | Passkeys, OIDC, réplication, intégration Unix ; version 1.10 | **Référence Rust** de la conception ; même règle MPL que Logto |
| [Rauthy](https://github.com/sebadob/rauthy) | **Rust** | **Apache-2.0** | Fournisseur OIDC et SSO, forte priorité aux passkeys (comptes sans mot de passe) | **Modèle Rust transcriptible** : licence permissive, code réutilisable avec mention |
| [Ory](https://github.com/ory) (Kratos, Hydra, Keto) | Go | Apache-2.0 | Kratos : parcours d'inscription et de connexion ; Hydra : OIDC certifié ; Keto : droits façon Zanzibar | **Modèle transcriptible** des parcours de connexion (Kratos) et des droits par relation (Keto) |
| [SuperTokens](https://github.com/supertokens/supertokens-core) | Java | Apache-2.0 hors dossier `ee/` | Sessions avec rotation des jetons de renouvellement | **Modèle** de la gestion des sessions |
| [authentik](https://github.com/goauthentik/authentik) | Python | MIT (cœur), licence propriétaire pour `enterprise/` | Parcours configurables, SAML, LDAP | Référence secondaire ; ne rien prendre dans `enterprise/` |
| [ZITADEL](https://zitadel.com/blog/apache-to-agpl) | Go | **AGPL-3.0** depuis la v3 (mars 2025) | Multi-locataire natif | **Écarté** comme source de code ; utilisable seulement comme service séparé non modifié |

## 4. Briques Rust (dépendances)

| Brique | Bibliothèque | Licence, état | Usage |
| :--- | :--- | :--- | :--- |
| Mots de passe | `lyxal_crypto::password` (Argon2id) | interne, API figée | **Obligatoire** (§11.3 des standards) : aucune autre bibliothèque de hachage |
| Signature des jetons, HMAC, aléa | `lyxal_crypto` (`hmac`, `OsRng`) | interne | **Obligatoire** ; tout besoin crypto non couvert (ex. signature asymétrique Ed25519 des jetons) est **soumis au CTO** (§11.3, hors périmètre actuel) |
| Passkeys / WebAuthn | [webauthn-rs](https://www.github.com/kanidm/webauthn-rs) | MPL-2.0 ; audité par SUSE ; utilisé en production par Kanidm | **Dépendance** (bibliothèque non modifiée : la licence MPL ne contamine pas notre code) |
| Connexion par fournisseur externe | [openidconnect](https://crates.io/api/v1/crates/openidconnect) (4.0.1) et [oauth2](https://crates.io/api/v1/crates/oauth2) (5.0.0) | MIT / Apache-2.0 ; activité à surveiller (dernières versions en 2025) | **Dépendance** côté client OIDC |
| Règles d'accès fines (plus tard) | [Cedar](https://github.com/cedar-policy/cedar) (`cedar-policy`) | Rust, Apache-2.0 ; moteur prouvé formellement par AWS | **Option** si les rôles ne suffisent plus (règles par attribut ou par objet) |
| Droits par relation, façon Zanzibar (plus tard) | [OpenFGA](https://www.infoq.com/news/2023/05/open-fine-grained-authorization/), [SpiceDB](https://startwithidentity.com/articles/top-7-open-source-authorization-tools/) | Go, Apache-2.0 | **Modèle** seulement : la même logique peut s'exprimer en relations SurrealDB |

## 5. Ce que SurrealDB fait déjà

SurrealDB sait vérifier un jeton et identifier l'appelant (`DEFINE ACCESS ... TYPE JWT` ou
`TYPE RECORD`), puis appliquer les droits table par table (`PERMISSIONS` avec `$auth`,
`$token`). Lyxal l'utilise déjà (accès `lyxal_catalogue_sync`, sessions des modules). `lyxal_auth`
ne réinvente donc pas l'application des droits : il **fournit** les identités, les rôles et les
jetons que SurrealDB vérifie, et un modèle unique que tous les modules utilisent dans leurs
`PERMISSIONS`.

## 6. Conséquences sur les modules existants

* `catalogue_session`, `ingestion_session` et l'accès `lyxal_catalogue_sync` sont remplacés par le
  modèle de `lyxal_auth` (régime zéro dette : rupture coordonnée, tous les appelants mis à jour).
* Les rôles des modules (`ingestion_agent`, `steward_admin`, `catalogue_sync_agent`…) deviennent
  des permissions déclarées par chaque module auprès de `lyxal_auth`.
* `lyxal_storage` (rang 3) s'appuie sur ces identités pour les droits sur les fichiers.

## 7. Questions pour le plan

1. **Approche** : option C (recommandée), A ou B.
2. **Méthodes de connexion de la première version** : mot de passe + double facteur + passkeys,
   ou passkeys et fournisseur externe seulement (sans mot de passe).
3. **Fédération OpenID Connect** dès la première version, ou plus tard.
4. **Format des jetons** : jetons signés HMAC par `lyxal_crypto` (vérifiés par SurrealDB, clé
   unique côté serveur) ou signature asymétrique (Ed25519), qui demande une extension de
   `lyxal_crypto` à valider par le CTO.
5. **Droits fins** : rôles par organisation seulement en première version (recommandé), Cedar ou
   relations façon Zanzibar ensuite.
6. **Écrans d'administration** : dans la première version, ou dans un lot console séparé.

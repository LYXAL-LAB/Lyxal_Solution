# `lyxal_auth` — sources retenues

Sources open source dont `lyxal_auth` reprend le modèle et les fonctionnalités (recherche du
8 novembre 2026, décision du CTO : cœur dans Lyxal, modèle repris des projets mûrs, aucun
produit déployé à côté). Correspondance table par table : [`MODELE_SOURCES.md`](MODELE_SOURCES.md) ;
analyses détaillées : [`sources/`](sources/). État du crate : [`README.md`](README.md).

Règle de licence : code transcrit seulement depuis Apache-2.0 / MIT (mention dans `NOTICE` si du
code est transcrit) ; MPL-2.0 : conception seulement ; AGPL : écarté.

## 1. Produits complets (modèles)

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

## 2. Briques Rust (dépendances)

| Brique | Bibliothèque | Licence, état | Usage |
| :--- | :--- | :--- | :--- |
| Mots de passe | `lyxal_crypto::password` (Argon2id) | interne, API figée | **Obligatoire** (§11.3 des standards) : aucune autre bibliothèque de hachage |
| Signature des jetons, HMAC, aléa | `lyxal_crypto` (`hmac`, `OsRng`) | interne | **Obligatoire** ; tout besoin crypto non couvert (ex. signature asymétrique Ed25519 des jetons) est **soumis au CTO** (§11.3, hors périmètre actuel) |
| Passkeys / WebAuthn | [webauthn-rs](https://www.github.com/kanidm/webauthn-rs) | MPL-2.0 ; audité par SUSE ; utilisé en production par Kanidm | **Dépendance** (bibliothèque non modifiée : la licence MPL ne contamine pas notre code) |
| Connexion par fournisseur externe | [openidconnect](https://crates.io/api/v1/crates/openidconnect) (4.0.1) et [oauth2](https://crates.io/api/v1/crates/oauth2) (5.0.0) | MIT / Apache-2.0 ; activité à surveiller (dernières versions en 2025) | **Dépendance** côté client OIDC |
| Règles d'accès fines (plus tard) | [Cedar](https://github.com/cedar-policy/cedar) (`cedar-policy`) | Rust, Apache-2.0 ; moteur prouvé formellement par AWS | **Option** si les rôles ne suffisent plus (règles par attribut ou par objet) |
| Droits par relation, façon Zanzibar (plus tard) | [OpenFGA](https://www.infoq.com/news/2023/05/open-fine-grained-authorization/), [SpiceDB](https://startwithidentity.com/articles/top-7-open-source-authorization-tools/) | Go, Apache-2.0 | **Modèle** seulement : la même logique peut s'exprimer en relations SurrealDB |

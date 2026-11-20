# Feuille de route — crates du noyau technique à créer

Ordre de création des crates du noyau technique inscrits « à créer » dans
`.agents/AGENTS.md` §6. Les crates du noyau déjà en place (`lyxal_error`, `lyxal_surreal`,
`lyxal_crypto`, `lyxal_parsing`, `lyxal_event`, `lyxal_runtime`, `lyxal_base`, `lyxal_auth`,
`lyxal_i18n`, `lyxal_storage`, `lyxal_secrets`, `lyxal_scheduler`, `lyxal_notification`) ont leur propre `ROADMAP.md`. `lyxal_i18n` est livré
(langues, traductions, rendu, échange par fichier ; `lyxal_base` et `lyxal_notification` en
dépendent pour leurs textes) ; ses évolutions sont dans `crates/lyxal_i18n/ROADMAP.md`. La V1 de `lyxal_auth` est livrée (lots 1 à 6 :
socle, connexion, double facteur, bascule du catalogue et de l'ingestion, clôture avec audit et
revue OWASP ASVS niveau 2) ; ses évolutions sont dans `crates/lyxal_auth/ROADMAP.md`.

La V1 de `lyxal_storage` (rang 3) est livrée (lots 1 à 8 : socle SurrealQL, octets écrits et lus
en flux sur disque ou sur un service S3, routes d'envoi et de téléchargement, contrôle du
contenu, envoi reprenable, fichiers sources de l'ingestion, clôture avec audit) ; ses évolutions
sont dans `crates/lyxal_storage/ROADMAP.md`.

La V1 de `lyxal_secrets` (rang 4) est livrée (lots 1 à 6 : socle SurrealQL, chiffrement par
organisation sous une clé maîtresse propre, cycle de vie et rotation, accès temporaires et
approbations, routes HTTP et partage à usage unique, clôture avec audit et procédures) ; ses
évolutions sont dans `crates/lyxal_secrets/ROADMAP.md`.

La V1 de `lyxal_scheduler` (rang 5) est livrée (lots 1 à 5 : socle SurrealQL, calcul des dates en
Rust, moteur avec planificateur élu et exécuteurs hébergés par l'hôte, routes HTTP, clôture avec
audit et exploitation) ; ses évolutions sont dans `crates/lyxal_scheduler/ROADMAP.md`.

La V1 de `lyxal_notification` est livrée (lots 1 à 7 : e-mail, parcours à étapes sur
`lyxal_scheduler`, intégrations et retours des fournisseurs avec identifiants dans
`lyxal_secrets`, SMS, messageries d'équipe et adresse web, fil dans l'application en temps réel,
notifications push, clôture avec audit et exploitation) ; tous ses canaux sont en place et ses
évolutions sont dans `crates/lyxal_notification/ROADMAP.md`.

Aucun crate ne démarre sans ordre du CTO et `implementation_plan.md` validé
(`.agents/AGENTS.md` §3). Les sources de chaque crate sont fixées par le CTO dans ce plan.
Un crate créé est retiré de ce document : son état est alors décrit par son `README.md`.

## Crates à créer : programme courrier, agendas et contacts

Cinq crates, inscrits dans `.agents/AGENTS.md` §6 après `lyxal_notification` ; l'hôte dédié
`apps/lyxal-groupware` est créé (lot 3, son état est décrit par son `README.md`). Le programme (architecture, sources, 23 lots, décisions F1 à F5 et P1 à
P15 du CTO) est décrit par `implementation_plan.md` à la racine du dépôt ; chaque lot a son
propre plan, validé avant tout code. L'ordre de création est celui des lots :

| Rang | Élément | Créé par le lot | Complété par les lots | Dossier |
| :-: | :--- | :--- | :--- | :--- |
| 2 | `lyxal_mail` (squelette créé au lot 3 : contrat réseau, limites, budget mémoire ; module au lot 4) | 3 et 4 — socle courrier | 5 à 13 (réception, envoi, IMAP, recherche, Sieve, anti-spam, JMAP, administration) | [`crates/lyxal_mail`](../../crates/lyxal_mail/README.md) |
| 3 | `lyxal_mail_proto` | 4 — socle courrier | 5, 7, 8, 9, 10, 12 (syntaxes portées) | [`crates/lyxal_mail_proto`](../../crates/lyxal_mail_proto/README.md) |
| 4 | `lyxal_dav` | 14 — formats agenda et contact | 15 (socle WebDAV) | [`crates/lyxal_dav`](../../crates/lyxal_dav/README.md) |
| 5 | `lyxal_calendar` | 16 — CalDAV | 17, 18, 20 (tâches, partage, planification, JMAP) | [`crates/lyxal_calendar`](../../crates/lyxal_calendar/README.md) |
| 6 | `lyxal_contacts` | 19 — CardDAV | 20 (JMAP) | [`crates/lyxal_contacts`](../../crates/lyxal_contacts/README.md) |

Avant eux : le lot 0 (cadre : sources figées, tri du code propriétaire de Stalwart, contrôle
des licences, mesures de SurrealDB, essai de deux hôtes sur une base) ; le lot 1 (mots de passe
d'application, dans `lyxal_auth`) ; le lot 2 (extensions de `lyxal_crypto`). Les lots 14 à 17 et
19 ne dépendent pas du courrier : le CTO peut les avancer après le lot 3 (décision P9). Les
lots 21 et 22 (durcissement, essais réels, clôture) portent sur les cinq crates.

Depuis le lot 0, chaque dossier contient ses documents (`README.md`, `SOURCES.md`,
`ROADMAP.md`, et `RECHERCHE_SOURCES.md` pour `lyxal_mail` et `lyxal_calendar`). `lyxal_mail` est
membre du workspace depuis le lot 3 (squelette Rust, licence `AGPL-3.0-only`) ; les quatre autres
crates n'ont encore ni `Cargo.toml` ni code.

Règles propres à ce programme (décisions F4, F5, P2, P3) :

- chaque crate déclare `license = "AGPL-3.0-only"` dans son `Cargo.toml` et tient un
  `SOURCES.md` (élément porté, projet, commit, licence, fichier d'origine) ;
- aucun fichier ni extrait de Stalwart sous `LicenseRef-SEL` n'est utilisé
  (`scripts/sources/strip_sel.py`) ;
- aucun crate existant ne reçoit de code porté d'une source AGPL ou GPL, et `lyxal-server` ne
  lie aucun de ces crates : ils sont hébergés par `apps/lyxal-groupware`.

---

## Critère « créé », commun à ces crates

- [ ] structure canonique (`.agents/AGENTS.md` §4) : `manifest.toml`, `README.md`, `ROADMAP.md` ;
- [ ] entrées traitées par `lyxal_core` (§5.7.8), erreurs `<MODULE>_*` en master data ;
- [ ] banc SurrealQL (`scripts/ci/test_lyxal_modules.py`) : cas nominaux, erreurs, identités et
      permissions ; chaque fonction publique appelée ;
- [ ] code Rust, s'il existe, sans avertissement `clippy -D warnings` ;
- [ ] hébergé par `lyxal-server` (`build.rs`, `src/modules/`), installation et rejeu vérifiés — pour les
      crates du programme courrier, agendas et contacts : hébergé par `apps/lyxal-groupware`, licence
      `AGPL-3.0-only` déclarée, `SOURCES.md` à jour, exception nommée dans `deny.toml` ;
- [ ] inscrit sans la mention « à créer » dans `.agents/AGENTS.md` §6 et retiré de ce document.

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

Aucun crate du noyau ne reste à créer.

---

## Critère « créé », commun à ces crates

- [ ] structure canonique (`.agents/AGENTS.md` §4) : `manifest.toml`, `README.md`, `ROADMAP.md` ;
- [ ] entrées traitées par `lyxal_core` (§5.7.8), erreurs `<MODULE>_*` en master data ;
- [ ] banc SurrealQL (`scripts/ci/test_lyxal_modules.py`) : cas nominaux, erreurs, identités et
      permissions ; chaque fonction publique appelée ;
- [ ] code Rust, s'il existe, sans avertissement `clippy -D warnings` ;
- [ ] hébergé par `lyxal-server` (`build.rs`, `src/modules/`), installation et rejeu vérifiés ;
- [ ] inscrit sans la mention « à créer » dans `.agents/AGENTS.md` §6 et retiré de ce document.

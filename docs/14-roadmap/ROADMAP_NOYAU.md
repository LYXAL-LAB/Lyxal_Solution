# Feuille de route — crates du noyau technique à créer

Ordre de création des crates du noyau technique inscrits « à créer » dans
`.agents/AGENTS.md` §6. Les crates du noyau déjà en place (`lyxal_error`, `lyxal_surreal`,
`lyxal_crypto`, `lyxal_parsing`, `lyxal_event`, `lyxal_runtime`, `lyxal_base`, `lyxal_auth`,
`lyxal_i18n`, `lyxal_storage`, `lyxal_notification`) ont leur propre `ROADMAP.md`. `lyxal_i18n` est livré
(langues, traductions, rendu, échange par fichier ; `lyxal_base` et `lyxal_notification` en
dépendent pour leurs textes) ; ses évolutions sont dans `crates/lyxal_i18n/ROADMAP.md`. La V1 de `lyxal_auth` est livrée (lots 1 à 6 :
socle, connexion, double facteur, bascule du catalogue et de l'ingestion, clôture avec audit et
revue OWASP ASVS niveau 2) ; ses évolutions sont dans `crates/lyxal_auth/ROADMAP.md`.

`lyxal_storage` (rang 3) est créé : son socle SurrealQL, son crate Rust (octets écrits et lus
en flux sur disque ou sur un service S3, nettoyage) et ses routes d'envoi et de téléchargement
et le contrôle du contenu sont en place ; son programme (lots 6 à 8) est dans
`implementation_plan.md` à la racine et sa `ROADMAP.md`.

`lyxal_notification` a été créé avant son rang (décision D8 du programme `lyxal_auth`) avec sa
partie e-mail et des solutions d'attente pour `lyxal_secrets` et
`lyxal_scheduler` ; ses lots suivants, qui dépendent de ces deux crates, sont dans
`crates/lyxal_notification/ROADMAP.md`.

Aucun crate ne démarre sans ordre du CTO et `implementation_plan.md` validé
(`.agents/AGENTS.md` §3). Les sources de chaque crate sont fixées par le CTO dans ce plan.
Un crate créé est retiré de ce document : son état est alors décrit par son `README.md`.

| Rang | Crate | Rôle | Dépend de (noyau) |
| :--- | :--- | :--- | :--- |
| 4 | `lyxal_secrets` | secrets applicatifs stockés chiffrés | `lyxal_crypto`, `lyxal_auth` |
| 5 | `lyxal_scheduler` | tâches planifiées | `lyxal_runtime`, `lyxal_event` |

Tous dépendent en outre de `lyxal_core` et `lyxal_error`.

---

## Raisons de l'ordre

4. **`lyxal_secrets`** : conserve les secrets applicatifs (clés de fournisseurs, identifiants de
   canaux) chiffrés par `lyxal_crypto` (`CryptoEngine::seal` / `open`, `SecretContext`), lisibles
   selon l'identité de `lyxal_auth`. Les canaux de `lyxal_notification` par locataire en dépendent
   (lot V1-e de sa feuille de route).
5. **`lyxal_scheduler`** : exécute des tâches planifiées par des workers supervisés
   (`LyxalWorker`) sous bail, et publie ses événements par `lyxal_event`. Les envois différés de
   `lyxal_notification` en dépendent (lot V1-c de sa feuille de route).

---

## Critère « créé », commun à ces crates

- [ ] structure canonique (`.agents/AGENTS.md` §4) : `manifest.toml`, `README.md`, `ROADMAP.md` ;
- [ ] entrées traitées par `lyxal_core` (§5.7.8), erreurs `<MODULE>_*` en master data ;
- [ ] banc SurrealQL (`scripts/ci/test_lyxal_modules.py`) : cas nominaux, erreurs, identités et
      permissions ; chaque fonction publique appelée ;
- [ ] code Rust, s'il existe, sans avertissement `clippy -D warnings` ;
- [ ] hébergé par `lyxal-server` (`build.rs`, `src/modules/`), installation et rejeu vérifiés ;
- [ ] inscrit sans la mention « à créer » dans `.agents/AGENTS.md` §6 et retiré de ce document.

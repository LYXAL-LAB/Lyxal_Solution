# Feuille de route — crates du noyau technique à créer

Ordre de création des crates du noyau technique inscrits « à créer » dans
`.agents/AGENTS.md` §6. Les crates du noyau déjà en place (`lyxal_error`, `lyxal_surreal`,
`lyxal_crypto`, `lyxal_parsing`, `lyxal_event`, `lyxal_runtime`, `lyxal_base`, `lyxal_auth`) ont
leur propre `ROADMAP.md` ; les lots restants de `lyxal_auth` (connexion, jetons, double facteur,
bascule des modules) sont dans `crates/lyxal_auth/ROADMAP.md`.

Exception d'ordre (décision D8 du programme `lyxal_auth`) : la **partie e-mail** de
`lyxal_notification` est réalisée tout de suite, avant le lot 3 de `lyxal_auth`, avec des
solutions d'attente pour `lyxal_i18n`, `lyxal_secrets` et `lyxal_scheduler`
(`crates/lyxal_notification/implementation_plan.md`) ; le reste du crate garde son rang.

Aucun crate ne démarre sans ordre du CTO et `implementation_plan.md` validé
(`.agents/AGENTS.md` §3). Les sources de chaque crate sont fixées par le CTO dans ce plan.
Un crate créé est retiré de ce document : son état est alors décrit par son `README.md`.

| Rang | Crate | Rôle | Dépend de (noyau) |
| :--- | :--- | :--- | :--- |
| 2 | `lyxal_i18n` | langues, traductions, formats régionaux | — |
| 3 | `lyxal_storage` | fichiers et documents stockés | `lyxal_auth` |
| 4 | `lyxal_secrets` | secrets applicatifs stockés chiffrés | `lyxal_crypto`, `lyxal_auth` |
| 5 | `lyxal_scheduler` | tâches planifiées | `lyxal_runtime`, `lyxal_event` |
| 6 | `lyxal_notification` | notifications sortantes | `lyxal_event`, `lyxal_i18n`, `lyxal_secrets`, `lyxal_scheduler` |

Tous dépendent en outre de `lyxal_core` et `lyxal_error`.

---

## Raisons de l'ordre

2. **`lyxal_i18n`** : sans dépendance dans le noyau, il fixe le référentiel des langues avant que
   d'autres crates traduisent leurs contenus (libellés traduits de `lyxal_base`, étape 2 de sa
   feuille de route ; modèles de `lyxal_notification`).
3. **`lyxal_storage`** : les modules métiers à venir (`lyxal_documents`, `lyxal_btp`) stockent des
   fichiers ; l'accès à un fichier suit l'identité de `lyxal_auth`. `lyxal_core` fournit déjà la
   validation des chemins (`fn::validation_lyxal_storage_path`).
4. **`lyxal_secrets`** : conserve les secrets applicatifs (clés de fournisseurs, identifiants de
   canaux) chiffrés par `lyxal_crypto` (`CryptoEngine::seal` / `open`, `SecretContext`), lisibles
   selon l'identité de `lyxal_auth`. Il précède `lyxal_notification`, qui en a besoin pour ses
   canaux d'envoi.
5. **`lyxal_scheduler`** : exécute des tâches planifiées par des workers supervisés
   (`LyxalWorker`) sous bail, et publie ses événements par `lyxal_event`. Il précède
   `lyxal_notification` pour les envois différés.
6. **`lyxal_notification`** : consomme les événements des autres modules (`lyxal_event`), rend ses
   messages dans la langue du destinataire (`lyxal_i18n`), lit les identifiants de ses canaux
   (`lyxal_secrets`) et planifie ses envois (`lyxal_scheduler`). Il vient donc en dernier.

---

## Critère « créé », commun à ces crates

- [ ] structure canonique (`.agents/AGENTS.md` §4) : `manifest.toml`, `README.md`, `ROADMAP.md` ;
- [ ] entrées traitées par `lyxal_core` (§5.7.8), erreurs `<MODULE>_*` en master data ;
- [ ] banc SurrealQL (`scripts/ci/test_lyxal_modules.py`) : cas nominaux, erreurs, identités et
      permissions ; chaque fonction publique appelée ;
- [ ] code Rust, s'il existe, sans avertissement `clippy -D warnings` ;
- [ ] hébergé par `lyxal-server` (`build.rs`, `src/modules/`), installation et rejeu vérifiés ;
- [ ] inscrit sans la mention « à créer » dans `.agents/AGENTS.md` §6 et retiré de ce document.
